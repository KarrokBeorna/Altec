var
  S: IomSession;
  Kit: IowKitType;
  ObjectsUIService: IpubObjectsUIService;
  Stuff: IowStuff;
  MarkupGroup: IowMarkupGroup;

begin
  S := CreateObjectSession();
  ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
  Kit := ObjectsUIService.SelectObject('IowKitType');
  MarkupGroup := ObjectsUIService.SelectObject('IowMarkupGroup');

  for i := 0 to SelectedRecords.count - 1 do begin
    Instance := S.OpenObject(IowArticul, SelectedRecords[i].value['ARTICULID']);
    try
      Stuff := S.NewObject(IowStuff);
      Stuff.Articul := S.OpenObject(IowArticul, Instance.Key);

      Stuff.MarkupGroup := MarkupGroup;

      {if VarIsClear(Instance.Price) or VarIsNull(Instance.Price) then begin
        Stuff.Price := 0;
      end else if VarIsClear(Instance.RecalcGroup) or VarIsNull(Instance.RecalcGroup) then begin
        Stuff.Price := Instance.Price * 2;
      end else begin
        Stuff.Price := Instance.Price * Instance.RecalcGroup.Factor * 2;
      end;}

      Stuff.KitType := Kit;
      Stuff.AllowUseAsExtra := True;

      Stuff.Apply();
    except
    end;
  end;

  S.Commit();
end;