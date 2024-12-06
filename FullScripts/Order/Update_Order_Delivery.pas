{
  * Скрипт позволяет назначать доставку заказу, открывая календарь с доставщиками.
  * После назначения доставщика выставляется плановое время и исполнитель доставки в диспетчеризации заказа
}

var
  Delivery: IowOrderStatusPlanResult;

begin
  Delivery := SelectOrderStatusPlanDate('Delivery', Date + 1, Instance.Key);
  if Delivery <> Empty then begin
    for i := 0 to Instance.StatusList.Count - 1 do begin
      if Instance.StatusList.Items[i].OrderStatus.Name = 'Доставка' then begin
        Instance.StatusList.Items[i].PlanDate := Delivery.Date;
        Instance.StatusList.Items[i].PlanTime := Delivery.Time;
        Instance.StatusList.Items[i].PlanDuration := Delivery.Duration;
        if Delivery.ExecutorId <> -1 then begin
          Instance.StatusList.Items[i].Executor := Instance.Session.OpenObject('IowEmployee', Delivery.ExecutorId);
        end else begin
          Instance.StatusList.Items[i].Executor := null;
        end;
        Instance.StatusList.Items[i].apply;
      end;
    end;
  end;
end;
