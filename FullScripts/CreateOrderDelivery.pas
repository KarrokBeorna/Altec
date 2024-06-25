var
  Form1: TForm;
  btnOk: TButton;
  Session: IomSession;
  dateDelivery, dataMounting: TDateTimePicker;
  timeDelivery, timeMounting, executorDelivery, executorMounting: TComboBox;
  timeStrings, executors: TStringList;
  employees: variant;
  panelDelivery, panelMounting: TGRoupBox;

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
   if timeDelivery.text = '--Время доставки--' then begin
      showMessage('Выберите время доставки');
   end else if timeMounting.text = '--Время монтажа--' then begin
      showMessage('Выберите время монтажа');
   end else begin
      for i := 0 to Instance.StatusList.Count - 1 do begin
        if Instance.StatusList.Items[i].OrderStatus.Name = 'Доставка' then begin
          Instance.StatusList.Items[i].PlanDate := StrToDateTime(Copy(dateTimeToStr(dateDelivery.time), 0, 11) + timeDelivery.text + ':00');
          if executorDelivery.text <> '--Исполнитель--' then begin
            Instance.StatusList.Items[i].Executor := session.OpenObject('IowEmployee', employees.items[executorDelivery.itemindex].value['EMPLOYEEID']);
          end;
          Instance.StatusList.Items[i].apply;
        end;

        if Instance.StatusList.Items[i].OrderStatus.Name = 'Монтаж' then begin
          Instance.StatusList.Items[i].PlanDate := StrToDateTime(Copy(dateTimeToStr(dateMounting.time), 0, 11) + timeMounting.text + ':00');
          if executorMounting.text <> '--Исполнитель--' then begin
            Instance.StatusList.Items[i].Executor := session.OpenObject('IowEmployee', employees.items[executorMounting.itemindex].value['EMPLOYEEID']);
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

  for i := 9 to 22 do begin
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
    Width := 265;
    Height := 230;
    caption := 'Доставка и монтаж';
    position := poScreenCenter;
    //color := 121*256*256 + 240*256 + 65;
    BorderIcons := biSystemMenu;
  end;

  panelDelivery := TGroupBox.Create(Application);
  with panelDelivery do begin
    Width := 240;
    Height := 73;
    Top := 2;
    Left := 5;
    caption := 'Доставка';
    //color := 121*256*256 + 240*256 + 91;
    Parent := Form1;
  end;

  panelMounting := TGroupBox.Create(Application);
  with panelMounting do begin
    Width := 240;
    Height := 73;
    Top := 79;
    Left := 5;
    caption := 'Монтаж';
    //color := 104*256*256 + 240*256 + 91;
    Parent := Form1;
  end;

  dateDelivery := TDateTimePicker.Create(Application);
  with dateDelivery do begin
    Left := 5;
    Top := 15;
    Width := 100;
    Parent := panelDelivery;
  end;

  timeDelivery := TComboBox.Create(Application);
  with timeDelivery do begin
    Left := 110;
    Top := 15;
    Width := 125;
    Text := '--Время доставки--';
    Parent := panelDelivery;
    items := timeStrings;
  end;

  executorDelivery := TComboBox.Create(Application);
  with executorDelivery do begin
    Left := 5;
    Top := 45;
    Width := 230;
    Height := 30;
    Text := '--Исполнитель доставки--';
    Parent := panelDelivery;
    items := executors;
  end;

  dateMounting := TDateTimePicker.Create(Application);
  with dateMounting do begin
    Left := 5;
    Top := 15;
    Width := 100;
    Parent := panelMounting;
  end;

  timeMounting := TComboBox.Create(Application);
  with timeMounting do begin
    Left := 110;
    Top := 15;
    Width := 125;
    Text := '--Время монтажа--';
    Parent := panelMounting;
    items := timeStrings;
  end;

  executorMounting := TComboBox.Create(Application);
  with executorMounting do begin
    Left := 5;
    Top := 45;
    Width := 230;
    Height := 30;
    Text := '--Исполнитель монтажа--';
    Parent := panelMounting;
    items := executors;
  end;

  btnOk := TButton.Create(Application);
  with btnOk do begin
    Left := 10;
    Top := 155;
    Width := 230;
    Height := 30;
    Caption := 'Сохранить';
    Parent := Form1;
    onClick := @btnOkClicked;
  end;

  if Form1.ShowModal = mrOk then Form1.Show;
end;
