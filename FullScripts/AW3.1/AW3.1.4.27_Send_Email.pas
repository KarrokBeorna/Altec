const
  SELECT_LAST_STATE = 'SELECT OS.CODE FROM ORDERSTATES OS JOIN ORDERS O ON O.ORDERSTATEID = OS.ORDERSTATEID WHERE ORDERID = :ID';
  SELECT_ORDNO = 'SELECT ORDERNO FROM ORDERS WHERE ORDERID = :ID';

var
  S: IomSession;
  //stateCode: String;
  ORDNO: String;
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
    showmessage('Не удалось отправить письмо по адресу ' + mail + '. ' + MS.LastError);
 }
  M := Empty;
  MS := Empty;
end;

begin
  S := CreateObjectSession('');
  //stateCode := S.QueryValue(SELECT_LAST_STATE, MakeDictionary(['ID', OrderID]));
  ORDNO := S.QueryValue(SELECT_ORDNO, MakeDictionary(['ID', OrderID]));

  if (OldStateCode <> 'dorabotka') and (StateCode = 'dorabotka') then
    sendMail(ORDNO, 'УКАЖИТЕ_ЗДЕСЬ_ПОЧТУ_СОТРУДНИКА');
{
    showmessage('Значит, надо отправлять письмо: ' + OldStateCode + ' - ' + StateCode)
  else
    showmessage('Иначе отправлять письмо не нужно: ' + OldStateCode + ' - ' + StateCode);
}
end.
