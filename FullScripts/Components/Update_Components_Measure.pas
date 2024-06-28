const
  UPDATE_ARTICULES = 'UPDATE VIRTARTICULES V SET V.DOPMEASUREID = :DOPMEASUREID WHERE V.ARTICULID = :SELECTID';

var
  ObjectsUIService: IpubObjectsUIService;
  MU: IowMeasureUnit;
  SQLparams: IcmDictionary;
  S: IomSession;

begin
  S := CreateObjectSession;
  SQLparams := CreateDictionary;
  ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
  MU := ObjectsUIService.SelectObject('IowMeasureUnit');

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      SQLparams.Clear;
      SQLparams.Add('SELECTID', SelectedRecords.Items[i]['ARTICULID']);
      SQLparams.Add('DOPMEASUREID', MU.key);
      S.ExecSQL(UPDATE_ARTICULES, SQLparams);
    end;
    //showmessage('Обновлено записей: ' + IntToStr(SelectedRecords.Count));
    S.Commit;
  except
    S.Rollback;
  end;
end;
