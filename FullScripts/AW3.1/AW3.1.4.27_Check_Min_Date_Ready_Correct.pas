const
  CHILL_DAY = ['01.01.2024', '02.01.2024', '03.01.2024', '04.01.2024', '05.01.2024', '06.01.2024', '07.01.2024', '08.01.2024', '23.02.2024', '08.03.2024', '29.04.2024', '30.04.2024', '01.05.2024', '09.05.2024', '10.05.2024', '12.06.2024', '04.11.2024', '30.12.2024', '31.12.2024', '01.01.2025', '02.01.2025', '03.01.2025', '04.01.2025', '05.01.2025', '06.01.2025', '07.01.2025', '08.01.2025', '23.02.2025', '08.03.2025', '09.03.2025', '01.05.2025', '02.05.2025', '08.05.2025', '09.05.2025', '12.06.2025', '13.06.2025', '03.11.2025', '04.11.2025', '31.12.2025'];
  WORK_DAY = ['22.02.2024', '07.03.2024', '27.04.2024', '08.05.2024', '11.06.2024', '02.11.2024', '28.12.2024', '07.03.2025', '30.04.2025', '11.06.2025', '01.11.2025'];

var
  trueUFValue, UFValue: Date;

function ContainsInArray(value: variant; arr: Array of Variant): Boolean;
begin
  result := False;
  for i := 0 to length(arr) - 1 do begin
    if arr[i] = value then begin
      result := True;
      break;
    end;
  end;
end;

begin
  UFValue := Document.PropertyByName['srok'];
  trueUFValue := Document.PropertyByName['srok_script'];

  if (UFValue < trueUFValue) then begin
    Document.PropertyByName['srok'] := Document.PropertyByName['srok_script'];
    RaiseException('Нельзя выставлять срок изготовления меньше значения, рассчитанного программой!');
  end;

  if ContainsInArray(DateToStr(UFValue), CHILL_DAY) then begin
    Document.PropertyByName['srok'] := Document.PropertyByName['srok_script'];
    RaiseException('Нельзя выставлять конечный срок изготовления на праздничный день!');
  end;
end;
