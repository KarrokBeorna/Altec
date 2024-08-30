const
  INSERT_ORDER_STATE = 'INSERT INTO ORDERSTATESREG VALUES (GEN_ID(GEN_ORDERSTATESREG, 1), :ORDERID, :ORDERSTATEID, 0, :TIME, :STATE_POSIT, :RCOMMENT)';

  UPDATE_ORDER_STATE = 'UPDATE ORDERS SET ORDERSTATEID = :ORDERSTATEID WHERE ORDERID = :ORDERID';

  SELECT_LAST_STATE = 'SELECT OSR.* FROM ORDERSTATESREG OSR                                                                                                ' + #13#10 +
                      '  JOIN ORDERSTATES OS ON OS.ORDERSTATEID = OSR.ORDERSTATEID                                                                         ' + #13#10 +
                      '  JOIN (SELECT ORDERID, MAX(STATEPOSIT) MS FROM ORDERSTATESREG GROUP BY 1) J ON J.ORDERID = OSR.ORDERID AND OSR.STATEPOSIT = J.MS   ' + #13#10 +
                      'WHERE LOWER(OS.CODE) = ''dogovor_zakluchen''';

  SELECT_STATE_ID = 'SELECT ORDERSTATEID FROM ORDERSTATES WHERE LOWER(CODE) = ''zakaz_sozdan''';

var
  S: IomSession;
  lastStates: IcmDictionaryList;
  stateId, orderid, statePosit: Integer;

begin
  S := CreateObjectSession('');
  stateId := S.QueryValue(SELECT_STATE_ID, empty);
  lastStates :=  S.QueryRecordList(SELECT_LAST_STATE, empty);

  for i := 0 to lastStates.count - 1 do begin
    orderid := lastStates.items[i].value['ORDERID'];
    statePosit := lastStates.items[i].value['STATEPOSIT'] + 1;

    S.ExecSQL(INSERT_ORDER_STATE, MakeDictionary(['ORDERID', orderid,
                                                  'ORDERSTATEID', stateId,
                                                  'TIME', Now,
                                                  'STATE_POSIT', statePosit,
                                                  'RCOMMENT', '']));
    S.ExecSQL(UPDATE_ORDER_STATE, MakeDictionary(['ORDERID', orderid,
                                                  'ORDERSTATEID', stateId]));
  end;

  S.Commit();
end;
