{
  * Скрипт позволяет создать товар из карточки "Прочего компонента"
  *
  * - Компонентом выступает сам "Прочий компонент"
  * - Цена берётся закупочная, если она не равна нулю, иначе выставляется ноль
  * - Группа переоценки берется из "Прочего компонента", и если она присутствует, то продажная цена будет равна умножению закупочной цены на модификатор группы переоценки
  * - Тип компонента берется первым из существующих в базе
}

var
  S: IomSession;
  KitID : integer;
  ObjectsUIService: IpubObjectsUIService;
  Stuff: IowStuff;
  LS: BOOLEAN;

begin
  S := CreateObjectSession();
  Stuff := S.NewObject(IowStuff);

  KitID := S.QueryValue('SELECT MIN(ID) FROM KITTYPES WHERE DELETED = 0', Empty);

  Stuff.Articul := S.OpenObject(IowArticul, Instance.Key);

  if VarIsClear(Instance.Price) or VarIsNull(Instance.Price) then begin
    Stuff.Price := 0;
  end else if VarIsClear(Instance.RecalcGroup) or VarIsNull(Instance.RecalcGroup) then begin
    Stuff.Price := Instance.Price;
  end else begin
    Stuff.Price := Instance.Price * Instance.RecalcGroup.Factor;
  end;

  try
    Stuff.KitType := S.OpenObject(IowKitType, KitID);
    ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
    LS := ObjectsUIService.EditObject(Stuff);
  except
    showmessage('Занесите какой-либо тип комплектации в разделе "Справочники - Типы комплектации"');
    Logoff;
  end;
end;
