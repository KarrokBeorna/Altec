{
  * Скрипт позволяет создавать ОДНУ производственную группу сразу из всех
  * свободных элементов всех выделенных заказов в производстве.
  * При этом дата запуска принудительно устанавливается на следующий день.
}

var
  S: IomSession;
  group: IowProductionGroup;
  groupItem: IowProductionGroupItem;
  prodOrder: IowProductionOrder;
  prodOrderItem: IowProductionOrderItem;
  ViewsUIService: IpubViewsUIService;
  ObjectsUIService: IpubObjectsUIService;

begin
  S := CreateObjectSession();
  group := S.NewObject('IowProductionGroup');

  for i := 0 to SelectedRecords.count - 1 do begin
    prodOrder := S.OpenObject('IowProductionOrder', SelectedRecords[i].Value['ID']);

    for j := 0 to prodOrder.Items.Count - 1 do begin
      prodOrderItem := prodOrder.Items.Items[j];
      q := prodOrderItem.Quantity - prodOrderItem.UsedQuantity;

      if q > 0 then begin
        groupItem := group.Items.Add(prodOrderItem);
        groupItem.Quantity := q;
        groupItem.Apply;
      end;
    end;
  end;

  ViewsUIService := ServiceProvider.GetService(IpubViewsUIService);
  ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);

  if not ViewsUIService.ActivateView('ProductionGroups') then
    ViewsUIService.OpenView('ProductionGroups', True)
  else
    ViewsUIService.RefreshActiveView;

  group.Date := Now + 1;
  ObjectsUIService.EditObject(group);
end.
