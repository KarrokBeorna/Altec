const
  GET_REPORTBLOB = 'SELECT REPORTBLOB FROM REPORTS WHERE NAME = :NAME AND REPORTTYPE = 0 AND DELETED = 0';

var
  S, T: TStream;
  reportName: String;
  ReportStream, AttachmentStream: IcmStream;
  fileID: Integer;
  File: IowFile;

begin
  reportName := 'Договор';
  S := TStringStream.Create(Instance.Session.QueryValue(GET_REPORTBLOB, MakeDictionary(['NAME', reportName])));

  try
    ReportStream := CreateIcmStreamAdapter(S);
    T := TMemoryStream.Create;

    try
      AttachmentStream := CreateIcmStreamAdapter(T);

      if FastReportExportToFP3(ReportStream, AttachmentStream, MakeDictionary(['RecordID', Instance.Key]), True) then begin
        File := Instance.Session.NewObject(IowFile);
        File.LoadFromStream(reportName + '.fp3', AttachmentStream);
        File.Apply;
        Instance.Attachments.Add(File).Apply;
        File := Empty;

        for i := 0 to Instance.StatusList.Count - 1 do begin
          if Instance.StatusList.Items[i].OrderStatus.Name = 'Заключение договора' then begin
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
