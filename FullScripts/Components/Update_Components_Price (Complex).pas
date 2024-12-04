{
 * Это чудо нужно доделать, чтобы можно было импортировать цены практически с любого линейного прайс-листа
 *
 * Если так подумать, то нужно сначала парсить заголовки таблицы (само собой здесь предполагается, что одна ячейка
 * состоит ровно из одной ячейки, а не какие-то возможные склейки из Excel, поэтому что мы делаем первым делом? - правильно,
 * говорим клиентам переводить Excel в CSV любыми конвертерами, которые они найдут в интернете, главное,
 * чтобы они переводили в ANSI или Windows-1251, а в качестве разделителя был использован символ ";").
 *
 * По полученному списку заголовков необходимо показывать чекбокс и 6 строк с выпадающими списками:
 * |cb| Обязательное совпадение всех выборов
 * |1| - Артикул - первый выбор
 * |2| - Доп. артикул - второй выбор
 * |3| - Наименование - третий выбор
 * |cb| - Единица измерения - четвертый выбор
 * Цена - пятый выбор
 * |cb| - Группа переоценки - шестой выбор
 *
 * То есть вы должны поставить в соответствие с артикулом в программе столбец, полученный из таблицы и так далее.
 *
 * Поле для ввода в левой части будет выступать в роли поискового фильтра, и в нём нужно будет указать порядковый номер,
 * по которому необходимо найти соответствие в программе, например, сначала по артикулу, затем по доп. артикулу, а затем по наименованию.
 *
 * Чекбокс же будет указывать на обязательное совпадение всего: артикула, наименования и доп. артикула, если рядом с ними проставлены номера.
 *
 * Если не нашли подходящий артикул, то пропускаем его.
 *
 * Единицу измерения, соответственно, будем пытаться найти по сокращению, затем по наименованию.
 * Если единица измерения не нашлась, то артикул обновлять не будем, поэтому можно выключить данную функцию по чекбоксу.
 *
 * Цена - понятно, ожидаем число. Если число имеет больше 2 знаков после запятой, то округляем.
 *
 * Группа переоценки - ищем полное соответствие с именованием.
 * Если именование не нашли, то артикул пропускаем, поэтому можно выключить сооветствие по группе переоценки.
 *
 * Артикулы, которые не попали в переоценку будут переданы в новый CSV-файл, где
 * в новом последнем столбце будет указана причина, почему он попал в данный список,
 * чтобы вы смогли проверить, что не так с артикулом/группой переоценки/единицей измерения
 *
 * Поэтому общий совет:
 * ПЕРЕД ИСПОЛЬЗОВАНИЕМ СКРИПТА/КНОПКИ УБЕДИТЕСЬ, ЧТО У ВАС ПОЛНОСТЬЮ СОВПАДАЮТ
 * ЕДИНИЦЫ ИЗМЕРЕНИЯ И ГРУППЫ ПЕРЕОЦЕНОК В ПРОГРАММЕ И В CSV-ФАЙЛЕ
}

const
  UpdatePriceByART = 'INSERT INTO ARTPRICES (ARTICULID, PRICE, EFFECTDATE, USERID) VALUES (:ARTICULID, :PRICE, CURRENT_TIMESTAMP, :USERID)';
  UpdatePriceByART2 = 'INSERT INTO ARTPRICES (ARTICULID, PRICE, EFFECTDATE, USERID) SELECT ARTICULID, :PRICE, CURRENT_TIMESTAMP, :USERID FROM VIRTARTICULES WHERE AR_ART2 = :AR_ART2';

var
  Form1:TForm;
  btnOk: TButton;
  S: IomSession;
  vFileName, currStr: String;
  entryDict, title, AR_ARTs, AR_ART2s: IcmDictionary;
  titleReady: Boolean;
  globalPosibleTitles: IcmDictionaryList;
  titleIndex: Integer;

  sFile, errorEntries,
  s_DOP_ART, s_ART, s_NAME, s_C_TYPE, s_MD_NAME, s_PRICE, s_W_GRPRICE, s_GARBAGE,
  s_WEIGHT, s_OPT, s_BEAMLENGTH, s_VIRTUALITY, s_DEALER, s_STORAGE, s_TO_ORDER,
  s_MIN_ITEMS, s_OPT_ITEMS: TStringList;

  cb_DOP_ART, cb_ART, cb_NAME, cb_C_TYPE, cb_MD_NAME, cb_PRICE, cb_W_GRPRICE, cb_GARBAGE,
  cb_WEIGHT, cb_OPT, cb_BEAMLENGTH, cb_VIRTUALITY, cb_DEALER, cb_STORAGE, cb_TO_ORDER,
  cb_MIN_ITEMS, cb_OPT_ITEMS, cb_IGNORE_MD, cb_SAVE_FILE: TCheckBox;

procedure print(msg: variant);
begin
  showmessage(msg);
end;

procedure printDictionary(dict: IcmDictionary);
begin
  TEXT_P := '';

  for k := 0 to dict.count - 1 do begin
    name := dict.name[k];
    TEXT_P := TEXT_P + name + ' ' + dict.value[name] + #13;
  end;

  showmessage(TEXT_P);
end;

procedure getAllVirtarticules;
var
  allVirtarticules: IcmDictionaryList;
begin
  allVirtarticules := S.QueryRecordList('SELECT DISTINCT AR_ART, COALESCE(TRIM(AR_ART2), '''') as AR_ART2, MD_NAME FROM VIRTARTICULES VA JOIN DOPMEASURE DM ON DM.DOPMEASUREID = VA.DOPMEASUREID', empty);

  AR_ARTs := CreateDictionary;
  AR_ART2s := CreateDictionary;
  count := allVirtarticules.count - 1;
  for i := 0 to count do begin
    elem := allVirtarticules[i];
    AR_ARTs.add(trim(elem.value['AR_ART']), elem.value['MD_NAME']);
    AR_ART2s.add(trim(elem.value['AR_ART2']), elem.value['MD_NAME']);
  end;
end;

procedure initErrorEntries;
begin
  errorEntries := TStringList.Create;
  titleStr := 'Номер строки; Причина';

  for j := 0 to title.count - 1 do begin
    titleStr := titleStr + ';' + title.name[j];
  end;

  errorEntries.add(titleStr);
end;

procedure addToDictionaryList(cb: TCheckBox; titles: TStringList);
begin
  tempDict := CreateDictionary;
  tempDict.add('CHECKBOX', cb);
  tempDict.add('TITLES', titles);
  globalPosibleTitles.add(tempDict);
end;

procedure initPosibleTitle;
begin
  globalPosibleTitles := CreateDictionaryList;

  s_DOP_ART :=    TStringList.Create; s_DOP_ART.add('Доп. артикул'); s_DOP_ART.add('Доп артикул'); s_DOP_ART.add('Дополнительный артикул'); s_DOP_ART.add('Доп.артикул'); addToDictionaryList(cb_DOP_ART, s_DOP_ART);
  s_ART :=        TStringList.Create; s_ART.add('Артикул');                                                                                              addToDictionaryList(cb_ART, s_ART);
  s_NAME :=       TStringList.Create; s_NAME.add('Наименование'); s_NAME.add('Название');                                                                addToDictionaryList(cb_NAME, s_NAME);
  s_C_TYPE :=     TStringList.Create; s_C_TYPE.add('Тип компонента'); s_C_TYPE.add('Тип');                                                               addToDictionaryList(cb_C_TYPE, s_C_TYPE);
  s_MD_NAME :=    TStringList.Create; s_MD_NAME.add('Ед. изм.'); s_MD_NAME.add('Ед.'); s_MD_NAME.add('Ед изм');                                          addToDictionaryList(cb_MD_NAME, s_MD_NAME);
  s_PRICE :=      TStringList.Create; s_PRICE.add('Цена'); s_PRICE.add('Стоимость');                                                                     addToDictionaryList(cb_PRICE, s_PRICE);
  s_W_GRPRICE :=  TStringList.Create; s_W_GRPRICE.add('Группа переоценки'); s_W_GRPRICE.add('Группа'); s_W_GRPRICE.add('Валюта');                        addToDictionaryList(cb_W_GRPRICE, s_W_GRPRICE);
  s_GARBAGE :=    TStringList.Create; s_GARBAGE.add('% отхода'); s_GARBAGE.add('Процент отхода'); s_GARBAGE.add('Отход');                                addToDictionaryList(cb_GARBAGE, s_GARBAGE);
  s_WEIGHT :=     TStringList.Create; s_WEIGHT.add('Удельный вес, г'); s_WEIGHT.add('Вес'); s_WEIGHT.add('Удельный вес');                                addToDictionaryList(cb_WEIGHT, s_WEIGHT);
  s_OPT :=        TStringList.Create; s_OPT.add('Группа оптимизации'); s_OPT.add('Оптимизация');                                                         addToDictionaryList(cb_OPT, s_OPT);
  s_BEAMLENGTH := TStringList.Create; s_BEAMLENGTH.add('Длина хлыста'); s_BEAMLENGTH.add('Хлыст'); s_BEAMLENGTH.add('Длина');                            addToDictionaryList(cb_BEAMLENGTH, s_BEAMLENGTH);
  s_VIRTUALITY := TStringList.Create; s_VIRTUALITY.add('Виртуальный');                                                                                   addToDictionaryList(cb_VIRTUALITY, s_VIRTUALITY);
  s_DEALER :=     TStringList.Create; s_DEALER.add('Сохранять у дилера'); s_DEALER.add('Дилер');                                                         addToDictionaryList(cb_DEALER, s_DEALER);
  s_STORAGE :=    TStringList.Create; s_STORAGE.add('Использовать на складе'); s_STORAGE.add('Склад');                                                   addToDictionaryList(cb_STORAGE, s_STORAGE);
  s_TO_ORDER :=   TStringList.Create; s_TO_ORDER.add('Под заказ');                                                                                       addToDictionaryList(cb_TO_ORDER, s_TO_ORDER);
  s_MIN_ITEMS :=  TStringList.Create; s_MIN_ITEMS.add('Мин. кол-во на складе'); s_MIN_ITEMS.add('Мин кол-во на складе'); s_MIN_ITEMS.add('Мин. кол-во'); addToDictionaryList(cb_MIN_ITEMS, s_MIN_ITEMS);
  s_OPT_ITEMS :=  TStringList.Create; s_OPT_ITEMS.add('Опт. кол-во на складе'); s_OPT_ITEMS.add('Опт кол-во на складе'); s_OPT_ITEMS.add('Опт. кол-во'); addToDictionaryList(cb_OPT_ITEMS, s_OPT_ITEMS);
end;

function readTitle(str: string): IcmDictionary;
var
  dict: IcmDictionary;
begin
  dict := CreateDictionary;
  index := 0;
  str := str + ';';

  while str <> '' do begin
    value := Copy(str, 1, Pos(';', str) - 1);
    DeleteStr(str, 1, Pos(';', str));

    for z := 0 to globalPosibleTitles.count - 1 do begin
      if globalPosibleTitles[z].value['TITLES'].indexOf(trim(value)) <> -1 then begin
        dict.Add(trim(value), intToStr(index));
        globalPosibleTitles[z].value['CHECKBOX'].enabled := True;
        break;
      end;
    end;

    index := index + 1;
  end;

  Result := dict;
end;

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
    titleValue := title.name[index];
    dict.Add(LowerCase(titleValue), trim(value));
    index := index + 1;
  end;

  Result := dict;
end;

function getValue(posibleNames: TStringList): Variant;
begin
  value := '';

  for m := 0 to posibleNames.count - 1 do begin
    if title.exists(LowerCase(posibleNames[m])) then
      value := entryDict.value[LowerCase(posibleNames[m])]
  end;

  Result := value;
end;

function findEntryIfExists(index: integer; AR_ART, AR_ART2, MD: variant): Integer;
begin
  temp := 0;
  reason := '';
  print(AR_ART + ' ' + AR_ART2 + ' ' + MD);
  if (trim(AR_ART2) <> '') and (AR_ART2s.exists(AR_ART2)) then begin
    if (MD = AR_ART2s.value(AR_ART2)) or (cb_IGNORE_MD.checked) then
      temp := 2
    else
      reason := ';Единица измерения не совпадает в программе и в таблице;';
  end else if (trim(AR_ART) <> '') and (AR_ARTs.exists(AR_ART)) then begin
    if (MD = AR_ARTs.value(AR_ART)) or (cb_IGNORE_MD.checked) then
      temp := 1
    else
      reason := ';Единица измерения не совпадает в программе и в таблице;';
  end else reason := ';Элемент не найден ни по доп. артикулу, ни по основному артикулу;';

  if temp = 0 then errorEntries.add(intToStr(index + 1) + reason + currStr);

  Result := temp;
end;

procedure updateEntrySQL(index: Integer; PRICE, ART, DOP_ART: String = '');
begin
  try
    if DOP_ART <> '' then
      S.ExecSQL(UpdatePriceByART2, MakeDictionary([
        'PRICE', strToFloat(PRICE),
        'AR_ART2', DOP_ART,
        'USERID', UserContext.UserID]))
    else
      S.ExecSQL(UpdatePriceByART, MakeDictionary([
        'PRICE', strToInt(PRICE),
        'ARTICULID', ART,
        'USERID', ]));
  except
    reason := ';Ошибка во время обновления таблиц;';
    errorEntries.add(intToStr(index + 1) + reason + currStr);
  end;
end;

procedure btnOkClicked;
begin
  for i := titleIndex to sFile.count - 1 do begin
    currStr := UTF8ToAnsi(sFile[i]);
    if currStr <> '' then begin
      entryDict := getDictionaryFromEntry(currStr);

      IF cb_DOP_ART.checked then DOP_ART := getValue(s_DOP_ART) else DOP_ART := '';
      IF cb_ART.checked then ART := getValue(s_ART) else ART := '';
      IF cb_NAME.checked then NAME := getValue(s_NAME) else NAME := '';
      IF cb_C_TYPE.checked then C_TYPE := getValue(s_C_TYPE) else C_TYPE := '';
      IF cb_MD_NAME.checked then MD_NAME := getValue(s_MD_NAME) else MD_NAME := '';
      IF cb_PRICE.checked then PRICE := getValue(s_PRICE) else PRICE := '';
      IF cb_W_GRPRICE.checked then W_GRPRICE := getValue(s_W_GRPRICE) else W_GRPRICE := '';
      IF cb_GARBAGE.checked then GARBAGE := getValue(s_GARBAGE) else GARBAGE := '';
      IF cb_WEIGHT.checked then WEIGHT := getValue(s_WEIGHT) else WEIGHT := '';
      IF cb_OPT.checked then OPT := getValue(s_OPT) else OPT := '';
      IF cb_BEAMLENGTH.checked then BEAMLENGTH := getValue(s_BEAMLENGTH) else BEAMLENGTH := '';
      IF cb_VIRTUALITY.checked then VIRTUALITY := getValue(s_VIRTUALITY) else VIRTUALITY := '';
      IF cb_DEALER.checked then DEALER := getValue(s_DEALER) else DEALER := '';
      IF cb_STORAGE.checked then STORAGE := getValue(s_STORAGE) else STORAGE := '';
      IF cb_TO_ORDER.checked then TO_ORDER := getValue(s_TO_ORDER) else TO_ORDER := '';
      IF cb_MIN_ITEMS.checked then MIN_ITEMS := getValue(s_MIN_ITEMS) else MIN_ITEMS := '';
      IF cb_OPT_ITEMS.checked then OPT_ITEMS := getValue(s_OPT_ITEMS) else OPT_ITEMS := '';

      artExists := findEntryIfExists(i, ART, DOP_ART, MD_NAME);

      if artExists = 2 then
        UpdateEntrySQL(i, PRICE, '', DOP_ART)
      else if artExists = 1 then
        UpdateEntrySQL(i, PRICE, ART, '');



      // Здесь еще нужно будет делать селекты по некоторым полученным полям, так как нужны ID
      // и затем обновлять не только цены, но и остальные поля

    end;
  end;
  if cb_SAVE_FILE.checked then begin
    errorFilepath := copy(vFileName, 0, length(vFileName) - 4) + '_error.csv';
    errorEntries.SaveToFile(errorFilepath);
    errorEntries.Free;
    print('Файл с ошибками сохранён по пути: ' + errorFilepath);
  end;
  S.Commit;
  Form1.close;
end;

procedure createModal;
begin
Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 300;
   Height := 500;
   caption := 'Обновление компонентов';
   position := poScreenCenter;
 end;

  for c := 0 to globalPosibleTitles.count - 1 do begin
    pair := globalPosibleTitles[c];
    pairCb := globalPosibleTitles[c].value['CHECKBOX'];
    pairTitles := globalPosibleTitles[c].value['TITLES'];

    pairCb := TCheckBox.Create(Application);
      with pairCb do begin
        Left := 10;
        Top := 5 + 20 * c;
        Width := 250;
        Caption := pairTitles.strings[0];
        Enabled := False;
        Parent := Form1;
      end;

    globalPosibleTitles[c]['CHECKBOX'] := pairCb;
  end;

cb_IGNORE_MD := TCheckBox.Create(Application);
 with cb_IGNORE_MD do begin
   Left := 10;
   Top := 375;
   Width := 250;
   Caption := 'Игнорировать разницу в единицах измерения';
   Parent := Form1;
 end;

cb_SAVE_FILE := TCheckBox.Create(Application);
 with cb_SAVE_FILE do begin
   Left := 10;
   Top := 395;
   Width := 250;
   Caption := 'Сохранить файл с ошибками';
   Checked := True;
   Parent := Form1;
 end;

btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 10;
   Top := 425;
   Width := 265;
   Height := 30;
   Caption := 'Обновить компоненты';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;
end;


begin
  if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите файл!', 'C:\', false) then begin
    S := CreateObjectSession();
    getAllVirtarticules();
    sFile := TStringList.Create;
    sFile.LoadFromFile(vFileName);
    initPosibleTitle();
    createModal();
    titleIndex := 0;

    while not titleReady do begin
      currStr := UTF8ToAnsi(sFile[titleIndex]);
      titleIndex := titleIndex + 1;
      if currStr <> '' then begin
        title := readTitle(currStr);
        titleReady := true;
        initErrorEntries();
        if Form1.ShowModal = mrOk then Form1.Show;
      end;
    end;
  end;
end;
