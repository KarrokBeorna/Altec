const
  FIND_MEASURE = 'SELECT FIRST 1 DOPMEASUREID FROM DOPMEASURE WHERE MD_NAME = :MEASURENAME';

var
  S: IomSession;
  Audit: IowWarehouseAudit;
  Beam: IowWarehouseAuditBeam;
  Bulk: IowWarehouseAuditBulk;
  Art: IowArticul;
  Size: IowMeasureUnit;

begin
  if MessageDlg('Вы действительно хотите провести инвентаризацию выделенных элементов?', mtInformation, mbOK + mbCancel, 0) then begin
    S := CreateObjectSession;
    Audit := S.NewObject(IowWarehouseAudit);
    Audit.Name := VarToStr(Now);

    for i := 0 to SelectedRecords.count - 1 do begin
      Art := S.OpenObject(IowArticul, SelectedRecords.Items[i].Value['ARTICULID']);

      if (not varIsClear(Art.BeamSize) and not varIsNull(Art.BeamSize)) or (Art.Type.Name = 'Профили') then begin
        Beam := Audit.Beams.Add(Art);

        if varIsClear(Art.BeamSize) or varIsNull(Art.BeamSize) then begin
          Size := S.OpenObject(IowMeasureUnit, S.QueryValue(FIND_MEASURE, MakeDictionary(['MEASURENAME', SelectedRecords.Items[i].Value['MEASURENAME']])));
          Beam.Size := Size;
        end;

        Beam.Quantity := 1;
        Beam.Apply(False);
      end else begin
        Bulk := Audit.Bulks.Add(Art);
        Bulk.Quantity := 1;
        Bulk.Apply(False);
      end;
    end;

    Audit.Apply(False);

    S.Commit;
  end;
end;
