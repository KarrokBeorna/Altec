var
  trueUFValue, UFValue: Date;

begin
  UFValue := Document.PropertyByName['srok'];
  trueUFValue := Document.PropertyByName['srok_script'];

  if (UFValue < trueUFValue) then begin
    Document.PropertyByName['srok'] := Document.PropertyByName['srok_script'];
    RaiseException('Нельзя выставлять срок изготовления меньше значения, рассчитанного программой!');
  end;
end;
