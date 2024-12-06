{
  * Скрипт позволяет печатать отчёт "Задание на МС" без захода в
  * меню "Отчёты".
  * Работает исключительно на последней выделенной группе
}

const
  GET_REPORTBLOB = 'SELECT REPORTBLOB FROM REPORTS WHERE NAME = :NAME AND DOCTYPE = :DOCTYPE AND REPORTTYPE = 0 AND DELETED = 0';

var
  Session: IomSession;
  S, T: TStream;
  RecordID, reportName: String = '';
  ReportStream, AttachmentStream: IcmStream;

begin
  Session := CreateObjectSession();
  reportName := 'Задание на МС';
  S := TStringStream.Create(Session.QueryValue(GET_REPORTBLOB, MakeDictionary(['NAME', reportName, 'DOCTYPE', 'IowProductionGroup'])));

  for i := 0 to SelectedRecords.count - 1 do begin
    if RecordID <> '' then RecordID := RecordID + ', ';
    RecordID := RecordID + varToStr(SelectedRecords.Items[i].Value['ID']);
  end;

   try
    ReportStream := CreateIcmStreamAdapter(S);
    T := TMemoryStream.Create;

    try
      AttachmentStream := CreateIcmStreamAdapter(T);
      FastReportExportToFP3(ReportStream, AttachmentStream, MakeDictionary(['RecordID', SelectedRecords.Items[0].Value['ID']]), True);
      AttachmentStream := Empty;
    finally
      T.Free;
    end;

    ReportStream := Empty;
  finally
    S.Free;
  end;
end.
