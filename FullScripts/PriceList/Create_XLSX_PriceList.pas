{
 * Если у вас на устройстве лицензированный Excel, то можно выгрузить прайс-лист в формате
 * .xlsx в формате:
 *
 * Название прайс-листа:	Окно одностворчатое "Эконом"        Ширина   Высота         Цена
 * Тип изделия:	          Окно                                   500     1000    9098,00 ?
 * Система профиля:	      KBE 58                                 500     1100    9622,00 ?
 * Фурнитура:	            WINKHAUS proPilot                      500     1200   10153,00 ?
 * Внешний цвет:                                                 500     1300   10677,00 ?
 * Внутренний цвет:                                              ...      ...          ...
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
   'WHERE PT.PT_ID = :PT_ID';

var
  vFileName : string;
  session: IomSession;
  XL, xLst: variant;
  priceList: IcmDictionaryList;
  i: integer;

procedure startExcel;
begin
  XL := CreateOleObject('Excel.Application');
  XL.visible := true;
  XL.DisplayAlerts := false;
  XL.WorkBooks.Add;
  XL.WorkBooks[1].WorkSheets[1].Name := 'Лист1';
end;

procedure changeExcelColumns(autofit: Boolean);
begin
  if autofit then begin
    XL.Columns.Autofit;
  end else begin
    xLst := XL.WorkBooks[1].WorkSheets['Лист1'].Columns;
    xLst.Columns[1].ColumnWidth:=10;
    xLst.Columns[2].ColumnWidth:=30;
    xLst.Columns[3].ColumnWidth:=50;
    xLst.Columns[4].ColumnWidth:=15;
    xLst.Columns[5].ColumnWidth:=15;
  end;
end;

{procedure changeExcelRows;
begin
  xLst := XL.WorkBooks[1].WorkSheets['Лист1'].Rows;
end;

procedure createTitle(startRange, stopRange, title:String);
begin
  xLst.Range[startRange + ':' + stopRange].MergeCells := True;
  xLst.Range[startRange + ':' + stopRange] := title;
end;}

procedure createGeneralInfo;
begin
  startExcel();
  changeExcelColumns(true);
  // changeExcelRows();

  XL.WorkBooks[1].WorkSheets[1].Cells[1,1] := 'Название прайс-листа';
  XL.WorkBooks[1].WorkSheets[1].Cells[1,2] := priceList.items[0].value['PT_NAME'];
  XL.WorkBooks[1].WorkSheets[1].Cells[2,1] := 'Тип изделия';
  XL.WorkBooks[1].WorkSheets[1].Cells[2,2] := priceList.items[0].value['TYPE_NAME'];
  XL.WorkBooks[1].WorkSheets[1].Cells[3,1] := 'Система профиля';
  XL.WorkBooks[1].WorkSheets[1].Cells[3,2] := priceList.items[0].value['PROFIL_NAME'];
  XL.WorkBooks[1].WorkSheets[1].Cells[4,1] := 'Фурнитура';
  XL.WorkBooks[1].WorkSheets[1].Cells[4,2] := priceList.items[0].value['FURN_NAME'];
  XL.WorkBooks[1].WorkSheets[1].Cells[5,1] := 'Внешний цвет';
  XL.WorkBooks[1].WorkSheets[1].Cells[5,2] := priceList.items[0].value['CO_NAME'];
  XL.WorkBooks[1].WorkSheets[1].Cells[6,1] := 'Внутренний цвет';
  XL.WorkBooks[1].WorkSheets[1].Cells[6,2] := priceList.items[0].value['CI_NAME'];

  XL.WorkBooks[1].WorkSheets[1].Cells[1,4] := 'Ширина';
  XL.WorkBooks[1].WorkSheets[1].Cells[1,5] := 'Высота';
  XL.WorkBooks[1].WorkSheets[1].Cells[1,6] := 'Цена';
  XL.Range['A1:A6'].Font.Bold := true;
  XL.Range['D1:F1'].Font.Bold := true;
end;

procedure createTable;
begin
  for i := 0 to priceList.Count - 1 do begin
    XL.WorkBooks[1].WorkSheets[1].Cells[i+2,4] := priceList.items[i].value['WIDTH'];
    XL.WorkBooks[1].WorkSheets[1].Cells[i+2,5] := priceList.items[i].value['HEIGHT'];
    XL.WorkBooks[1].WorkSheets[1].Cells[i+2,6] := priceList.items[i].value['PRICE'];
  end;
end;

begin
  if PromptForFileName(vFileName, 'Excel files (*.xlsx)|*.xlsx', '', 'Место сохранения', 'C:\', true) then begin
    session := CreateObjectSession();
    priceList := session.QueryRecordList(selectPriceList, MakeDictionary(['PT_ID', SelectedRecords.items[0].Value['PT_ID']]));

    createGeneralInfo();
    createTable();
    XL.WorkBooks[1].SaveAs(vFileName);
    XL.Workbooks.Close();
    XL.quit();
  end;
end;
