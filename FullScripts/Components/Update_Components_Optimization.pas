{
 * Для всех выделенных записей в представлении "Компоненты" можно поменять группу
 * оптимизации и длину хлыста, однако это применится лишь к тем артикулам, у кого
 * единица измерения из группы "Длина"
}

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
  ObjectsUIService: IpubObjectsUIService;
  OG: IowOptimizationGroup;
  MU: IowMeasureUnit;

begin
  S := CreateObjectSession;
  ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
  OG := ObjectsUIService.SelectObject('IowOptimizationGroup');
  MU := ObjectsUIService.SelectObject('IowMeasureUnit');

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      S.ExecSQL(UPDATE_ARTICUL, MakeDictionary(['SELECTID', SelectedRecords.Items[i]['ARTICULID'],
                                                'OG_ID', OG.key,
                                                'BEAMSIZEID', MU.key]));
    end;
    S.Commit;
  except
    S.Rollback;
  end;
end;
