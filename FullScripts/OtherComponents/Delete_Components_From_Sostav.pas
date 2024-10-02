const
  DELETE_FROM_SOSTAV = 'DELETE FROM E_VALUES WHERE EVID IN (SELECT ARTICULID FROM VIRTARTICULES WHERE AR_ART IN (';

var
  objectsIDs: String;
  S: IomSession;


begin
  objectsIDs := '';
  S := CreateObjectSession();

  for i := 0 to SelectedRecords.Count - 1 do begin
    if objectsIDs <> '' then objectsIDs := objectsIDs + ', ';
    objectsIDs := objectsIDs + '''' + SelectedRecords.Items[i].Value['AR_ART'] + '''';
  end;

  try
    S.ExecSQL(DELETE_FROM_SOSTAV + objectsIDs + '))', empty);
    S.Commit;
  except
    S.Rollback;
  end;
end.
