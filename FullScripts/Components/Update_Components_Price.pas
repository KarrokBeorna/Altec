const
  FIND_ARTICULID = 'SELECT ARTICULID FROM VIRTARTICULES WHERE AR_ART = :AR_ART';

var
  S: IomSession;
  vFileName, currStr: String;
  entryDict: IcmDictionary;
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

        ART := entryDict['0'];
        NAME := entryDict['1'];
        DOP_ART := entryDict['2'];
        C_TYPE := entryDict['3'];
        MD_NAME := entryDict['4'];
        OLD_PRICE := entryDict['5'];
        PRICE := entryDict['6'];

        if OLD_PRICE <> PRICE then begin
          ARTICULIDs := S.QueryRecordList(FIND_ARTICULID, MakeDictionary([
            'AR_ART', ART
          ]));

          for z := 0 to ARTICULIDs.Count - 1 do begin
            ARTICULID := ARTICULIDs.Items[z].value['ARTICULID'];

            try
              RI := RP.Items.Add(S.OpenObject(IowArticul, ARTICULID));
            except
              visible := false;
              showMessage('Артикул "' + ART + '" (строка №' + intToStr(i + 1) + ') не найден в программе - переоценка не будет сформирована');
              break;
            end;

            try
              RI.Price := PRICE;
              RI.Apply;
            except
              visible := false;
              showMessage('На артикуле "' + ART + '" (строка №' + intToStr(i + 1) + ') стоит пустая цена - ' + #13 + 'переоценка не будет сформирована');
              break;
            end;
          end;
        end;
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
