const
  GET_REPORTBLOB = 'SELECT REPORTBLOB FROM REPORTS WHERE TITLE = :TITLE AND DELETED = 0';

  GET_ORGANIZATIONID = 'SELECT CONTRACTS.ORGANIZATIONID  FROM CONTRACTS  WHERE CONTRACTS.ID = :RECORDID';

var
  TSS, TMS: TStream;
  S: IomSession;
  reportName: String = '';
  ReportStream, AttachmentStream: IcmStream;
  Dlg, ORGANIZATIONID, RecordId, pechat: integer;
  D: IcmDictionary;

procedure sendMail(File: IcmStream);
var
  MS: IPubMailer;
  M: IPubEmail;
  mail: String = 'buhg@altec.ru';
begin
  MS := CreateMailer();
  MS.Account.Address := 'support@altec.ru';
  MS.Account.UserName := 'AltaWin';
  MS.Account.SmtpHost := 'mail.altec.ru';
  MS.Account.SmtpPassword := 'kwfbenbynacvjmch';
  MS.Account.SmtpPort := 465;
  MS.Account.SmtpUser := 'support@altec.ru';
  MS.Account.SmtpUseSSL := True;

  M := MS.NewEmail;
  M.RecipientsField := mail;
  M.Subject := 'Договор ' + VarToStr(SelectedRecords[0].value['CONTRACTNUMBER']) + ' от ' + DateToStr(SelectedRecords[0].value['CONTRACTDATE']);
  M.ContentType := 'text/html';
  M.Body := '';
  M.Attachments.AddStream('Договор.pdf', File);

  if MS.SendEmail(M, False) then begin
    showmessage('Письмо отправлено по адресу ' + mail)
  end else begin
    showmessage('Не удалось отправить письмо по адресу ' + mail);
  end;

  M := Empty;
  MS := Empty;
end;

begin
  S := CreateObjectSession;
  if SelectedRecords[0].value['TYPENAME'] = 'Oferta' then begin
    reportName := 'Договор-оферта';
  end else begin
    reportName := 'Договор';
  end;

  TSS := TStringStream.Create(S.QueryValue(GET_REPORTBLOB, MakeDictionary(['TITLE', reportName])));

  try
    ReportStream := CreateIcmStreamAdapter(TSS);
    TMS := TMemoryStream.Create;

    try
      AttachmentStream := CreateIcmStreamAdapter(TMS);
      Dlg := DlgBox('Вопрос','Вы хотите сформировать отчет "Договор" без подписей или с подписями?' ,['Без подписей','С подписями','Отмена'] );

      if (Dlg <> 3) then begin
        RecordId := SelectedRecords[0].value['ID'];
        D := MakeDictionary(['RecordId', RecordId, 'pechat', 0]);

        if (Dlg = 2) then begin
          ORGANIZATIONID := S.QueryValue(GET_ORGANIZATIONID, D);
          //ООО "Алтек"
          if ORGANIZATIONID = 58 then  pechat := 1;
          //ООО "КВЦ "Алтек"
          if ORGANIZATIONID = 2022 then  pechat := 2;
          //ООО "Окна ВЕБ"
          if ORGANIZATIONID = 13933 then  pechat := 3;

          D.value['pechat'] := pechat;
        end;

        if FastReportExportToPDF(ReportStream, AttachmentStream, D, False) then begin
          sendMail(AttachmentStream);
        end;
      end;

      AttachmentStream := Empty;
    finally
      TMS.Free;
    end;

    ReportStream := Empty;
  finally
    TSS.Free;
  end;
end.
