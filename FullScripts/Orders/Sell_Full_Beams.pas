const
  CREATE_PRODUCTION_ORDER = 'SELECT PRODUCTIONORDERID FROM CREATE_PRODUCTION_ORDER(:ORDERID, :EMPLOYEEID)';
  DELETE_PRODUCTION_ORDER = 'EXECUTE PROCEDURE DELETE_PRODUCTION_ORDER(:ORDERID)';
  GET_STUFF = 'SELECT ID FROM STUFFS WHERE ARTICULID = :ID';
  DELETE_ITEMS_DETAILS = 'DELETE FROM ORDERS_ITEMS_DETAILS WHERE ORDERITEMID = :ORDERITEMID';
  DELETE_ORDERS_MATERIALS = 'DELETE FROM ORDERS_MATERIALS WHERE ORDERID = :ORDERID';
  UPDATE_ORDERS_ITEMS = 'UPDATE ORDERS_ITEMS SET COST = 0, TOTALCOST = 0, CALCPRICE = 0, USERPRICE = 0, DISCOUNTEDPRICE = 0, CALCTOTALPRICE = 0, USERTOTALPRICE = 0, TOTALPRICE = 0 WHERE ID = :ORDERITEMID';

var
  S: IomSession;
  Instance, OriginalOrder: IowOrder;
  ProdOrderId: Integer;
  ProdOrder: IowProductionOrder;
  StuffOrderItem: IowStuffOrderItem;
  OptBeam: IowBOMBeam;
  OptBulk: IowBOMBulk;

begin
  S := CreateObjectSession;

  for i := 0 to SelectedRecords.Count - 1 do begin
    OriginalOrder := S.OpenObject(IowOrder, SelectedRecords[i]['ID']);
    OriginalOrder.Take();

    Instance := OriginalOrder.Duplicate(S);
    Instance.Take();
    Instance.Recalculate(empty);
    Instance.Apply();
    Instance.Name := OriginalOrder.Name + '-' + VarToStr(Instance.Key);

    ProdOrderId := S.QueryValue(CREATE_PRODUCTION_ORDER, MakeDictionary(['ORDERID', Instance.Key]));

    ProdOrder := S.OpenObject(IowProductionOrder, ProdOrderId);
    ProdOrder.Take;
    ProdOrder.Optimize(empty);
    ProdOrder.Apply();

    for j := 0 to ProdOrder.OptimizedBeams.Count - 1 do begin
      OptBeam := ProdOrder.OptimizedBeams[j];

      StuffOrderItem := Instance.Items.AddStuff(S.OpenObject(IowStuff, S.QueryValue(GET_STUFF, MakeDictionary(['ID', OptBeam.Articul.Key]))));
      StuffOrderItem.SizeFloat := OptBeam.Size.Factor / OptBeam.Measure.Factor;
      StuffOrderItem.Quantity := OptBeam.NumberOfBlanks;
      StuffOrderItem.InnerColor := OptBeam.InnerColor;
      StuffOrderItem.OuterColor := OptBeam.OuterColor;
      StuffOrderItem.Recalculate(empty);
      StuffOrderItem.Apply();
    end;

    for j := 0 to ProdOrder.OptimizedBulks.Count - 1 do begin
      OptBulk := ProdOrder.OptimizedBulks[j];

      StuffOrderItem := Instance.Items.AddStuff(S.OpenObject(IowStuff, S.QueryValue(GET_STUFF, MakeDictionary(['ID', OptBulk.Articul.Key]))));
      StuffOrderItem.Size := 1 * OptBulk.Measure.Factor;
      StuffOrderItem.Quantity := Round(OptBulk.Quantity);
      StuffOrderItem.InnerColor := OptBulk.InnerColor;
      StuffOrderItem.OuterColor := OptBulk.OuterColor;
      StuffOrderItem.Recalculate(empty);
      StuffOrderItem.Apply();
    end;

    //S.ExecSQL(DELETE_ORDERS_MATERIALS, MakeDictionary(['ORDERID', Instance.Key]));
    //S.ExecSQL(DELETE_PRODUCTION_ORDER, MakeDictionary(['ORDERID', Instance.Key]));

    for j := 0 to Instance.Items.Count - 1 do begin
      if (Instance.Items[j].Type.Name = 'Окно') or (Instance.Items[j].Type.Name = 'Оконная конструкция') then begin
        Instance.Items[j].Price := 0;
        Instance.Items[j].TotalPrice := 0;
        Instance.Items[j].Apply();
        //S.ExecSQL(DELETE_ITEMS_DETAILS, MakeDictionary(['ORDERITEMID', Instance.Items[j].Key]));
        S.ExecSQL(UPDATE_ORDERS_ITEMS, MakeDictionary(['ORDERITEMID', Instance.Items[j].Key]));
      end;
    end;

    Instance.Apply();
  end;

  S.Commit;
end;