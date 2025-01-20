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
  * помощью скрипта "Импорт цен на покрытия"
}

var
  CoatingPrice: IowCoatingPrice;
  S: IomSession;
  sFile: TStringList;


begin
  S := CreateObjectSession();
  CoatingPrice := S.OpenObject(IowCoatingPrice, SelectedRecords.items[0].value['ID']);

  if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите место сохранения', 'C:\', True) then begin
    TITLE := 'Система;Артикул;Наименование;Доп. артикул;Тип компонента;Единица измерения;Закупочная цена;Новая закупочная цена;Цена вн. покрытия;Цена внутр. покрытия;Цена двустороннего покрытия';
    sFile := TStringList.Create;
    sFile.add(TITLE);

    for i := 0 to CoatingPrice.BaseValues.count - 1 do begin
      bv := CoatingPrice.BaseValues[i];
      sFile.add('' + ';' +
                varToStr(bv.Articul.Marking) + ';' +
                varToStr(bv.Articul.Name) + ';' +
                varToStr(bv.Articul.AdditionalMarking) + ';' +
                varToStr(bv.Articul.Type.Name) + ';' +
                varToStr(bv.Articul.Measure.Name) + ';' +
                varToStr(bv.Articul.Price) + ';' +
                varToStr(bv.Articul.Price) + ';' +
                varToStr(bv.OuterPrice) + ';' +
                varToStr(bv.InnerPrice) + ';' +
                varToStr(bv.BothPrice));
    end;

    path := '';
    while pos('\', vFileName) > 0 do begin
      path := path + copy(vFileName, 0, pos('\', vFileName));
      vFileName := copy(vFileName, pos('\', vFileName) + 1, length(vFileName));
    end;

    //showmessage(path + CoatingPrice.Name + '.csv');

    sFile.SaveToFile(path + CoatingPrice.Name + '.csv');
    sFile.Free;
  end;
end;
