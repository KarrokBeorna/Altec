const
  UpdateOrInsertStuffs =
'UPDATE OR INSERT INTO STUFFS (  ' + #13#10 +
'  ID,                           ' + #13#10 +
'  TYPE,                         ' + #13#10 +
'  NAME,                         ' + #13#10 +
'  STUFFTYPEID,                  ' + #13#10 +
'  AMOUNTGROUPID,                ' + #13#10 +
'  MARKING,                      ' + #13#10 +
'  MEASUREID,                    ' + #13#10 +
'  CURRENCYID,                   ' + #13#10 +
'  GUID                          ' + #13#10 +
') VALUES (                      ' + #13#10 +
'  :ID,                          ' + #13#10 +
'  :TYPE,                        ' + #13#10 +
'  :NAME,                        ' + #13#10 +
'  :STUFFTYPEID,                 ' + #13#10 +
'  :AMOUNTGROUPID,               ' + #13#10 +
'  :MARKING,                     ' + #13#10 +
'  :MEASUREID,                   ' + #13#10 +
'  :CURRENCYID,                  ' + #13#10 +
'  :GUID                         ' + #13#10 +
')                               ';

var
  GGTypeID, UnitId, CurrencyID, TypeID: Integer;
  GGtypes: IdocStuffType;
  Currency: IdocCurrency;
  Units: IdocUnit;
  AmountGr: IdocAmountGroup;
  vFileName, DocType: String;
  sFile: TStringList;
  vGUID, AmountGrID: Variant;
  Stuff: IcmDictionary;
  SepStuff: IcmDictionary;

function Separator(a:string): IcmDictionary;
var
  Icm: IcmDictionary;
  a1, a2: String;
begin
  Icm := CreateDictionary;
  temp := '';
  Ind := 0;

  if a <> '' then begin
    //CSV-line example: Привет;Андрей
    a := a + ';';
    a1 := Copy(a, 1, Pos(';', a) - 1);
    DeleteStr(a, 1, Pos(';', a));
    a2 := Copy(a, 1, Pos(';', a) - 1);
    DeleteStr(a, 1, Pos(';', a));

    Icm.Add('1', a1);
    Icm.Add('2', a2);
  end;
  Result := Icm;
end;

begin
  DocType := SelectDocumentType(IDocStuff, True);
  if DocType = 'IdocBulkStuff' then TypeID := 0
  else if DocType = 'IdocLinearBlankStuff' then TypeID := 1
  else if DocType = 'IdocPlanarBlankStuff' then TypeID := 2;

  if DocType <>  '' then begin
    GGtypes := SelectDocument(IdocStuffType, 'Выберите тип компонента!', 'Выберите тип компонента!', 'Выберите тип компонента!');
    if GGtypes <> empty then begin
      GGTypeID := GGtypes.Key;
      if TypeID > 0 then AmountGr := SelectDocument(IdocAmountGroup, 'Выберите группу размерности!', 'Выберите группу размерности!', 'Выберите группу размерности!');
      if (TypeID = 0) or (AmountGr <> empty) then begin
        if TypeID > 0 then AmountGrID := AmountGr.Key else AmountGrID := null;
        Units := SelectDocument(IdocUnit, 'Выберите единицу измерения!', 'Выберите единицу измерения!', 'Выберите единицу измерения!');
        if Units <> empty then begin
          UnitId := Units.Key;
          Currency := SelectDocument(IdocCurrency, 'Выберите валюту!', 'Выберите валюту!', 'Выберите валюту!');
          if Currency <> empty then begin
            CurrencyID := Currency.Key;
            if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите файл!', 'C:\', false) then begin
              sFile := TStringList.Create;
              sFile.LoadFromFile(vFileName);

              for i:= 0 to sFile.Count-1 do begin
                vGUID := GenerateGUID;
                Stuff := QueryRecord('select gen_id(gen_stuffs,1) as id from rdb$database', empty);
                SepStuff := Separator(sFile[i]);
                vMarking := SepStuff.value['1'];
                vName := SepStuff.value['2'];

                ExecSQL(UpdateOrInsertStuffs, MakeDictionary([
                              'ID', Stuff.value['ID'],
                              'TYPE', TypeID,
                              'NAME', vName,
                              'STUFFTYPEID', GGTypeID,
                              'AMOUNTGROUPID', AmountGrID,
                              'MARKING', vMarking,
                              'MEASUREID', UnitId,
                              'CURRENCYID', CurrencyID,
                              'GUID', vGUID]));
              end;
            end else showmessage('Вы не выбрали файл!');
          end else showmessage('Вы не выбрали валюту!');
        end else showmessage('Вы не выбрали единицу измерения!');
      end else Showmessage('Вы не выбрали группу размерности!');
    end else Showmessage('Вы не выбрали тип компонента!');
  end else Showmessage('Вы не выбрали тип документа!');
end;
