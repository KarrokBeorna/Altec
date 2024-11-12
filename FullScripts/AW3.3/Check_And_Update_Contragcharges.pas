const
  SELECT_CONTRAGCHARGES = 'SELECT                                                                                            ' + #13#10 +
                          '  *                                                                                               ' + #13#10 +
                          '  FROM                                                                                            ' + #13#10 +
                          '    CONTRAGCHARGES CC                                                                             ' + #13#10 +
                          '      JOIN CONTRAGCHARGES_UF_VALUES CCUF ON CCUF.CONTRAGCHARGEID + 0 = CC.CONTRAGCHARGEID         ' + #13#10 +
                          '      JOIN USERFIELDS UF ON UF.USERFIELDID + 0 = CCUF.USERFIELDID                                 ' + #13#10 +
                          '  WHERE                                                                                           ' + #13#10 +
                          '    UF.FIELDNAME = ''StageBill''                                                                  ' + #13#10 +
                          '    AND CCUF.VAR_STR = ''Оплачен в 1С''';

  UPDATE_STATE_CONTRAGCHARGES = 'UPDATE                                    ' + #13#10 +
                                '  CONTRAGCHARGES_UF_VALUES CCUF           ' + #13#10 +
                                'SET                                       ' + #13#10 +
                                '  VAR_STR = ''Оплачен''                   ' + #13#10 +
                                'WHERE                                     ' + #13#10 +
                                '  CCUF.CONTRAGCHARGES_UF_VALUEID = :ID';

  GET_CONTRAGCHARGEID = 'SELECT GEN_ID(GEN_CONTRAGCHARGES, 1) FROM RDB$DATABASE';

  GET_PROTOCOL = 'SELECT FIRST 1                                                    ' + #13#10 +
                 '  CCUF.*                                                          ' + #13#10 +
                 'FROM                                                              ' + #13#10 +
                 '  CONTRAGCHARGES_UF_VALUES CCUF                                   ' + #13#10 +
                 '    JOIN USERFIELDS UF ON UF.USERFIELDID + 0 = CCUF.USERFIELDID   ' + #13#10 +
                 'WHERE                                                             ' + #13#10 +
                 '  CONTRAGCHARGEID = :CONTRAGCHARGEID                              ' + #13#10 +
                 '  AND UF.FIELDNAME = ''Protocol''';

  INSERT_CHARGE = 'INSERT INTO                                                                            ' + #13#10 +
                  '  CONTRAGCHARGES                                                                       ' + #13#10 +
                  '  (CONTRAGCHARGEID, TITLE, CONTRAGID, CHARGETYPE, ACCOUNTID, AMOUNT, GUID)             ' + #13#10 +
                  'VALUES                                                                                 ' + #13#10 +
                  '  (:CONTRAGCHARGEID, :TITLE, :CONTRAGID, :CHARGE_TYPE, :ACCOUNTID, :AMOUNT, :GUID)     ' + #13#10 +
                  'RETURNING CONTRAGCHARGEID';

  INSERT_CHARGE_UF_VALUE = 'UPDATE OR INSERT INTO                                                                                                 ' + #13#10 +
                           '  CONTRAGCHARGES_UF_VALUES                                                                                            ' + #13#10 +
                           '  (CONTRAGCHARGES_UF_VALUEID, CONTRAGCHARGEID, USERFIELDID, VAR_DATE, VAR_STR, VAR_GUID)                              ' + #13#10 +
                           'VALUES                                                                                                                ' + #13#10 +
                           '  (GEN_ID(GEN_CONTRAGCHARGES_UF_VALUES, 1), :CCID,                                                                    ' + #13#10 +
                           '  (SELECT FIRST 1 USERFIELDID FROM USERFIELDS WHERE FIELDNAME = :FIELDNAME AND DOCTYPE = ''IdocCounteragentCharge''), ' + #13#10 +
                           '  :VAR_DATE, :VAR_STR, :VAR_GUID)                                                                                     ' + #13#10 +
                           'MATCHING (CONTRAGCHARGEID, USERFIELDID)';


var
  LS: IpubLogService;
  CONTRAGCHARGES: IcmDictionaryList;
  num, contragChargeID: Integer;
  protocol: IcmDictionary;

begin
  LS := ServiceProvider.GetService(IpubLogService);

  S := CreateObjectSession;
  CONTRAGCHARGES := S.QueryRecordList(SELECT_CONTRAGCHARGES, empty);

  for i := 0 to CONTRAGCHARGES.count - 1 do begin
    contracharge := CONTRAGCHARGES.items[i];

    if contracharge.value['STATE'] = '' then begin
      num := PseudoSequenceQuery('ACT_INDEX');
      try
        S.ExecSQL(UPDATE_STATE_CONTRAGCHARGES, MakeDictionary(['ID', contracharge.Value['CONTRAGCHARGES_UF_VALUEID']]));

        contragChargeID := S.QueryValue(GET_CONTRAGCHARGEID, empty);

        S.ExecSQL(INSERT_CHARGE, MakeDictionary(['CONTRAGCHARGEID', contragChargeID,
                                                 'TITLE', '№' + varToStr(num) + ' от ',
                                                 'CONTRAGID', contracharge.Value['CONTRAGID'],
                                                 'CHARGE_TYPE', 1,
                                                 'ACCOUNTID', contracharge.Value['ACCOUNTID'],
                                                 'AMOUNT', contracharge.Value['AMOUNT'],
                                                 'GUID', GenerateGUID]));

        protocol := S.QueryRecord(GET_PROTOCOL, MakeDictionary(['CONTRAGCHARGEID', contracharge.value['CONTRAGCHARGEID']]));

        S.ExecSQL(INSERT_CHARGE_UF_VALUE, MakeDictionary(['CCID', contragChargeID,
                                                          'FIELDNAME', 'Number',
                                                          'VAR_DATE', NULL,
                                                          'VAR_STR', varToStr(num),
                                                          'VAR_GUID', NULL]));

        S.ExecSQL(INSERT_CHARGE_UF_VALUE, MakeDictionary(['CCID', contragChargeID,
                                                          'FIELDNAME', 'StageAct',
                                                          'VAR_DATE', NULL,
                                                          'VAR_STR', 'Отсутствует',
                                                          'VAR_GUID', NULL]));

        S.ExecSQL(INSERT_CHARGE_UF_VALUE, MakeDictionary(['CCID', contragChargeID,
                                                          'FIELDNAME', 'Date',
                                                          'VAR_DATE', contracharge.value['DATECREATED'],
                                                          'VAR_STR', NULL,
                                                          'VAR_GUID', NULL]));

        try
          S.ExecSQL(INSERT_CHARGE_UF_VALUE, MakeDictionary(['CCID', contragChargeID,
                                                            'FIELDNAME', 'Protocol',
                                                            'VAR_DATE', NULL,
                                                            'VAR_STR', VarToStr(protocol.value['VAR_STR']),
                                                            'VAR_GUID', VarToStr(protocol.value['VAR_GUID'])]));
        except
          LS.WriteEvent(0, plmtInfo, 'US2S+I ERROR', contracharge.value['TITLE'] + ' протокол не заполнен');
        end;

        LS.WriteEvent(0, plmtInfo, 'US2S+I SUCCESS', contracharge.value['TITLE'] + ' переведен в состояние ''Оплачен'' и на него создан акт');
        S.Commit;
      except
        LS.WriteEvent(0, plmtInfo, 'US2S+I ERROR', 'Error INSERT CONTRAGCHARGE');
        S.Rollback;
      end;
    end;
  end;
end;
