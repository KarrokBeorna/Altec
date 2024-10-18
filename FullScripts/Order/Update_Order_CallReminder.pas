var
  Form1: TForm;
  btnOk: TButton;
  date, dateOld: TDateTimePicker;
  time, timeOld: TComboBox;
  timeStrings: TStringList;
  cbNew, cbReady: TCheckBox;
  PanelComment, PanelCommentOld: TGroupBox;
  comment, commentOld: TRichEdit;
  commentText: String;
  done: Boolean;
  planDate: variant;
  close: Boolean;

// См. Instance.StatusList - статусы текущего заказа

procedure btnOkClicked(Sender: TOBject);
begin
  for i := 0 to Instance.StatusList.Count - 1 do begin
    if Instance.StatusList.Items[i].OrderStatus.Name = 'Напоминание о звонке' then begin
      if cbReady.checked then begin
        Instance.StatusList.Items[i].PlanDate := Now;
        Instance.StatusList.Items[i].Done := True;
        Instance.StatusList.Items[i].Comment := commentOld.lines.text;
        Instance.StatusList.Items[i].apply;
        close := True;
      end;

      if cbNew.checked then begin
        if time.text = '--Время--' then begin
          showMessage('Выберите время');
          close := False;
        end else begin
          Instance.apply;
          Instance.Session.Commit;
          Instance.StatusList.Items[i].PlanDate := StrToDateTime(Copy(dateTimeToStr(date.time), 0, 11) + time.text + ':00');
          Instance.StatusList.Items[i].Done := False;
          Instance.StatusList.Items[i].Comment := comment.lines.text;
          Instance.StatusList.Items[i].apply;
          Instance.apply;
          Instance.Session.Commit;
          close := True;
        end;
      end;
    end;
  end;
  if close then Form1.close;
end;

procedure cbReadyClicked(Sender: TOBject);
begin
  if cbReady.checked and not cbNew.checked then begin
    btnOk.caption := 'Звонок выполнен';
    btnOk.enabled := True;
  end else begin
    btnOk.caption := 'Установить напоминание';
    if not cbNew.checked then begin
      btnOk.enabled := False;
    end;
  end;
end;

procedure cbNewClicked(Sender: TOBject);
begin
  if cbNew.checked then begin
    Form1.Height := 285;
    date.visible := True;
    time.visible := True;
    panelComment.visible := True;
    comment.visible := True;
    btnOk.Top := PanelComment.Top + 73;
    btnOk.caption := 'Установить напоминание';
    btnOk.enabled := True;
  end else begin
    Form1.Height := 285 - 98;
    date.visible := False;
    time.visible := False;
    panelComment.visible := False;
    comment.visible := False;
    btnOk.Top := cbNew.Top + 20;

    if cbReady.checked then begin
      btnOk.caption := 'Звонок выполнен';
      btnOk.enabled := True;
    end else begin
      btnOk.enabled := False;
    end;
  end;
end;

begin
  for i := 0 to Instance.StatusList.Count - 1 do begin
    if Instance.StatusList.Items[i].OrderStatus.Name = 'Напоминание о звонке' then begin
      commentText := Instance.StatusList.Items[i].Comment;
      done := Instance.StatusList.Items[i].Done;
      planDate := Instance.StatusList.Items[i].PlanDate;
    end;
  end;

  timeStrings := TStringList.Create();

  for i := 9 to 18 do begin
    timeStrings.add(IntToStr(i) + ':00');
    timeStrings.add(IntToStr(i) + ':30');
  end;

 Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 235;
   Height := 285 - 98;
   caption := 'Напоминание о звонке';
   position := poScreenCenter;
   BorderIcons := biSystemMenu;
 end;

 cbReady := TCheckBox.Create(Application);
 with cbReady do begin
   Left := 10;
   Top := 5;
   Width := 150;
   Caption := 'Звонок выполнен';
   Parent := Form1;
   enabled := not done and not varIsClear(planDate) and not varIsNull(planDate);
   onClick := @cbReadyClicked;
 end;
 {
 dateOld := TDateTimePicker.Create(Application);
 with dateOld do begin
   Left := 10;
   Top := 25;
   Width := 100;
   Parent := Form1;
 end;

 timeOld := TComboBox.Create(Application);
 with timeOld do begin
   Left := 115;
   Top := 25;
   Width := 95;
   Text := '--Время--';
   Parent := Form1;
   items := timeStrings;
 end;
 }
 PanelCommentOld := TGroupBox.Create(Application);
 with PanelCommentOld do begin
   Width := 210;
   Height := 70;
   Top := cbReady.Top + 20;
   Left := 5;
   caption := 'Примечание прошлого напоминания';
   Parent := Form1;
 end;

 commentOld := TRichEdit.Create(Application);
 with commentOld do begin
   Left := 5;
   Top := 15;
   Width := 200;
   height := PanelCommentOld.height - 20;
   Parent := PanelCommentOld;
 end;

 commentOld.lines.text := commentText;

 cbNew := TCheckBox.Create(Application);
 with cbNew do begin
   Left := 10;
   Top := PanelCommentOld.Top + 70;
   Width := 150;
   Caption := 'Новое напоминание';
   Parent := Form1;
   onClick := @cbNewClicked;
 end;

 date := TDateTimePicker.Create(Application);
 with date do begin
   Left := 10;
   Top := cbNew.Top + 20;
   Width := 100;
   visible := False;
   Parent := Form1;
 end;

 time := TComboBox.Create(Application);
 with time do begin
   Left := 115;
   Top := cbNew.Top + 20;
   Width := 95;
   Text := '--Время--';
   visible := False;
   Parent := Form1;
   items := timeStrings;
 end;

 PanelComment := TGroupBox.Create(Application);
 with PanelComment do begin
   Width := 210;
   Height := 70;
   Top := time.Top + 25;
   Left := 5;
   caption := 'Примечание нового напоминания';
   visible := False;
   Parent := Form1;
 end;

 comment := TRichEdit.Create(Application);
 with comment do begin
   Left := 5;
   Top := 15;
   Width := 200;
   height := PanelComment.height - 20;
   visible := False;
   Parent := PanelComment;
 end;

 comment.lines.text := commentText;

 btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 10;
   Top := cbNew.Top + 20;
   Width := 200;
   Height := 30;
   Caption := 'Установить напоминание';
   enabled := False;
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
