const
  NULL_CART_CELL = 'UPDATE BOM_BEAMS_BLANKS_DETAILS SET CARTNUM = NULL, CELLNUM = NULL                 ' + #13#10 +
                   'WHERE PRODUCTIONORDERITEMDETAILID IN (                                             ' + #13#10 +
                   '  SELECT                                                                           ' + #13#10 +
                   '    POID.ID                                                                        ' + #13#10 +
                   '  FROM                                                                             ' + #13#10 +
                   '    PRODUCTION_ORDERS_ITEMS_DETAILS POID                                           ' + #13#10 +
                   '      JOIN PRODUCTION_ORDERS_ITEMS POI ON POI.ID = POID.PRODUCTIONORDERITEMID      ' + #13#10 +
                   '      JOIN PRODUCTION_GROUPS_ITEMS PGI ON PGI.PRODUCTIONORDERITEMID = POI.ID       ' + #13#10 +
                   '  WHERE                                                                            ' + #13#10 +
                   '    PGI.PRODUCTIONGROUPID = :PRODUCTIONGROUPID                                     ' + #13#10 +
                   ')';

  GET_CART_CELL = 'SELECT DISTINCT                       ' + #13#10 +
                  '  BBBD.CARTNUM AS CART,               ' + #13#10 +
                  '  BBBD.CELLNUM AS CELL                ' + #13#10 +
                  'FROM                                  ' + #13#10 +
                  '  BOM_BEAMS_BLANKS_DETAILS BBBD       ' + #13#10 +
                  'WHERE                                 ' + #13#10 +
                  '  BBBD.CARTNUM IS NOT NULL            ' + #13#10 +
                  'ORDER BY                              ' + #13#10 +
                  '  CART, CELL';

  GET_BEAMS  = 'SELECT                                                                                                                                 ' + #13#10 +
               '  OIU.ID AS UNITID,                                                                                                                    ' + #13#10 +
               '  IIF(PWR.SHORTTAG IN (''Иг'', ''Ив''), ''И'', PWR.SHORTTAG) || IIF(PWR.SHORTTAG = ''C'', ''-'' || POID.WINDOWPARTNO, '''') AS PIECE,  ' + #13#10 +
               '  BBBD.ID,                                                                                                                             ' + #13#10 +
               '  BBBD.WINDOWNUM,                                                                                                                      ' + #13#10 +
               '  CASE PWR.ITEMNAME                                                                                                                    ' + #13#10 +
               '    WHEN ''Рама'' THEN 1                                                                                                               ' + #13#10 +
               '    WHEN ''Створка'' THEN 2                                                                                                            ' + #13#10 +
               '    WHEN ''Импост вертикальный'' THEN 3                                                                                                ' + #13#10 +
               '    WHEN ''Импост горизонтальный'' THEN 3                                                                                              ' + #13#10 +
               '    ELSE 4                                                                                                                             ' + #13#10 +
               '  END AS "SORT",                                                                                                                       ' + #13#10 +
               '  EFR.FR_NAME                                                                                                                          ' + #13#10 +
               'FROM                                                                                                                                   ' + #13#10 +
               '  BOM_BEAMS BB                                                                                                                         ' + #13#10 +
               '    JOIN BOM_BEAMS_BLANKS BBB ON BBB.BOMBEAMID = BB.ID                                                                                 ' + #13#10 +
               '    JOIN BOM_BEAMS_BLANKS_DETAILS BBBD ON BBBD.BOMBEAMBLANKID = BBB.ID + 0                                                             ' + #13#10 +
               '    JOIN PRODUCTION_ORDERS_ITEMS_DETAILS POID ON POID.ID = BBBD.PRODUCTIONORDERITEMDETAILID                                            ' + #13#10 +
               '    JOIN PRODUCTION_ORDERS_ITEMS POI ON POI.ID = POID.PRODUCTIONORDERITEMID                                                            ' + #13#10 +
               '    JOIN ORDERS_ITEMS_UNITS OIU ON OIU.ID = POI.ORDERITEMUNITID                                                                        ' + #13#10 +
               '      LEFT JOIN ORDERS_ITEMS_UNITS OIU2 ON OIU2.ID = OIU.PARENTWINDOWID                                                                ' + #13#10 +
               '    LEFT JOIN PARTWINDOWREP PWR ON PWR.PARTWINDREPID = POID.PARTWINDREPID                                                              ' + #13#10 +
               '    LEFT JOIN E_FORREPORT EFR ON EFR.REPORTID = POID.REPORTID                                                                          ' + #13#10 +
               'WHERE                                                                                                                                  ' + #13#10 +
               '  BB.PRODUCTIONGROUPID = :PGID                                                                                                         ' + #13#10 +
               'ORDER BY                                                                                                                               ' + #13#10 +
               '  UNITID,                                                                                                                              ' + #13#10 +
               '  BBBD.WINDOWNUM,                                                                                                                      ' + #13#10 +
               '  "SORT",                                                                                                                              ' + #13#10 +
               '  PIECE,                                                                                                                               ' + #13#10 +
               '  EFR.POSIT';

  SET_CART_CELL = 'UPDATE BOM_BEAMS_BLANKS_DETAILS SET CARTNUM = :CART, CELLNUM = :CELL  ' + #13#10 +
                  'WHERE ID = :ID';

  NUM_OF_CARTS = 48;
  NUM_OF_CELLS = 32;
  NUM_OF_TYPES_CARTS = 6;


var
  S: IomSession;
  Beams, CartCellsDL: IcmDictionaryList;
  CartCellsSL: TStringList;
  PrevUnit, PrevWindowNum, PrevSort, FreeCart, FreeCell: Integer = 0;
  PrevPiece, PrevFrName: String = '';
  Stop: Boolean;

procedure UpdateFreeCartCells(_Mod: Integer);
begin
  Stop := False;
  for k := 1 to NUM_OF_CARTS do begin
    if (k mod NUM_OF_TYPES_CARTS = _Mod) then begin
      if Stop then Break;
      for z := 1 to NUM_OF_CELLS do begin
        if CartCellsSL.IndexOf(VarToStr(k) + '-' + VarToStr(z)) < 0 then begin
          CartCellsSL.Add(VarToStr(k) + '-' + VarToStr(z));
          FreeCart := k;
          FreeCell := z;
          Stop := True;
          Break;
        end;
      end;
    end;
  end;
end;

begin
  S := CreateObjectSession();

  for i := 0 to SelectedRecords.Count - 1 do begin
    S.ExecSQL(NULL_CART_CELL, MakeDictionary(['PRODUCTIONGROUPID', SelectedRecords[i]['ID']]));
  end;

  S.Commit();


  for i := 0 to SelectedRecords.Count - 1 do begin
    Beams := S.QueryRecordList(GET_BEAMS, MakeDictionary(['PGID', SelectedRecords[i]['ID']]));

    CartCellsDL := S.QueryRecordList(GET_CART_CELL, empty);
    CartCellsSL := TStringList.Create;

    for j := 0 to CartCellsDL.Count - 1 do begin
      CartCellsSL.Add(VarToStr(CartCellsDL[j]['CART']) + '-' + VarToStr(CartCellsDL[j]['CELL']));
    end;

    for j := 0 to Beams.Count - 1 do begin
      if (PrevUnit <> Beams[j]['UNITID']) or
         (PrevWindowNum <> Beams[j]['WINDOWNUM']) or
         (PrevFrName <> Beams[j]['FR_NAME']) or
         (PrevSort <> Beams[j]['SORT']) or
         ((Copy(PrevPiece, 0, 1) = 'C') and(PrevPiece <> Beams[j]['PIECE'])) then begin

        PrevUnit := Beams[j]['UNITID'];
        PrevWindowNum := Beams[j]['WINDOWNUM'];
        PrevPiece := Beams[j]['PIECE'];
        PrevFrName := Beams[j]['FR_NAME'];
        PrevSort := Beams[j]['SORT'];

                 {showmessage(VarToStr(PrevUnit) + ' - ' +
                     VarToStr(PrevWindowNum) + ' - ' +
                     VarToStr(PrevFrName) + ' - ' +
                     VarToStr(PrevSort) + ' - ' +
                     VarToStr(PrevPiece));  }

        if (PrevFrName = 'Профили') and (PrevSort < 3) then begin
          UpdateFreeCartCells(1);
        end;

        if (PrevFrName = 'Армирование') and (PrevSort < 3) then begin
          UpdateFreeCartCells(2);
        end;

        if (PrevFrName = 'Профили') and (PrevSort = 3) then begin
          UpdateFreeCartCells(3);
        end;

        if (PrevFrName = 'Армирование') and (PrevSort = 3) then begin
          UpdateFreeCartCells(4);
        end;

        if (PrevFrName = 'Профили') and (PrevSort > 3) then begin
          UpdateFreeCartCells(5);
        end;

        if (PrevFrName = 'Армирование') and (PrevSort > 3) then begin
          UpdateFreeCartCells(0);
        end;
      end;

      S.ExecSQL(SET_CART_CELL, MakeDictionary(['CART', FreeCart, 'CELL', FreeCell, 'ID', Beams[j]['ID']]));
    end;
  end;

  S.Commit();
end;