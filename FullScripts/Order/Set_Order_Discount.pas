{
  * Скрипт позволяет проставить заказу скидку, указанную в диалоговой форме.
  * Также можно проставить вычет в валюте, указанный в диалоговой форме
}

var
  Form1: TForm;
  btnOk: TButton;
  procentPanel, valuePanel: TGroupBox;
  procent, value: TRichEdit;
  procentCB, valueCB: TCheckBox;

procedure CBOnClick(Sender: TOBject);
begin
  valuePanel.Enabled := valueCB.Checked;
  procentPanel.Enabled := procentCB.Checked;
end;

procedure btnOkClicked(Sender: TOBject);
begin
  try
    if (procentCB.Checked) and (Trim(procent.Lines.Text) <> '') then begin
      Instance.Discount := StrToInt(Copy(procent.Lines.Text, 1, Length(procent.Lines.Text) - 2));
    end;

    if (valueCB.Checked) and (Trim(value.Lines.Text) <> '') then begin
      Instance.Deduction := StrToInt(Copy(value.Lines.Text, 1, Length(value.Lines.Text) - 2));
    end;

    Form1.close;
  except
    ShowMessage('Оставьте поле пустым или введите численное значение');
  end;
end;

begin
Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 225;
   Height := 170;
   Caption := 'Скидка и вычет в валюте на заказ';
   Position := poScreenCenter;
   BorderIcons := biSystemMenu;
 end;

procentCB := TCheckBox.Create(Application);
with procentCB do begin
   Left := 5;
   Top := 15;
   Checked := True;
   Parent := Form1;
   onClick := @CBOnClick;
 end;

procentPanel := TGroupBox.Create(Application);
 with procentPanel do begin
   Width := 180;
   Height := 40;
   Top := 2;
   Left := 25;
   Caption := 'Введите % скидки';
   Parent := Form1;
 end;

procent := TRichEdit.Create(Application);
 with procent do begin
   Left := 5;
   Top := 15;
   Width := 170;
   Height := 20;
   Parent := procentPanel;
 end;

valueCB := TCheckBox.Create(Application);
with valueCB do begin
   Left := 5;
   Top := 63;
   Checked := True;
   Parent := Form1;
   onClick := @CBOnClick;
 end;

valuePanel := TGroupBox.Create(Application);
 with valuePanel do begin
   Width := 180;
   Height := 40;
   Top := 50;
   Left := 25;
   Caption := 'Введите вычет в валюте';
   Enabled := True;
   Parent := Form1;
 end;

value := TRichEdit.Create(Application);
 with value do begin
   Left := 5;
   Top := 15;
   Width := 170;
   Height := 20;
   Parent := valuePanel;
 end;

btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 25;
   Top := 98;
   Width := 160;
   Height := 25;
   Caption := 'Проставить скидку';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
