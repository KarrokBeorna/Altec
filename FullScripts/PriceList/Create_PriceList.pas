{
 * Данная кнопка позволяет выгружать прайс-лист в формате .csv, где каждая строка
 * будет в формате
 * "Название конструкции [ширина]x[высота];Цена"
 *
 * Например:
 * Окно одностворчатое "Эконом" 500x1000;9098
 * Окно одностворчатое "Эконом" 500x1100;9622
 * Окно одностворчатое "Эконом" 500x1200;10153
 * Окно одностворчатое "Эконом" 500x1300;10677
 * Окно одностворчатое "Эконом" 500x1400;11207
 * ...
}

const
  selectPriceList =
   'SELECT                                                          ' + #13#10 +
   '  PT_NAME,                                                      ' + #13#10 +
   '  RIT.it_name as TYPE_NAME,                                     ' + #13#10 +
   '  RFP.FP_NAME as PROFIL_NAME,                                   ' + #13#10 +
   '  RFF.FF_NAME as FURN_NAME,                                     ' + #13#10 +
   '  CO.CP_NAME as CO_NAME,                                        ' + #13#10 +
   '  CI.CP_NAME as CI_NAME,                                        ' + #13#10 +
   '  PV_VALUE as PRICE,                                            ' + #13#10 +
   '  PH_VALUE as HEIGHT,                                           ' + #13#10 +
   '  PW_VALUE as WIDTH                                             ' + #13#10 +
   'FROM p_templates PT                                             ' + #13#10 +
   '  LEFT JOIN p_values PV ON PV.PT_ID = PT.PT_ID                  ' + #13#10 +
   '  LEFT JOIN colorspart CI ON CI.colorspartid = PT.INCOLORID     ' + #13#10 +
   '  LEFT JOIN colorspart CO ON CO.colorspartid = PT.OUTCOLORID    ' + #13#10 +
   '  LEFT JOIN r_itemstype RIT ON RIT.itemstypeid = PT.ITEMSTYPEID ' + #13#10 +
   '  LEFT JOIN r_firmprofil RFP ON RFP.firmid = PT.FIRMID          ' + #13#10 +
   '  LEFT JOIN r_firmfurn RFF ON RFF.firmid = PT.FIRMFURNID        ' + #13#10 +
   'WHERE ';

var
  vFileName, PT_IDs : string;
  session: IomSession;
  priceList: variant;
  buf: TStringList;

procedure createTable(initialRow, initialColumn: Integer);
begin
  for i := 0 to priceList.Count - 1 do begin
    buf.Add(priceList.items[i].value['PT_NAME'] + ' ' + varToStr(priceList.items[i].value['WIDTH']) + 'x' + varToStr(priceList.items[i].value['HEIGHT']) + ';' + varToStr(priceList.items[i].value['PRICE']));
  end;
end;

begin
  if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Место сохранения', 'C:\', true) then begin
    PT_IDs := 'PT.PT_ID in (';
    for i := 0 to SelectedRecords.Count - 2 do begin
      PT_IDs := PT_IDs + varToStr(SelectedRecords.items[i].Value['PT_ID']) + ', ';
    end;
    PT_IDs := PT_IDs + varToStr(SelectedRecords.items[SelectedRecords.Count - 1].Value['PT_ID']) + ')';

    session := CreateObjectSession();
    priceList := session.QueryRecordList(selectPriceList + PT_IDs, empty);

    buf := TStringList.Create;
    createTable(1, 1);
    buf.SaveToFile(vFileName + '.csv');
    buf.Free;
  end;
end;
