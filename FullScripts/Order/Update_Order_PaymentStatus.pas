begin
  if Instance.Payment > 0 then begin
    for i := 0 to Instance.StatusList.Count - 1 do begin
      if Instance.StatusList.Items[i].OrderStatus.Name = 'Оплата' then begin
        Instance.StatusList.Items[i].FactDate := Now;
        Instance.StatusList.Items[i].Comment := 'На текущий момент долг составляет: ' + varToStr(Instance.Debt);
        Instance.StatusList.Items[i].apply;
      end;
    end;
  end;
end.
