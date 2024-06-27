var
  Form1: TForm;
  btnOk: TButton;
  Session: IomSession;
  PanelReason: TGroupBox;
  reason: TRichEdit;
  r: String;

// См. Instance.StatusList - статусы текущего заказа

procedure btnOkClicked(Sender: TOBject);
begin
   for i := 0 to Instance.StatusList.Count - 1 do begin
      if Instance.StatusList.Items[i].OrderStatus.Name = 'Отказ' then begin
        Instance.StatusList.Items[i].Done := True;
        r := '';
        Instance.StatusList.Items[i].Comment := reason.Lines.Text;
        Instance.StatusList.Items[i].apply;
      end;
    end;
    Form1.close;
end;

begin

Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 235;
   Height := 152;
   caption := 'Отказ';
   position := poScreenCenter;
   BorderIcons := biSystemMenu;
 end;

PanelReason := TGroupBox.Create(Application);
 with PanelReason do begin
   Width := 210;
   Height := 73;
   Top := 2;
   Left := 5;
   caption := 'Причина отказа';
   Parent := Form1;
 end;

reason := TRichEdit.Create(Application);
 with reason do begin
   Left := 5;
   Top := 15;
   Width := 200;
   height := Form1.height - 100;
   Parent := PanelReason;
 end;

btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 10;
   Top := 78;
   Width := 200;
   Height := 30;
   Caption := 'Сохранить';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
