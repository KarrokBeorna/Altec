const
  UPDATE_ARTICULES = 'UPDATE VIRTARTICULES V SET V.WASTE = :PROCENTWASTE WHERE V.ARTICULID = :SELECTID';

var
  Form1: TForm;
  btnOk: TButton;
  procentPanel: TGroupBox;
  procent: TRichEdit;
  SQLparams: IcmDictionary;
  Session: IomSession;
  text: variant;


procedure btnOkClicked(Sender: TOBject);
begin
  Session := CreateObjectSession;
  SQLparams := CreateDictionary;

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      if TRIM(procent.Lines.Text) <> '' then
        text := procent.Lines.Text
      else
        text := Null;
      SQLparams.clear;
      SQLparams.Add('SELECTID', SelectedRecords.Items[i]['ARTICULID']);
      SQLparams.Add('PROCENTWASTE', text);
      Session.ExecSQL(UPDATE_ARTICULES, SQLparams);
    end;
    //showmessage('Обновлено записей: ' + IntToStr(SelectedRecords.Count));
    Session.Commit;
    Form1.close;
  except
    Session.Rollback;
    SHOWMESSAGE('Оставьте поле пустым или ведите численное значение отхода');
  end;
end;

begin

Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 205;
   Height := 120;
   caption := '% отхода';
   position := poScreenCenter;
   BorderIcons := biSystemMenu;
 end;

procentPanel := TGroupBox.Create(Application);
 with procentPanel do begin
   Width := 180;
   Height := 40;
   Top := 2;
   Left := 5;
   caption := 'Введите % отхода';
   Parent := Form1;
 end;

procent := TRichEdit.Create(Application);
 with procent do begin
   Left := 5;
   Top := 15;
   Width := 170;
   height := 20;
   Parent := procentPanel;
 end;

btnOk := TButton.Create(Application);
 with btnOk do begin
   Left := 25;
   Top := 50;
   Width := 140;
   Height := 25;
   Caption := 'Обновить';
   Parent := Form1;
   onClick := @btnOkClicked;
 end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
