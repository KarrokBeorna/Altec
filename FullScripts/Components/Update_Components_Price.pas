{
  * В файле, полученном после использования кнопки "Выгрузка компонентов в CSV-файл",
  * обновляем цены в 8 столбце ("Новая закупочная цена").
  *
  * Затем запускаем данных скрипт, выбираем файл с новыми ценами.
  * Вас перекинет на вкладку "Переоценка" и создастся новая переоценка,
  * куда попадут все артикулы, у которых вы изменили цены.
  *
  * Поиск компонентов, у которых нужно обновить цену производится по артикулу.
  * При необходимости можно заменить на поиск по доп. артикулу, наименованию
  * или же по всему сразу.
  *
  * В случае, если такой артикул в программе не найден, то выводится ошибка
  * "[Артикул] (№ строки в CSV-файле) не найден" и переоценка не создается.
  * Вам нужно будет проверить, не тронули ли вы артикул.
  *
  * Также при некорректном вводе новой цены, которая не будет числом, выведется
  * ошибка "На [артикуле] (№ строки в CSV-файле) стоит пустая цена" и
  * переоценка не будет создана.
}

const
  FIND_ARTICULID = 'SELECT ARTICULID FROM VIRTARTICULES WHERE AR_ART = :AR_ART';

var
  S: IomSession;
  vFileName, currStr: String;
  entryDict, articulDict: IcmDictionary;
  sFile: TStringList;
  ViewsUIService: IpubViewsUIService;
  ObjectsUIService: IpubObjectsUIService;
  RP: IowReprice;
  RI: IowRepriceItem;
  visible: Boolean = True;

function getDictionaryFromEntry(str: string): IcmDictionary;
var
  dict: IcmDictionary;
begin
  dict := CreateDictionary;
  index := 0;
  str := str + ';';

  while str <> '' do begin
    value := Copy(str, 1, Pos(';', str) - 1);
    DeleteStr(str, 1, Pos(';', str));
    dict.Add(intToStr(index), value);
    index := index + 1;
  end;

  Result := dict;
end;


begin
  if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите файл', 'C:\', false) then begin
    S := CreateObjectSession();
    sFile := TStringList.Create;
    sFile.LoadFromFile(vFileName);
    articulDict := CreateDictionary;

    REPRICENAME := 'Переоценка от ' + DateTimeToStr(Now);
    REPRICENOTE := 'Переоценка, созданная с помощью скрипта, от ' + DateTimeToStr(Now);

    RP := S.NewObject(IowReprice);
    RP.Name := REPRICENAME;
    RP.Comment := REPRICENOTE;
    RP.EffectDate := Now + 1/24;

    for i := 1 to sFile.count - 1 do begin
      currStr := trim(sFile[i]);

      if currStr <> '' then begin
        entryDict := getDictionaryFromEntry(currStr);

        ART := entryDict['1'];
        NAME := entryDict['2'];
        DOP_ART := entryDict['3'];
        C_TYPE := entryDict['4'];
        MD_NAME := entryDict['5'];
        OLD_PRICE := entryDict['6'];
        PRICE := entryDict['7'];

        if OLD_PRICE <> PRICE then begin
          ARTICULIDs := S.QueryRecordList(FIND_ARTICULID, MakeDictionary(['AR_ART', ART]));

          for z := 0 to ARTICULIDs.Count - 1 do begin
            ARTICULID := VarToStr(ARTICULIDs.Items[z].value['ARTICULID']);

            if not articulDict.Exists(ARTICULID) then begin
              articulDict.add(ARTICULID, MakeDictionary(['ART', ART, 'PRICE', PRICE]));
            end else begin
              if StrToFloat(articulDict[ARTICULID].Value['PRICE']) < StrToFloat(PRICE) then begin
                t := articulDict[ARTICULID];
                t.Value['PRICE'] := PRICE;
              end;
            end;
          end;
        end;
      end;
    end;

    for i := 0 to articulDict.Count - 1 do begin
      ART := articulDict[articulDict.Name[i]].Value['ART'];

      try
        RI := RP.Items.Add(S.OpenObject(IowArticul, StrToInt(articulDict.Name[i])));
      except
        visible := false;
        showMessage('Артикул "' + ART + '" (строка №' + intToStr(i + 2) + ') не найден в программе - переоценка не будет сформирована');
        break;
      end;

      try
        RI.Price := articulDict[articulDict.Name[i]].Value['PRICE'];
        RI.Apply;
      except
        visible := false;
        showMessage('На артикуле "' + ART + '" (строка №' + intToStr(i + 2) + ') стоит пустая цена - ' + #13 + 'переоценка не будет сформирована');
        break;
      end;
    end;

    if visible then begin
      ViewsUIService := ServiceProvider.GetService(IpubViewsUIService);
      ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);

      if not ViewsUIService.ActivateView('Reprices') then
        ViewsUIService.OpenView('Reprices', True)
      else
        ViewsUIService.RefreshActiveView;

      ObjectsUIService.EditObject(RP);
    end;
  end;
end;
