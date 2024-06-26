const
  GET_GPNAME = 'SELECT GP_NAME, WGRPRICEID FROM W_GRPRICE WHERE DELETED = 0';
  UPDATE_ARTICULES = 'UPDATE VIRTARTICULES V SET V.WGRPRICEID = :WGRPRICEID WHERE V.ARTICULID = :SELECTID';

var
  Form1: TForm;
  btnOk: TButton;
  reprice: TComboBox;
  repricePanel: TGroupBox;
  SQLparams, GRNAME: IcmDictionary;
  S: IomSession;
  IDupd: Integer;
  allGroup: IcmDictionaryList;
  GRNAME_LIST: TStringList;

procedure btnOkClicked(Sender: TOBject);
begin
  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      SQLparams.Clear;
      SQLparams.Add('SELECTID', SelectedRecords.Items[i]['ARTICULID']);
      SQLparams.Add('WGRPRICEID', GRNAME.value[reprice.text]);
      S.ExecSQL(UPDATE_ARTICULES, SQLparams);
    end;
    showmessage('Обновлено записей: ' + IntToStr(SelectedRecords.Count));
    S.Commit;
    Form1.close;
  except
    S.Rollback;
    SHOWMESSAGE('Выберите группу переоценки');
  end;
end;

begin
  S := CreateObjectSession;
  allGroup := S.QueryRecordList(GET_GPNAME, empty);
  GRNAME := CreateDictionary;
  SQLparams := CreateDictionary;
  GRNAME_LIST := TStringList.create;

  GRNAME.add('Удалить переоценку', Null);
  GRNAME_LIST.add('Удалить переоценку');

  for i := 0 to (allGroup.count - 1) do begin
    elem := allGroup[i];
    GRNAME.add(elem.value['GP_NAME'], elem.value['WGRPRICEID']);
    GRNAME_LIST.add(elem.value['GP_NAME']);
  end;

Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 220;
   Height := 125;
   caption := 'Смена группы переоценки';
   position := poScreenCenter;
   BorderIcons := biSystemMenu;
 end;

repricePanel := TGroupBox.Create(Application);
 with repricePanel do begin
   Width := 190;
   Height := 50;
   Top := 2;
   Left := 5;
   caption := 'Укажите группу переоценки';
   Parent := Form1;
 end;

reprice := TComboBox.Create(Application);
 with reprice do begin
   Left := 5;
   Top := 20;
   Width := 180;
   height := 20;
   text := 'Удалить переоценку';
   Parent := repricePanel;
   items := GRNAME_LIST;
 end;

btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 35;
   Top := 55;
   Width := 140;
   Height := 25;
   Caption := 'Обновить';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
