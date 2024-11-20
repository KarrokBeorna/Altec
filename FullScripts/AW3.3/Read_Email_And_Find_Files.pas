const
  GET_CONTRACT_ID = 'SELECT ID, CONTRACTTYPEID FROM CONTRACTS WHERE CONTRACTNUMBER = :TITLE';
  GET_DOCS_ID = 'SELECT ID FROM DOCS WHERE TITLE = :TITLE';

  UPDATE_CONTRACT_STATE = 'UPDATE CONTRACTS SET STATEID = (SELECT ID FROM CONTRACTS_TYPES_STATES WHERE TITLE = :TITLE AND CONTRACTTYPEID = :TYPE) WHERE ID = :ID';
  UPDATE_DOCS_STATE = 'UPDATE DOCS SET DOCSTATEID = (SELECT ID FROM DOCS_TYPES_STATES WHERE TITLE = :TITLE) WHERE ID = :ID';

  DiadocEmailHost = '';  // заполнить
  DiadocEmailPort = ;  // заполнить
  DiadocEmailLogin = '';  // заполнить
  DiadocEmailPassword = '';  // заполнить

function HexToDec(num: String): Extended;
begin
  result := 0;
  for k := 0 to length(num) - 1 do begin
    if copy(num, k + 1, 1) = 'a' then result := result + 10 * Power(16, length(num) - 1 - k) else
    if copy(num, k + 1, 1) = 'b' then result := result + 11 * Power(16, length(num) - 1 - k) else
    if copy(num, k + 1, 1) = 'c' then result := result + 12 * Power(16, length(num) - 1 - k) else
    if copy(num, k + 1, 1) = 'd' then result := result + 13 * Power(16, length(num) - 1 - k) else
    if copy(num, k + 1, 1) = 'e' then result := result + 14 * Power(16, length(num) - 1 - k) else
    if copy(num, k + 1, 1) = 'f' then result := result + 15 * Power(16, length(num) - 1 - k) else
    result := result + StrToInt(copy(num, k + 1, 1)) * Power(16, length(num) - 1 - k);
  end;
end;

var
  MS: IpubMailer;
  ML: IpubEmailList;
  M: IpubEmail;
  B, oldMsgId, currMsgID: string;
  S: IomSession;
  msgCount, contractID, contractTypeID, docID: Integer;
  reportNames: TStringList;
  msgID: Extended;

begin
  MS := CreateMailer;
  reportNames := TStringList.Create;
  S := CreateObjetSession;

  MS.Account.Pop3Host := DiadocEmailHost;
  MS.Account.Pop3User := DiadocEmailLogin;
  MS.Account.Pop3Password := DiadocEmailPassword;
  MS.Account.Pop3Port := DiadocEmailPort;
  MS.Account.Pop3UseSSL := true;

  msgCount := 0;

  ML := MS.ReadEmails;

  if ML.Count > 0 then begin
    oldMsgId := GetDatabaseVariable('DIADOC_EMAIL_MSG_ID', '0');
    for i := 0 to ML.Count - 1 do begin
      M := ML.Items[i];
      msgID := HexToDec(copy(M.MsgID, 0, 8));

      if msgID > StrToInt(oldMsgId) then begin
      //if M.SenderField = 'diadoc-notifications@kontur.ru' then begin // это почему-то не работает, M.SenderField пустой
        if Pos('уведомлен', M.Subject) > 0 then begin
          if MS.LoadEmail(M) then begin
            info := M.Body;
            while pos('>Контрагент подписал документ<', info) > 0 do begin
              info := copy(info, pos('>Контрагент подписал документ<', info), Length(info));
              div_report := copy(info, pos('<a ', info), Length(info));
              report_link := copy(div_report, 0, pos('</a>', div_report) - 1);
              report := copy(report_link, pos('>', report_link) + 1, Length(report_link));

              if pos('<span', report) > 0 then begin
                report_before_name := copy(report, 0, pos('</span', report) - 1);
                report_name := copy(report_before_name, pos('>', report_before_name) + 1,  Length(report_before_name));
              end else begin
                report_name := copy(report, pos('>', report) + 1,  Length(report));
              end;

              if pos('.pdf', report_name) > 0 then begin
                contract_name := copy(report_name, 0, pos('.pdf', report_name) - 1);
              end else begin
                contract_name := report_name;
              end;

              reportNames.add(trim(contract_name));

              info := copy(info, 10, Length(info));
            end;

            //if not MS.DeleteEmail(M) then RaiseException(MS.LastError);      // пытаемся удалить письмо с сервера
            Inc(msgCount, 1);                                                  // наращиваем счетчик принятых обращений
          end;
        end;
      end;
    end;

    if msgCount > 0 then begin
      {SetDatabaseVariable('DIADOC_EMAIL_MSG_ID', M.MsgID);

      for i := 0 to reportNames.count - 1 do begin
        temp := S.QueryRecord(GET_CONTRACT_ID, MakeDictionary(['TITLE', reportNames[i]]));
        contractID := temp.value['ID'];
        contractTypeID := temp.value['CONTRACTTYPEID'];

        if contractID > 0 then begin
          S.ExecSQL(UPDATE_CONTRACT_STATE, MakeDictionary(['TITLE', 'Подписан', 'TYPE', contractTypeID, 'ID', contractID]));
        end else begin
          docID := S.QueryValue(GET_DOCS_ID, MakeDictionary(['TITLE', reportNames[i]]));

          if docID > 0 then begin
            S.ExecSQL(UPDATE_DOCS_STATE, MakeDictionary(['TITLE', 'Подписан', 'ID', docID]));
          end;
        end;
      end;

      S.Commit();}
    end;
  end;

  ML := Empty;
  MS := Empty;

  ShowMessage('Получено документов с почты: ' + IntToStr(reportNames.count));
  ShowMessage('Получено писем с почты: ' + IntToStr(msgCount));
end;
