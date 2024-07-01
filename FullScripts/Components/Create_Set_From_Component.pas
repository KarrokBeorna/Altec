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

  STI := ST.Items.Add(S.OpenObject(IowArticul, Instance.Key));
  STI.QuantityFormula := '1';
  STI.SizeFormula := '0';
  STI.Apply;

  ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
  ObjectsUIService.EditObject(ST);
end;
