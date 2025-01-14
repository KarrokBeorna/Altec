{
  * Скрипт позволяет удалить все вхождения выбранного элемента на вкладке
  * "Вхождения" в открытой карточке компонента
}

const
  DELETE_COMPLETE = 'DELETE FROM FURNCOMPLETE WHERE FRCID = :ID';

begin
  Instance.Articul.Session.ExecSQL(DELETE_COMPLETE, MakeDictionary(['ID', Focused.Key]));
  Instance.Articul.Session.Commit;
  Instance.Articul.Apply;
  Instance.Articul.Reload;
end
