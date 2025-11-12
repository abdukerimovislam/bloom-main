import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru')
  ];

  /// No description provided for @trackYourCycle.
  ///
  /// In en, this message translates to:
  /// **'Track your cycle'**
  String get trackYourCycle;

  /// No description provided for @lastPeriod.
  ///
  /// In en, this message translates to:
  /// **'Last Period: {date}'**
  String lastPeriod(Object date);

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data yet. Log your first cycle!'**
  String get noData;

  /// No description provided for @avatarStateResting.
  ///
  /// In en, this message translates to:
  /// **'Resting...'**
  String get avatarStateResting;

  /// No description provided for @avatarStateActive.
  ///
  /// In en, this message translates to:
  /// **'Active!'**
  String get avatarStateActive;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Calendar'**
  String get calendarTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @tapToLogPeriod.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to log or unlog it'**
  String get tapToLogPeriod;

  /// No description provided for @logSymptomsButton.
  ///
  /// In en, this message translates to:
  /// **'How do you feel today?'**
  String get logSymptomsButton;

  /// No description provided for @symptomsTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Symptoms'**
  String get symptomsTitle;

  /// No description provided for @symptomCramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get symptomCramps;

  /// No description provided for @symptomHeadache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get symptomHeadache;

  /// No description provided for @symptomNausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get symptomNausea;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodIrritable.
  ///
  /// In en, this message translates to:
  /// **'Irritable'**
  String get moodIrritable;

  /// No description provided for @noSymptomsLogged.
  ///
  /// In en, this message translates to:
  /// **'No symptoms logged for today.'**
  String get noSymptomsLogged;

  /// No description provided for @predictionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get predictionsTitle;

  /// No description provided for @nextPeriodPrediction.
  ///
  /// In en, this message translates to:
  /// **'Next period in ~{days} days'**
  String nextPeriodPrediction(Object days);

  /// No description provided for @nextPeriodDate.
  ///
  /// In en, this message translates to:
  /// **'Around {date}'**
  String nextPeriodDate(Object date);

  /// No description provided for @fertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Fertile Window'**
  String get fertileWindow;

  /// No description provided for @ovulation.
  ///
  /// In en, this message translates to:
  /// **'Est. Ovulation'**
  String get ovulation;

  /// No description provided for @cycleLength.
  ///
  /// In en, this message translates to:
  /// **'Avg. Cycle: {days} days'**
  String cycleLength(Object days);

  /// No description provided for @periodLength.
  ///
  /// In en, this message translates to:
  /// **'Avg. Period: {days} days'**
  String periodLength(Object days);

  /// No description provided for @notEnoughData.
  ///
  /// In en, this message translates to:
  /// **'Log at least 2 cycles to see predictions.'**
  String get notEnoughData;

  /// No description provided for @calendarLegendPeriod.
  ///
  /// In en, this message translates to:
  /// **'Your Period'**
  String get calendarLegendPeriod;

  /// No description provided for @calendarLegendPredicted.
  ///
  /// In en, this message translates to:
  /// **'Predicted Period'**
  String get calendarLegendPredicted;

  /// No description provided for @calendarLegendFertile.
  ///
  /// In en, this message translates to:
  /// **'Fertile Window'**
  String get calendarLegendFertile;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Bloom!'**
  String get welcomeTitle;

  /// No description provided for @welcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'Your personal cycle pal. Let\'s get you set up.'**
  String get welcomeDesc;

  /// No description provided for @questionPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'When did your last period start?'**
  String get questionPeriodTitle;

  /// No description provided for @questionPeriodDesc.
  ///
  /// In en, this message translates to:
  /// **'You can log this in the calendar. If you don\'t remember, that\'s okay!'**
  String get questionPeriodDesc;

  /// No description provided for @questionLengthTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your average cycle length?'**
  String get questionLengthTitle;

  /// No description provided for @questionLengthDesc.
  ///
  /// In en, this message translates to:
  /// **'This is the time from one period start to the next. (Default is 28 days)'**
  String get questionLengthDesc;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @pickADate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get pickADate;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Show alerts for predictions'**
  String get settingsNotificationsDesc;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsSupport;

  /// No description provided for @settingsSupportDesc.
  ///
  /// In en, this message translates to:
  /// **'Report a bug or ask a question'**
  String get settingsSupportDesc;

  /// No description provided for @notificationPeriodTitle.
  ///
  /// In en, this message translates to:
  /// **'Heads up from Bloom!'**
  String get notificationPeriodTitle;

  /// No description provided for @notificationPeriodBody.
  ///
  /// In en, this message translates to:
  /// **'Your period is predicted to start in {days} days.'**
  String notificationPeriodBody(Object days);

  /// No description provided for @notificationFertileTitle.
  ///
  /// In en, this message translates to:
  /// **'Heads up from Bloom!'**
  String get notificationFertileTitle;

  /// No description provided for @notificationFertileBody.
  ///
  /// In en, this message translates to:
  /// **'Your fertile window is predicted to start tomorrow.'**
  String get notificationFertileBody;

  /// No description provided for @logPeriodStartButton.
  ///
  /// In en, this message translates to:
  /// **'Period Started Today'**
  String get logPeriodStartButton;

  /// No description provided for @logPeriodEndButton.
  ///
  /// In en, this message translates to:
  /// **'Period Ended Today'**
  String get logPeriodEndButton;

  /// No description provided for @periodIsActive.
  ///
  /// In en, this message translates to:
  /// **'You are on day {day} of your period'**
  String periodIsActive(Object day);

  /// No description provided for @periodDelayed.
  ///
  /// In en, this message translates to:
  /// **'Period is {days} days late'**
  String periodDelayed(Object days);

  /// No description provided for @avatarStateDelayed.
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get avatarStateDelayed;

  /// No description provided for @avatarStateFollicular.
  ///
  /// In en, this message translates to:
  /// **'Energy is returning!'**
  String get avatarStateFollicular;

  /// No description provided for @avatarStateOvulation.
  ///
  /// In en, this message translates to:
  /// **'Peak energy!'**
  String get avatarStateOvulation;

  /// No description provided for @avatarStateLuteal.
  ///
  /// In en, this message translates to:
  /// **'Time to rest'**
  String get avatarStateLuteal;

  /// No description provided for @insightNone.
  ///
  /// In en, this message translates to:
  /// **'Log your first cycle in the calendar to start seeing insights!'**
  String get insightNone;

  /// No description provided for @insightMenstruation_1.
  ///
  /// In en, this message translates to:
  /// **'Time for coziness! Your energy is at its lowest - that\'s okay. Remember to rest, watch your favorite show, and maybe eat that chocolate bar. 🍫'**
  String get insightMenstruation_1;

  /// No description provided for @insightMenstruation_2.
  ///
  /// In en, this message translates to:
  /// **'Your body is doing hard work. Listen to it! Gentle stretching or a warm bath can do wonders for cramps.'**
  String get insightMenstruation_2;

  /// No description provided for @insightMenstruation_3.
  ///
  /// In en, this message translates to:
  /// **'It\'s normal to feel tired. Your hormones are at their lowest. Prioritize sleep and hydration today.'**
  String get insightMenstruation_3;

  /// No description provided for @insightFollicular_1.
  ///
  /// In en, this message translates to:
  /// **'Energy is returning! Estrogen is rising. Great day to make plans or do that workout you\'ve been putting off.'**
  String get insightFollicular_1;

  /// No description provided for @insightFollicular_2.
  ///
  /// In en, this message translates to:
  /// **'Your mind is getting clearer. This is a great time to learn something new or tackle a tricky problem.'**
  String get insightFollicular_2;

  /// No description provided for @insightFollicular_3.
  ///
  /// In en, this message translates to:
  /// **'Mood boost! As your period ends, you might feel more positive and sociable. Enjoy it!'**
  String get insightFollicular_3;

  /// No description provided for @insightOvulation_1.
  ///
  /// In en, this message translates to:
  /// **'You\'re peaking! 🌟 Today is your day to shine. Confidence and energy are at their maximum. Perfect time for challenging tasks or socializing.'**
  String get insightOvulation_1;

  /// No description provided for @insightOvulation_2.
  ///
  /// In en, this message translates to:
  /// **'You might feel extra confident today. It\'s the estrogen peak! A great day to speak up or lead a project.'**
  String get insightOvulation_2;

  /// No description provided for @insightOvulation_3.
  ///
  /// In en, this message translates to:
  /// **'Peak energy! Your body is ready for more intense exercise if you feel up for it. You might also feel more connected to others.'**
  String get insightOvulation_3;

  /// No description provided for @insightLuteal_1.
  ///
  /// In en, this message translates to:
  /// **'You might feel a bit irritable or tired - blame progesterone. This is called PMS. Be kinder to yourself, now is the time for self-care.'**
  String get insightLuteal_1;

  /// No description provided for @insightLuteal_2.
  ///
  /// In en, this message translates to:
  /// **'Food cravings? It\'s normal. Your body is burning more calories. Opt for complex carbs or dark chocolate to stay balanced.'**
  String get insightLuteal_2;

  /// No description provided for @insightLuteal_3.
  ///
  /// In en, this message translates to:
  /// **'Feeling a bit bloated or sensitive? It\'s the luteal phase. Try to reduce salt and drink extra water. It helps!'**
  String get insightLuteal_3;

  /// No description provided for @insightDelayed_1.
  ///
  /// In en, this message translates to:
  /// **'Period delayed? Small fluctuations are normal, stress or changes in routine can be the cause. Just keep track.'**
  String get insightDelayed_1;

  /// No description provided for @insightDelayed_2.
  ///
  /// In en, this message translates to:
  /// **'Waiting... It\'s common to be off by a day or two. Try to relax, get good sleep, and see what happens tomorrow.'**
  String get insightDelayed_2;

  /// No description provided for @insightDelayed_3.
  ///
  /// In en, this message translates to:
  /// **'Your body has its own rhythm. A late period can happen for many reasons. If you\'re worried, you can always talk to a trusted adult.'**
  String get insightDelayed_3;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get settingsTheme;

  /// No description provided for @themeRose.
  ///
  /// In en, this message translates to:
  /// **'Gentle Rose'**
  String get themeRose;

  /// No description provided for @themeNight.
  ///
  /// In en, this message translates to:
  /// **'Moonlit Night'**
  String get themeNight;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest Calm'**
  String get themeForest;

  /// No description provided for @questionPeriodLengthTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s your average period duration?'**
  String get questionPeriodLengthTitle;

  /// No description provided for @questionPeriodLengthDesc.
  ///
  /// In en, this message translates to:
  /// **'This helps us make a more accurate first prediction. (Usually 3-7 days)'**
  String get questionPeriodLengthDesc;

  /// No description provided for @settingsCycleCalculationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cycle Length Calculation'**
  String get settingsCycleCalculationTitle;

  /// No description provided for @settingsUseManualCalculation.
  ///
  /// In en, this message translates to:
  /// **'Use manual calculation'**
  String get settingsUseManualCalculation;

  /// No description provided for @settingsUseManualCalculationDesc.
  ///
  /// In en, this message translates to:
  /// **'Predictions will be based on the value below'**
  String get settingsUseManualCalculationDesc;

  /// No description provided for @settingsManualCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Manual cycle length'**
  String get settingsManualCycleLength;

  /// No description provided for @settingsManualCycleLengthDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Select cycle length'**
  String get settingsManualCycleLengthDialogTitle;

  /// No description provided for @settingsManualCycleLengthDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String settingsManualCycleLengthDays(int count);

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogOK.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get dialogOK;

  /// No description provided for @homeConfirmStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Period?'**
  String get homeConfirmStartTitle;

  /// No description provided for @homeEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your period to see predictions. Press the \'+\' button to begin.'**
  String get homeEmptyDesc;

  /// No description provided for @homeConfirmStartDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark today as the start of your period?'**
  String get homeConfirmStartDesc;

  /// No description provided for @homeConfirmEndTitle.
  ///
  /// In en, this message translates to:
  /// **'End Period?'**
  String get homeConfirmEndTitle;

  /// No description provided for @homeConfirmEndDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark today as the end of your period?'**
  String get homeConfirmEndDesc;

  /// No description provided for @homeConfirmYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get homeConfirmYes;

  /// No description provided for @homeConfirmNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get homeConfirmNo;

  /// No description provided for @calendarLongPressHint.
  ///
  /// In en, this message translates to:
  /// **'Long press a day to log symptoms'**
  String get calendarLongPressHint;

  /// No description provided for @homeHello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get homeHello;

  /// No description provided for @homeInsight.
  ///
  /// In en, this message translates to:
  /// **'Insight'**
  String get homeInsight;

  /// No description provided for @homeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeToday;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Data Yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeDayOfCycle.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String homeDayOfCycle(int day);

  /// No description provided for @homePredictionNextIn.
  ///
  /// In en, this message translates to:
  /// **'Next period in {days} days'**
  String homePredictionNextIn(Object days);

  /// No description provided for @homePredictionOvulationIn.
  ///
  /// In en, this message translates to:
  /// **'Ovulation in {days} days'**
  String homePredictionOvulationIn(Object days);

  /// No description provided for @homePredictionFertile.
  ///
  /// In en, this message translates to:
  /// **'Fertile Window'**
  String get homePredictionFertile;

  /// No description provided for @homePredictionPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get homePredictionPeriod;

  /// No description provided for @homePredictionDelayed.
  ///
  /// In en, this message translates to:
  /// **'Delayed'**
  String get homePredictionDelayed;

  /// No description provided for @phaseMenstruation.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get phaseMenstruation;

  /// No description provided for @phaseFollicular.
  ///
  /// In en, this message translates to:
  /// **'Follicular Phase'**
  String get phaseFollicular;

  /// No description provided for @phaseOvulation.
  ///
  /// In en, this message translates to:
  /// **'Ovulation'**
  String get phaseOvulation;

  /// No description provided for @phaseLuteal.
  ///
  /// In en, this message translates to:
  /// **'Luteal Phase'**
  String get phaseLuteal;

  /// No description provided for @phaseDelayed.
  ///
  /// In en, this message translates to:
  /// **'Delayed'**
  String get phaseDelayed;

  /// No description provided for @phaseNone.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get phaseNone;

  /// No description provided for @settingsPillTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Contraceptive Pills'**
  String get settingsPillTrackerTitle;

  /// No description provided for @settingsPillTrackerEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable Pill Reminders'**
  String get settingsPillTrackerEnable;

  /// No description provided for @settingsPillTrackerDesc.
  ///
  /// In en, this message translates to:
  /// **'This will disable all cycle predictions (ovulation, fertile window) and set up daily pill reminders.'**
  String get settingsPillTrackerDesc;

  /// No description provided for @settingsPillTrackerTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get settingsPillTrackerTime;

  /// No description provided for @settingsPillTrackerTimeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get settingsPillTrackerTimeNotSet;

  /// No description provided for @pillTrackerTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Pills'**
  String get pillTrackerTabTitle;

  /// No description provided for @pillScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Pill Tracker'**
  String get pillScreenTitle;

  /// No description provided for @pillTakenButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve taken my pill'**
  String get pillTakenButton;

  /// No description provided for @pillAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken today!'**
  String get pillAlreadyTaken;

  /// No description provided for @pillInfoButton.
  ///
  /// In en, this message translates to:
  /// **'Learn about pills'**
  String get pillInfoButton;

  /// No description provided for @pillInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About Pills'**
  String get pillInfoTitle;

  /// No description provided for @pillInfoWhatAreThey.
  ///
  /// In en, this message translates to:
  /// **'What are contraceptive pills?'**
  String get pillInfoWhatAreThey;

  /// No description provided for @pillInfoWhatAreTheyBody.
  ///
  /// In en, this message translates to:
  /// **'Contraceptive pills (often called \'the pill\') are a type of medication that women can take daily to prevent pregnancy. They contain hormones that stop ovulation (the release of an egg from the ovaries).'**
  String get pillInfoWhatAreTheyBody;

  /// No description provided for @pillInfoHowToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use them?'**
  String get pillInfoHowToUse;

  /// No description provided for @pillInfoHowToUseBody.
  ///
  /// In en, this message translates to:
  /// **'You must take one pill every day, at the same time each day. Consistency is very important. Most packs have 21 active pills and 7 placebo (sugar) pills, or 28 active pills. During the placebo week, you will likely have a withdrawal bleed, which is like a period.'**
  String get pillInfoHowToUseBody;

  /// No description provided for @pillInfoWhatIfMissed.
  ///
  /// In en, this message translates to:
  /// **'What if I miss a pill?'**
  String get pillInfoWhatIfMissed;

  /// No description provided for @pillInfoWhatIfMissedBody.
  ///
  /// In en, this message translates to:
  /// **'If you miss one pill, take it as soon as you remember, even if it means taking two pills in one day. If you miss two or more pills, your risk of pregnancy increases. Take the last pill you missed, discard the other missed pills, and use a backup method of contraception (like a condom) for the next 7 days. Always read the leaflet that comes with your specific brand of pill or consult your doctor.'**
  String get pillInfoWhatIfMissedBody;

  /// No description provided for @notificationPillTitle.
  ///
  /// In en, this message translates to:
  /// **'Bloom Pill Reminder 💊'**
  String get notificationPillTitle;

  /// No description provided for @notificationPillBody.
  ///
  /// In en, this message translates to:
  /// **'Time to take your pill!'**
  String get notificationPillBody;

  /// No description provided for @pillSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Pack Setup'**
  String get pillSetupTitle;

  /// No description provided for @pillSetupDesc.
  ///
  /// In en, this message translates to:
  /// **'To start tracking, please provide some info about your pill pack.'**
  String get pillSetupDesc;

  /// No description provided for @pillSetupStartDate.
  ///
  /// In en, this message translates to:
  /// **'When did this pack start?'**
  String get pillSetupStartDate;

  /// No description provided for @pillSetupActiveDays.
  ///
  /// In en, this message translates to:
  /// **'Active pills in pack (e.g., 21)'**
  String get pillSetupActiveDays;

  /// No description provided for @pillSetupPlaceboDays.
  ///
  /// In en, this message translates to:
  /// **'Placebo/break days (e.g., 7)'**
  String get pillSetupPlaceboDays;

  /// No description provided for @pillSetupSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Start Tracking'**
  String get pillSetupSaveButton;

  /// No description provided for @pillDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get pillDay;

  /// No description provided for @pillDayActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get pillDayActive;

  /// No description provided for @pillDayPlacebo.
  ///
  /// In en, this message translates to:
  /// **'Placebo'**
  String get pillDayPlacebo;

  /// No description provided for @calendarLegendPill.
  ///
  /// In en, this message translates to:
  /// **'Pill Taken'**
  String get calendarLegendPill;

  /// No description provided for @pillResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Pack?'**
  String get pillResetTitle;

  /// No description provided for @pillResetDesc.
  ///
  /// In en, this message translates to:
  /// **'This will clear your current pill pack settings and you will need to set it up again. Your history of taken pills will be kept.'**
  String get pillResetDesc;

  /// No description provided for @pillResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get pillResetButton;

  /// No description provided for @symptomNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes for today...'**
  String get symptomNotesLabel;

  /// No description provided for @calendarLegendNote.
  ///
  /// In en, this message translates to:
  /// **'Note Added'**
  String get calendarLegendNote;

  /// No description provided for @logBleedingButton.
  ///
  /// In en, this message translates to:
  /// **'Log Bleeding'**
  String get logBleedingButton;

  /// No description provided for @logBleedingEndButton.
  ///
  /// In en, this message translates to:
  /// **'End Bleeding'**
  String get logBleedingEndButton;

  /// No description provided for @homeBleedingDay.
  ///
  /// In en, this message translates to:
  /// **'Bleeding Day {day}'**
  String homeBleedingDay(int day);

  /// No description provided for @calendarLegendBleeding.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Bleeding'**
  String get calendarLegendBleeding;

  /// No description provided for @insightPillActive.
  ///
  /// In en, this message translates to:
  /// **'You are on an active pill. Remember to take it at the same time every day! Consistency is key.'**
  String get insightPillActive;

  /// No description provided for @insightPillPlacebo.
  ///
  /// In en, this message translates to:
  /// **'You are in your placebo (break) week. A withdrawal bleed (like a period) is normal now. Don\'t forget to start your new pack on time!'**
  String get insightPillPlacebo;

  /// No description provided for @notificationPillActionTaken.
  ///
  /// In en, this message translates to:
  /// **'Mark as Taken'**
  String get notificationPillActionTaken;

  /// No description provided for @calendarEmptyState.
  ///
  /// In en, this message translates to:
  /// **'Your history will appear here. Tap a day to log your period or bleeding.'**
  String get calendarEmptyState;

  /// No description provided for @authLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLogin;

  /// No description provided for @authRegister.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authRegister;

  /// No description provided for @authEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authSwitchToRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get authSwitchToRegister;

  /// No description provided for @authSwitchToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get authSwitchToLogin;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get authSignOut;

  /// No description provided for @authSignOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get authSignOutConfirm;

  /// No description provided for @authWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authWithGoogle;

  /// No description provided for @authAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get authAsGuest;

  /// No description provided for @authLinkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Google Account'**
  String get authLinkAccount;

  /// No description provided for @authLinkDesc.
  ///
  /// In en, this message translates to:
  /// **'Save your data and sync across devices by linking your Google Account.'**
  String get authLinkDesc;

  /// No description provided for @authAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get authAccount;

  /// No description provided for @authOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get authOr;

  /// No description provided for @authLinkSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account linked successfully!'**
  String get authLinkSuccess;

  /// No description provided for @authLinkError.
  ///
  /// In en, this message translates to:
  /// **'Failed to link account: '**
  String get authLinkError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
