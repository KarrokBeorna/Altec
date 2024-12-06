{
  * Скрипт выгружает все выделенные записи в CSV-файл с разделителем ";".
  * Выгружаемые данные:
  * - Система
  * - Артикул
  * - Наименование
  * - Доп. артикул
  * - Тип компонента
  * - Единица измерения
  * - Закупочная цена
  * - Новая закупочная цена
  * - Цена вн. покрытия
  * - Цена внутр. покрытия
  * - Цена двустороннего покрытия
  *
  * Полученный файл в дальнейшем редактируется и используется для загрузки цен с
  * помощью скрипта "Обновление цен из CSV-файла"
  *
  * Также артикул и три последних столбца необходимы для скрипта "Импорт цен на покрытия"
}

begin
  if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите место сохранения', 'C:\', True) then begin
    TITLE := 'Система;Артикул;Наименование;Доп. артикул;Тип компонента;Единица измерения;Закупочная цена;Новая закупочная цена;Цена вн. покрытия;Цена внутр. покрытия;Цена двустороннего покрытия';
    sFile := TStringList.Create;
    sFile.add(TITLE);

    for i := 0 to SelectedRecords.count - 1 do begin
      e := SelectedRecords.items[i];
      sFile.add(varToStr(e.value['SYSNAME']) + ';' +
                varToStr(e.value['AR_ART']) + ';' +
                varToStr(e.value['AR_LONGNAME']) + ';' +
                varToStr(e.value['AR_ART2']) + ';' +
                varToStr(e.value['VIRTARTTYPENAME']) + ';' +
                varToStr(e.value['MEASURENAME']) + ';' +
                varToStr(e.value['PRICE']) + ';' +
                varToStr(e.value['PRICE']) + ';' +
                '' + ';' +
                '' + ';' +
                '');
    end;

    if copy(vFileName, length(vFileName) - 3, 4) <> '.csv' then
      sFile.SaveToFile(vFileName + '.csv')
    else sFile.SaveToFile(vFileName);
    sFile.Free;
  end;
end;
