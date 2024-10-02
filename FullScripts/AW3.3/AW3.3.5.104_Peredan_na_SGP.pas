const
  SET_CUTTED1_1 = 'UPDATE FACTORY_UNITS_1D_DETAILS F1 SET CUTTED = 1   ' + #13#10 +
                  'WHERE F1.FACTORYUNITID = :ID';
  SET_CUTTED1_2 = 'UPDATE BEAMS_CUTTING_TASKS SET CLOSED = 1, RESERVED = 0, EXECUTED = 1, USEDAMOUNT = 0, USEDCOST = 0, TECHWASTEAMOUNT = 0, OPTWASTEAMOUNT = 0, WASTECOST = 0   ' + #13#10 +
                  'WHERE FACTORYTASKID = :ID';
  SET_CUTTED2_1 = 'UPDATE FACTORY_UNITS_2D_DETAILS F2 SET CUTTED = 1   ' + #13#10 +
                  'WHERE F2.FACTORYUNITID = :ID';
  SET_CUTTED2_2 = 'UPDATE SHEETS_CUTTING_TASKS SET CLOSED = 1, RESERVED = 0, EXECUTED = 1, USEDAMOUNT = 0, USEDCOST = 0, TECHWASTEAMOUNT = 0, OPTWASTEAMOUNT = 0, WASTECOST = 0   ' + #13#10 +
                  'WHERE FACTORYTASKID = :ID';

  GET_FACTORY_TASK = 'SELECT FIRST 1 FT.ID FROM FACTORY_TASKS FT JOIN FACTORY_UNITS FU ON FU.FACTORYTASKID = FT.ID WHERE FU.ID = :ID';

  CHECK_PARTS_READY = 'SELECT                                                    ' + #13#10 +
                      '  COALESCE(M, 1) RES                                      ' + #13#10 +
                      'FROM (                                                    ' + #13#10 +
                      '  SELECT                                                  ' + #13#10 +
                      '    MIN(FU2.PRODUCED) M                                   ' + #13#10 +
                      '  FROM                                                    ' + #13#10 +
                      '    FACTORY_UNITS FU                                      ' + #13#10 +
                      '      JOIN FACTORY_TASKS FT ON FT.ID = FU.FACTORYTASKID   ' + #13#10 +
                      '      JOIN FACTORY_UNITS FU2 ON FU.ID = FU2.PARENTUNITID  ' + #13#10 +
                      '  WHERE                                                   ' + #13#10 +
                      '    FU.ID = :ID                                           ' + #13#10 +
                      ')';

  SET_READY_ELEMENTS = 'UPDATE FACTORY_UNITS SET        ' + #13#10 +
                       '  PRODUCED = 1,                 ' + #13#10 +
                       '  PRODUCTIONDATE = :PRDATE,     ' + #13#10 +
                       '  PRODUCERID = :USERID          ' + #13#10 +
                       'WHERE ID = :ID';

  SET_PARTS_PRODUCED = '                                                ' + #13#10 +
  'UPDATE FACTORY_UNITS FU SET PARTSPRODUCED = 1 WHERE                  ' + #13#10 +
  '  ID = (SELECT PARENTUNITID FROM FACTORY_UNITS WHERE ID = :ID) AND   ' + #13#10 +
  '  (SELECT MIN(PRODUCED) FROM FACTORY_UNITS WHERE PARENTUNITID = (SELECT PARENTUNITID FROM FACTORY_UNITS WHERE ID = :ID)) = 1';

  SET_STAGE_QUEUE = 'UPDATE FACTORY_UNITS_QUEUE SET  ' + #13#10 +
                    '  STAGE = 3                     ' + #13#10 +
                    'WHERE UNITID = :ID';

  DELETE_STAGE_QUEUE = 'DELETE FROM FACTORY_UNITS_QUEUE WHERE STAGE = 3 AND (UNITID IN (SELECT ID FROM FACTORY_UNITS WHERE PARENTUNITID = :ID) OR UNITID = :ID)';

  SET_READY_ITEMS = 'UPDATE FACTORY_TASKS_ITEMS SET ' + #13#10 +
                    '  POSTED = 1,                  ' + #13#10 +
                    '  POSTDATE = :PDATE            ' + #13#10 +
                    'WHERE FACTORYUNITID = :ID';

  SET_READY_SHIPPING = 'UPDATE SHIPPING_UNITS SET                              ' + #13#10 +
                       '  READY = 1,                                           ' + #13#10 +
                       '  ACCEPTED = 1,                                        ' + #13#10 +
                       '  ACCEPTDATE = :DATE,                                  ' + #13#10 +
                       '  ACCEPTORID = :ACCEPTORID,                            ' + #13#10 +
                       '  LOCATION = ''Принят по штрихкоду''                   ' + #13#10 +
                       'WHERE ID = (SELECT SHIPPINGUNITID FROM FACTORY_UNITS WHERE ID = :ID)';

  CHECK_POSTED_ITEMS = 'SELECT MIN(POSTED) FROM FACTORY_TASKS_ITEMS WHERE FACTORYTASKID = :ID';

  SET_READY_TASK = 'UPDATE FACTORY_TASKS SET  ' + #13#10 +
                   '  COMPLETED = 1,          ' + #13#10 +
                   '  COMPLETEDATE = :CDATE   ' + #13#10 +
                   'WHERE ID = :ID';

  CHECK_ACCEPTED_SHIPPING = 'SELECT MIN(ACCEPTED) FROM SHIPPING_UNITS WHERE SHIPPINGORDERID = (SELECT FIRST 1 ID FROM SHIPPING_ORDERS WHERE ORDERID = :ID)';

  SET_ACCEPT_SHIPPING = 'UPDATE SHIPPING_ORDERS SET  ' + #13#10 +
                        '  ACCEPTED = 1              ' + #13#10 +
                        'WHERE ORDERID = :ID';

  SET_EMPLOYEE = 'UPDATE FACTORY_UNITS_EVENTS SET EMPID = :NEWEMPID WHERE FACTORYUNITID = :FACTORYUNITID AND EVENTTYPEID IN (SELECT ID FROM PRODUCTTYPES_EVENTTYPES WHERE CODE = :CODE)';


var
  task: IawFactoryTask;
  facUnit: IawFactoryUnit;
  S: IomSession;
  checkParts, checkShipping, checkPostedItems: Boolean;

begin
  S := CreateObjectSession;
  facUnit := S.OpenObject(IawFactoryUnit, Params.FactoryUnitId);
  task := S.OpenDocumentByKey(IawFactoryTask, S.QueryValue(GET_FACTORY_TASK, MakeDictionary(['ID', facUnit.key])));
  checkParts := S.QueryRecord(CHECK_PARTS_READY, MakeDictionary(['ID', facUnit.key]))['RES'];

  if checkParts then begin
    S.ExecSQL(SET_CUTTED1_2, MakeDictionary(['ID', task.key]));
    S.ExecSQL(SET_CUTTED2_2, MakeDictionary(['ID', task.key]));

    if varIsNull(facUnit.ProductionDate) then begin
      S.ExecSQL(SET_CUTTED1_1, MakeDictionary(['ID', facUnit.key]));
      S.ExecSQL(SET_CUTTED2_1, MakeDictionary(['ID', facUnit.key]));
      S.ExecSQL(SET_READY_ELEMENTS, MakeDictionary(['PRDATE', Now, 'USERID', SessionVariables.User, 'ID', facUnit.key]));
      S.ExecSQL(SET_PARTS_PRODUCED, MakeDictionary(['ID', facUnit.key]));
      S.ExecSQL(SET_READY_ITEMS, MakeDictionary(['PDATE', Now, 'ID', facUnit.key]));
      S.ExecSQL(SET_STAGE_QUEUE, MakeDictionary(['ID', facUnit.key]));
      S.ExecSQL(DELETE_STAGE_QUEUE, MakeDictionary(['ID', facUnit.key]));
      S.ExecSQL(SET_READY_SHIPPING, MakeDictionary(['ID', facUnit.key,
                                                    'DATE', Now,
                                                    'ACCEPTORID', SessionVariables.User]));
      AddFactoryUnitEvent(facUnit.key, 'peredan_na_sgp', 'Передан на СГП');
      S.Commit;
      S.ExecSQL(SET_EMPLOYEE, MakeDictionary(['NEWEMPID', SessionVariables.User, 'FACTORYUNITID', facUnit.key, 'CODE', 'peredan_na_sgp']));
      S.Commit;
    end;

    checkShipping := S.QueryValue(CHECK_ACCEPTED_SHIPPING, MakeDictionary(['ID', facUnit.OrderUnit.OrderItem.Order.Key]));
    if checkShipping then begin
      S.ExecSQL(SET_ACCEPT_SHIPPING, MakeDictionary(['ID', facUnit.OrderUnit.OrderItem.Order.Key]));
      S.Commit;
    end;

    checkPostedItems := S.QueryValue(CHECK_POSTED_ITEMS, MakeDictionary(['ID', task.key]));
    if checkPostedItems then begin
      S.ExecSQL(SET_READY_TASK, MakeDictionary(['CDATE', Now, 'ID', facUnit.key]));
      S.Commit;
    end;
  end else begin
    ShowMessageDlg(task.name + ' - Части изделия в других сменных заданиях не готовы или не закуплены', mtWarning, mbOK);
  end;
end.
