const
  INSERT_EXTENDER = 'INSERT INTO EXTENDERS (ID,  THICK) VALUES (:ID, :THICK)';
  INSERT_EXTENDER_FIRM = 'INSERT INTO R_FIRMPROFIL_EXTENDERS (ID, FIRMID, EXTENDERID, POSIT) ' + #13#10 +
                         'SELECT ID, FIRMID, COUPLERID, POSIT FROM R_FIRMPROFIL_COUPLERS WHERE COUPLERID = :COUPLERID';
  INSERT_EXTENDER_ARM = 'INSERT INTO EXTENDERS_REINFORCEMENTS (ID, EXTENDERID, REINFORCEMENTID, MINLENGTH, F_DECREMENT, RULE, POSIT) ' + #13#10 +
                        'SELECT ID, COUPLERID, REINFORCEMENTID, MINLENGTH, F_DECREMENT, RULE, POSIT FROM COUPLERS_REINFORCEMENTS WHERE COUPLERID = :COUPLERID';
  DELETE_COUPLER_FIRM = 'DELETE FROM R_FIRMPROFIL_COUPLERS WHERE COUPLERID = :COUPLERID';
  DELETE_COUPLER_ARM = 'DELETE FROM COUPLERS_REINFORCEMENTS WHERE COUPLERID = :COUPLERID';
  DELETE_COUPLER = 'DELETE FROM COUPLERS WHERE ID = :ID';

var
  S: IomSession;

begin
  S := CreateObjectSession;

  for i := 0 to SelectedRecords.Count - 1 do begin
    try
      S.ExecSQL(INSERT_EXTENDER, MakeDictionary(['ID', SelectedRecords[i].Value['ARTICULID'], 'THICK', SelectedRecords[i].Value['THICK']]));
    except
    end;
    try
      S.ExecSQL(INSERT_EXTENDER_FIRM, MakeDictionary(['COUPLERID', SelectedRecords[i].Value['ARTICULID']]));
    except
    end;
    try
      S.ExecSQL(INSERT_EXTENDER_ARM, MakeDictionary(['COUPLERID', SelectedRecords[i].Value['ARTICULID']]));
    except
    end;
    try
      S.ExecSQL(DELETE_COUPLER_FIRM, MakeDictionary(['COUPLERID', SelectedRecords[i].Value['ARTICULID']]));
    except
    end;
    try
      S.ExecSQL(DELETE_COUPLER_ARM, MakeDictionary(['COUPLERID', SelectedRecords[i].Value['ARTICULID']]));
    except
    end;
    try
      S.ExecSQL(DELETE_COUPLER, MakeDictionary(['ID', SelectedRecords[i].Value['ARTICULID']]));
    except
    end;
  end;

  S.Commit();
end;
