const
  INSERT_ORDER_UF_VALUE = 'INSERT INTO ORDER_UF_VALUES (ORDER_UF_VALUEID, ORDERID, USERFIELDID, VAR_DATE) VALUES (GEN_ID(GEN_ORDER_UF_VALUES, 1), :ORDERID, :USERFIELDID, :VAR_DATE)';

  UPDATE_ORDER_UF_VALUE = 'UPDATE ORDER_UF_VALUES SET VAR_DATE = :VAR_DATE WHERE ORDERID = :ORDERID AND USERFIELDID = :USERFIELDID';

  SELECT_USERFIELD_VALUE = 'SELECT ORDER_UF_VALUEID FROM ORDER_UF_VALUES WHERE USERFIELDID = :UFID AND ORDERID = :ID';

  SELECT_USERFIELD_ID = 'SELECT USERFIELDID FROM USERFIELDS WHERE LOWER(FIELDNAME) = ''payment_date''';

  SELECT_FIRST_PAY =  'SELECT OSR.CHANGEDATE FROM ORDERSTATESREG OSR                     ' + #13#10 +
                      '  JOIN ORDERSTATES OS ON OS.ORDERSTATEID = OSR.ORDERSTATEID       ' + #13#10 +
                      'WHERE                                                             ' + #13#10 +
                      '  LOWER(OS.CODE) = ''pay''                                        ' + #13#10 +
                      '  AND OSR.ORDERID = :ORDERID                                      ' + #13#10 +
                      'ORDER BY                                                          ' + #13#10 +
                      '  OSR.CHANGEDATE';

var
  S: IomSession;
  userFieldID, UFValueID: Integer;
  payDate: Date;

begin
  S := CreateObjectSession('');
  userFieldID := S.QueryValue(SELECT_USERFIELD_ID, empty);
  payDate := S.QueryValue(SELECT_FIRST_PAY, MakeDictionary(['ORDERID', OrderId]));
  UFValueID := S.QueryValue(SELECT_USERFIELD_VALUE, MakeDictionary(['UFID', userFieldID, 'ID', OrderId]));

  // Устанавливаем текущее время, если состояние "Оплачено" выставляется впервые
  if (NewStateCode = 'pay') and (payDate = 0) then begin
    try
      S.ExecSQL(INSERT_ORDER_UF_VALUE, MakeDictionary(['ORDERID', OrderID,
                                                       'USERFIELDID', userFieldID,
                                                       'VAR_DATE', Now]));
      S.Commit();
    except
      S.ExecSQL(UPDATE_ORDER_UF_VALUE, MakeDictionary(['ORDERID', OrderID,
                                                       'USERFIELDID', userFieldID,
                                                       'VAR_DATE', Now]));
      S.Commit();
    end;
  end else begin
    // Устанавливается первое время состояния "Оплачен", если данное состояние
    // уже присутствовало в стеке во время выставления нового состояния
    if (UFValueID = 0) and (payDate > 0) then begin
      S.ExecSQL(INSERT_ORDER_UF_VALUE, MakeDictionary(['ORDERID', OrderID,
                                                       'USERFIELDID', userFieldID,
                                                       'VAR_DATE', payDate]));
      S.Commit();
    end else begin
      if (payDate > 0) then begin
        S.ExecSQL(UPDATE_ORDER_UF_VALUE, MakeDictionary(['ORDERID', OrderID,
                                                       'USERFIELDID', userFieldID,
                                                       'VAR_DATE', payDate]));
        S.Commit();
      end;
    end;
  end;
end;
