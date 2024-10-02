const
  FIND_SYSTEM = 'SELECT FIRST 1 FIRMID FROM R_FIRMPROFIL WHERE FP_NAME = :SYSTEMNAME';
  FIND_MEASURE = 'SELECT FIRST 1 DOPMEASUREID FROM DOPMEASURE WHERE MD_LONGNAME = :MEASURENAME';
  FIND_RECALC = 'SELECT FIRST 1 WGRPRICEID FROM W_GRPRICE WHERE GP_NAME = :RECALCNAME';
  FIND_PART = 'SELECT FIRST 1 PARTWINDOWID FROM R_PARTWINDOW WHERE PW_NAME = :PARTNAME';
  FIND_ARTICUL = 'SELECT FIRST 1 ARTICULID FROM VIRTARTICULES WHERE AR_ART = :AR_ART';

var
  S: IomSession;
  vFileName, currStr: String;
  entryDict, partsDict, paramsDict, armouringsDict, armouringDict: IcmDictionary;
  sFile: TStringList;
  MainProfile: IowMainProfile;
  MainProfilePart: IowMainProfilePart;
  ProfileSystem: IowProfileSystem;
  Measure: IowMeasureUnit;
  RecalcGroup: IowRecalcGroup;
  Purpose: IowProfilePurpose;
  Part: IowMainProfileType;
  Armouring, ArmouringProfile: IowArmouringProfile;
  MainArm: IowMainProfileArmouring;

function getDictionaryFromEntry(str, delim: string): IcmDictionary;
var
  dict: IcmDictionary;
begin
  dict := CreateDictionary;
  index := 0;
  str := str + delim;

  while str <> '' do begin
    value := Copy(str, 1, Pos(delim, str) - 1);
    DeleteStr(str, 1, Pos(delim, str));
    dict.Add(intToStr(index), value);
    index := index + 1;
  end;

  Result := dict;
end;

// Привязываем армирование к данной части изделия
procedure setPartArmourings(ARMOURINGS: String);
begin
  armouringsDict := getDictionaryFromEntry(ARMOURINGS, '=');

  for k := 0 to armouringsDict.Count - 1 do begin
    armouringDict := getDictionaryFromEntry(armouringsDict[IntToStr(k)], '?');

    ARMOURINGART := TRIM(armouringDict['0']);
    DECREMENT := TRIM(armouringDict['1']);

    ARMOURINGID := S.QueryValue(FIND_ARTICUL, MakeDictionary(['AR_ART', ARMOURINGART]));
    Armouring := S.OpenObject(IowArmouringProfile, ARMOURINGID);

    MainArm := MainProfilePart.Armourings.Add(Armouring);
    MainArm.DecrementFormula := DECREMENT;
    MainArm.Apply;
  end;
  MainProfilePart.Apply;
end;

// Привязываем артикул к частям изделий
procedure setPartsMainProfile(PARTS_AND_ARMS: String);
begin
  partsDict := getDictionaryFromEntry(PARTS_AND_ARMS, ':');

  for j := 0 to partsDict.Count - 1 do begin
    paramsDict := getDictionaryFromEntry(partsDict[IntToStr(j)], '|');

    PARTNAME := TRIM(paramsDict['0']);
    A_SIZE := TRIM(paramsDict['1']);
    B_SIZE := TRIM(paramsDict['2']);
    C_SIZE := TRIM(paramsDict['3']);
    D_SIZE := TRIM(paramsDict['4']);
    F_SIZE := TRIM(paramsDict['5']);
    ARMOURINGS := TRIM(paramsDict['6']);
    POSITION := TRIM(paramsDict['7']);

    PARTID := S.QueryValue(FIND_PART, MakeDictionary(['PARTNAME', PARTNAME]));
    Part := S.OpenObject(IowMainProfileType, PARTID);

    MainProfilePart := S.NewObject(IowMainProfilePart);

    MainProfilePart.MainProfile := MainProfile;
    MainProfilePart.Type := Part;
    MainProfilePart.A := StrToFloat(A_SIZE);
    if B_SIZE <> '' then MainProfilePart.B := StrToFloat(B_SIZE);
    if C_SIZE <> '' then MainProfilePart.C := StrToFloat(C_SIZE);
    if D_SIZE <> '' then MainProfilePart.D := StrToFloat(D_SIZE);
    if F_SIZE <> '' then MainProfilePart.Cutter := StrToFloat(F_SIZE);
    if POSITION <> '' then MainProfilePart.Position := StrToInt(POSITION);
    MainProfilePart.Apply;

    if ARMOURINGS <> '' then begin
      setPartArmourings(ARMOURINGS);
    end;
  end;
end;

procedure createMainProfile(SYSTEMNAME: String);
begin
  MARKING := TRIM(entryDict['1']);
  NAME := TRIM(entryDict['2']);
  ADDMARKING := TRIM(entryDict['3']);
  MEASURENAME := TRIM(entryDict['4']);
  PRICE := TRIM(entryDict['5']);
  RECALCNAME := TRIM(entryDict['6']);
  FOLDWIDTH := TRIM(entryDict['7']);
  PURPOSEID := StrToInt(TRIM(entryDict['8']));
  PARTS_AND_ARMS := TRIM(entryDict['9']);

  SYSTEMID := S.QueryValue(FIND_SYSTEM, MakeDictionary(['SYSTEMNAME', SYSTEMNAME]));
  MEASUREID := S.QueryValue(FIND_MEASURE, MakeDictionary(['MEASURENAME', MEASURENAME]));
  if RECALCNAME <> '' then RECALCID := S.QueryValue(FIND_SYSTEM, MakeDictionary(['RECALCNAME', RECALCNAME]));

  ProfileSystem := S.OpenObject(IowProfileSystem, SYSTEMID);
  Measure := S.OpenObject(IowMeasureUnit, MEASUREID);
  if RECALCNAME <> '' then RecalcGroup := S.OpenObject(IowRecalcGroup, RECALCID);
  Purpose := S.OpenObject(IowProfilePurpose, PURPOSEID);

//  MAINPROFILEID := S.QueryValue(FIND_ARTICUL, MakeDictionary(['AR_ART', MARKING]));
//  if MAINPROFILEID > 0 then begin
//    MainProfile := S.OpenObject(IowMainProfile, MAINPROFILEID);
//  end else begin
    MainProfile := S.NewObject(IowMainProfile);
//  end;

  MainProfile.ProfileSystem := ProfileSystem;
  MainProfile.Marking := MARKING;
  MainProfile.Name := NAME;
  if ADDMARKING <> '' then MainProfile.AdditionalMarking := ADDMARKING;
  MainProfile.Measure := Measure;
  if PRICE <> '' then MainProfile.Price := StrToFloat(PRICE) else MainProfile.Price := 0;
  if RECALCNAME <> '' then MainProfile.RecalcGroup := RecalcGroup;
  if FOLDWIDTH <> '' then MainProfile.FoldWidth := StrToFloat(FOLDWIDTH);
  MainProfile.Purpose := Purpose;
  MainProfile.Apply;

  setPartsMainProfile(PARTS_AND_ARMS);
end;

procedure createArmouringProfile;
begin
  MARKING := TRIM(entryDict['1']);
  NAME := TRIM(entryDict['2']);
  ADDMARKING := TRIM(entryDict['3']);
  MEASURENAME := TRIM(entryDict['4']);
  PRICE := TRIM(entryDict['5']);
  RECALCNAME := TRIM(entryDict['6']);

  MEASUREID := S.QueryValue(FIND_MEASURE, MakeDictionary(['MEASURENAME', MEASURENAME]));
  if RECALCNAME <> '' then RECALCID := S.QueryValue(FIND_SYSTEM, MakeDictionary(['RECALCNAME', RECALCNAME]));

  Measure := S.OpenObject(IowMeasureUnit, MEASUREID);
  if RECALCNAME <> '' then RecalcGroup := S.OpenObject(IowRecalcGroup, RECALCID);

//  ARMOURINGID := S.QueryValue(FIND_ARTICUL, MakeDictionary(['AR_ART', MARKING]));
//  if ARMOURINGID > 0 then begin
//    ArmouringProfile := S.OpenObject(IowArmouringProfile, ARMOURINGID);
//  end else begin
    ArmouringProfile := S.NewObject(IowArmouringProfile);
//  end;

  ArmouringProfile.Marking := MARKING;
  ArmouringProfile.Name := NAME;
  if ADDMARKING <> '' then ArmouringProfile.AdditionalMarking := ADDMARKING;
  ArmouringProfile.Measure := Measure;
  if PRICE <> '' then ArmouringProfile.Price := StrToFloat(PRICE) else MainProfile.Price := 0;
  if RECALCNAME <> '' then ArmouringProfile.RecalcGroup := RecalcGroup;
  ArmouringProfile.Apply;
end;


begin
  if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите файл', 'C:\', false) then begin
    S := CreateObjectSession();
    sFile := TStringList.Create;
    sFile.LoadFromFile(vFileName);

    for i := 1 to sFile.count - 1 do begin
      currStr := trim(sFile[i]);

      if currStr <> '' then begin
        entryDict := getDictionaryFromEntry(currStr, ';');

        SYSTEMNAME := TRIM(entryDict['0']);
        if SYSTEMNAME <> 'Армирование' then begin
          createMainProfile(SYSTEMNAME);
        end else begin
          createArmouringProfile();
        end;
      end;
    end;
    S.Commit;
  end;
end;
