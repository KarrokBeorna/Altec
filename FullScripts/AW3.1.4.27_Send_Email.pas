const
  SELECT_LAST_STATE = 'SELECT OS.CODE FROM ORDERSTATES OS JOIN ORDERS O ON O.ORDERSTATEID = OS.ORDERSTATEID WHERE ORDERID = :ID';

var
  S: IomSession;
  stateCode: String;
  MS: IpubMailer;
  M: IpubEmail;

procedure sendMail(body, mail: String);
begin
  MS := CreateMailer;
  M := MS.NewEmail;
  M.RecipientsField := varToStr(mail);
  M.Subject := 'Test_Subject';
  M.ContentType := 'text/html';
  M.Body := Body;

  MS.SendEmail(M, False);
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
  S := CreateObjectSession('');
  stateCode := S.QueryValue(SELECT_LAST_STATE, MakeDictionary(['ID', Document.Key]));

  if (stateCode <> 'dorabotka') and (Document.State.Code = 'dorabotka') then
    sendMail(Document.Title, 'УКАЖИТЕ_ЗДЕСЬ_АДРЕС_КЛИЕНТА');
{
    showmessage('Значит, надо отправлять письмо: ' + stateCode + ' - ' + Document.State.Code)
  else
    showmessage('Иначе отправлять письмо не нужно: ' + stateCode + ' - ' + Document.State.Code);
}
end.
