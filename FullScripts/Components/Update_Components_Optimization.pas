const
  UPDATE_ARTICUL = 'UPDATE VIRTARTICULES V'                                + #13#10 +
                   'SET V.OG_ID = :OG_ID, V.BEAMSIZEID = :BEAMSIZEID'      + #13#10 +
                   'WHERE V.ARTICULID = :SELECTID AND V.DOPMEASUREID IN (' + #13#10 +
                   '  SELECT'                                              + #13#10 +
                   '    DOPMEASUREID'                                      + #13#10 +
                   '  FROM DOPMEASURE D'                                   + #13#10 +
                   '    JOIN MEASURE M ON D.MEASUREID = M.MEASUREID'       + #13#10 +
                   '  WHERE M.MEASUREID = 2'                               + #13#10 +
                   ')';

var
  S: IomSession;
  SQLparams: IcmDictionary;
  ObjectsUIService: IpubObjectsUIService;
  OG: IowOptimizationGroup;
  MU: IowMeasureUnit;

begin
  S := CreateObjectSession;
  SQLparams := CreateDictionary;
  ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
  OG := ObjectsUIService.SelectObject('IowOptimizationGroup');
  MU := ObjectsUIService.SelectObject('IowMeasureUnit');

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      SQLparams.Clear;
      SQLparams.Add('SELECTID', SelectedRecords.Items[i]['ARTICULID']);
      SQLparams.Add('OG_ID', OG.key);
      SQLparams.Add('BEAMSIZEID', MU.key);
      S.ExecSQL(UPDATE_ARTICUL, SQLparams);
    end;
    //showmessage('Обновлено записей: ' + IntToStr(SelectedRecords.Count));
    S.Commit;
  except
    S.Rollback;
  end;
end;
