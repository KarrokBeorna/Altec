{
  * Скрипт позволяет создать набор из карточки "Прочего компонента"
  *
  * - Наименование, артикул и сторонность цвета набора берутся из карточки "Прочего компонента"
  * - Разрешается использовать как дополнение
  * - В комплектующие попадает выбранный артикул с количеством 1, а также размером 0, если его единица измерения с типом "Длина"
}

var
  S: IomSession;
  ViewsUIService: IpubViewsUIService;
  ObjectsUIService: IpubObjectsUIService;
  ST: IowSetType;
  STI: IowSetTypeItem;

begin
  S := CreateObjectSession();
  ST := S.NewObject(IowSetType);

  ST.Name := Instance.Name;
  ST.Marking := Instance.Marking;
  ST.AllowUseAsExtra := True;
  ST.ColorType := Instance.ColorType;

  STI := ST.Items.Add(S.OpenObject(IowArticul, Instance.Key));
  STI.QuantityFormula := '1';
  if Instance.Measure.MeasureType.Key <> 4 then STI.SizeFormula := '0';
  STI.Apply;

  ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
  ObjectsUIService.EditObject(ST);
end;
