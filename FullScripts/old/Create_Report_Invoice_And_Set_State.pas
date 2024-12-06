const
  GET_REPORTBLOB = 'SELECT REPORTBLOB FROM REPORTS WHERE NAME = :NAME AND REPORTTYPE = 0 AND DELETED = 0';

  SET_STATUS1 = 'INSERT INTO ORDERSTATUSLOG (ORDERID, ORDERSTATUSID, MARK, AUTOR, WP_PROCESSED, DONE) VALUES   ' + #13#10 +
                '(:ORDERID, (SELECT FIRST 1 ID FROM ORDERSTATUSES WHERE NAME = ''Отгружен''), 0, :USERID, 0, 1)';

  SET_STATUS2 = 'UPDATE OR INSERT INTO ORDERSTATUSBANK (ORDERID, ORDERSTATUSID, MARK, DONE) VALUES           ' + #13#10 +
                '(:ORDERID, (SELECT FIRST 1 ID FROM ORDERSTATUSES WHERE NAME = ''Отгружен''), 0, 1)          ' + #13#10 +
                'MATCHING (ORDERID, ORDERSTATUSID, MARK)';


var
  Session: IomSession;
  S, T: TStream;
  reportName: String;
  ReportStream, AttachmentStream: IcmStream;
  Instance: IowOrder;
  fileID: Integer;
  File: IowFile;

begin
  Session := CreateObjectSession();
  Instance := Session.OpenDocumentByKey(IowOrder, SelectedRecords.items[0]['ID']);
  reportName := 'Накладная на получение заказа';
  S := TStringStream.Create(Instance.Session.QueryValue(GET_REPORTBLOB, MakeDictionary(['NAME', reportName])));

  try
    ReportStream := CreateIcmStreamAdapter(S);
    T := TMemoryStream.Create;

    try
      AttachmentStream := CreateIcmStreamAdapter(T);

      if FastReportExportToFP3(ReportStream, AttachmentStream, MakeDictionary(['RecordID', Instance.Key]), True) then begin
        Session.ExecSQL(SET_STATUS1, MakeDictionary(['ORDERID', Instance.Key, 'USERID', UserContext.UserID]));
        Session.ExecSQL(SET_STATUS2, MakeDictionary(['ORDERID', Instance.Key]));
        Session.Commit;
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
