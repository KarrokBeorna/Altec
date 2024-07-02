var
  S: IomSession;
  KitID : integer;
  ObjectsUIService: IpubObjectsUIService;
  Stuff: IowStuff;

begin
    S := CreateObjectSession();
    Stuff := S.NewObject(IowStuff);

    KitID := S.QueryValue('SELECT MIN(ID) FROM KITTYPES WHERE DELETED = 0', Empty);

    Stuff.Articul := S.OpenObject(IowArticul, Instance.Key);
    Stuff.Price := Instance.Price * Instance.RecalcGroup.Factor;
    Stuff.KitType := S.OpenObject(IowKitType, KitID);

    ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
    ObjectsUIService.EditObject(Stuff);
end;
