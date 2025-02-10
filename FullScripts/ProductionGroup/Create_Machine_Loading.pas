{
  * Скрипт выгружает у всех выделенных групп оптимизированные материалы
  * в CSV-файл с разделителем ";".
  *
  * Выгружаемые данные:
  * - Номер балки по порядку (от 001 до 999)
  * - Заказчик
  * - Номер заказа
  * - Артикул балки
  * - Положение балки + наименование части балки
  * - Длина балки
  * - Левый угол балки
  * - Правый угол балки
  * - Количество
  * - Длина хлыста
  *
  * На диалоговой форме можно выбирать все необходимые части изделия
  * В том числе на диалоговой форме регулируется, нужно ли выводить армирование
}

const
  GET_BEAMS = 'SELECT                                                                                                         ' + #13#10 +
              '  C.CO_NAME AS CUSTOMER,                                                                                       ' + #13#10 +
              '  PG.NAME || '' / '' || O.ORDNO AS JOB,                                                                        ' + #13#10 +
              '  VA.AR_ART AS ARTICUL,                                                                                        ' + #13#10 +
              '  IIF(P.SHORTNAME IS NOT NULL AND P.SHORTNAME <> '''', P.SHORTNAME || '' '', '''') || PWR.ITEMNAME AS PIECE,   ' + #13#10 +
              '  POID."LENGTH",                                                                                               ' + #13#10 +
              '  POID.ANGLE1,                                                                                                 ' + #13#10 +
              '  POID.ANGLE2,                                                                                                 ' + #13#10 +
              '  POID.QUANTITY,                                                                                               ' + #13#10 +
              '  BBB."LENGTH" AS PROFILE_LENGTH,                                                                              ' + #13#10 +
              '  BBBD.BOMBEAMBLANKID,                                                                                         ' + #13#10 +
              '  BBBD.ID,                                                                                                     ' + #13#10 +
              '  CASE PWR.ITEMNAME                                                                                            ' + #13#10 +
              '    WHEN ''Рама'' THEN 1                                                                                       ' + #13#10 +
              '    WHEN ''Створка'' THEN 2                                                                                    ' + #13#10 +
              '    WHEN ''Импост вертикальный'' THEN 3                                                                        ' + #13#10 +
              '    WHEN ''Импост горизонтальный'' THEN 3                                                                      ' + #13#10 +
              '    WHEN ''Штульп'' THEN 4                                                                                     ' + #13#10 +
              '    WHEN ''Порог'' THEN 5                                                                                      ' + #13#10 +
              '    WHEN ''Соединитель'' THEN 6                                                                                ' + #13#10 +
              '    WHEN ''Добор'' THEN 7                                                                                      ' + #13#10 +
              '    WHEN ''Заполнение'' THEN 8                                                                                 ' + #13#10 +
              '    WHEN ''Цоколь'' THEN 9                                                                                     ' + #13#10 +
              '    WHEN ''Проставочный брусок'' THEN 10                                                                       ' + #13#10 +
              '    ELSE 100                                                                                                   ' + #13#10 +
              '  END AS "SORT"                                                                                                ' + #13#10 +
              'FROM                                                                                                           ' + #13#10 +
              '  BOM_BEAMS BB                                                                                                 ' + #13#10 +
              '    JOIN BOM_BEAMS_BLANKS BBB ON BBB.BOMBEAMID = BB.ID                                                         ' + #13#10 +
              '    JOIN BOM_BEAMS_BLANKS_DETAILS BBBD ON BBBD.BOMBEAMBLANKID = BBB.ID                                         ' + #13#10 +
              '    JOIN PRODUCTION_ORDERS_ITEMS_DETAILS POID ON POID.ID = BBBD.PRODUCTIONORDERITEMDETAILID                    ' + #13#10 +
              '    JOIN PRODUCTION_ORDERS_ITEMS POI ON POI.ID = POID.PRODUCTIONORDERITEMID                                    ' + #13#10 +
              '    JOIN PRODUCTION_ORDERS PO ON PO.ID = POI.PRODUCTIONORDERID                                                 ' + #13#10 +
              '    JOIN ORDERS O ON O.ID = PO.ORDERID                                                                         ' + #13#10 +
              '    LEFT JOIN CONTRAGENTS C ON C.CONTRAGID = O.CUSTOMERID                                                      ' + #13#10 +
              '    JOIN PRODUCTION_GROUPS_ITEMS PGI ON PGI.PRODUCTIONORDERITEMID = POI.ID                                     ' + #13#10 +
              '    JOIN PRODUCTION_GROUPS PG ON PG.ID = PGI.PRODUCTIONGROUPID                                                 ' + #13#10 +
              '    JOIN VIRTARTICULES VA ON VA.ARTICULID = POID.ARTICULID                                                     ' + #13#10 +
              '    LEFT JOIN POSITIONS P ON P.POSITIONID = POID.POSITIONID                                                    ' + #13#10 +
              '    LEFT JOIN PARTWINDOWREP PWR ON PWR.PARTWINDREPID = POID.PARTWINDREPID                                      ' + #13#10 +
              '    LEFT JOIN E_FORREPORT EFR ON EFR.REPORTID = POID.REPORTID                                                  ' + #13#10 +
              'WHERE                                                                                                          ' + #13#10 +
              '';

  GET_BEAMS_SORT = 'ORDER BY                                                                                                  ' + #13#10 +
                   '  "SORT",                                                                                                 ' + #13#10 +
                   '  BBBD.ID,                                                                                                ' + #13#10 +
                   '  BBBD.BOMBEAMBLANKID';

  distBetweenCheckboxes = 18;

var
  S: IomSession;
  vFileName, SQL, itemnames: String;
  delimiter: String = ';';
  sFile, parts: TStringList;
  GROUP: IowProductionGroup;
  Item: IowProductionOrderItem;
  Order: IowOrder;
  Element: IowProductionOrderItemElement;
  numBeam: Integer = 1;
  beams: IcmDictionaryList;
  checkboxes: IcmDictionary;
  Form1: TForm;
  btnOk: TButton;
  cbAll: TCheckBox;

procedure btnOkClicked(Sender: TOBject);
begin
  if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите место сохранения', 'C:\', True) then begin
    S := CreateObjectSession;
    TITLE := 'Part Number' + delimiter +        // номер балки по порядку (от 001 до 999)
             'Customer' + delimiter +           // заказчик
             'Job' + delimiter +                // номер заказа
             'Articul' + delimiter +            // артикул балки
             'Piece' + delimiter +              // положение балки + наименование части балки
             'Length (mm)' + delimiter +        // длина балки
             'Left side angle' + delimiter +    // левый угол балки
             'Right side angle' + delimiter +   // правый угол балки
             'Quantity' + delimiter +           // количество
             'Profile length';                  // длина хлыста
    sFile := TStringList.Create;
    sFile.add(TITLE);

    // Модельная форма выгрузки
    {for i := 0 to SelectedRecords.count - 1 do begin
      GROUP := S.OpenObject(IowProductionGroup, SelectedRecords[i].value['ID']);

      for j := 0 to GROUP.Items.Count - 1 do begin
        Item := GROUP.Items[j].ProductionOrderItem;
        Order := Item.OrderItem.Order;

        customer := Item.OrderItem.Order.Customer;
        if not VarIsClear(customer) then begin
          customer := Order.Customer.Name;
        end else begin
          customer := '';
        end;

        for z := 0 to Item.Elements.Count - 1 do begin
          Element := Item.Elements[z];

          BeamSize := Element.Articul.BeamSize;
          if not VarIsClear(BeamSize) then begin
            BeamSize := Element.Articul.BeamSize.Factor;
          end else begin
            BeamSize := '';
          end;

          if Element.BeamLength > 0 then begin
            for k := 0 to Item.Quantity - 1 do begin
              sFile.add(FillLeft(varToStr(numBeam), '0', 3) + delimiter +
                        customer + delimiter +
                        Order.Name + delimiter +
                        varToStr(Element.Articul.Marking) + delimiter +
                        varToStr(Element.Position.Name + ' ' + Element.WindowPart) + delimiter +
                        varToStr(Element.BeamLength) + delimiter +
                        varToStr(Element.Angle1) + delimiter +
                        varToStr(Element.Angle2) + delimiter +
                        varToStr(Element.Quantity) + delimiter +
                        varToStr(Element.Articul.BeamSize.Factor)
              );
              numBeam := numBeam + 1;
            end;
          end;
        end;
      end;
    end;}

    // Форма выгрузки на основе SQL-запроса
    for i := 0 to SelectedRecords.count - 1 do begin
      SQL := GET_BEAMS + '  BB.PRODUCTIONGROUPID = ' + VarToStr(SelectedRecords[i].value['ID']) + #13#10;
      SQL := SQL + '  AND PWR.ITEMNAME IN (';

      itemnames := '';
      for j := 0 to parts.Count - 1 do begin
        if checkboxes[parts[j]].checked then begin
          if itemnames <> '' then itemnames := itemnames + ', ';
          if parts[j] = 'Штапик' then begin
            itemnames := itemnames + '''Заполнение''';
          end else begin
            itemnames := itemnames + '''' + parts[j] + '''';
          end;
        end;
      end;

      SQL := SQL + itemnames + ')' + #13#10;

      if not cbArm.checked then begin
        SQL := SQL + '  AND EFR.FR_NAME NOT IN (''Армирование'')' + #13#10;
      end;

      SQL := SQL + GET_BEAMS_SORT;

      beams := S.QueryRecordList(SQL, empty);

      for j := 0 to beams.count - 1 do begin
        sFile.add(FillLeft(varToStr(numBeam), '0', 3) + delimiter +
                  VarToStr(beams[j].Value['CUSTOMER']) + delimiter +
                  VarToStr(beams[j].Value['JOB']) + delimiter +
                  VarToStr(beams[j].Value['ARTICUL']) + delimiter +
                  VarToStr(beams[j].Value['PIECE']) + delimiter +
                  VarToStr(Round(beams[j].Value['LENGTH'])) + delimiter +
                  VarToStr(beams[j].Value['ANGLE1']) + delimiter +
                  VarToStr(beams[j].Value['ANGLE2']) + delimiter +
                  VarToStr(beams[j].Value['QUANTITY']) + delimiter +
                  VarToStr(beams[j].Value['PROFILE_LENGTH'])
        );
        numBeam := numBeam + 1;
      end;
    end;

    if copy(vFileName, length(vFileName) - 3, 4) <> '.csv' then
      sFile.SaveToFile(vFileName + '.csv')
    else sFile.SaveToFile(vFileName);
    sFile.Free;
    Form1.close;
  end;
end;

procedure cbAllClicked(Sender: TOBject);
begin
  for j := 0 to parts.Count - 1 do begin
    checkboxes[parts[j]].checked := cbAll.checked;
  end;
end;

procedure createCheckbox(index: Integer; cap: String);
var
  cb: TCheckBox;
begin
  cb := TCheckBox.Create(Application);
  with cb do begin
    Left := 10;
    Top := 5 + index * distBetweenCheckboxes;
    Width := 150;
    Caption := cap;
    Parent := Form1;
    State := cbChecked;
  end;

  checkboxes.add(cap, cb);
end;


begin
  checkboxes := CreateDictionary;
  parts := TStringList.Create;
  parts.Delimiter := ' ';
  parts.DelimitedText := 'Рама Створка "Импост вертикальный" "Импост горизонтальный" Штульп Порог соединитель Добор Штапик Цоколь "Проставочный брусок"';

  Form1 := TForm.Create(Application);
  with Form1 do begin
    Width := 235;
    Height := 335;
    caption := 'Выгрузка на станок';
    position := poScreenCenter;
    BorderIcons := biSystemMenu;
  end;

  for i := 0 to parts.Count - 1 do begin
    createCheckbox(i, parts[i]);
  end;

  cbAll := TCheckBox.Create(Application);
  with cbAll do begin
    Left := 10;
    Top := 5 + i * distBetweenCheckboxes + 30;
    Width := 150;
    Caption := 'Все части изделий';
    Parent := Form1;
    State := cbChecked;
    onClick := @cbAllClicked;
  end;

  cbArm := TCheckBox.Create(Application);
  with cbArm do begin
    Left := 10;
    Top := cbAll.Top + distBetweenCheckboxes;
    Width := 150;
    Caption := 'Армирование';
    Parent := Form1;
    State := cbUnchecked;
  end;

  btnOk := TButton.Create(Application);
  with btnOk do begin
    Left := 10;
    Top := cbArm.Top + 25;
    Width := 200;
    Height := 30;
    Caption := 'Сформировать файл';
    Parent := Form1;
    onClick := @btnOkClicked;
  end;

 if Form1.ShowModal = mrOk then Form1.Show;
end;
