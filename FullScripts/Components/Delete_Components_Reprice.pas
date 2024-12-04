{
 * Для всех выделенных записей в представлении "Компоненты" удаляет группу переоценки.
}

const
  UPDATE_ARTICULES = 'UPDATE VIRTARTICULES V SET V.WGRPRICEID = :WGRPRICEID WHERE V.ARTICULID = :SELECTID';

var
  S: IomSession;

begin
  S := CreateObjectSession;

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      S.ExecSQL(UPDATE_ARTICULES, MakeDictionary(['SELECTID', SelectedRecords.Items[i]['ARTICULID'],
                                                  'WGRPRICEID', Null]));
    end;
    S.Commit;
  except
    S.Rollback;
  end;
end;
