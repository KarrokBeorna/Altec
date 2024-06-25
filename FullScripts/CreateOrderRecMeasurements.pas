var
  Form1: TForm;
  btnOk: TButton;
  Session: IomSession;
  SQLparams: IcmDictionary;
  date: TDateTimePicker;
  time, executor: TComboBox;
  timeStrings, executors: TStringList;
  employees: variant;

const
  SQLQ =
'SELECT                                                             ' + #13#10 +
'    PERSONTITLE,                                                   ' + #13#10 +
'    E.EMPLOYEEID                                                   ' + #13#10 +
'FROM EMPLOYEE E                                                    ' + #13#10 +
'    JOIN PERSONS P ON P.PERSONID = E.EMPLOYEEID                    ' + #13#10 +
'    LEFT JOIN EMPLOYEES_ROLES ER ON ER.EMPLOYEEID = E.EMPLOYEEID   ' + #13#10 +
'    LEFT JOIN ROLES R ON R.ID = ER.ROLEID                          ' + #13#10 +
'WHERE R.NAME = :ROLE';

// См. Instance.StatusList - статусы текущего заказа

procedure btnOkClicked(Sender: TOBject);
begin
   if time.text = '--Время--' then begin
      showMessage('Выберите время');
   end else begin
      for i := 0 to Instance.StatusList.Count - 1 do begin
        if Instance.StatusList.Items[i].OrderStatus.Name = 'Замер' then begin
          Instance.StatusList.Items[i].PlanDate := StrToDateTime(Copy(dateTimeToStr(date.time), 0, 11) + time.text + ':00');
          if executor.text <> '--Исполнитель--' then begin
            Instance.StatusList.Items[i].Executor := session.OpenObject('IowEmployee', employees.items[executor.itemindex].value['EMPLOYEEID']);
          end;
          Instance.StatusList.Items[i].apply;
        end;
      end;
      Form1.close;
   end;
end;

begin

timeStrings := TStringList.Create();
executors := TStringList.Create();

for i := 9 to 18 do begin
  timeStrings.add(IntToStr(i) + ':00');
  timeStrings.add(IntToStr(i) + ':30');
end;

session := CreateObjectSession();
employees := session.QueryRecordList(SQLQ, MakeDictionary(['ROLE', 'Замерщик']));

for j := 0 to employees.count - 1 do begin
  executors.add(employees.items[j].value['PERSONTITLE']);
end;

session.Commit();

Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 235;
   Height := 145;
   caption := 'Замер';
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

executor := TComboBox.Create(Application);
 with executor do begin
   Left := 10;
   Top := 40;
   Width := 200;
   Height := 30;
   Text := '--Исполнитель--';
   Parent := Form1;
   items := executors;
 end;

btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 10;
   Top := 70;
   Width := 200;
   Height := 30;
   Caption := 'Сохранить';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
