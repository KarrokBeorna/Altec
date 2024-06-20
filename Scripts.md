# Содержание
1. [Выбор файла ("Проводник")](#выбор-файла-проводник) 
2. [Выгрузка в файл](#выгрузка-в-файл)
3. [Взаимодействие с БД](#взаимодействие-с-бд)
4. [Взаимодействие с текущим объектом (Instance)](#взаимодействие-с-текущим-объектом-instance)
5. [Взаимодействие с отчётами](#взаимодействие-с-отчётами)
6. [Создание диалоговых окон](#создание-диалоговых-окон)
7. [Добавление дополнительного действия на стандартное событие](#добавление-дополнительного-действия-на-стандартное-событие)
8. [Переход между представлениями OptimaWin](#переход-между-представлениями-OptimaWin)
9. [Создание нового объекта](#создание-нового-объекта)

## Выбор файла ("Проводник")
```delphi
// для сохранения в файл
if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Место сохранения', 'C:\', true) then begin
  showmessage(vFileName);
end;

// для чтения из файла
if PromptForFileName(vFileName, 'CSV files (*.csv)|*.csv', '', 'Выберите файл', 'C:\', false) then begin
  showmessage(vFileName);
end;
```

## Выгрузка в файл
```delphi
buf := TStringList.Create;
for i := 0 to 10 do begin
  buf.add(intToStr(i));
end;
buf.SaveToFile(vFileName + '.csv');
buf.Free;
```

## Взаимодействие с БД
```delphi
session := CreateObjectSession();
temp1 := session.QueryRecordList(sqlQuery, empty);

for i := 0 to temp1.Count - 1 do begin
  value1 := temp1.items[i].value['SOME_COLUMN'];
end;

temp2 := session.QueryRecord(sqlQuery, empty);
value2 := temp2.value['SOME_COLUMN'];

temp3 := session.QueryValue(sqlQuery, empty); // первый столбец первой записи
```

## Взаимодействие с текущим объектом (Instance)
```delphi
for i := 0 to Instance.StatusList.Count - 1 do begin
  if Instance.StatusList.Items[i].OrderStatus.Name = 'Монтаж' then begin
    Instance.StatusList.Items[i].PlanDate := StrToDateTime(Copy(dateTimeToStr(dateMounting.time), 0, 11) + timeMounting.text + ':00');
    Instance.StatusList.Items[i].apply;
  end;
end;
```

## Взаимодействие с отчётами
1. Лучше глянуть полный пример скрипта для понимания
2. Читаем отчёт из потока ReportStream и конвертируем в поток для вложения AttachmentStream
3. Параметры в отчёт передаем при помощи словаря
4. При необходимости отображаем отчёт
5. Сохраняем как вложение

```delphi
if FastReportExportToFP3(ReportStream, AttachmentStream, MakeDictionary(['RecordID', Instance.Key]), True) then begin
  File := Instance.Session.NewObject(IowFile);
  File.LoadFromStream(reportName + '.fp3', AttachmentStream);
  File.Apply;
  Instance.Attachments.Add(File).Apply;
  File := Empty;
end;
```

## Создание диалоговых окон
1. Создаём форму определенного размера, располагаем в удобном месте на экране и удяляем лишние кнопки "Свернуть" и "Свернуть в окно"/"Развернуть"
2. Создаём элементы (кнопки, выпадающие списки, чекбоксы и т.д.) - задаем им размеры, смещение на форме и затем привязываем к ней
3. Обработчики событий привязываются с помощью `@nameOfProcedure`
4. Для отображения в конце пишем `if Form1.ShowModal = mrOk then Form1.Show;`

```delphi
Form1 := TForm.Create(Application);
with Form1 do begin
  Width := 265;
  Height := 205;
  caption := 'Доставка и монтаж';
  position := poScreenCenter;
  BorderIcons := biSystemMenu; // оставляем только кнопку закрытия
end;

dateMounting := TDateTimePicker.Create(Application);
with dateMounting do begin
  Left := 10;
  Top := 70;
  Width := 100;
  Parent := Form1;
end;

timeMounting := TComboBox.Create(Application);
with timeMounting do begin
  Left := 115;
  Top := 70;
  Width := 125;
  Text := '--Время монтажа--';
  Parent := Form1;
  items := timeStrings; // TStringList
end;

btnOk := TButton.Create(Application);
with btnOk do begin
  Left := 10;
  Top := 130;
  Width := 230;
  Height := 30;
  Caption := 'Сохранить';
  Parent := Form1;
  onClick := @btnOkClicked; // где-то в коде должна лежать данная процедура
end;

if Form1.ShowModal = mrOk then Form1.Show;
```

## Добавление дополнительного действия на стандартное событие
![image](https://github.com/KarrokBeorna/Altec/assets/43076360/d5ea96ef-b1a0-4bc4-a7f6-0bcb7c4cca81)

## Переход между представлениями OptimaWin
1. Создаём объекта типа `IpubViewsUIService`.
2. Смотрим открыто ли уже представление - если да, то переходим на него, если нет, то открываем.

```delphi
ViewsUIService := ServiceProvider.GetService(IpubViewsUIService);

if not ViewsUIService.ActivateView('Reprices') then
  ViewsUIService.OpenView('Reprices', True)
else
  ViewsUIService.RefreshActiveView;
```

Названия представлений можно взять:
1. Из таблицы `UI_ACTIONS` (если на искомое представление уже было создано какое-то действие)
![image](https://github.com/KarrokBeorna/Altec/assets/43076360/df75d266-1c35-4e8d-b82f-596e89d7060f)
2. С помощью исполнения скрипта на искомом представлении:

```delphi
var
  ViewsUIService: IpubViewsUIService;

begin
  ViewsUIService := ServiceProvider.GetService(IpubViewsUIService);
  showmessage(ViewsUIService.ActiveView.Name);
end.
```

## Создание нового объекта
1. Создаём объект в текущей сессии и заполняем необходимые поля (доступные поля можно найти в поиске по типу объекта)
2. Создаем объект типа `IpubObjectsUIService`
3. Открываем созданный на первом шаге объект на редактирование

```delphi
S := CreateObjectSession();
RP := S.NewObject(IowReprice);
RP.Name := REPRICENAME;
RP.Comment := REPRICENOTE;
RP.EffectDate := Now + 1/24;

ObjectsUIService := ServiceProvider.GetService(IpubObjectsUIService);
ObjectsUIService.EditObject(RP);
```

Названия объектов можно взять из представления "Действия объекта"
![image](https://github.com/KarrokBeorna/Altec/assets/43076360/00be02ca-7c96-4a60-97da-aff59b4239bc)
