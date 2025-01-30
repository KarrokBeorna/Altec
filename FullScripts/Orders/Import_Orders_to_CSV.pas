begin
  if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите место сохранения', 'C:\', True) then begin
    TITLE := 'Дата заказа;Наименование;Адрес установки;Кол-во изделий;Заказчик;Стоимость;Оплачено;Долг;Примечание';
    sFile := TStringList.Create;
    sFile.add(TITLE);

    for i := 0 to SelectedRecords.count - 1 do begin
      e := SelectedRecords.items[i];
      sFile.add(varToStr(e.value['DATECREATED']) + ';' +
                varToStr(e.value['ORDNO']) + ';' +
                varToStr(e.value['ADDRESSINSTALL']) + ';' +
                varToStr(e.value['WINQTY']) + ';' +
                varToStr(e.value['CUSTOMERNAME']) + ';' +
                varToStr(e.value['PRICE']) + ';' +
                varToStr(e.value['PAYMENT']) + ';' +
                varToStr(e.value['DEBT']) + ';' +
                varToStr(e.value['ORD_COMMENT']) + ';' +
                );
    end;

    if copy(vFileName, length(vFileName) - 3, 4) <> '.csv' then
      sFile.SaveToFile(vFileName + '.csv')
    else sFile.SaveToFile(vFileName);
    sFile.Free;
  end;
end;
