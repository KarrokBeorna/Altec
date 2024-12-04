{
 * Аналог отчёта "Расход материалов" с выгрузкой всех рассчитанных материалов в CSV-файл в формате:
 * №;Артикул;Наименование;Внутренний;Внешний;Кол-во;Кол-во с отходами;Ед.изм.;Отх.в цене;Цена;Сумма
 *
 * Здесь представлена лишь заготовка для начала работы не с нуля.
 * Сама же работа исключительно платная, так как нужно согласовывать число
 * выгружаемых файлов, порядок столбцов, формат значений и т.д.
}

const
  GET_DETAILS = '                                                                                         ' + #13#10 +
'SELECT                                                                                                   ' + #13#10 +
'  VA.AR_ART,                                                                                             ' + #13#10 +
'  VA.AR_LONGNAME,                                                                                        ' + #13#10 +
'  COALESCE(EFR.FR_NAME, ''Без группы'') AS TYPE,                                                         ' + #13#10 +
'  DM.MD_FACTOR,                                                                                          ' + #13#10 +
'  DM.MD_NAME,                                                                                            ' + #13#10 +
'  COALESCE(VA.WASTE, 0) AS WASTE,                                                                        ' + #13#10 +
'  C1.CP_NAME,                                                                                            ' + #13#10 +
'  C2.CP_NAME,                                                                                            ' + #13#10 +
'  AP.PRICE,                                                                                              ' + #13#10 +
'  EFR.POSIT,                                                                                             ' + #13#10 +
'  WG.GP_FACTOR,                                                                                          ' + #13#10 +
'  DM.MEASUREID,                                                                                          ' + #13#10 +
'  PG.ID AS PGID,                                                                                         ' + #13#10 +
'  PG.NAME,                                                                                               ' + #13#10 +
'  SUM(POID.QUANTITY * COALESCE(POID."SIZE", 1) / DM.MD_FACTOR) AS AMOUNT,                                ' + #13#10 +
'  SUM(AP.PRICE * POID.QUANTITY) SUMM,                                                                    ' + #13#10 +
'  SUM(POID.QUANTITY * COALESCE(POID."SIZE", 1) / DM.MD_FACTOR * (VA.WASTE + 100) / 100)  AS WASTEAMOUNT  ' + #13#10 +
'FROM                                                                                                     ' + #13#10 +
'  PRODUCTION_GROUPS PG                                                                                   ' + #13#10 +
'    JOIN PRODUCTION_GROUPS_ITEMS PGI ON PGI.PRODUCTIONGROUPID = PG.ID                                    ' + #13#10 +
'    JOIN PRODUCTION_ORDERS_ITEMS POI ON POI.ID = PGI.PRODUCTIONORDERITEMID                               ' + #13#10 +
'    JOIN PRODUCTION_ORDERS_ITEMS_DETAILS POID ON POID.PRODUCTIONORDERITEMID = POI.ID                     ' + #13#10 +
'    JOIN ORDERS_ITEMS_DETAILS AS OID ON OID.ID = POID.ORDERITEMDETAILID                                  ' + #13#10 +
'    JOIN ORDERS_ITEMS OI ON OI.ID = OID.ORDERITEMID                                                      ' + #13#10 +
'    JOIN ORDERS O ON O.ID = OI.ORDERID                                                                   ' + #13#10 +
'    JOIN VIRTARTICULES VA ON VA.ARTICULID = OID.ARTICULID                                                ' + #13#10 +
'    JOIN DOPMEASURE DM ON DM.DOPMEASUREID = VA.DOPMEASUREID                                              ' + #13#10 +
'    LEFT JOIN COLORSPART C1 ON C1.COLORSPARTID = OID.INCOLORID                                           ' + #13#10 +
'    LEFT JOIN COLORSPART C2 ON C2.COLORSPARTID = OID.OUTCOLORID                                          ' + #13#10 +
'    LEFT JOIN E_FORREPORT EFR ON EFR.REPORTID = OID.REPORTID                                             ' + #13#10 +
'    LEFT JOIN ARTPRICES AP ON AP.ARTICULID = VA.ARTICULID                                                ' + #13#10 +
'    LEFT JOIN W_GRPRICE WG ON WG.WGRPRICEID = VA.WGRPRICEID                                              ' + #13#10 +
'WHERE                                                                                                    ' + #13#10 +
'  PG.ID = :ID                                                                                            ' + #13#10 +
'GROUP BY                                                                                                 ' + #13#10 +
'  1,2,3,4,5,6,7,8,9,10,11,12,13,14                                                                       ' + #13#10 +
'ORDER BY                                                                                                 ' + #13#10 +
'  PGID, EFR.POSIT ASC NULLS LAST, VA.AR_ART';


var
  S: IomSession;
  Details: IcmDictionaryList;
  PrevType, TITLE, WasteExists: string;
  Detail: IcmDictionary;
  sFile: TStringList;
  Price, Summ: variant;

begin
  if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите место сохранения', 'C:\', True) then begin
    S := CreateObjectSession();
    sFile := TStringList.Create;
    Details := S.QueryRecordList(GET_DETAILS, MakeDictionary(['ID', SelectedRecords.Items[0].value['ID']]));
    PrevType := '';

    TITLE := '№;Артикул;Наименование;Внутренний;Внешний;Кол-во;Кол-во с отходами;Ед.изм.;Отх.в цене;Цена;Сумма';
    sFile.add(TITLE);

    for i := 0 to Details.Count - 1 do begin
      Detail := Details.items[i];
      {
      if Detail.value['TYPE'] <> PrevType then begin
        PrevType := Detail.value['TYPE'];
        if i <> 0 then sFile.add('');
        sFile.add(PrevType);
        sFile.add(TITLE);
      end;
      }

      if (not varIsNull(Detail.value['GP_FACTOR'])) and (Detail.value['GP_FACTOR'] <> 0) then begin
        Price := Detail.value['GP_FACTOR'] * Detail.value['PRICE'];
      end else begin
        Price := Detail.value['PRICE'];
      end;

      if (not varIsNull(Detail.value['WASTEAMOUNT'])) and (Detail.value['WASTEAMOUNT'] <> 0) then begin
        WasteExists := 'Да';
        Summ := Price * Detail.value['WASTEAMOUNT'];
      end else begin
        WasteExists := 'Нет';
        Summ := Price * Detail.value['AMOUNT'];
      end;

      sFile.add(
        varToStr(i + 1) + ';' +
        varToStr(Detail.value['AR_ART']) + ';' +
        varToStr(Detail.value['AR_LONGNAME']) + ';' +
        varToStr(Detail.value['CP_NAME']) + ';' +
        varToStr(Detail.value['CP_NAME1']) + ';' +
        varToStr(Detail.value['AMOUNT']) + ';' +
        varToStr(Detail.value['WASTEAMOUNT']) + ';' +
        varToStr(Detail.value['MD_NAME']) + ';' +
        varToStr(WasteExists) + ';' +
        varToStr(Price) + ';' +
        varToStr(Summ)
      );
    end;

    if copy(vFileName, length(vFileName) - 3, 4) <> '.csv' then
      sFile.SaveToFile(vFileName + '.csv')
    else sFile.SaveToFile(vFileName);
    sFile.Free;
  end;
end;
