{
  * Скрипт позволяет обновлять цены на покрытия у выделенных компонентов
  * в прайс-листе. Для всех будет проставлена одинаковая цена за внешнее,
  * внутреннее и двустороннее покрытия.
}

var
  Form1: TForm;
  btnOk: TButton;
  pricePanelOuter, pricePanelInner, pricePanelDouble: TGroupBox;
  priceOuter, priceInner, priceDouble: TEdit;
  item: IowCoatingPriceBaseValue;

procedure btnOkClicked(Sender: TOBject);
begin
  try
    for i := 0 to Selected.Count - 1 do begin
      item := IowCoatingPriceBaseValue(Selected.Objects[i]);
      item.OuterPrice := StrToFloat(priceOuter.text);
      item.InnerPrice := StrToFloat(priceInner.text);
      item.BothPrice := StrToFloat(priceDouble.text);
      //item.Apply;
    end;
    Form1.Close;
  except
    showmessage('Введите численные значения в оба поля. Для нецелых чисел используйте разделитель '',''');
  end;
end;

begin
  Form1 := TForm.Create(Application);
  with Form1 do begin
    Width := 195;
    Height := 196;
    Caption := 'Стоимость на покрытие';
    Position := poScreenCenter;
    BorderIcons := biSystemMenu;
    BorderStyle := bsDialog;
  end;

  pricePanelOuter := TGroupBox.Create(Application);
  with pricePanelOuter do begin
    Width := 180;
    Height := 40;
    Top := 2;
    Left := 5;
    Caption := 'Цена за внеш. покрытие';
    Parent := Form1;
  end;

  priceOuter := TEdit.Create(Application);
  with priceOuter do begin
    Left := 5;
    Top := 15;
    Width := 170;
    Height := 20;
    Parent := pricePanelOuter;
  end;

  pricePanelInner := TGroupBox.Create(Application);
  with pricePanelInner do begin
    Width := 180;
    Height := 40;
    Top := 45;
    Left := 5;
    Caption := 'Цена за внутр. покрытие';
    Parent := Form1;
  end;

  priceInner := TEdit.Create(Application);
  with priceInner do begin
    Left := 5;
    Top := 15;
    Width := 170;
    Height := 20;
    Parent := pricePanelInner;
  end;

  pricePanelDouble := TGroupBox.Create(Application);
  with pricePanelDouble do begin
    Width := 180;
    Height := 40;
    Top := 88;
    Left := 5;
    Caption := 'Цена за двустор. покрытие';
    Parent := Form1;
  end;

  priceDouble := TEdit.Create(Application);
  with priceDouble do begin
    Left := 5;
    Top := 15;
    Width := 170;
    Height := 20;
    Parent := pricePanelDouble;
  end;

  btnOk := TButton.Create(Application);
  with btnOk do begin
    Left := 15;
    Top := 133;
    Width := 158;
    Height := 30;
    Caption := 'Обновить';
    Parent := Form1;
    OnClick := @btnOkClicked;
  end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
