{
  * Позволяет вручную менять дату и время создания заказа, которые можно выбрать
  * в выпадающих списках. Часы ограничены выбором между 6 и 20 часами.
  * А минуты только ":00" и ":30"
}

const
  UPDATE_ORDERS = 'UPDATE ORDERS SET DATECREATED = :DATECREATED WHERE ID = :ID';

var
  Form1: TForm;
  btnOk: TButton;
  Session: IomSession;
  date: TDateTimePicker;
  time: TComboBox;
  timeStrings: TStringList;

procedure btnOkClicked(Sender: TOBject);
begin
  Session := CreateObjectSession;

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      Session.ExecSQL(UPDATE_ORDERS, MakeDictionary(['ID', SelectedRecords.Items[i]['ID'],
                                                     'DATECREATED', StrToDateTime(Copy(dateTimeToStr(date.time), 0, 11) + time.text + ':00')]));
    end;
    Session.Commit;
    Form1.close;
  except
    Session.Rollback;
  end;
end;

begin
  timeStrings := TStringList.Create();

  for i := 6 to 20 do begin
    timeStrings.add(IntToStr(i) + ':00');
    timeStrings.add(IntToStr(i) + ':30');
  end;

  Form1 := TForm.Create(Application);
  with Form1 do begin
    Width := 235;
    Height := 120;
    caption := 'Изменение даты создания заказа';
    position := poScreenCenter;
    BorderIcons := biSystemMenu;
  end;

  date := TDateTimePicker.Create(Application);
  with date do begin
    Left := 10;
    Top := 10;
    Width := 100;
    Parent := Form1;
  end;

  time := TComboBox.Create(Application);
  with time do begin
    Left := 115;
    Top := 10;
    Width := 95;
    Text := '8:00';
    Parent := Form1;
    items := timeStrings;
  end;

  btnOk := TButton.Create(Application);
  with btnOk do begin
    Left := 10;
    Top := 45;
    Width := 200;
    Height := 30;
    Caption := 'Изменить дату создания';
    Parent := Form1;
    onClick := @btnOkClicked;
  end;

  if Form1.ShowModal = mrOk then Form1.Show;
end;
