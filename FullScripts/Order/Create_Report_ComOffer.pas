const
  GET_REPORTBLOB = 'SELECT REPORTBLOB FROM REPORTS WHERE NAME = :NAME AND REPORTTYPE = 0 AND DELETED = 0';

var
  S, T: TStream;
  reportName: String;
  ReportStream, AttachmentStream: IcmStream;
  fileID: Integer;
  File: IowFile;

procedure sendMail(body, mail: String);
begin
  MS := CreateMailSender();
  MS.Account.FromAddress := 'support@altec.ru';
  MS.Account.FromName := 'Test';
  MS.Account.SmtpHost := 'mail.altec.ru';
  MS.Account.SmtpPassword := '';
  MS.Account.SmtpPort := 465;
  MS.Account.SmtpUser := 'support@altec.ru';
  MS.Account.SmtpUseSSL := True;
  M := MS.NewEmail;
  M.RecipientsField := varToStr(mail);
  M.Subject := 'Коммерческое предложение';
  M.ContentType := 'text/html';
  M.Body := Body;

  MS.SendEmail(M, empty);
{
  if MS.SendEmail(M, False) then
    showmessage('Письмо отправлено по адресу ' + mail)
  else
    showmessage('Не удалось отправить письмо по адресу ' + mail);
}
  M := Empty;
  MS := Empty;
end;

begin
  Instance.Apply(True);
  Instance.Session.Commit;
  reportName := 'Коммерческое предложение';
  S := TStringStream.Create(Instance.Session.QueryValue(GET_REPORTBLOB, MakeDictionary(['NAME', reportName])));

  try
    ReportStream := CreateIcmStreamAdapter(S);
    T := TMemoryStream.Create;

    try
      AttachmentStream := CreateIcmStreamAdapter(T);

      if FastReportExportToFP3(ReportStream, AttachmentStream, MakeDictionary(['RecordID', Instance.Key]), True) then begin
        File := Instance.Session.NewObject(IowFile);
        File.LoadFromStream(reportName + ' (' + varToStr(Instance.Price) + ' руб.).fp3', AttachmentStream);
        File.Apply;
        Instance.Attachments.Add(File).Apply;
        File := Empty;

        for i := 0 to Instance.StatusList.Count - 1 do begin
          if Instance.StatusList.Items[i].OrderStatus.Name = 'Предварительный расчёт (КП)' then begin
            Instance.StatusList.Items[i].Done := True;
            Instance.StatusList.Items[i].Comment := 'Отчёт прикреплён во вложениях';
            Instance.StatusList.Items[i].apply;
          end;
        end;

        for i := 0 to Instance.Customer.Emails.Count - 1 do begin
          if Instance.Customer.Emails.Items[i].IsMain then begin
            sendMail(Instance.Name, Instance.Customer.Emails.Items[i].Email);
          end;
        end;
      end;

      AttachmentStream := Empty;
    finally
      T.Free;
    end;

    ReportStream := Empty;
  finally
    S.Free;
  end;
end.
