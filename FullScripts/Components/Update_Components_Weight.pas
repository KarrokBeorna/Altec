{
 * Для всех выделенных записей в представлении "Компоненты" устанавливает
 * вес, равным значению из поля для ввода.
 * Если поле оставить пустым, то вес выставится нулевым.
}

const
  UPDATE_ARTICULES = 'UPDATE VIRTARTICULES V SET V.WEIGHT = :WEIGHT WHERE V.ARTICULID = :SELECTID';

var
  Form1: TForm;
  btnOk: TButton;
  WeightPanel: TGroupBox;
  Weight: TRichEdit;
  Session: IomSession;
  text: variant;

procedure btnOkClicked(Sender: TOBject);
begin
  Session := CreateObjectSession;

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      if TRIM(Weight.Lines.Text) <> '' then begin
        text := Weight.Lines.Text;
      end else begin
        text := Null;
      end;

      Session.ExecSQL(UPDATE_ARTICULES, MakeDictionary(['SELECTID', SelectedRecords.Items[i]['ARTICULID'],
                                                        'WEIGHT', text]));
    end;
    Session.Commit;
    Form1.close;
  except
    Session.Rollback;
    ShowMessage('Оставьте поле пустым или ведите целочисленное значение веса');
  end;
end;

begin
Form1 := TForm.Create(Application);
 with Form1 do begin
   Width := 205;
   Height := 120;
   caption := 'Вес';
   position := poScreenCenter;
   BorderIcons := biSystemMenu;
 end;

WeightPanel := TGroupBox.Create(Application);
 with WeightPanel do begin
   Width := 180;
   Height := 40;
   Top := 2;
   Left := 5;
   caption := 'Введите вес в граммах';
   Parent := Form1;
 end;

Weight := TRichEdit.Create(Application);
 with Weight do begin
   Left := 5;
   Top := 15;
   Width := 170;
   height := 20;
   Parent := WeightPanel;
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