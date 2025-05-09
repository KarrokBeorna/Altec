{
  * Скрипт сгенерирует все доступные стекопакеты с дистанционными рамками Distance1K и Distance2K
  * С плёнками Plenka, которые ставятся лишь на первое стекло
  * Со стёклами первыми уличными или центральными Glasses1
  * Со стёклами домашними Glasses2
  * С начальными ценами стёкол Price4 (просто стекло 4мм)
  *                            Price6 (просто стекло 6мм)
  *                            Price2K4 (однокамерный стеклопакет со стёклами 4мм)
  *                            Price3K4 (двухкамерный стеклопакет со стёклами 4мм)
  * С наценками за покрытие стёкол GPrices
  * С наценками за дистанционные рамки Dist1Prices и Dist2Prices
  * С ценами плёнок PlenkaPrices
}

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

  Price4 := 675;
  Price6 := 1000;
  Price2K4 := 1593;
  Price3K4 := 2079;

  index := 1;

  // Стекло 4мм
  for a := 0 to length(Glasses1) - 1 do begin
    for b := 0 to length(Plenka) - 1 do begin
      Formula := Glasses1[a] + Plenka[b];
      index := index + 1;
      createGlassPacket(Price4, 0, 0, PlenkaPrices[b], GPrices[a], 0, 0, index, Formula);
    end;
  end;

  index := 1;

  // Стекло 6мм
  for a := 0 to length(Glasses3) - 1 do begin
    for b := 0 to length(Plenka) - 1 do begin
      Formula := Glasses3[a] + Plenka[b];
      index := index + 1;
      createGlassPacket(Price6, 0, 0, PlenkaPrices[b], GPrices[a], 0, 0, index, Formula);
    end;
  end;

  index := 0;

  // Однокамерные
  for a := 0 to length(Glasses1) - 1 do begin
    for b := 0 to length(Plenka) - 1 do begin
      for c := 0 to length(Distance1K) - 1 do begin
        for d := 0 to length(Glasses2) - 1 do begin
          Formula := Glasses1[a] + Plenka[b] + '\' + Distance1K[c] + '\' + Glasses2[d];
          index := index + 1;
          createGlassPacket(Price2K4, Dist1Prices[c], 0, PlenkaPrices[b], GPrices[a], GPrices[d], 0, index, Formula);
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
              createGlassPacket(Price3K4, Dist2Prices[c], Dist2Prices[e], PlenkaPrices[b], GPrices[a], GPrices[d], GPrices[f], index, Formula);
            end;
          end;
        end;
      end;
    end;
  end;

  S.Commit();
end;
