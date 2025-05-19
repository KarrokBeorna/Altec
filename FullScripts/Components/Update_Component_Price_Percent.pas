{
  * Данный скрипт работает по всем выделенным записям, увеличивая или уменьшая
  * закупочную цену компонентов на введённый процент. При нажатии на кнопку "ОК"
  * Вас перекинет на вкладку "Переоценка" и создастся новая переоценка,
  * куда попадут все выделенные артикулы.
  *
  * Поиск компонентов, у которых нужно обновить цену производится по артикулу.
  * Если одинаковые артикулы занесены в программу и имеют одинаковые цены, то
  * будет браться наибольшая цена, после чего умножаться на процент переоценки.
  * При необходимости можно заменить на поиск по доп. артикулу, наименованию
  * или же по всему сразу.
  *
  * Также при некорректном вводе новой цены, которая не будет числом, выведется
  * ошибка "Введите численное значение процентов (в том числе отрицательное)" и
  * переоценка не будет создана.
}

const
  FIND_ARTICULID = 'SELECT ARTICULID FROM VIRTARTICULES WHERE AR_ART = :AR_ART';

var
  S: IomSession;
  articulDict: IcmDictionary;
  ViewsUIService: IpubViewsUIService;
  ObjectsUIService: IpubObjectsUIService;
  RP: IowReprice;
  RI: IowRepriceItem;
  visible: Boolean = True;
  Form1: TForm;
  btnOk: TButton;
  procentPanel: TGroupBox;
  procent: TRichEdit;
  text: variant;


procedure updateComponents;
begin
  S := CreateObjectSession();

  REPRICENAME := 'Переоценка от ' + DateTimeToStr(Now) + ' (на ' + text + ' %)';
  REPRICENOTE := 'Переоценка, созданная с помощью скрипта, от ' + DateTimeToStr(Now) + ' (на ' + text + ' %)';

  RP := S.NewObject(IowReprice);
  RP.Name := REPRICENAME;
  RP.Comment := REPRICENOTE;
  RP.EffectDate := Now + 1/24;

  // Первый вариант обновления цен:
  // * Выгрузка всех найденных одинаковых артикулов,
  // * даже если они находятся в другой системе и не были выделены
  {articulDict := CreateDictionary;
  for i := 0 to SelectedRecords.count - 1 do begin
    ARTICULIDs := S.QueryRecordList(FIND_ARTICULID, MakeDictionary(['AR_ART', SelectedRecords[i].value['AR_ART']]));

    for z := 0 to ARTICULIDs.Count - 1 do begin
      ARTICULID := VarToStr(ARTICULIDs.Items[z].value['ARTICULID']);

      if not articulDict.Exists(ARTICULID) then begin
        articulDict.add(ARTICULID, MakeDictionary(['ART', SelectedRecords[i].value['AR_ART'], 'PRICE', SelectedRecords[i].value['PRICE']]));
      end else begin
        if StrToFloat(articulDict[ARTICULID].Value['PRICE']) < StrToFloat(SelectedRecords[i].value['PRICE']) then begin
          t := articulDict[ARTICULID];
          t.Value['PRICE'] := SelectedRecords[i].value['PRICE'];
        end;
      end;
    end;
  end;

  for i := 0 to articulDict.Count - 1 do begin
    ART := articulDict[articulDict.Name[i]].Value['ART'];
    RI := RP.Items.Add(S.OpenObject(IowArticul, StrToInt(articulDict.Name[i])));
    RI.Price := StrToFloat(articulDict[articulDict.Name[i]].Value['PRICE']) * (100 + StrToFloat(text)) / 100;
    RI.Apply;
  end;}

  for i := 0 to SelectedRecords.count - 1 do begin
    if not VarIsNull(SelectedRecords[i].value['PRICE']) then begin
      RI := RP.Items.Add(S.OpenObject(IowArticul, SelectedRecords[i].value['ARTICULID']));
      RI.Price := SelectedRecords[i].value['PRICE'] * (100 + StrToFloat(text)) / 100;
      RI.Apply;
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

procedure btnOkClicked(Sender: TOBject);
begin
  try
    if TRIM(procent.Lines.Text) <> '' then begin
      text := TRIM(procent.Lines.Text);
    end;
    Form1.close;
    updateComponents();
  except
    ShowMessage('Введите численное значение процентов (в том числе отрицательное)');
  end;
end;

begin
Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 205;
   Height := 120;
   caption := '% переоценки';
   position := poScreenCenter;
   BorderIcons := biSystemMenu;
 end;

procentPanel := TGroupBox.Create(Application);
 with procentPanel do begin
   Width := 180;
   Height := 40;
   Top := 2;
   Left := 5;
   caption := 'Введите % переоценки';
   Parent := Form1;
 end;

procent := TRichEdit.Create(Application);
 with procent do begin
   Left := 5;
   Top := 15;
   Width := 170;
   height := 20;
   Parent := procentPanel;
 end;

btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 25;
   Top := 50;
   Width := 140;
   Height := 25;
   Caption := 'Обновить';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;