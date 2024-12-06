{
  * Скрипт позволяет имитировать отчёт представление, давая возможность
  * печатать несколько коммерческих предложений одновременно по всем выделенным
  * записям. Просто подаём в отчёт вместо одного RecordID целый список из ID заказов.
  *
  * При этом внутри самих отчётов необходимо в основном блоке begin~end
  * разместить подстановку в нужных местах SQL-запросов.
}

const
  GET_REPORTBLOB = 'SELECT REPORTBLOB FROM REPORTS WHERE NAME = :NAME AND REPORTTYPE = 0 AND DELETED = 0';

var
  Session: IomSession;
  S, T: TStream;
  RecordID, reportName: String = '';
  ReportStream, AttachmentStream: IcmStream;

begin
  Session := CreateObjectSession();
  reportName := 'Коммерческое предложение';
  S := TStringStream.Create(Session.QueryValue(GET_REPORTBLOB, MakeDictionary(['NAME', reportName])));

  for i := 0 to SelectedRecords.count - 1 do begin
    if RecordID <> '' then RecordID := RecordID + ', ';
    RecordID := RecordID + varToStr(SelectedRecords.Items[i].Value['ID']);
  end;

  try
    ReportStream := CreateIcmStreamAdapter(S);
    T := TMemoryStream.Create;

    try
      AttachmentStream := CreateIcmStreamAdapter(T);
      FastReportExportToFP3(ReportStream, AttachmentStream, MakeDictionary(['RecordID', RecordID]), True);
      AttachmentStream := Empty;
    finally
      T.Free;
    end;

    ReportStream := Empty;
  finally
    S.Free;
  end;
end.
