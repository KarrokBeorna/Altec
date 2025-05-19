{
  * Скрипт позволяет печатать отчёт "Коммерческое предложение" без захода в меню "Отчёты".
  * После исполнения сохраняет отчёт во "Вложениях" заказа.
  *
  * После успешного исполнения отчёта выставляется статус "Предварительный расчёт (КП)" сделано
  *
  * Также нужно доделать отправку непосредственно тела объекта по электронному адресу,
  * указанному в появляющемся окне, который автоматически заполняется из карточки
  * заказчика
}

const
  GET_REPORTBLOB = 'SELECT REPORTBLOB FROM REPORTS WHERE NAME = :NAME AND REPORTTYPE = 0 AND DELETED = 0';

var
  S, T: TStream;
  Form1: TForm;
  btnOk: TButton;
  cbReady: TCheckBox;
  PanelComment: TGroupBox;
  comment: TRichEdit;
  reportName, mainEmail: String = '';
  ReportStream, AttachmentStream: IcmStream;
  File: IowFile;

procedure sendMail(body, mail: String; File2: IcmStream);
begin
  MS := CreateMailSender();
  MS.Account.FromAddress := 'support@altec.ru';
  MS.Account.FromName := 'OptimaWin - Коммерческие предложения';
  MS.Account.SmtpHost := 'mail.altec.ru';
  MS.Account.SmtpPassword := '';
  MS.Account.SmtpPort := 465;
  MS.Account.SmtpUser := 'support@altec.ru';
  MS.Account.SmtpUseSSL := True;

  M := MS.NewEmail;
  M.RecipientsField := varToStr(mail);
  M.Subject := 'Коммерческое предложение от ' + VarToStr(Date);
  M.ContentType := 'text/html';
  M.Body := Body;
  M.Attachments.AddStream(body + '.pdf', File2);

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

procedure btnOkClicked(Sender: TOBject);
begin
  Form1.close;
end;

begin
  Instance.Apply(True);
  Instance.Session.Commit;
  reportName := 'Коммерческое предложение';
  S := TStringStream.Create(Instance.Session.QueryValue(GET_REPORTBLOB, MakeDictionary(['NAME', reportName])));

  try
    for i := 0 to Instance.Customer.Emails.Count - 1 do begin
      if (cbReady.checked) and (Instance.Customer.Emails.Items[i].IsMain) then begin
        mainEmail := Instance.Customer.Emails.Items[i].Email;
      end;
    end;
  except
  end;

  Form1 := TForm.Create(Application);
  with Form1 do begin
    Width := 235;
    Height := 140;
    caption := 'Отправка письма';
    position := poScreenCenter;
    BorderIcons := biSystemMenu;
  end;

  cbReady := TCheckBox.Create(Application);
  with cbReady do begin
    Left := 10;
    Top := 5;
    Width := 150;
    Caption := 'Отправить письмо';
    Parent := Form1;
  end;

  PanelEmail := TGroupBox.Create(Application);
  with PanelEmail do begin
     Width := 210;
     Height := 40;
     Top := 25;
     Left := 5;
     caption := 'Почта клиента';
     Parent := Form1;
  end;

  email := TRichEdit.Create(Application);
  with email do begin
    Left := 5;
    Top := 15;
    Width := 200;
    height := PanelEmail.height - 20;
    Parent := PanelEmail;
  end;

  email.lines.text := mainEmail;

  btnOk := TButton.Create(Application);
  with btnOk do begin
    Left := 10;
    Top := 68;
    Width := 200;
    Height := 30;
    Caption := 'ОК';
    Parent := Form1;
    onClick := @btnOkClicked;
  end;

  if Form1.ShowModal = mrOk then Form1.Show;

  try
    ReportStream := CreateIcmStreamAdapter(S);
    T := TMemoryStream.Create;

    try
      AttachmentStream := CreateIcmStreamAdapter(T);

      if (cbReady.checked) then begin
        if FastReportExportToPDF(ReportStream, AttachmentStream, MakeDictionary(['RecordID', Instance.Key]), False) then begin
          sendMail(Instance.Name, email.lines.text, AttachmentStream);
        end;
      end;

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
