// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get trackYourCycle => 'Отслеживайте свой цикл';

  @override
  String lastPeriod(Object date) {
    return 'Последние: $date';
  }

  @override
  String get noData => 'Пока нет данных. Отметьте свой первый цикл!';

  @override
  String get avatarStateResting => 'Отдых...';

  @override
  String get avatarStateActive => 'Активность!';

  @override
  String get calendarTitle => 'Календарь цикла';

  @override
  String get save => 'Сохранить';

  @override
  String get tapToLogPeriod =>
      'Нажмите на день, чтобы отметить или снять отметку';

  @override
  String get logSymptomsButton => 'Как вы себя чувствуете сегодня?';

  @override
  String get symptomsTitle => 'Сегодняшние симптомы';

  @override
  String get symptomCramps => 'Спазмы';

  @override
  String get symptomHeadache => 'Головная боль';

  @override
  String get symptomNausea => 'Тошнота';

  @override
  String get moodHappy => 'Счастье';

  @override
  String get moodSad => 'Грусть';

  @override
  String get moodIrritable => 'Раздражение';

  @override
  String get noSymptomsLogged => 'Симптомы за сегодня не отмечены.';

  @override
  String get predictionsTitle => 'Прогнозы';

  @override
  String nextPeriodPrediction(Object days) {
    return 'Следующие через ~$days дней';
  }

  @override
  String nextPeriodDate(Object date) {
    return 'Примерно $date';
  }

  @override
  String get fertileWindow => 'Фертильное окно';

  @override
  String get ovulation => 'Прим. Овуляция';

  @override
  String cycleLength(Object days) {
    return 'Сред. цикл: $days дней';
  }

  @override
  String periodLength(Object days) {
    return 'Сред. длительность: $days дней';
  }

  @override
  String get notEnoughData =>
      'Отметьте хотя бы 2 цикла, чтобы увидеть прогнозы.';

  @override
  String get calendarLegendPeriod => 'Ваши месячные';

  @override
  String get calendarLegendPredicted => 'Прогноз месячных';

  @override
  String get calendarLegendFertile => 'Фертильное окно';

  @override
  String get welcomeTitle => 'Добро пожаловать в Bloom!';

  @override
  String get welcomeDesc => 'Ваш личный помощник по циклу. Давайте начнем.';

  @override
  String get questionPeriodTitle => 'Когда начались ваши последние месячные?';

  @override
  String get questionPeriodDesc =>
      'Вы можете отметить это в календаре. Если не помните, ничего страшного!';

  @override
  String get questionLengthTitle => 'Какая у вас средняя длина цикла?';

  @override
  String get questionLengthDesc =>
      'Это время от начала одного периода до начала следующего. (По умолчанию 28 дней)';

  @override
  String get skip => 'Пропустить';

  @override
  String get done => 'Готово';

  @override
  String get pickADate => 'Выбрать дату';

  @override
  String get days => 'дней';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsNotificationsDesc => 'Показывать оповещения о прогнозах';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsSupport => 'Поддержка';

  @override
  String get settingsSupportDesc => 'Сообщить об ошибке или задать вопрос';

  @override
  String get notificationPeriodTitle => 'Напоминание от Bloom!';

  @override
  String notificationPeriodBody(Object days) {
    return 'Ваши месячные, по прогнозу, начнутся через $days дней.';
  }

  @override
  String get notificationFertileTitle => 'Напоминание от Bloom!';

  @override
  String get notificationFertileBody =>
      'Ваше фертильное окно, по прогнозу, начнется завтра.';

  @override
  String get logPeriodStartButton => 'Месячные начались сегодня';

  @override
  String get logPeriodEndButton => 'Месячные закончились сегодня';

  @override
  String periodIsActive(Object day) {
    return 'У вас $day-й день месячных';
  }

  @override
  String periodDelayed(Object days) {
    return 'Задержка $days дней';
  }

  @override
  String get avatarStateDelayed => 'Ожидание...';

  @override
  String get avatarStateFollicular => 'Энергия возвращается!';

  @override
  String get avatarStateOvulation => 'Пик энергии!';

  @override
  String get avatarStateLuteal => 'Время отдыхать';

  @override
  String get insightNone =>
      'Отметьте свой первый цикл в календаре, чтобы увидеть инсайты!';

  @override
  String get insightMenstruation_1 =>
      'Время уюта! Ваша энергия на минимуме - это нормально. Не забывайте отдыхать, смотреть любимые шоу и, возможно, съесть ту шоколадку. 🍫';

  @override
  String get insightMenstruation_2 =>
      'Ваше тело усердно работает. Прислушайтесь к нему! Легкая растяжка или теплая ванна могут творить чудеса при спазмах.';

  @override
  String get insightMenstruation_3 =>
      'Чувствовать усталость - это нормально. Ваши гормоны на самом низком уровне. Приоритет - сон и гидратация.';

  @override
  String get insightFollicular_1 =>
      'Энергия возвращается! Эстроген растет. Отличный день, чтобы строить планы или сделать ту тренировку, которую вы откладывали.';

  @override
  String get insightFollicular_2 =>
      'Ваш разум проясняется. Это отличное время, чтобы выучить что-то новое или решить сложную проблему.';

  @override
  String get insightFollicular_3 =>
      'Настроение улучшается! По мере окончания месячных вы можете чувствовать себя более позитивно и общительно. Наслаждайтесь!';

  @override
  String get insightOvulation_1 =>
      'Вы на пике! 🌟 Сегодня ваш день. Уверенность и энергия на максимуме. Идеальное время для сложных задач или общения.';

  @override
  String get insightOvulation_2 =>
      'Сегодня вы можете чувствовать себя особенно уверенно. Это пик эстрогена! Отличный день, чтобы высказаться или возглавить проект.';

  @override
  String get insightOvulation_3 =>
      'Пик энергии! Ваше тело готово к более интенсивным упражнениям, если вы в настроении. Вы также можете почувствовать большую связь с окружающими.';

  @override
  String get insightLuteal_1 =>
      'Вы можете чувствовать себя немного раздражительной или уставшей - вините прогестерон. Это называется ПМС. Будьте добрее к себе, сейчас время для заботы о себе.';

  @override
  String get insightLuteal_2 =>
      'Тяга к еде? Это нормально. Ваше тело сжигает больше калорий. Выбирайте сложные углеводы или темный шоколад, чтобы оставаться в равновесии.';

  @override
  String get insightLuteal_3 =>
      'Чувствуете вздутие или чувствительность? Это лютеиновая фаза. Постарайтесь уменьшить количество соли и пейте больше воды. Это помогает!';

  @override
  String get insightDelayed_1 =>
      'Задержка? Небольшие колебания - это нормально, причиной могут быть стресс или изменения в режиме. Просто продолжайте следить.';

  @override
  String get insightDelayed_2 =>
      'Ожидание... Опоздание на день-два - это обычное дело. Постарайтесь расслабиться, хорошо выспаться и посмотреть, что будет завтра.';

  @override
  String get insightDelayed_3 =>
      'У вашего тела свой ритм. Задержка может случиться по многим причинам. Если вы беспокоитесь, вы всегда можете поговорить с доверенным взрослым.';

  @override
  String get settingsTheme => 'Тема приложения';

  @override
  String get themeRose => 'Нежная Роза';

  @override
  String get themeNight => 'Лунная Ночь';

  @override
  String get themeForest => 'Лесное Спокойствие';

  @override
  String get questionPeriodLengthTitle =>
      'Какая у вас средняя длительность месячных?';

  @override
  String get questionPeriodLengthDesc =>
      'Это поможет нам точнее рассчитать первый прогноз. (Обычно 3-7 дней)';

  @override
  String get settingsCycleCalculationTitle => 'Расчет длины цикла';

  @override
  String get settingsUseManualCalculation => 'Использовать ручной расчет';

  @override
  String get settingsUseManualCalculationDesc =>
      'Прогнозы будут основаны на значении ниже';

  @override
  String get settingsManualCycleLength => 'Ручная длина цикла';

  @override
  String get settingsManualCycleLengthDialogTitle => 'Выберите длину цикла';

  @override
  String settingsManualCycleLengthDays(int count) {
    return '$count дней';
  }

  @override
  String get dialogCancel => 'Отмена';

  @override
  String get dialogOK => 'OK';

  @override
  String get homeConfirmStartTitle => 'Начать месячные?';

  @override
  String get homeEmptyDesc =>
      'Начните отслеживать свой цикл, чтобы увидеть прогнозы. Нажмите кнопку \'+\' для начала.';

  @override
  String get homeConfirmStartDesc =>
      'Вы уверены, что хотите отметить сегодня как начало месячных?';

  @override
  String get homeConfirmEndTitle => 'Закончить месячные?';

  @override
  String get homeConfirmEndDesc =>
      'Вы уверены, что хотите отметить сегодня как конец месячных?';

  @override
  String get homeConfirmYes => 'Да';

  @override
  String get homeConfirmNo => 'Нет';

  @override
  String get calendarLongPressHint =>
      'Долгое нажатие на день, чтобы отметить симптомы';

  @override
  String get homeHello => 'Привет!';

  @override
  String get homeInsight => 'Инсайт';

  @override
  String get homeToday => 'Сегодня';

  @override
  String get homeEmptyTitle => 'Пока нет данных';

  @override
  String homeDayOfCycle(int day) {
    return 'День $day';
  }

  @override
  String homePredictionNextIn(Object days) {
    return 'Следующие через $days дней';
  }

  @override
  String homePredictionOvulationIn(Object days) {
    return 'Овуляция через $days дней';
  }

  @override
  String get homePredictionFertile => 'Фертильное окно';

  @override
  String get homePredictionPeriod => 'Месячные';

  @override
  String get homePredictionDelayed => 'Задержка';

  @override
  String get phaseMenstruation => 'Месячные';

  @override
  String get phaseFollicular => 'Фолликулярная фаза';

  @override
  String get phaseOvulation => 'Овуляция';

  @override
  String get phaseLuteal => 'Лютеиновая фаза';

  @override
  String get phaseDelayed => 'Задержка';

  @override
  String get phaseNone => 'Нет данных';

  @override
  String get settingsPillTrackerTitle => 'Контрацептивы';

  @override
  String get settingsPillTrackerEnable => 'Включить напоминания о таблетках';

  @override
  String get settingsPillTrackerDesc =>
      'Это отключит все прогнозы цикла (овуляция, фертильное окно) и установит ежедневные напоминания о приеме.';

  @override
  String get settingsPillTrackerTime => 'Время напоминания';

  @override
  String get settingsPillTrackerTimeNotSet => 'Не установлено';

  @override
  String get pillTrackerTabTitle => 'Таблетки';

  @override
  String get pillScreenTitle => 'Трекер Таблеток';

  @override
  String get pillTakenButton => 'Я приняла таблетку';

  @override
  String get pillAlreadyTaken => 'Сегодня принято!';

  @override
  String get pillInfoButton => 'Узнать о таблетках';

  @override
  String get pillInfoTitle => 'О таблетках';

  @override
  String get pillInfoWhatAreThey => 'Что такое контрацептивы?';

  @override
  String get pillInfoWhatAreTheyBody =>
      'Противозачаточные таблетки (КОК) — это тип лекарств, которые женщины могут принимать ежедневно для предотвращения беременности. Они содержат гормоны, которые останавливают овуляцию (выход яйцеклетки из яичника).';

  @override
  String get pillInfoHowToUse => 'Как их использовать?';

  @override
  String get pillInfoHowToUseBody =>
      'Вы должны принимать одну таблетку каждый день, в одно и то же время. Постоянство очень важно. Большинство упаковок содержат 21 активную таблетку и 7 таблеток плацебо («пустышек») или 28 активных таблеток. В неделю плацебо у вас, вероятно, начнется кровотечение отмены, похожее на месячные.';

  @override
  String get pillInfoWhatIfMissed => 'Что, если я пропустила таблетку?';

  @override
  String get pillInfoWhatIfMissedBody =>
      'Если вы пропустили одну таблетку, примите ее, как только вспомните, даже если это означает прием двух таблеток в один день. Если вы пропустили две или более таблеток, риск беременности возрастает. Примите последнюю пропущенную таблетку, выбросьте остальные пропущенные и используйте дополнительный метод контрацепции (например, презерватив) в течение следующих 7 дней. Всегда читайте инструкцию к вашему конкретному препарату или проконсультируйтесь с врачом.';

  @override
  String get notificationPillTitle => 'Bloom: Напоминание 💊';

  @override
  String get notificationPillBody => 'Время принять таблетку!';

  @override
  String get pillSetupTitle => 'Настройка упаковки';

  @override
  String get pillSetupDesc =>
      'Чтобы начать отслеживание, укажите информацию о вашей упаковке таблеток.';

  @override
  String get pillSetupStartDate => 'Когда началась эта упаковка?';

  @override
  String get pillSetupActiveDays => 'Активных таблеток (например, 21)';

  @override
  String get pillSetupPlaceboDays => 'Дней плацебо/перерыва (например, 7)';

  @override
  String get pillSetupSaveButton => 'Начать отслеживание';

  @override
  String get pillDay => 'День';

  @override
  String get pillDayActive => 'Активная';

  @override
  String get pillDayPlacebo => 'Плацебо';

  @override
  String get calendarLegendPill => 'Таблетка принята';

  @override
  String get pillResetTitle => 'Сбросить упаковку?';

  @override
  String get pillResetDesc =>
      'Это очистит настройки вашей текущей упаковки, и вам нужно будет настроить ее заново. Ваша история принятых таблеток сохранится.';

  @override
  String get pillResetButton => 'Сбросить';

  @override
  String get symptomNotesLabel => 'Notes for today...';

  @override
  String get calendarLegendNote => 'Note Added';

  @override
  String get logBleedingButton => 'Отметить кровотечение';

  @override
  String get logBleedingEndButton => 'Закончить кровотечение';

  @override
  String homeBleedingDay(int day) {
    return 'День кровотечения: $day';
  }

  @override
  String get calendarLegendBleeding => 'Кровотечение отмены';

  @override
  String get insightPillActive =>
      'Вы принимаете активную таблетку. Не забывайте принимать ее в одно и то же время! Постоянство — это ключ.';

  @override
  String get insightPillPlacebo =>
      'У вас неделя плацебо (перерыв). Кровотечение отмены (похожее на месячные) в это время — это нормально. Не забудьте вовремя начать новую упаковку!';

  @override
  String get notificationPillActionTaken => 'Принято';

  @override
  String get calendarEmptyState =>
      'Здесь появится ваша история. Нажмите на день, чтобы отметить месячные или кровотечение.';

  @override
  String get authLogin => 'Войти';

  @override
  String get authRegister => 'Регистрация';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authSwitchToRegister => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get authSwitchToLogin => 'Уже есть аккаунт? Войти';

  @override
  String get authSignOut => 'Выйти';

  @override
  String get authSignOutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get authWithGoogle => 'Войти через Google';

  @override
  String get authAsGuest => 'Продолжить как гость';

  @override
  String get authLinkAccount => 'Привязать аккаунт Google';

  @override
  String get authLinkDesc =>
      'Сохраните ваши данные и синхронизируйте их между устройствами, привязав аккаунт Google.';

  @override
  String get authAccount => 'Аккаунт';

  @override
  String get authOr => 'или';

  @override
  String get authLinkSuccess => 'Аккаунт успешно привязан!';

  @override
  String get authLinkError => 'Ошибка привязки аккаунта: ';
}
