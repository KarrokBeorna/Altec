const
  GET_MEASURE = 'SELECT DOPMEASUREID, MD_LONGNAME, MD_FACTOR FROM DOPMEASURE WHERE MEASUREID = 2 ORDER BY MD_FACTOR DESC';
  GET_OPTGROUP = 'SELECT OG_ID, OG_NAME FROM OPTGROUP WHERE DELETED = 0';
  UPDATE_OG_ARTICUL = 'UPDATE VIRTARTICULES V'                                + #13#10 +
                      'SET V.OG_ID = :OG_ID'                                  + #13#10 +
                      'WHERE V.ARTICULID = :SELECTID AND V.DOPMEASUREID IN (' + #13#10 +
                      '  SELECT'                                              + #13#10 +
                      '    DOPMEASUREID'                                      + #13#10 +
                      '  FROM DOPMEASURE D'                                   + #13#10 +
                      '    JOIN MEASURE M ON D.MEASUREID = M.MEASUREID'       + #13#10 +
                      '  WHERE M.MEASUREID = 2'                               + #13#10 +
                      ')';
  UPDATE_BEAMSIZE_ARTICUL = 'UPDATE VIRTARTICULES V'                                 + #13#10 +
                            'SET V.BEAMSIZEID = :BEAMSIZEID '                        + #13#10 +
                            'WHERE V.ARTICULID = :SELECTID AND V.DOPMEASUREID IN ('  + #13#10 +
                            '  SELECT'                                               + #13#10 +
                            '    DOPMEASUREID'                                       + #13#10 +
                            '  FROM DOPMEASURE D'                                    + #13#10 +
                            '    JOIN MEASURE M ON D.MEASUREID = M.MEASUREID'        + #13#10 +
                            '  WHERE M.MEASUREID = 2'                                + #13#10 +
                            ')';

var
  Form1: TForm;
  btnOk: TButton;
  EDIZMPanel, OPTIMPanel: TGroupBox;
  EDIZM, OPTIM: TComboBox;
  S: IomSession;
  dopmID, optID: Integer;
  allEd, allOptim: IcmDictionaryList;
  SQLparams, GRNAME, OPTIMNAME: IcmDictionary;
  GRNAME_LIST, OPTIM_LIST: TStringList;

procedure btnOkClicked(Sender: TOBject);
begin
  for i := 0 to (allEd.count - 1) do begin
    elem := allEd[i];
    GRNAME.add(elem.value['DOPMEASUREID'], elem.value['MD_LONGNAME']);
    if EDIZM.text = elem.value['MD_LONGNAME'] then dopmID := elem.value['DOPMEASUREID'];
  end;

  for i := 0 to (allOptim.count - 1) do begin
    opt := allOptim[i];
    OPTIMNAME.add(opt.value['OG_ID'], opt.value['OG_NAME']);
    if OPTIM.text = opt.value['OG_NAME'] then optID := opt.value['OG_ID'];
  end;

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      SQLparams.Clear;
      SQLparams.Add('SELECTID', SelectedRecords.Items[i]['ARTICULID']);
      SQLparams.Add('OG_ID', optID);
      S.ExecSQL(UPDATE_OG_ARTICUL, SQLparams);
      SQLparams.Clear;
      SQLparams.Add('SELECTID', SelectedRecords.Items[i]['ARTICULID']);
      SQLparams.Add('BEAMSIZEID', dopmID);
      S.ExecSQL(UPDATE_BEAMSIZE_ARTICUL, SQLparams);
    end;
    showmessage('Обновлено записей: ' + IntToStr(SelectedRecords.Count));
    S.Commit;
    Form1.close;
  except
    S.Rollback;
    SHOWMESSAGE('Выберите группу оптимизации и длину хлыста');
  end;
end;

begin
  S := CreateObjectSession;
  GRNAME := CreateDictionary;
  OPTIMNAME := CreateDictionary;
  SQLparams := CreateDictionary;
  GRNAME_LIST := TStringList.create;
  OPTIM_LIST := TStringList.create;
  allEd := S.QueryRecordList(GET_MEASURE, empty);
  allOptim := S.QueryRecordList(GET_OPTGROUP, empty);

  for i := 0 to (allEd.count - 1) do begin
    elem := allEd[i];
    GRNAME.add(elem.value['DOPMEASUREID'], elem.value['MD_LONGNAME']);
    GRNAME_LIST.add(elem.value['MD_LONGNAME']);
  end;

  for i := 0 to (allOptim.count - 1) do begin
    opt := allOptim[i];
    OPTIMNAME.add(opt.value['OG_ID'], opt.value['OG_NAME']);
    OPTIM_LIST.add(opt.value['OG_NAME']);
  end;

Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 215;
   Height := 180;
   caption := 'Группа переоценки';
   position := poScreenCenter;
   BorderIcons := biSystemMenu;
 end;

EDIZMPanel := TGroupBox.Create(Application);
 with EDIZMPanel do begin
   Width := 190;
   Height := 50;
   Top := 2;
   Left := 5;
   caption := 'Выберите длину хлыста';
   Parent := Form1;
 end;

EDIZM := TComboBox.Create(Application);
 with EDIZM do begin
   Left := 5;
   Top := 20;
   Width := 180;
   height := 20;
   Parent := EDIZMPanel;
   items := GRNAME_LIST;
 end;

OPTIMPanel := TGroupBox.Create(Application);
 with OPTIMPanel do begin
   Width := 190;
   Height := 50;
   Top := 57;
   Left := 5;
   caption := 'Выберите группу оптимизации';
   Parent := Form1;
 end;

OPTIM := TComboBox.Create(Application);
 with OPTIM do begin
   Left := 5;
   Top := 20;
   Width := 180;
   height := 20;
   Parent := OPTIMPanel;
   items := OPTIM_LIST;
 end;

btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 25;
   Top := 110;
   Width := 150;
   Height := 25;
   Caption := 'Обновить';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
