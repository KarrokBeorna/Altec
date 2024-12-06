{
  * Скрипт позволяет выставить причину отказа заказа.
  * Если причина указывается "Другое", то берется текст из комментария
  * Если указана одна из причин списка, то берется она
  * Если в списке остаётся значение "--Причина отказа--", то указывается, что отказ был без указания причины
}

var
  Form1: TForm;
  btnOk: TButton;
  Session: IomSession;
  PanelReason: TGroupBox;
  reason: TRichEdit;
  reasons: TStringList;
  reasonsCB: TComboBox;

procedure btnOkClicked(Sender: TOBject);
begin
   for i := 0 to Instance.StatusList.Count - 1 do begin
      if Instance.StatusList.Items[i].OrderStatus.Name = 'Отказ' then begin
        Instance.StatusList.Items[i].Done := True;
        if reasonsCB.text = 'Другое' then begin
          Instance.StatusList.Items[i].Comment := reason.Lines.Text;
        end else if reasonsCB.text = '--Причина отказа--' then begin
          Instance.StatusList.Items[i].Comment := 'Без указания причины';
        end else begin
          Instance.StatusList.Items[i].Comment := reasonsCB.text;
        end;
        Instance.StatusList.Items[i].apply;
      end;
    end;
    Form1.close;
end;

begin
  reasons := TStringList.Create();

  reasons.add('Дорого');
  reasons.add('Не устроил ассортимент');
  reasons.add('Долго ждать');
  reasons.add('Закажет позже');
  reasons.add('Дубль');
  reasons.add('Другое');

  Form1 := TForm.Create(Application);
  with Form1 do begin
    Width := 235;
    Height := 182;
    caption := 'Отказ';
    position := poScreenCenter;
    BorderIcons := biSystemMenu;
  end;

  reasonsCB := TComboBox.Create(Application);
  with reasonsCB do begin
    Left := 5;
    Top := 5;
    Width := 210;
    Height := 30;
    Text := '--Причина отказа--';
    Parent := Form1;
    items := reasons;
  end;

  PanelReason := TGroupBox.Create(Application);
  with PanelReason do begin
    Width := 210;
    Height := 73;
    Top := 32;
    Left := 5;
    caption := 'Причина отказа';
    Parent := Form1;
  end;

  reason := TRichEdit.Create(Application);
  with reason do begin
    Left := 5;
    Top := 15;
    Width := 200;
    height := PanelReason.height - 20;
    Parent := PanelReason;
  end;

  btnOk := TButton.Create(Application);
  with btnOk do begin
    Left := 10;
    Top := 108;
    Width := 200;
    Height := 30;
    Caption := 'Сохранить';
    Parent := Form1;
    onClick := @btnOkClicked;
  end;

  if Form1.ShowModal = mrOk then Form1.Show;
end;
