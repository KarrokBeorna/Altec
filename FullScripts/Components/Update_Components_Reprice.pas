const
  UPDATE_ARTICULES = 'UPDATE VIRTARTICULES V SET V.WGRPRICEID = :WGRPRICEID WHERE V.ARTICULID = :SELECTID';

var
  ObjectsUIService: IpubObjectsUIService;
  RG: IowRecalcGroup;
  SQLparams: IcmDictionary;
  S: IomSession;

begin
  S := CreateObjectSession;
  SQLparams := CreateDictionary;
  ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
  RG := ObjectsUIService.SelectObject('IowRecalcGroup');

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      SQLparams.Clear;
      SQLparams.Add('SELECTID', SelectedRecords.Items[i]['ARTICULID']);
      SQLparams.Add('WGRPRICEID', RG.key);
      S.ExecSQL(UPDATE_ARTICULES, SQLparams);
    end;
    showmessage('Обновлено записей: ' + IntToStr(SelectedRecords.Count));
    S.Commit;
  except
    S.Rollback;
    showmessage('Что-то пошло не так');
  end;
end;
