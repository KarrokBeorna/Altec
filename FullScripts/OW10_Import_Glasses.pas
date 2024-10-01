var
  S: IomSession;
  Price: IowGlassPacketPrice;
  GlassPacket: IowGlassPacket;

procedure createGlassPacket(InitPrice, Dist1Price, Dist2Price, PlenkaPrice, G1Price, G2Price, G3Price, i: Integer;
                            Formula: String);
begin
  GlassPacket := S.NewObject(IowGlassPacket);

  GlassPacket.Name := Formula;
  GlassPacket.Formula := Formula;
  GlassPacket.MinimalPrice := 350;
  GlassPacket.Number := i;

  Price := GlassPacket.Prices.Add;
  Price.Area := 0;
  Price.Price := InitPrice + Dist1Price + Dist2Price + PlenkaPrice + G1Price + G2Price + G3Price;

  Price.Apply;
  GlassPacket.Apply;
end;


begin
  S := CreateObjectSession();
  Distance1K := ['16','18','20','22','24'];
  Distance2K := ['10','12','14','16'];
  Plenka := ['', 'AI', 'AII', 'AIII'];
  Glasses1 := ['4', '4Sol', '4Royal', '4Sil', '4Br'];
  Glasses2 := ['4', '4Sol', '4Royal', '4Sil', '4Br', '4LowE'];
  Glasses3 := ['6', '6Sol', '6Royal', '6Sil', '6Br'];

  GPrices := [0, 350, 900, 900, 900, 135];
  Dist1Prices := [0, 50, 80, 110, 130];
  Dist2Prices := [0, 30, 15, 90];
  PlenkaPrices := [0, 1800, 2000, 2450];

  index := 1;

  // Стекло 4мм
  for a := 0 to length(Glasses1) - 1 do begin
    for b := 0 to length(Plenka) - 1 do begin
      Formula := Glasses1[a] + Plenka[b];
      index := index + 1;
      createGlassPacket(675, 0, 0, PlenkaPrices[b], GPrices[a], 0, 0, index, Formula);
    end;
  end;

  index := 1;

  // Стекло 6мм
  for a := 0 to length(Glasses3) - 1 do begin
    for b := 0 to length(Plenka) - 1 do begin
      Formula := Glasses3[a] + Plenka[b];
      index := index + 1;
      createGlassPacket(1000, 0, 0, PlenkaPrices[b], GPrices[a], 0, 0, index, Formula);
    end;
  end;
{
  index := 0;

  // Однокамерные
  for a := 0 to length(Glasses1) - 1 do begin
    for b := 0 to length(Plenka) - 1 do begin
      for c := 0 to length(Distance1K) - 1 do begin
        for d := 0 to length(Glasses2) - 1 do begin
          Formula := Glasses1[a] + Plenka[b] + '\' + Distance1K[c] + '\' + Glasses2[d];
          index := index + 1;
          createGlassPacket(1593, Dist1Prices[c], 0, PlenkaPrices[b], GPrices[a], GPrices[d], 0, index, Formula);
        end;
      end;
    end;
  end;

  index := 0;

  // Двухкамерные
  for a := 0 to length(Glasses1) - 1 do begin
    for b := 0 to length(Plenka) - 1 do begin
      for c := 0 to length(Distance2K) - 1 do begin
        for d := 0 to length(Glasses1) - 1 do begin
          for e := 0 to length(Distance2K) - 1 do begin
            for f := 0 to length(Glasses2) - 1 do begin
              Formula := Glasses1[a] + Plenka[b] + '\' + Distance2K[c] + '\' + Glasses1[d] + '\' + Distance2K[e] + '\' + Glasses2[f];
              index := index + 1;
              createGlassPacket(2079, Dist2Prices[c], Dist2Prices[e], PlenkaPrices[b], GPrices[a], GPrices[d], GPrices[f], index, Formula);
            end;
          end;
        end;
      end;
    end;
  end;
}
  S.Commit();
end;
