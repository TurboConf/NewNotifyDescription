//@script_name NewNotifyDescription
//@script_display_name Генератор обработчиков оповещений
//@script_description Скрипт генерирует создание нового описания оповещения и его обработчик для популярных асинхронных методов
//@script_author dhurricane
//@script_developer_url https://github.com/d-hurricane
//@script_hotkey Control+Shift+N
//@retain_clipboard 1
//@enterprise_mode 0
//@hide_actions 1
//@turbobutton 1

Перем МодульРасширения;	// дополненние скрипта, определяющее его поведение
Перем ТурбоКонф;		// доступ к API взаимодействия с конфигуратором
Перем КодЯзыка;			// язык разработки
Перем ТекстМодуля;		// содержимое модуля на момент запуска скрипта
Перем ПозицияКурсора;	// структура, содержащая символ, строку и колонку позиции курсора при запуске скрипта

Перем ВсеАсинхМетоды;			// коллекция методов и аргументов их обработчиков
Перем ВыбранныйАсинхМетод;		// описание асинхронного метода, для которого генерируется обработчик
Перем ИмяТекущегоМетода;		// имя метода модуля, где реализован вызов асинхронного метода
Перем ОбработчикОповещения;		// имя обработчика оповещения для асинхронного метода и его тело

Процедура ИнициализироватьКонтекст()
	
	ТурбоКонф = Новый ТурбоКонф;
	
	ЗагрузитьСценарийРасширения();	

	ВыделенныйТекст = "";
	ПозицияКурсора = Новый Структура("Строка, Колонка, Символ");

	ТекстМодуля = ТурбоКонф.ПолучитьТекстСПозицией(
		ВыделенныйТекст,
		ПозицияКурсора.Символ,
		ПозицияКурсора.Колонка,
		ПозицияКурсора.Строка);

	КодЯзыка = "ru";
	МодульРасширения.ПриОпределенииЯзыкаРазработки(КодЯзыка);

	ВсеАсинхМетоды = ОписаниеАсинхронныхМетодов();
	ФильтрМетодов = Неопределено;
	
	ВыбранныйАсинхМетод = Неопределено;
	ИмяТекущегоМетода = "";
	ОбработчикОповещения = Новый Структура("Имя, Тело");

КонецПроцедуры

Процедура ВыполнитьСкрипт()

	ИнициализироватьКонтекст();
	ВыполнитьСкрипт_Шаг1();

КонецПроцедуры

Процедура ВыполнитьСкрипт_Шаг1()

	ИменаМетодов = ПолучитьИменаМетодовИзТекстаМодуля();

	ИмяТекущегоМетода = ИменаМетодов.ТекущийМетод;
	ФильтрМетодов = Неопределено;

	Если Не ПустаяСтрока(ИменаМетодов.АсинхМетод) Тогда
		
		КлючиМетодов = КлючиАсинхМетодовПоИмени(ИменаМетодов.АсинхМетод);

		Если КлючиМетодов.Количество() = 1 Тогда

			КлючМетода = КлючиМетодов[0];
			ВыбранныйАсинхМетод = ВсеАсинхМетоды[КлючМетода];
			
		ИначеЕсли КлючиМетодов.Количество() > 1 Тогда

			ВыбранныйАсинхМетод = Неопределено;
			ФильтрМетодов = КлючиМетодов;

		Иначе

			ВыбранныйАсинхМетод = Неопределено;
			ФильтрМетодов = Неопределено;

		КонецЕсли;

	КонецЕсли;

	Если ВыбранныйАсинхМетод = Неопределено Тогда
		
		ВыбратьАсинхронныйМетодИзСписка(ФильтрМетодов);

	Иначе
		
		ВыполнитьСкрипт_Шаг2();

	КонецЕсли;

КонецПроцедуры

Процедура ВыполнитьСкрипт_Шаг2()

	Перем АсинхМетод, ТекущийМетод, ИмяОбработчика, ПоказатьВводИмени;
	
	АсинхМетод = ВыбранныйАсинхМетод.Имя;
	ТекущийМетод = ИмяТекущегоМетода;
	ИмяОбработчика = "";
	ПоказатьВводИмени = Неопределено;
	ТелоОбработчика = "";

	МодульРасширения.ПриНазначенииОбработчика(АсинхМетод, ТекущийМетод, ИмяОбработчика, ПоказатьВводИмени, ТелоОбработчика);

	Если ПоказатьВводИмени = Неопределено Тогда
		ПоказатьВводИмени = ПустаяСтрока(ИмяОбработчика);
	КонецЕсли;

	ОбработчикОповещения.Имя = ИмяОбработчика;
	ОбработчикОповещения.Тело = ТелоОбработчика;

	Если ПоказатьВводИмени Тогда
		ВыбратьИмяОбработчикаОповещения();
	Иначе
		ВыполнитьСкрипт_Шаг3();	
	КонецЕсли;

КонецПроцедуры

Процедура ВыполнитьСкрипт_Шаг3()
	
	// Вставляем конструктор описания оповещения.
	
	Если КодЯзыка = "en" Тогда
		ШаблонВставки = "New NotifyDescription(""%1"", ThisObject)";
	Иначе
		ШаблонВставки = "Новый ОписаниеОповещения(""%1"", ЭтотОбъект)";
	КонецЕсли;

	ТекстВставки = СтрШаблон(ШаблонВставки, ОбработчикОповещения.Имя);

	ТурбоКонф.ВставитьТекст(ТекстВставки);

	ПозицияКурсора.Колонка = ПозицияКурсора.Колонка + СтрДлина(ТекстВставки);
	ПозицияКурсора.Символ = ПозицияКурсора.Символ + СтрДлина(ТекстВставки);

	// Вставляем сам обработчик оповщения.

	Если КодЯзыка = "en" Тогда
		ШаблонВставки = "
		|
		|&AtClient
		|Procedure %1(%2) Export
		|	%3
		|EndProcedure";
	Иначе
		ШаблонВставки = "
		|
		|&НаКлиенте
		|Процедура %1(%2) Экспорт
		|	%3
		|КонецПроцедуры";
	КонецЕсли;

	ТекстВставки = СтрШаблон(ШаблонВставки,
		ОбработчикОповещения.Имя,
		ВыбранныйАсинхМетод.Параметры,
		ОбработчикОповещения.Тело);

	ПерейтиКОкончаниюМетода();
	ТурбоКонф.ВставитьТекст(ТекстВставки);

	// Возвращаем курсор в конец конструктора оповещения.

	ТурбоКонф.ПерейтиВПозицию(ПозицияКурсора.Колонка, ПозицияКурсора.Строка);

КонецПроцедуры

Функция ПолучитьИменаМетодовИзТекстаМодуля()
	
	ИменаМетодов = Новый Структура();
	ИменаМетодов.Вставить("ТекущийМетод", "");
	ИменаМетодов.Вставить("АсинхМетод", "");
	
	ТекстДоКурсора = ПолучитьТекстМодуляДоКурсора();

	РегулярноеВыражение = Новый РегулярноеВыражение(ШаблонПоискаАсинхМетода());
	РегулярноеВыражение.ИгнорироватьРегистр = Истина;

	Совпадения = РегулярноеВыражение.НайтиСовпадения(ТекстДоКурсора);

	Если Совпадения.Количество() <> 0 Тогда
		
		ГруппыСовпадения = Совпадения[Совпадения.Количество() - 1].Группы;
		ИменаМетодов.АсинхМетод = ГруппыСовпадения[1].Значение;

	КонецЕсли;
	
	РегулярноеВыражение = Новый РегулярноеВыражение(ШаблонПоискаТекущегоМетода());
	РегулярноеВыражение.ИгнорироватьРегистр = Истина;
	РегулярноеВыражение.Многострочный = Истина;

	Совпадения = РегулярноеВыражение.НайтиСовпадения(ТекстДоКурсора);

	Если Совпадения.Количество() <> 0 Тогда
		
		ГруппыСовпадения = Совпадения[Совпадения.Количество() - 1].Группы;
		ИменаМетодов.ТекущийМетод = ГруппыСовпадения[1].Значение;

	КонецЕсли;

	Возврат ИменаМетодов;

КонецФункции

Функция ШаблонПоискаАсинхМетода()
	
	Шаблон = "\b(?<methodName>\w+)\(\s*$";

	Возврат Шаблон;

КонецФункции

Функция ШаблонПоискаТекущегоМетода()

	Шаблон = "^\s*(?:Процедура|Procedure|Функция|Function)\s+(\w+)";

	Возврат Шаблон;

КонецФункции

Процедура ВыбратьАсинхронныйМетодИзСписка(ФильтрМетодов = Неопределено)
	
	Форма = Новый ФормаСписка();
	Форма.УстановитьДействие(ЭтотОбъект, "ВыбратьАсинхронныйМетодИзСпискаЗавершение");

	Элементы = Новый Массив;

	Если ЗначениеЗаполнено(ФильтрМетодов) Тогда
		
		КоллекцияМетодовДляСписка = Новый Структура();
		Для каждого КлючМетода Из ФильтрМетодов Цикл
			Метод = ВсеАсинхМетоды[КлючМетода];
			КоллекцияМетодовДляСписка.Вставить(КлючМетода, Метод);
		КонецЦикла;

	Иначе

		КоллекцияМетодовДляСписка = ВсеАсинхМетоды;

	КонецЕсли;

	Для каждого ЭлементКоллекции Из КоллекцияМетодовДляСписка Цикл

		Метод = ЭлементКоллекции.Значение;
		
		ЭлементСписка = Новый Соответствие();
		ЭлементСписка.Вставить("Значение", ЭлементКоллекции.Ключ);
		ЭлементСписка.Вставить("Фильтр", Метод.Имя);
		ЭлементСписка.Вставить("Представление", Метод.Представление);
		
		Элементы.Добавить(ЭлементСписка);

	КонецЦикла;

	Форма.Данные = Элементы;
	Форма.Заголовок = "Выбор метода";

	Форма.Показать();

КонецПроцедуры

Процедура ВыбратьАсинхронныйМетодИзСпискаЗавершение(Значение, Отказ) Экспорт
	
	Если Не Отказ Тогда

		ВыбранныйАсинхМетод = ВсеАсинхМетоды[Значение];

		ВыполнитьСкрипт_Шаг2();

	КонецЕсли;

КонецПроцедуры

Процедура ВыбратьИмяОбработчикаОповещения()
	
	Подсказка = СтрШаблон("Укажите имя для обработчика метода ""%1"":", ВыбранныйАсинхМетод.Имя);

	Форма = Новый ФормаВводаЗначения();
	Форма.УстановитьДействие(ЭтотОбъект, "ВыбратьИмяОбработчикаОповещенияЗавершение");

	Форма.Значение = ОбработчикОповещения.Имя;
	Форма.Заголовок = "Имя обработчика";
	Форма.Текст = Подсказка;

	Форма.Показать();

КонецПроцедуры

Процедура ВыбратьИмяОбработчикаОповещенияЗавершение(Значение, Отказ) Экспорт

	Если Не Отказ Тогда

		ОбработчикОповещения.Имя = Значение;

		ВыполнитьСкрипт_Шаг3();

	КонецЕсли;
	
КонецПроцедуры

Процедура ПерейтиКНачалуМетода()
	
	ТурбоКонф.КонтролАльтКлавиша(Клавиши.P);
	
	Окно = ТурбоКонф.ЖдатьОкно("Процедуры и функции", 2000, Истина, Ложь);
	
	ТурбоКонф.Клавиша(Клавиши.Enter);
	
	ТурбоКонф.ЖдатьЗакрытияОкна(Окно, "Процедуры и функции", 1000);

КонецПроцедуры

Процедура ПерейтиКОкончаниюМетода()
		
	ПерейтиКНачалуМетода();

	ТурбоКонф.КонтролКлавиша(Клавиши.OemCloseBrackets);
	ТурбоКонф.Клавиша(Клавиши.End);

КонецПроцедуры

Процедура ЗагрузитьСценарийРасширения()
	
	СценарийПоУмолчанию = "settings/NewNotifyDescription/DefaultSettings.os";
	СценарийПользователя = "settings/NewNotifyDescription/Settings.os";

	Файл = Новый Файл(СценарийПользователя);

	Если Файл.Существует() Тогда
		МодульРасширения = ЗагрузитьСценарий(СценарийПользователя);
	Иначе
		МодульРасширения = ЗагрузитьСценарий(СценарийПоУмолчанию);
	КонецЕсли;

КонецПроцедуры

Функция ОписаниеАсинхронныхМетодов()
	
	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.ОткрытьФайл("settings\NewNotifyDescription\Methods.json", "UTF-8");	
	ДанныеФайла = ПрочитатьJSON(ЧтениеJSON);
	ЧтениеJSON.Закрыть();

	Результат = Новый Структура();

	ДополнительныйПараметр = ?(КодЯзыка = "en", "AdditionalParameters", "ДополнительныеПараметры");

	Для каждого Элемент Из ДанныеФайла[КодЯзыка] Цикл
		
		КлючМетода = Элемент.Ключ;
		ДанныеМетодаВФайле = Элемент.Значение;

		ИмяМетода = СвойствоСтруктуры(ДанныеМетодаВФайле, "name", КлючМетода);
		Представление = СвойствоСтруктуры(ДанныеМетодаВФайле, "presentation", ИмяМетода);
		ПараметрыМетода = СвойствоСтруктуры(ДанныеМетодаВФайле, "parameters", "");

		Если Не ПустаяСтрока(ПараметрыМетода) Тогда
			ПараметрыМетода = ПараметрыМетода + ", ";
		КонецЕсли;
		ПараметрыМетода = ПараметрыМетода + ДополнительныйПараметр;

		ОписаниеМетода = Новый Структура();
		ОписаниеМетода.Вставить("Имя", ИмяМетода);
		ОписаниеМетода.Вставить("Представление", Представление);
		ОписаниеМетода.Вставить("Параметры", ПараметрыМетода);

		Результат.Вставить(КлючМетода, ОписаниеМетода);

	КонецЦикла;

	Возврат Результат;

КонецФункции

Функция КлючиАсинхМетодовПоИмени(ИмяМетода)
	
	Результат = Новый Массив();

	Для каждого ЭлементКоллекции Из ВсеАсинхМетоды Цикл
		
		Метод = ЭлементКоллекции.Значение;

		Если СтрСравнить(ИмяМетода, Метод.Имя) = 0 Тогда
			Результат.Добавить(ЭлементКоллекции.Ключ);
		КонецЕсли;

	КонецЦикла;

	Возврат Результат;

КонецФункции

Функция СвойствоСтруктуры(Структура, Свойство, ЗначениеПоУмолчанию = Неопределено)
	
	Если Структура.Свойство(Свойство) Тогда
		Возврат Структура[Свойство];
	Иначе
		Возврат ЗначениеПоУмолчанию;
	КонецЕсли;

КонецФункции

Функция ПолучитьТекстМодуляДоКурсора(МаксСимволов = 0)
	
	Если ЗначениеЗаполнено(МаксСимволов) И МаксСимволов < ПозицияКурсора.Символ Тогда
		Возврат Сред(ТекстМодуля, ПозицияКурсора.Символ - МаксСимволов + 1, МаксСимволов);
	Иначе
		Возврат Лев(ТекстМодуля, ПозицияКурсора.Символ);
	КонецЕсли;

КонецФункции

ВыполнитьСкрипт();
