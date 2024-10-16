const
  CHILL_DAY = ['01.01.2024', '02.01.2024', '03.01.2024', '04.01.2024', '05.01.2024', '06.01.2024', '07.01.2024', '08.01.2024', '23.02.2024', '08.03.2024', '29.04.2024', '30.04.2024', '01.05.2024', '09.05.2024', '10.05.2024', '12.06.2024', '04.11.2024', '30.12.2024', '31.12.2024', '01.01.2025', '02.01.2025', '03.01.2025', '04.01.2025', '05.01.2025', '06.01.2025', '07.01.2025', '08.01.2025', '23.02.2025', '08.03.2025', '09.03.2025', '01.05.2025', '02.05.2025', '08.05.2025', '09.05.2025', '12.06.2025', '13.06.2025', '03.11.2025', '04.11.2025', '31.12.2025'];
  WORK_DAY = ['22.02.2024', '07.03.2024', '27.04.2024', '08.05.2024', '11.06.2024', '02.11.2024', '28.12.2024', '07.03.2025', '30.04.2025', '11.06.2025', '01.11.2025'];

  INSUPD_ORDER_UF_VALUE = 'UPDATE OR INSERT INTO ORDER_UF_VALUES (ORDERID, USERFIELDID, VAR_DATE) VALUES ' + #13#10 +
                          '(:ORDERID, :USERFIELDID, :VAR_DATE)                                           ' + #13#10 +
                          'MATCHING (ORDERID, USERFIELDID)';

  SELECT_USERFIELD_ID = 'SELECT USERFIELDID FROM USERFIELDS WHERE LOWER(FIELDNAME) = :CODE';
  
  SELECT_USER_DEPARTS = 'SELECT                                              ' + #13#10 +
                        '  D.TITLE                                           ' + #13#10 +
                        'FROM                                                ' + #13#10 +
                        '  EMPLOYEE E                                        ' + #13#10 +
                        '    JOIN DEPEMPLOYEE DE ON DE.EMPID = E.EMPID       ' + #13#10 +
                        '    JOIN DEPARTMENT D ON D.DEPID = DE.DEPID         ' + #13#10 +
                        'WHERE E.EMPID = :ID';
                        
  SELECT_FULL_INFO =  'SELECT DISTINCT                                                                                                     ' + #13#10 +
                      '  RSTP.TYPENAME AS PROFTYPE,                                                                                        ' + #13#10 +
                      '  RSG.FULLNAME AS GLASSNAME,                                                                                        ' + #13#10 +
                      '  RSF.NAME AS FURNNAME,                                                                                             ' + #13#10 +
                      '  COALESCE(MF.GEOMETRY, ISD.VALUE1) AS NESTANDART,                                                                  ' + #13#10 +
                      '  MF.SHPROSSES AS RASKLADKA,                                                                                        ' + #13#10 +
                      '  GG.NAME AS PLENKA,                                                                                                ' + #13#10 +
                      '  M.INCOLORID AS INCOLOR,                                                                                           ' + #13#10 +
                      '  M.OUTCOLORID AS OUTCOLOR                                                                                          ' + #13#10 +
                      'FROM                                                                                                                ' + #13#10 +
                      '  ORDERITEMS OI                                                                                                     ' + #13#10 +
                      '    LEFT JOIN ITEMSECDETAIL ISD ON ISD.ORDERITEMSID = OI.ORDERITEMSID AND (ISD.ECITEMID = 33 OR ISD.ECITEMID = 80)  ' + #13#10 +
                      '    JOIN MODELS M ON M.ORDERITEMSID  = OI.ORDERITEMSID                                                              ' + #13#10 +
                      '    LEFT JOIN MODELPARTS MP ON MP.MODELID = M.MODELID                                                               ' + #13#10 +
                      '      LEFT JOIN MODELFILLINGS MF ON MF.MODELPARTID = MP.MODELPARTID                                                 ' + #13#10 +
                      '      LEFT JOIN GPACKETTYPES GPT ON GPT.GPTYPEID = MP.GPTYPEID                                                      ' + #13#10 +
                      '    LEFT JOIN R_SYSTEMS RSP ON RSP.RSYSTEMID = M.SYSPROFID                                                          ' + #13#10 +
                      '      LEFT JOIN R_SYSTEMTYPES RSTP ON RSTP.TYPEID = RSP.SYSTEMTYPE                                                  ' + #13#10 +
                      '    LEFT JOIN R_SYSTEMS RSF ON RSF.RSYSTEMID = M.SYSFURNID                                                          ' + #13#10 +
                      '    LEFT JOIN R_SYSTEMS RSG ON RSG.RSYSTEMID = GPT.RSYSTEMID                                                        ' + #13#10 +
                      '    LEFT JOIN ITEMSDETAIL ITD ON ITD.ORDERITEMSID = OI.ORDERITEMSID                                                 ' + #13#10 +
                      '      LEFT JOIN GROUPGOODS GG ON GG.GRGOODSID = ITD.GRGOODSID AND GG.NAME CONTAINING ''Пленка''                     ' + #13#10 +
                      'WHERE                                                                                                               ' + #13#10 +
                      '  OI.ORDERID = :ORDERID';


var
  S: IomSession;
  ORDNO: String;
  userDeparts, fullInfo: IcmDictionaryList;
  userRoznica: Boolean = False;
  numOfWork: Integer = 3;
  userFieldID, UFValueID, countedDays: Integer = 0;
  resultDay: TDateTime;

function ContainsInArray(value: variant; arr: Array of Variant): Boolean;
begin
  result := False;
  for i := 0 to length(arr) - 1 do begin
    if arr[i] = value then begin
      result := True;
      break;
    end;
  end;
end;

procedure CountDaysOfWork;
begin
  for z := 0 to fullInfo.count - 1 do begin
    if (numOfWork < 6) and (fullInfo.items[z].value['GLASSNAME'] = 'Заказной стеклопакет') then numOfWork := 6;
    if (numOfWork < 10) and (fullInfo.items[z].value['NESTANDART'] > 0) then numOfWork := 10;
    if (numOfWork < 14) and (fullInfo.items[z].value['GLASSNAME'] = 'Заказной стеклопакет') and (fullInfo.items[z].value['RASKLADKA'] > 0) then numOfWork := 14;
    if (numOfWork < 17) and (fullInfo.items[z].value['GLASSNAME'] = 'Заказной стеклопакет') and (fullInfo.items[z].value['NESTANDART'] > 0) then numOfWork := 17;
    if (numOfWork < 20) and not VarIsNull(fullInfo.items[z].value['PLENKA']) and (fullInfo.items[z].value['PLENKA'] <> '') then numOfWork := 20;
    if (numOfWork < 20) and (fullInfo.items[z].value['PROFTYPE'] = 'Алюминий') then numOfWork := 20;
    if (numOfWork < 26) and ((fullInfo.items[z].value['INCOLOR'] <> 1) or (fullInfo.items[z].value['OUTCOLOR'] <> 1)) then numOfWork := 26;
    if (numOfWork < 70) and (not ContainsInArray(fullInfo.items[z].value['FURNNAME'], ['ROTO NX', 'VORNE', 'Без фурнитуры', 'Фурнитура для алюминия'])) then numOfWork := 70;
  end;
end;

procedure CountResultDay;
var
  j: Integer = 0;
begin
  CountDaysOfWork();
  while countedDays <> numOfWork do begin
    j := j + 1;
    if (DayOfWeek(Date + j) = 1) or (DayOfWeek(Date + j) = 7) then begin
      if ContainsInArray(DateToStr(Date + j), WORK_DAY) then begin
        countedDays := countedDays + 1;
      end;
    end;
    if (DayOfWeek(Date + j) > 1) and (DayOfWeek(Date + j) < 7) then begin
      if not ContainsInArray(DateToStr(Date + j), CHILL_DAY) then begin
        countedDays := countedDays + 1;
      end;
    end;
  end;
  resultDay := Date + j;
end;

begin
  S := CreateObjectSession('');
  userFieldID := S.QueryValue(SELECT_USERFIELD_ID, MakeDictionary(['CODE', 'srok']));
  trueUserFieldID := S.QueryValue(SELECT_USERFIELD_ID, MakeDictionary(['CODE', 'srok_script']));
  userDeparts := S.QueryRecordList(SELECT_USER_DEPARTS, MakeDictionary(['ID', UserID]));
  fullInfo := S.QueryRecordList(SELECT_FULL_INFO, MakeDictionary(['ORDERID', OrderID]));
  
  for i := 0 to userDeparts.count - 1 do begin
    if userDeparts[i].value['TITLE'] = 'Розница' then userRoznica := True;
  end;

  if ((userRoznica) and (StateCode = 'dogovor_zakluchen')) or
     ((not userRoznica) and (StateCode = 'Zakaz_sozdan')) then begin
    CountResultDay();

    try
      S.ExecSQL(INSUPD_ORDER_UF_VALUE, MakeDictionary(['ORDERID', OrderId,
                                                       'USERFIELDID', userFieldID,
                                                       'VAR_DATE', resultDay + 1/3]));
      S.ExecSQL(INSUPD_ORDER_UF_VALUE, MakeDictionary(['ORDERID', OrderId,
                                                       'USERFIELDID', trueUserFieldID,
                                                       'VAR_DATE', resultDay + 1/3]));
      S.Commit();
    except
    end;
  end;
end.
