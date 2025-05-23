**КРАТКО:**
Для того чтобы вывести пользовательские параметры в стандартных отчётах достаточно заполнить словари с частями изделия, на которых Вы хотите искать пользовательские параметры.

В отчёте есть такая процедура как `GetUserParameters(...)`:

```pascal
procedure GetUserParameters(paramsPair: IcmDictionary; CI: IcsConstruction; whoParam: String);
begin
  ...
end;
```
На вход она принимает словарь параметров в виде:
```javascript
{
  Key: "Идентификатор пользовательского параметра",
  Value: "Наименование, отображаемое в отчете"
}
```
А также объект конструкции, на которой хотим искать какой-либо параметр, и наименование части.  
Например: `'Профиль - Балка рамы'` или `'Общие - Изделие'`

Данная процедура на основе полученного словаря параметров проходит по конструкции (всем окнам, рамам, балкам рамы, створкам и т.д.) и ищет параметр на заданной части.  
После чего берёт `Наименование значения` данного параметра и подсчитывает кол-во повторений на каждом изделии при помощи процедуры `AddToParamDict(...)`.
![image](https://github.com/user-attachments/assets/6bda01f8-7bbc-41af-87e4-a9f77a0b65eb)

Затем полученный словарь добавляет в список словарей, который в конечном итоге будет примерно следующим:
```javascript
  {
    [0]: {
          Key1: "1.2",
          Value1: 3;
          Key2: "1.4",
          Value2: 2;
         },
    [1]: {
          Key1: "Черный",
          Value1: 2;
          Key2: "Серый",
          Value2: 1;
         },
  }
```

Для того, чтобы начать вызывать процедуру `GetUserParameters(...)` Вам необходимо собрать словарь из пар 
