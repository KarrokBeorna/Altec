const
  UPDATE_PRICE = 'INSERT INTO ARTPRICES (ARTICULID, PRICE, EFFECTDATE) VALUES (:ARTICULID, :PRICE, CURRENT_TIMESTAMP)';

var
  Form1: TForm;
  btnOk: TButton;
  PricePanel: TGroupBox;
  Price: TRichEdit;
  Session: IomSession;
  PriceValue: Variant;

procedure btnOkClicked(Sender: TOBject);
begin
  Session := CreateObjectSession;

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      if TRIM(Price.Lines.Text) <> '' then
        PriceValue := Price.Lines.Text
      else
        PriceValue := Null;

      Session.ExecSQL(UPDATE_PRICE, MakeDictionary(['ARTICULID', SelectedRecords.Items[i]['ARTICULID'], 'PRICE', PriceValue]));
    end;
    Session.Commit;
    Form1.close;
  except
    Session.Rollback;
    ShowMessage('Введите численное значение цены');
  end;
end;

begin

  Form1 := TForm.Create(Application);
  with Form1 do begin
    Width := 205;
    Height := 120;
    caption := 'Обновление закупочной цены';
    position := poScreenCenter;
    BorderIcons := biSystemMenu;
  end;

  PricePanel := TGroupBox.Create(Application);
  with PricePanel do begin
    Width := 180;
    Height := 40;
    Top := 2;
    Left := 5;
    caption := 'Введите цену';
    Parent := Form1;
  end;

  Price := TRichEdit.Create(Application);
  with Price do begin
    Left := 5;
    Top := 15;
    Width := 170;
    height := 20;
    Parent := PricePanel;
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
