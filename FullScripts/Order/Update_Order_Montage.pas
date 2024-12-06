{
  * Скрипт позволяет назначать монтаж заказу, открывая календарь с монтажными бригадами.
  * После назначения исполнителя выставляется плановое время и исполнитель монтажа в диспетчеризации заказа
}
var
  Montage: IowOrderStatusPlanResult;

begin
  Montage := SelectOrderStatusPlanDate('Installation', Date + 1, Instance.Key);
  if Montage <> Empty then begin
    for i := 0 to Instance.StatusList.Count - 1 do begin
      if Instance.StatusList.Items[i].OrderStatus.Name = 'Монтаж' then begin
        Instance.StatusList.Items[i].PlanDate := Montage.Date;
        Instance.StatusList.Items[i].PlanTime := Montage.Time;
        Instance.StatusList.Items[i].PlanDuration := Montage.Duration;
        if Montage.ExecutorId <> -1 then begin
          Instance.StatusList.Items[i].Executor := Instance.Session.OpenObject('IowEmployee', Montage.ExecutorId);
        end else begin
          Instance.StatusList.Items[i].Executor := null;
        end;
        Instance.StatusList.Items[i].apply;
      end;
    end;
  end;
end;
