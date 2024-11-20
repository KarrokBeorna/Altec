const
  SELECT_SCRIPT_EV = 'SELECT HANDLERTITLE, SCRIPT FROM EVENTHANDLERS WHERE HANDLERTITLE IN ' + #13#10 +
                     '(''Установка минимального срока готовности заказа'', ' + #13#10 +
                     '''Установка минимального срока изготовления заказа'',' + #13#10 +
                     '''Проверка на корректность срока производства'')';

  UPDATE_EVENT_HANDLER = 'UPDATE EVENTHANDLERS SET SCRIPT = :SCRIPT WHERE HANDLERTITLE = :HANDLERTITLE';

var
  S: IomSession;
  vFileName, currStr, year, chillDays, workDays, script, day: string = '';
  sFile, existsChillDate, existsWorkDate: TStringList;
  start1, start2, finish1, finish2: Integer = 0;
  scripts: IcmDictionaryList;

function getListFromRow(str: string): TStringList;
var
  list: TStringList;
begin
  list := TStringList.Create;
  str := str + ', ';

  while str <> '' do begin
    value := Copy(str, 1, Pos(' ', str) - 2);
    DeleteStr(str, 1, Pos(' ', str));
    list.Add(value);
  end;

  Result := list;
end;

begin
  if PromptForFileName(vFileName, 'XML files (*.xml)|*.xml', '', 'Выберите файл', 'C:\', false) then begin
    S := CreateObjectSession('');
    sFile := TStringList.Create;
    sFile.LoadFromFile(vFileName);

    scripts := S.QueryRecordList(SELECT_SCRIPT_EV, empty);

    for j := 0 to scripts.count - 1 do begin
      script := scripts.Items[j].value['SCRIPT'];

      for z := 0 to length(script) - 1 do begin
        if (copy(script, z, 1) = '[') then begin
          if (start1 = 0) then begin
            start1 := z;
          end else begin
            start2 := z;
          end;
        end;
        if (copy(script, z, 1) = ';') then begin
          if (finish1 = 0) then begin
            finish1 := z;
          end else begin
            finish2 := z;
            break;
          end;
        end;
      end;

      chillDays := copy(script, start1 + 1, finish1 - start1 - 2);
      workDays := copy(script, start2 + 1, finish2 - start2 - 2);

      existsChillDate := getListFromRow(chillDays);
      existsWorkDate := getListFromRow(workDays);

      for i := 0 to sFile.count - 1 do begin
        currStr := trim(sFile[i]);

        if copy(currStr, 11, 4) = 'year' then begin
          year := copy(currStr, 17, 4);
        end;

        if copy(currStr, 0, 4) = '<day' then begin
          if (copy(currStr, 19, 1) = '2') or (copy(currStr, 19, 1) = '3') then begin
            day := '''' + copy(currStr, 12, 2) + '.' + copy(currStr, 9, 2) + '.' + year + '''';
            if existsWorkDate.IndexOf(day) < 0 then begin
              if workDays <> '' then workDays := workDays + ', ';
              workDays := workDays + day;
            end;
          end;
          if copy(currStr, 19, 1) = '1' then begin
            day := '''' + copy(currStr, 12, 2) + '.' + copy(currStr, 9, 2) + '.' + year + '''';
            if existsChillDate.IndexOf(day) < 0 then begin
              if chillDays <> '' then chillDays := chillDays + ', ';
              chillDays := chillDays + day;
            end;
          end;
        end;
      end;

      script := 'const' + #13#10 +
                '  CHILL_DAY = [' + chillDays + '];' + #13#10 +
                '  WORK_DAY = [' + workDays + '];' + #13#10 + #13#10 +
                copy(script, finish2 + 5, length(script) - finish2);

      S.ExecSQL(UPDATE_EVENT_HANDLER, MakeDictionary(['HANDLERTITLE', scripts.Items[j].value['HANDLERTITLE'], 'SCRIPT', script]));
      S.Commit;
      start1 := 0; start2 := 0; finish1 := 0; finish2 := 0;
    end;

    showmessage('Праздничные и рабочие дни ' + year + ' года успешно обновлены');
  end;
end.
