var
  Form1: TForm;
  btnOk: TButton;
  Session: IomSession;
  date: TDateTimePicker;
  time: TComboBox;
  timeStrings: TStringList;
  cbReady: TCheckBox;
  PanelComment: TGroupBox;
  comment: TRichEdit;
  commentText: String;

// См. Instance.StatusList - статусы текущего заказа

procedure btnOkClicked(Sender: TOBject);
begin
   if time.text = '--Время--' then begin
      showMessage('Выберите время');
   end else begin
      for i := 0 to Instance.StatusList.Count - 1 do begin
        if Instance.StatusList.Items[i].OrderStatus.Key = 7 then begin
          Instance.StatusList.Items[i].PlanDate := StrToDateTime(Copy(dateTimeToStr(date.time), 0, 11) + time.text + ':00');
          Instance.StatusList.Items[i].Done := cbReady.checked;
          Instance.StatusList.Items[i].Comment := comment.lines.text;
          Instance.StatusList.Items[i].apply;
        end;
      end;
      Form1.close;
   end;
end;

procedure cbReadyClicked(Sender: TOBject);
begin
  if cbReady.checked then begin
    btnOk.caption := 'Звонок выполнен';
  end else begin
    btnOk.caption := 'Установить напоминание';
  end;
end;

begin

for i := 0 to Instance.StatusList.Count - 1 do begin
  if Instance.StatusList.Items[i].OrderStatus.Key = 7 then begin
    commentText := Instance.StatusList.Items[i].Comment;
  end;
end;

timeStrings := TStringList.Create();

for i := 9 to 18 do begin
  timeStrings.add(IntToStr(i) + ':00');
  timeStrings.add(IntToStr(i) + ':30');
end;

Form1:=TForm.Create(Application);
 with Form1 do begin
   Width := 235;
   Height := 205;
   caption := 'Напоминание о звонке';
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
   Text := '--Время--';
   Parent := Form1;
   items := timeStrings;
 end;

cbReady := TCheckBox.Create(Application);
 with cbReady do begin
   Left := 10;
   Top := 35;
   Caption := 'Выполнено';
   Parent := Form1;
   onClick := @cbReadyClicked;
 end;

PanelComment := TGroupBox.Create(Application);
 with PanelComment do begin
   Width := 210;
   Height := 70;
   Top := 55;
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

comment.lines.text := commentText;

btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 10;
   Top := 130;
   Width := 200;
   Height := 30;
   Caption := 'Установить напоминание';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
