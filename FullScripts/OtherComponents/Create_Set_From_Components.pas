{
  * В представлении "Прочие компоненты" по выделенным элементам создастся набор, где
  * - артикулом будет артикул верхнего выделенного элемента
  * - наименованием будет наименование верхнего выделенного элемента
  * - разрешаем использовать в качестве дополнения
  * - сторонность цвета будет также взята у верхнего выделенного элемента
  * - в комплектующие попадут все выделенные элементы, где
  *   - Артикул и наименование возьмутся у выделенного элемента
  *   - Количество равно 1
  *   - Размер будет заполнен в зависимости от единицы измерения элемента
  *
  * В конце будет открываться карточка создаваемого набора
}

var
  ViewsUIService: IpubViewsUIService;
  ObjectsUIService: IpubObjectsUIService;
  ST: IowSetType;
  STI: IowSetTypeItem;
  Instance: IowArticul;
  S: IomSession;

begin
  S := CreateObjectSession();
  ST := S.NewObject(IowSetType);
  Instance := S.OpenObject(IowArticul, SelectedRecords.items[0].value['ARTICULID']);

  ST.Name := Instance.Name;
  ST.Marking := Instance.Marking;
  ST.AllowUseAsExtra := True;
  ST.ColorType := Instance.ColorType;
  ST.apply;

  for i := 0 to SelectedRecords.count - 1 do begin
    Instance := S.OpenObject(IowArticul, SelectedRecords.items[i].value['ARTICULID']);
    STI := ST.Items.Add(Instance);
    STI.QuantityFormula := '1';
    if Instance.Measure.MeasureType.Key <> 4 then STI.SizeFormula := '0';
    STI.Apply;
  end;

  ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
  ObjectsUIService.EditObject(ST);
end;
