const
  UPDATE_CART_CELL = 'UPDATE BOM_BEAMS_BLANKS_DETAILS SET CARTNUM = NULL, CELLNUM = NULL                   ' + #13#10 +
                     'WHERE PRODUCTIONORDERITEMDETAILID IN (                                               ' + #13#10 +
                     '  SELECT                                                                             ' + #13#10 +
                     '    POID.ID                                                                          ' + #13#10 +
                     '  FROM                                                                               ' + #13#10 +
                     '    PRODUCTION_ORDERS_ITEMS_DETAILS POID                                             ' + #13#10 +
                     '      JOIN PRODUCTION_ORDERS_ITEMS POI ON POI.ID = POID.PRODUCTIONORDERITEMID        ' + #13#10 +
                     '  WHERE                                                                              ' + #13#10 +
                     '    POI.PRODUCTIONORDERID = :PRODUCTIONORDERID                                       ' + #13#10 +
                     ')';

begin
  Session.ExecSQL(UPDATE_CART_CELL, MakeDictionary(['PRODUCTIONORDERID', ProductionOrderId]));
  Session.Commit();
end;