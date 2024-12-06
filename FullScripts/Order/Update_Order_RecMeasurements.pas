{
  * Скрипт позволяет назначать замер заказу, открывая календарь с замерщиками.
  * После назначения замерщика выставляется исполнитель и время замера в диспетчеризации заказа
}

var
  Metering: IowOrderStatusPlanResult;

begin
  Metering := SelectOrderStatusPlanDate('Metering', Date + 1, Instance.Key);
  if Metering <> Empty then begin
    for i := 0 to Instance.StatusList.Count - 1 do begin
      if Instance.StatusList.Items[i].OrderStatus.Name = 'Замер' then begin
        Instance.StatusList.Items[i].PlanDate := Metering.Date;
        Instance.StatusList.Items[i].PlanTime := Metering.Time;
        Instance.StatusList.Items[i].PlanDuration := Metering.Duration;
        if Metering.ExecutorId <> -1 then begin
          Instance.StatusList.Items[i].Executor := Instance.Session.OpenObject('IowEmployee', Metering.ExecutorId);
        end else begin
          Instance.StatusList.Items[i].Executor := null;
        end;
        Instance.StatusList.Items[i].apply;
      end;
    end;
  end;
end;
