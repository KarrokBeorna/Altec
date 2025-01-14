{
  * Скрипт позволяет вносить записи в диспетчеризацию "Отгружен".
  * Это можно выполнить лишь в том случае, если долг меньше, либо равен нулю,
  * а также если все изделия в заказе произведены.
  * В противном случае будет будет показано диалоговое окно с
  * предупреждением.
}

var
  Form1: TForm;
  btnOk: TButton;
  Session: IomSession;
  PanelComment: TGroupBox;
  comment: TRichEdit;

// См. Instance.StatusList - статусы текущего заказа

procedure btnOkClicked(Sender: TOBject);
begin
  for i := 0 to Instance.StatusList.Count - 1 do begin
    if Instance.StatusList.Items[i].OrderStatus.Name = 'Отгружен' then begin
      if (Instance.Debt <= 0) and (Instance.Produced) then begin
        Instance.StatusList.Items[i].Done := True;
        Instance.StatusList.Items[i].Comment := comment.Lines.Text;
        Instance.StatusList.Items[i].apply;
      end else begin
        MessageDlg('Все изделия в заказе должны быть произведены, а сам заказ полностью оплачен', mtWarning, mbOK, 0);
      end;
      break;
    end;
  end;
  Form1.close;
end;

begin
  Form1 := TForm.Create(Application);
  with Form1 do begin
    Width := 235;
    Height := 152;
    caption := 'Отгрузка';
    position := poScreenCenter;
    BorderIcons := biSystemMenu;
  end;

  PanelComment := TGroupBox.Create(Application);
  with PanelComment do begin
    Width := 210;
    Height := 73;
    Top := 2;
    Left := 5;
    caption := 'Примечание';
    Parent := Form1;
  end;

  comment := TRichEdit.Create(Application);
  with comment do begin
    Left := 5;
    Top := 15;
    Width := 200;
    height := PanelComment.height - 20;
    Parent := PanelComment;
  end;

  btnOk := TButton.Create(Application);
  with btnOk do begin
    Left := 10;
    Top := 78;
    Width := 200;
    Height := 30;
    Caption := 'Отгружен';
    Parent := Form1;
    onClick := @btnOkClicked;
  end;

  if Form1.ShowModal = mrOk then Form1.Show;
end;
