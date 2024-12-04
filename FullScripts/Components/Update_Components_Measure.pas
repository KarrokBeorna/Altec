{
 * Для всех выделенных записей в представлении "Компоненты" можно поменять
 * единицу измерения вне зависимости от того, чем он был раньше и куда он был
 * добавлен.
 *
 * Однако помните, что формулы "Состава" и "Наборов" могут поломаться.
 * Возможно, что-то сломается и в "Ценах на покрытие", если вы переводите
 * компонент с единицы измерения "Длина", на какую-нибудь другую
}

const
  UPDATE_ARTICULES = 'UPDATE VIRTARTICULES V SET V.DOPMEASUREID = :DOPMEASUREID WHERE V.ARTICULID = :SELECTID';

var
  ObjectsUIService: IpubObjectsUIService;
  MU: IowMeasureUnit;
  S: IomSession;

begin
  S := CreateObjectSession;
  ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
  MU := ObjectsUIService.SelectObject('IowMeasureUnit');

  try
    for i := 0 to SelectedRecords.Count - 1 do begin
      S.ExecSQL(UPDATE_ARTICULES, MakeDictionary(['SELECTID', SelectedRecords.Items[i]['ARTICULID'],
                                                  'DOPMEASUREID', MU.key]));
    end;
    S.Commit;
  except
    S.Rollback;
  end;
end;
