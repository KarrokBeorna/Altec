{
 * Для всех выделенных записей в представлении "Компоненты" можно
 * установить одну группу переоценки.
}

const
  UPDATE_ARTICULES = 'UPDATE VIRTARTICULES V SET V.WGRPRICEID = :WGRPRICEID WHERE V.ARTICULID = :SELECTID';

var
  ObjectsUIService: IpubObjectsUIService;
  RG: IowRecalcGroup;
  S: IomSession;

begin
  S := CreateObjectSession;
  SQLparams := CreateDictionary;
  ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
  RG := ObjectsUIService.SelectObject('IowRecalcGroup');

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      S.ExecSQL(UPDATE_ARTICULES, MakeDictionary(['SELECTID', SelectedRecords.Items[i]['ARTICULID'],
                                                  'WGRPRICEID', RG.key]));
    end;
    S.Commit;
  except
    S.Rollback;
  end;
end;
