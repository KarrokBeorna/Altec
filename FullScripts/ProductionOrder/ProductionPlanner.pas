const
  CHECK_COMPLEX_GLASS = 'SELECT                                                       ' + #13#10 +
                        '  *                                                          ' + #13#10 +
                        'FROM                                                         ' + #13#10 +
                        '  PRODUCTION_ORDERS PO                                       ' + #13#10 +
                        '    JOIN ORDERS_ITEMS OI ON OI.ORDERID = PO.ORDERID          ' + #13#10 +
                        '    JOIN ORDERS_ITEMS_UNITS OIU ON OIU.ORDERITEMID = OI.ID   ' + #13#10 +
                        'WHERE                                                        ' + #13#10 +
                        '  PO.ID = :ID AND                                            ' + #13#10 +
                        '  (OIU.GEOMETRYTYPEID > 0 OR OIU.SHPROSSID IS NOT NULL)';

var
  Form1: TForm;
  btnOk: TButton;
  datePicker: TDateTimePicker;
  labelStart: TLabel;
  dictList: IcmDictionaryList;
  dur_purch, dur_prepare, dur_binding, dur_hard_glass: Integer;
  Glass : IowOrderItemCalculatedGlass;

// См. Instance.StatusList - статусы текущего заказа

procedure SetProductionDate(Sender: TOBject);
begin
  for i := 0 to Instance.StatusList.Count - 1 do begin
    if Instance.StatusList.Items[i].OrderStatus.Name = 'Планирование изготовления' then begin
      Instance.StatusList.Items[i].Done := True;
      Instance.StatusList.Items[i].apply;
    end;

    for j := 0 to dictList.Count - 1 do begin
      if Instance.StatusList.Items[i].OrderStatus.Name = dictList.Items[j].Value['panel'].Caption then begin
        if dictList.Items[j].Value['cb'].checked then begin
          numOfWorkDays := 0;
          day := 0;
          while numOfWorkDays <> StrToInt(dictList.Items[j].Value['shift'].text) do begin
            day := day + 1;
            if (DayOfWeek(datePicker.date + Day) <> 1) and (DayOfWeek(datePicker.date + Day) <> 7) then numOfWorkDays := numOfWorkDays + 1;
          end;
          Instance.StatusList.Items[i].PlanDate := StrToDate(Copy(DateTimeToStr(datePicker.date + Day), 0, 10));
          Instance.StatusList.Items[i].apply;
        end;
      end;
    end;
  end;

  if (dictList.items[0].value['duration'].text <> '') and (dictList.items[0].value['cb'].checked) then SetDatabaseVariable('dur_purch', StrToInt(dictList.items[0].value['duration'].text));
  if (dictList.items[1].value['duration'].text <> '') and (dictList.items[1].value['cb'].checked) then SetDatabaseVariable('dur_prepare', StrToInt(dictList.items[1].value['duration'].text));
  if (dictList.items[2].value['duration'].text <> '') and (dictList.items[2].value['cb'].checked) then SetDatabaseVariable('dur_binding', StrToInt(dictList.items[2].value['duration'].text));
  if (dictList.items[3].value['duration'].text <> '') and (dictList.items[3].value['cb'].checked) then SetDatabaseVariable('dur_hard_glass', StrToInt(dictList.items[3].value['duration'].text));
  Form1.close;

  for i := 0 to Instance.Items.Count - 1 do begin
    for j := 0 to Instance.StatusList.Count - 1 do begin
      if VarToStr(Instance.StatusList.Items[j].PlanDate) <> '' then begin
        if (Instance.StatusList.Items[j].Key = 2) and ((Instance.Items[i].Type.Name = 'Окно') or
                                                       (Instance.Items[i].Type.Name = 'Соединитель') or
                                                       (Instance.Items[i].Type.Name = 'Сэндвич') or
                                                       (Instance.Items[i].Type.Name = 'Москитная сетка')) then begin
          Instance.Items[i].JobDate := Instance.StatusList.Items[j].PlanDate;
          Instance.Items[i].Apply;
        end;

        if (Instance.StatusList.Items[j].Key = 3025) and (Instance.Items[i].Type.Name = 'Стеклопакет') then begin
          Glass := Instance.Items[i].OrderUnit;

          if (Glass.GeometryType.Key <> 0) OR (Glass.ShprossChamberIndex > -1) then begin
            Instance.Items[i].JobDate := Instance.StatusList.Items[j].PlanDate;
            Instance.Items[i].Apply;
          end;
        end;

        if (Instance.StatusList.Items[j].Key = 3026) and (Instance.Items[i].Type.Name = 'Набор') then begin
          Instance.Items[i].JobDate := Instance.StatusList.Items[j].PlanDate;
          Instance.Items[i].Apply;
        end;

        if (Instance.StatusList.Items[j].Key = 3027) and (Instance.Items[i].Type.Name = 'Комплект') then begin
          Instance.Items[i].JobDate := Instance.StatusList.Items[j].PlanDate;
          Instance.Items[i].Apply;
        end;

        if (Instance.StatusList.Items[j].Key = 8) and (Instance.Items[i].Type.Name = 'Арка') then begin
          Instance.Items[i].JobDate := Instance.StatusList.Items[j].PlanDate;
          Instance.Items[i].Apply;
        end;
      end;
    end;
  end;
end;

procedure cbClicked(Sender: TOBject);
begin
  ind := TCheckBox(Sender).Tag;
  if TCheckBox(Sender).checked then begin
    dictList.items[ind].value['panel'].font.color := clNone;
    dictList.items[ind].value['panel'].enabled := True;
  end else begin
    dictList.items[ind].value['panel'].font.color := clGray;
    dictList.items[ind].value['panel'].enabled := False;
  end;
end;

procedure CreatePanel(index, offset, dur, leftV, topV: Integer; panelName: String);
var
  panel: TGroupBox;
  cb: TCheckBox;
  labelShift, labelDuration: TLabel;
  shift, duration: TEdit;
  dict: IcmDictionary;
begin
  panel := TGroupBox.Create(Application);
  with panel do begin
    if leftV = 5 then Width := 240 else Width := 225;
    Height := 45;
    Top := topV;
    Left := leftV;
    caption := panelName;
    Parent := Form1;
  end;

  cb := TCheckBox.Create(Application);
  with cb do begin
    Left := 10;
    Top := 20;
    checked := True;
    tag := index;
    onClick := @cbClicked;
    Parent := panel;
  end;

  labelShift := TLabel.Create(Application);
  with labelShift do begin
    Left := cb.Left + 30;
    Top := 20;
    Width := 20;
    Caption := 'Сдвиг:';
    Parent := panel;
  end;

  shift := TEdit.Create(Application);
  with shift do begin
    Left := labelShift.Left + 40;
    Top := 18;
    Width := 30;
    text := varToStr(offset);
    Parent := panel;
  end;

  dict := CreateDictionary();
  dict.add('panel', panel);
  dict.add('cb', cb);
  dict.add('shift', shift);

  if (leftV = 5) then begin
    labelDuration := TLabel.Create(Application);
    with labelDuration do begin
      Left := shift.Left + 40;
      Top := 20;
      Width := 20;
      Caption := 'Длительность:';
      Parent := panel;
    end;

    duration := TEdit.Create(Application);
    with duration do begin
      Left := labelDuration.Left + 80;
      Top := 18;
      Width := 30;
      text := varToStr(dur);
      Parent := panel;
    end;

    dict.add('duration', duration);
  end;

  dictList.add(dict);
end;

procedure disablePanel(index: Integer);
begin
  dictList.items[index].value['panel'].enabled := false;
  dictList.items[index].value['panel'].font.color := clGray;
  dictList.items[index].value['cb'].visible := false;
  dictList.items[index].value['cb'].checked := false;
  dictList.items[index].value['shift'].text := '';
  dictList.items[index].value['duration'].text := '';
end;

begin
  dictList := CreateDictionaryList();

  dur_purch := GetDatabaseVariable('dur_purch', 5);
  dur_prepare := GetDatabaseVariable('dur_prepare', 5);
  dur_binding := GetDatabaseVariable('dur_binding', 3);
  dur_hard_glass := GetDatabaseVariable('dur_hard_glass', 20);

  offset_binding := 1;
  if Instance.MaterialsPreparation then begin
    offset_binding := 1 + dur_prepare;
  end;

  Form1 := TForm.Create(Application);
  with Form1 do begin
    Width := 495;
    Height := 306;
    caption := 'Планирование сроков изготовления';
    position := poScreenCenter;
    BorderIcons := biSystemMenu;
  end;

  labelStart := TLabel.Create(Application);
  with labelStart do begin
    Left := 30;
    Top := 20;
    Width := 50;
    Caption := 'Дата запуска:';
    Parent := Form1;
  end;

  datePicker := TDateTimePicker.Create(Application);
  with datePicker do begin
    Left := 105;
    Top := 17;
    Width := 100;
    Parent := Form1;
  end;

  CreatePanel(0, 1, dur_purch, 5, 5 + 45 * 1, 'Закупка материалов (редких)');
  CreatePanel(1, 1, dur_prepare, 5, 5 + 45 * 2, 'Подготовка материалов (профиля)');
  CreatePanel(2, offset_binding, dur_binding, 5, 5 + 45 * 3, 'Гибка профиля');
  CreatePanel(3, 1, dur_hard_glass, 5, 5 + 45 * 4, 'Заказ сложных стеклопакетов');
  CreatePanel(4, 1, 0, 250, 5 + 45 * 0, 'Формирование производственной группы');
  CreatePanel(5, 1, 0, 250, 5 + 45 * 1, 'Изготовление');
  CreatePanel(6, 1, 0, 250, 5 + 45 * 2, 'Дополнения (заказ)');
  CreatePanel(7, 1, 0, 250, 5 + 45 * 3, 'Комплектация (сборка заказа)');
  CreatePanel(8, 1, 0, 250, 5 + 45 * 4, 'Отгрузка');

  if not Instance.OnDemandMaterials then begin
    disablePanel(0);
  end;

  if not Instance.MaterialsPreparation then begin
    disablePanel(1);
  end;

  arcsEnabled := False;
  for i := 0 to Instance.Items.Count - 1 do begin
    if Instance.Items.Items[i].Type.Name = 'Арка' then begin
      arcsEnabled := True;
      break;
    end;
  end;

  if not arcsEnabled then begin
    disablePanel(2);
  end;

  complexGlass := False;
  if Instance.Session.QueryRecordList(CHECK_COMPLEX_GLASS, MakeDictionary(['ID', Instance.Key])).Count > 0 then complexGlass := True;

  if not complexGlass then begin
    disablePanel(3);
  end;

  numOfDays := 1;
  if (numOfDays < dur_purch + 1) and Instance.OnDemandMaterials then numOfDays := 1 + dur_purch;
  if (numOfDays < dur_binding + 1) and arcsEnabled then numOfDays := 1 + dur_binding;
  if (numOfDays < dur_prepare + 1) and Instance.MaterialsPreparation then numOfDays := 1 + dur_prepare;
  if (numOfDays < dur_binding + dur_prepare + 1) and arcsEnabled and Instance.MaterialsPreparation then numOfDays := 1 + dur_binding + dur_prepare;
  if (numOfDays < dur_hard_glass + 1) and complexGlass then numOfDays := 1 + dur_hard_glass;

  dictList.items[4].value['shift'].text := varToStr(numOfDays);
  dictList.items[5].value['shift'].text := varToStr(numOfDays);
  dictList.items[6].value['shift'].text := varToStr(numOfDays);
  dictList.items[7].value['shift'].text := varToStr(numOfDays);
  dictList.items[8].value['shift'].text := varToStr(numOfDays + 1);

  btnOk := TButton.Create(Application);
  with btnOk do begin
    Left := 140;
    Top := dictList.items[8].value['panel'].Top + 48;
    Width := 200;
    Height := 30;
    Caption := 'Установить плановые даты';
    Parent := Form1;
    onClick := @SetProductionDate;
  end;

  if Form1.ShowModal = mrOk then Form1.Show;
end;
