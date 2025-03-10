{
  * В файле, полученном после использования кнопки "Выгрузка компонентов в CSV-файл",
  * обновляем цены в 9-11 столбцах.
  *
  * Затем запускаем данных скрипт, выбираем файл с новыми ценами.
  * Если название файла совпадает с каким-либо уже созданным прайс-листом, то
  * обновляться будет именно он. Внутри этого прайс-листа будет производиться
  * поиск по всем добавленным элементам:
  * 1) Если нашли артикул, то обновляем его цены
  * 2) Если артикул не нашли, то добавляем его в прайс-лист и выставляем цены
  * 3) Если артикул был в прайс-листе, но не требуется обновление, то он просто останется там дальше существовать с прежними ценами
  *
  * Если название файла не совпадает ни с одним наименование прайс-листа, то
  * создаётся новый прайс, появляются окна с выбором единицы измерения и палитры,
  * после чего в цены добавляются все компоненты с их ценами за покрытия.
}

const
  FIND_ARTICULID = 'SELECT ARTICULID FROM VIRTARTICULES WHERE AR_ART = :AR_ART';
  FIND_PRICELISTID = 'SELECT ID FROM COATING_PRICES WHERE NAME = :NAME';

var
  ObjectsUIService: IpubObjectsUIService;
  ViewsUIService: IpubViewsUIService;
  S: IomSession;
  M: IowMeasureUnit;
  PriceList: IowCoatingPrice;
  BaseValue: IowCoatingPriceBaseValue;
  Palette: IowCoatingPalette;
  sFile: TStringList;
  entryDict, articulDict: IcmDictionary;
  ArtO: IowArticul;
  visible: Boolean = True;
  PLID, count: Integer;
  RealFileName, vFileName: String;

function getDictionaryFromEntry(str: string): IcmDictionary;
var
  dict: IcmDictionary;
begin
  dict := CreateDictionary;
  index := 0;
  str := str + ';';

  while str <> '' do
  begin
    value := Copy(str, 1, Pos(';', str) - 1);
    DeleteStr(str, 1, Pos(';', str));
    dict.Add(intToStr(index), value);
    index := index + 1;
  end;

  Result := dict;
end;

begin
  S := CreateObjectSession;

  if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите файл', 'C:\', false) then begin
    sFile := TStringList.Create;
    ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
    articulDict := CreateDictionary;

    RealFileName := ExtractFileName(vFileName);
    PLID := S.QueryValue(FIND_PRICELISTID, MakeDictionary(['NAME', copy(RealFileName, 0, length(RealFileName) - 4)]));
    if PLID = 0 then begin
      M := ObjectsUIService.SelectObject('IowMeasureUnit');
      Palette := ObjectsUIService.SelectObject('IowCoatingPalette');
      PriceList := S.NewDocument('IowCoatingPrice');
      PriceList.Name := copy(RealFileName, 0, length(RealFileName) - 4);
      PriceList.Measure := M;
      PriceList.Palettes.Add(Palette).Apply();
      PriceList.Active := True;
    end else begin
      PriceList := S.OpenDocumentByKey('IowCoatingPrice', PLID);
      PriceList.Take;
    end;

    sFile.LoadFromFile(vFileName);
    for i := 1 to sFile.count - 1 do begin // со второй строки, так как на первой заголовки
      currStr := trim(sFile[i]);

      if currStr <> '' then begin
        entryDict := getDictionaryFromEntry(currStr);
        ART := entryDict['1'];
        OUTPRICE := entryDict['8'];
        INPRICE := entryDict['9'];
        DOUBLEPRICE := entryDict['10'];

        ARTICULIDs := S.QueryRecordList(FIND_ARTICULID, MakeDictionary(['AR_ART', ART]));

        for z := 0 to ARTICULIDs.Count - 1 do begin
          ARTICULID := VarToStr(ARTICULIDs.Items[z].value['ARTICULID']);

          if not articulDict.Exists(ARTICULID) then begin
            articulDict.add(ARTICULID, MakeDictionary(['ART', ART, 'INPRICE', INPRICE, 'OUTPRICE', OUTPRICE, 'DOUBLEPRICE', DOUBLEPRICE]));
          end else begin
            if StrToFloat(articulDict[ARTICULID].Value['INPRICE']) < StrToFloat(INPRICE) then begin
              t := articulDict[ARTICULID];
              t.Value['INPRICE'] := INPRICE;
            end;
            if StrToFloat(articulDict[ARTICULID].Value['OUTPRICE']) < StrToFloat(OUTPRICE) then begin
              t := articulDict[ARTICULID];
              t.Value['OUTPRICE'] := OUTPRICE;
            end;
            if StrToFloat(articulDict[ARTICULID].Value['DOUBLEPRICE']) < StrToFloat(DOUBLEPRICE) then begin
              t := articulDict[ARTICULID];
              t.Value['DOUBLEPRICE'] := DOUBLEPRICE;
            end;
          end;
        end;
      end;
    end;

    for i := 0 to articulDict.Count - 1 do begin
      ArtO := S.OpenObject(IowArticul, StrToInt(articulDict.Name[i]));

      if PLID <> 0 then begin
        count := PriceList.BaseValues.Count - 1;
        j := 0;
        while j <= count do begin
          if ArtO.Key = PriceList.BaseValues[j].Articul.Key then begin
            PriceList.BaseValues.Delete(PriceList.BaseValues[j]);
            count := count - 1;
          end else begin
            j := j + 1;
          end;
        end;
      end;

      try
        BaseValue := PriceList.BaseValues.Add(ArtO);
        BaseValue.InnerPrice := articulDict[articulDict.Name[i]].Value['INPRICE'];
        BaseValue.OuterPrice := articulDict[articulDict.Name[i]].Value['OUTPRICE'];
        BaseValue.BothPrice := articulDict[articulDict.Name[i]].Value['DOUBLEPRICE'];
        BaseValue.Apply;
      except
        visible := false;
        RaiseException('Артикул "' + ArtO.Marking + '". Ошибка во время установки цен - прайс-лист не может быть создан/обновлён');
      end;
    end;

    if visible then begin
      ObjectsUIService.EditObject(PriceList);
    end;
  end else showmessage('Файл не выбран');
end;
