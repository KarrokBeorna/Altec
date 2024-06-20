begin
  if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите место сохранения', 'C:\', True) then begin
    TITLE := 'Артикул;Наименование;Доп. артикул;Тип компонента;Единица измерения;Закупочная цена';
    sFile := TStringList.Create;
    sFile.add(TITLE);

    for i := 0 to SelectedRecords.count - 1 do begin
      e := SelectedRecords.items[i];
      sFile.add(varToStr(e.value['AR_ART']) + ';' +
                varToStr(e.value['AR_LONGNAME']) + ';' +
                varToStr(e.value['AR_ART2']) + ';' +
                varToStr(e.value['VIRTARTTYPENAME']) + ';' +
                varToStr(e.value['MEASURENAME']) + ';' +
                varToStr(e.value['PRICE']));
    end;

    if copy(vFileName, length(vFileName) - 3, 4) <> '.csv' then
      sFile.SaveToFile(vFileName + '.csv')
    else sFile.SaveToFile(vFileName);
    sFile.Free;
  end;
end;
