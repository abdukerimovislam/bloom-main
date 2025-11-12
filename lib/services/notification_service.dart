// Файл: lib/services/notification_service.dart

import 'package:bloom/l10n/app_localizations.dart';
import 'package:bloom/models/cycle_prediction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:bloom/services/pill_service.dart';

const String _pillCategoryId = 'PILL_CATEGORY';
const String _pillTakenActionId = 'PILL_TAKEN_ACTION';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  if (notificationResponse.actionId == _pillTakenActionId) {
    WidgetsFlutterBinding.ensureInitialized();
    final PillService pillService = PillService();
    // --- ИСПРАВЛЕНИЕ: Используем payload ---
    if (notificationResponse.payload != null && notificationResponse.payload!.isNotEmpty) {
      await pillService.savePillTaken(DateTime.parse(notificationResponse.payload!));
    } else {
      await pillService.savePillTaken(DateTime.now()); // Запасной вариант
    }
    // ---
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initTimezones() async {
    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Bishkek'));
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  static Future<void> init() async {

    final DarwinNotificationCategory pillCategory = DarwinNotificationCategory(
      _pillCategoryId,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          _pillTakenActionId,
          'Mark as Taken',
          options: {DarwinNotificationActionOption.authenticationRequired},
        ),
      ],
    );
    final List<DarwinNotificationCategory> categories = [pillCategory];

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: categories,
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == _pillTakenActionId) {
          final PillService pillService = PillService();
          // --- ИСПРАВЛЕНИЕ: Используем payload ---
          if (response.payload != null && response.payload!.isNotEmpty) {
            await pillService.savePillTaken(DateTime.parse(response.payload!));
          } else {
            await pillService.savePillTaken(DateTime.now()); // Запасной вариант
          }
          // ---
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // --- ИЗМЕНЕНИЕ: ЗАПРАШИВАЕМ РАЗРЕШЕНИЕ НА "БУДИЛЬНИКИ" ---
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // Запрашиваем разрешение, если оно нужно (API 31+)
    await androidImplementation?.requestExactAlarmsPermission();
    // ---
  }

  static const AndroidNotificationDetails _androidNotificationDetails =
  AndroidNotificationDetails(
    'bloom_channel_id',
    'Bloom Notifications',
    channelDescription: 'Channel for Bloom app notifications',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  static const NotificationDetails _platformChannelInfo =
  NotificationDetails(android: _androidNotificationDetails);

  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  static const int _periodPredictionId = 0;
  static const int _fertilePredictionId = 1;

  static Future<void> cancelPredictionNotifications() async {
    await _flutterLocalNotificationsPlugin.cancel(_periodPredictionId);
    await _flutterLocalNotificationsPlugin.cancel(_fertilePredictionId);
  }

  static Future<void> schedulePredictionNotifications(
      CyclePrediction prediction, AppLocalizations l10n) async {

    await cancelPredictionNotifications();
    final now = tz.TZDateTime.now(tz.local);

    final dtPeriod = prediction.nextPeriodStartDate.subtract(const Duration(days: 2));
    final nextPeriodTime = tz.TZDateTime(
        tz.local, dtPeriod.year, dtPeriod.month, dtPeriod.day, 12);

    if (nextPeriodTime.isAfter(now)) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _periodPredictionId,
        l10n.notificationPeriodTitle,
        l10n.notificationPeriodBody(2),
        nextPeriodTime,
        _platformChannelInfo,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }

    final dtFertile = prediction.fertileWindowStart.subtract(const Duration(days: 1));
    final nextFertileTime = tz.TZDateTime(
        tz.local, dtFertile.year, dtFertile.month, dtFertile.day, 12);

    if (nextFertileTime.isAfter(now)) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _fertilePredictionId,
        l10n.notificationFertileTitle,
        l10n.notificationFertileBody,
        nextFertileTime,
        _platformChannelInfo,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }

  static const int _pillReminderStartId = 10;

  static Future<void> cancelPillReminders() async {
    for (int i = 0; i < 28; i++) {
      await _flutterLocalNotificationsPlugin.cancel(_pillReminderStartId + i);
    }
  }

  static Future<void> schedulePillReminder({
    required TimeOfDay time,
    required AppLocalizations l10n,
    required DateTime packStartDate,
    required int activeDays,
  }) async {
    await cancelPillReminders();

    final AndroidNotificationDetails pillAndroidDetails =
    AndroidNotificationDetails(
      'bloom_pill_channel',
      'Pill Reminders',
      channelDescription: 'Reminders to take your contraceptive pill.',
      importance: Importance.max,
      priority: Priority.high,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          _pillTakenActionId,
          l10n.notificationPillActionTaken,
        ),
      ],
    );

    final NotificationDetails pillPlatformChannelInfo = NotificationDetails(
      android: pillAndroidDetails,
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: _pillCategoryId,
      ),
    );

    final now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < activeDays; i++) {
      final dayToSchedule = packStartDate.add(Duration(days: i));

      tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        dayToSchedule.year,
        dayToSchedule.month,
        dayToSchedule.day,
        time.hour,
        time.minute,
      );

      if (scheduledTime.isBefore(now)) {
        continue;
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        _pillReminderStartId + i,
        l10n.notificationPillTitle,
        l10n.notificationPillBody,
        scheduledTime,
        pillPlatformChannelInfo,
        // --- ИСПРАВЛЕНИЕ: Отправляем payload (Баг №2) ---
        payload: dayToSchedule.toIso8601String(),
        // ---
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
    }
  }
}