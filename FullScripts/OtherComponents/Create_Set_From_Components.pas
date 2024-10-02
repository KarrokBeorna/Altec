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
