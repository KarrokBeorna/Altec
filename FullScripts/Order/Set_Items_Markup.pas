{
  * Скрипт позволяет добавлять процент на заказ от рассчитанной
  * стоимости, либо введённую сумму распределит между всеми элементами заказа,
  * при этом распределение будет в зависимости от стоимости элемента
  * в общей сумме стоимостей выделенных элементов.
}

var
  Form1: TForm;
  btnOk: TButton;
  procentPanel, valuePanel: TGroupBox;
  procent, value: TRichEdit;
  procentRB, valueRB: TRadioButton;
  OrderItem: IowOrderItem;
  itemsCalcPrice: Double;

procedure RBOnClick(Sender: TOBject);
begin
  valuePanel.enabled := not procentRB.checked;
  procentPanel.enabled := procentRB.checked;
end;

procedure btnOkClicked(Sender: TOBject);
begin
  itemsCalcPrice := 0;

  for i := 0 to Instance.Count - 1 do begin
    itemsCalcPrice := itemsCalcPrice + Instance[i].CalculatedPrice * Instance[i].Quantity;

    for j := 0 to Instance[i].Extras.Count - 1 do begin
      itemsCalcPrice := itemsCalcPrice + Instance[i].Extras[j].CalculatedPrice * Instance[i].Extras[j].Quantity;
    end;

    for j := 0 to Instance[i].Services.Count - 1 do begin
      itemsCalcPrice := itemsCalcPrice + Instance[i].Services[j].CalculatedPrice * Instance[i].Services[j].QtyFloat;
    end;
  end;

  try
    for i := 0 to Instance.Count - 1 do begin
      OrderItem := Instance[i];

      if procentRB.checked then begin
        if trim(procent.Lines.Text) <> '' then begin
          OrderItem.UserPrice := True;
          OrderItem.Price := StrToFloat(FormatFloat('0.00', OrderItem.CalculatedPrice * (100 + StrToInt(trim(procent.Lines.Text))) / 100));

          for j := 0 to OrderItem.Extras.Count - 1 do begin
            OrderItem.Extras[j].UserPrice := True;
            OrderItem.Extras[j].Price := StrToFloat(FormatFloat('0.00', OrderItem.Extras[j].CalculatedPrice * (100 + StrToInt(trim(procent.Lines.Text))) / 100));
            OrderItem.Extras[j].Apply();
          end;

          for j := 0 to OrderItem.Services.Count - 1 do begin
            OrderItem.Services[j].UserPrice := True;
            OrderItem.Services[j].Price := StrToFloat(FormatFloat('0.00', OrderItem.Services[j].CalculatedPrice * (100 + StrToInt(trim(procent.Lines.Text))) / 100));
            OrderItem.Services[j].Apply();
          end;
        end else begin
          OrderItem.UserPrice := False;
          OrderItem.Price := OrderItem.CalculatedPrice;

          for j := 0 to OrderItem.Extras.Count - 1 do begin
            OrderItem.Extras[j].UserPrice := False;
            OrderItem.Extras[j].Price := OrderItem.Extras[j].CalculatedPrice;
            OrderItem.Extras[j].Apply();
          end;

          for j := 0 to OrderItem.Services.Count - 1 do begin
            OrderItem.Services[j].UserPrice := False;
            OrderItem.Services[j].Price := OrderItem.Services[j].CalculatedPrice;
            OrderItem.Services[j].Apply();
          end;
        end;
        OrderItem.apply;
      end;

      if valueRB.checked then begin
        if trim(value.Lines.Text) <> '' then begin
          OrderItem.UserPrice := True;
          OrderItem.Price := StrToFloat(FormatFloat('0.00', OrderItem.CalculatedPrice + (OrderItem.CalculatedPrice / itemsCalcPrice * StrToInt(trim(value.Lines.Text)))));

          for j := 0 to OrderItem.Extras.Count - 1 do begin
            CP := OrderItem.Extras[j].CalculatedPrice;
            OrderItem.Extras[j].UserPrice := True;
            OrderItem.Extras[j].Price := StrToFloat(FormatFloat('0.00', CP + (CP / OrderItem.Extras[j].Quantity / itemsCalcPrice * StrToInt(trim(value.Lines.Text))))); // OrderItem.Quantity
            OrderItem.Extras[j].Apply();
          end;

          for j := 0 to OrderItem.Services.Count - 1 do begin
            CP := OrderItem.Services[j].CalculatedPrice;
            OrderItem.Services[j].UserPrice := True;
            OrderItem.Services[j].Price := StrToFloat(FormatFloat('0.00', CP + (CP / OrderItem.Services[j].QtyFloat / itemsCalcPrice * StrToInt(trim(value.Lines.Text)))));
          end;
        end else begin
          OrderItem.UserPrice := False;
          OrderItem.Price := OrderItem.CalculatedPrice;

          for j := 0 to OrderItem.Extras.Count - 1 do begin
            OrderItem.Extras[j].UserPrice := False;
            OrderItem.Extras[j].Price := OrderItem.Extras[j].CalculatedPrice;
            OrderItem.Extras[j].Apply();
          end;

          for j := 0 to OrderItem.Services.Count - 1 do begin
            OrderItem.Services[j].UserPrice := False;
            OrderItem.Services[j].Price := OrderItem.Services[j].CalculatedPrice;
          end;
        end;
        OrderItem.apply;
      end;
    end;

    Form1.close;
  except
    showmessage('Оставьте поле пустым или введите целочисленное значение');
  end;
end;

begin
Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 225;
   Height := 170;
   caption := 'Надбавка на заказ';
   position := poScreenCenter;
   BorderIcons := biSystemMenu;
 end;

procentRB := TRadioButton.Create(Application);
with procentRB do begin
   Left := 5;
   Top := 15;
   Checked := True;
   Parent := Form1;
   onClick := @RBOnClick;
 end;

procentPanel := TGroupBox.Create(Application);
 with procentPanel do begin
   Width := 180;
   Height := 40;
   Top := 2;
   Left := 25;
   caption := 'Введите % надбавки';
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

valueRB := TRadioButton.Create(Application);
with valueRB do begin
   Left := 5;
   Top := 63;
   Parent := Form1;
   onClick := @RBOnClick;
 end;

valuePanel := TGroupBox.Create(Application);
 with valuePanel do begin
   Width := 180;
   Height := 40;
   Top := 50;
   Left := 25;
   caption := 'Введите надбавку в валюте';
   enabled := false;
   hint := 'Данное значение равномерно распределится между всеми изделиями в заказе в зависимости от их первоначально рассчитанной цены';
   Parent := Form1;
 end;

value := TRichEdit.Create(Application);
 with value do begin
   Left := 5;
   Top := 15;
   Width := 170;
   height := 20;
   Parent := valuePanel;
 end;

btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 25;
   Top := 98;
   Width := 160;
   Height := 25;
   Caption := 'Установить надбавку';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
