var
  Form1: TForm;
  btnOk: TButton;
  Session: IomSession;
  SQLQ: string;
  SQLparams: IcmDictionary;
  date: TDateTimePicker;
  time: TComboBox;
  timeStrings: TStringList;

// См. Instance.StatusList - статусы текущего заказа

procedure btnOkClicked(Sender: TOBject);
begin
   if time.text = '--Время--' then begin
      showMessage('Выберите время');
   end else begin
      for i := 0 to Instance.StatusList.Count - 1 do begin
        if Instance.StatusList.Items[i].OrderStatus.Key = 7 then begin
          Instance.StatusList.Items[i].PlanDate := StrToDateTime(Copy(dateTimeToStr(date.time), 0, 11) + time.text + ':00');
          Instance.StatusList.Items[i].apply;
        end;
      end;
      Form1.close;
   end;
end;

begin

timeStrings := TStringList.Create();

for i := 9 to 18 do begin
  timeStrings.add(IntToStr(i) + ':00');
  timeStrings.add(IntToStr(i) + ':30');
end;

Form1:=TForm.Create(Application);
 with Form1 do begin
   Width := 235;
   Height := 120;
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

btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 10;
   Top := 45;
   Width := 200;
   Height := 30;
   Caption := 'Установить напоминание';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
