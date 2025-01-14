{
  * Скрипт позволяет проставить всем выделенным изделиям в заказе скидку,
  * указанную в диалоговой форме. Скидка может быть только целочисленной
}

var
  Form1: TForm;
  btnOk: TButton;
  procentPanel: TGroupBox;
  procent: TRichEdit;
  OrderItem: IowOrderItem;

procedure btnOkClicked(Sender: TOBject);
begin
  try
    for i := 0 to Selected.Count - 1 do begin
      OrderItem := IowOrderItem(Selected.Objects[i]);
      if TRIM(procent.Lines.Text) <> '' then begin
        OrderItem.Discount := StrToInt(Copy(procent.Lines.Text, 1, Length(procent.Lines.Text) - 2));
      end else begin
        OrderItem.Discount := 0;
      end;
      OrderItem.apply;
    end;

    Form1.close;
  except
    showmessage('Оставьте поле пустым или введите численное значение');
  end;
end;

begin

Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 205;
   Height := 120;
   caption := '% скидки';
   position := poScreenCenter;
   BorderIcons := biSystemMenu;
 end;

procentPanel := TGroupBox.Create(Application);
 with procentPanel do begin
   Width := 180;
   Height := 40;
   Top := 2;
   Left := 5;
   caption := 'Введите % скидки';
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
   Caption := 'Проставить скидку';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
