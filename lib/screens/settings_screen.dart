// Файл: lib/screens/settings_screen.dart

import 'package:bloom/services/cycle_service.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:bloom/services/settings_service.dart';
import 'package:bloom/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:bloom/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bloom/services/notification_service.dart';

import 'package:bloom/services/auth_service.dart';
import 'package:bloom/navigation/app_router.dart';


class SettingsScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  final Function(AppTheme) onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.onLanguageChanged,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  final AuthService _authService = AuthService();

  bool _notificationsEnabled = true;
  String? _currentLocaleCode;
  AppTheme _currentTheme = AppTheme.rose;
  bool _useManualLength = false;
  int _manualCycleLength = 28;

  bool _isPillTrackerEnabled = false;
  TimeOfDay? _pillReminderTime;

  late AppLocalizations l10n;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    l10n = AppLocalizations.of(context)!;
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final notifs = await _settingsService.areNotificationsEnabled();
    final localeCode = await _settingsService.getAppLocale();
    final theme = await _settingsService.getAppTheme();
    final useManual = await _settingsService.getUseManualCycleLength();
    final manualLength = await _settingsService.getManualAvgCycleLength();
    final isPillEnabled = await _settingsService.isPillTrackerEnabled();
    final pillTime = await _settingsService.getPillReminderTime();

    if (mounted) {
      setState(() {
        _notificationsEnabled = notifs;
        _currentLocaleCode = localeCode;
        _currentTheme = theme;
        _useManualLength = useManual;
        _manualCycleLength = manualLength;
        _isPillTrackerEnabled = isPillEnabled;
        _pillReminderTime = pillTime;
      });
    }
  }

  void _onNotificationChanged(bool value) {
    setState(() { _notificationsEnabled = value; });
    _settingsService.setNotificationsEnabled(value);
  }

  void _onLanguageChanged(String? newLocaleCode) {
    if (newLocaleCode == null) return;
    setState(() { _currentLocaleCode = newLocaleCode; });
    _settingsService.setAppLocale(newLocaleCode);
    widget.onLanguageChanged(Locale(newLocaleCode));
  }

  void _onThemeSelected(AppTheme? newTheme) {
    if (newTheme == null) return;
    setState(() { _currentTheme = newTheme; });
    _settingsService.setAppTheme(newTheme);
    widget.onThemeChanged(newTheme);
  }

  void _onUseManualLengthChanged(bool value) {
    setState(() { _useManualLength = value; });
    _settingsService.setUseManualCycleLength(value);
  }

  void _showManualLengthPicker() async {
    int tempValue = _manualCycleLength;

    final int? newLength = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(l10n.settingsManualCycleLengthDialogTitle),
                content: NumberPicker(
                  value: tempValue,
                  minValue: 15,
                  maxValue: 45,
                  step: 1,
                  onChanged: (value) => setDialogState(() => tempValue = value),
                ),
                actions: [
                  TextButton(
                    child: Text(l10n.dialogCancel),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: Text(l10n.dialogOK),
                    onPressed: () => Navigator.of(context).pop(tempValue),
                  ),
                ],
              );
            }
        );
      },
    );

    if (newLength != null && newLength != _manualCycleLength) {
      setState(() {
        _manualCycleLength = newLength;
      });
      await _settingsService.saveManualAvgCycleLength(newLength);
    }
  }

  void _launchSupportEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@bloom.app',
      query: 'subject=Bloom App Support',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app.')),
        );
      }
    }
  }

  // --- ИЗМЕНЕНИЕ: Добавлены _signOut и _linkAccount ---
  Future<void> _signOut() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.authSignOut),
        content: Text(l10n.authSignOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.authSignOut),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Перед выходом, нужно очистить SharedPreferences,
      // чтобы следующий пользователь не увидел кэш
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.clear();

      await _authService.signOut();

      Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.authGate, (route) => false);
    }
  }

  Future<void> _linkAccount() async {
    final String? error = await _authService.linkGoogleAccount();

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.authLinkSuccess),
          backgroundColor: Colors.green,
        ),
      );
      // Обновляем UI, чтобы "Выйти" заменило "Привязать"
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${l10n.authLinkError} $error"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
  // ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String displayLocale = _currentLocaleCode ?? l10n.localeName;
    final theme = Theme.of(context);

    return ListView(
      children: [
        // --- ИЗМЕНЕНИЕ: "Умная" секция "Аккаунт" ---
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(l10n.authAccount),
        ),
        ListTile(
          title: Text(
            _authService.isAnonymous() ? l10n.authLinkAccount : l10n.authSignOut,
          ),
          subtitle: _authService.isAnonymous()
              ? Text(l10n.authLinkDesc)
              : Text(_authService.currentUser?.email ?? "Signed in"),
          trailing: Icon(
            _authService.isAnonymous() ? Icons.link : Icons.logout,
            color: _authService.isAnonymous() ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          onTap: () {
            if (_authService.isAnonymous()) {
              _linkAccount(); // <-- Вызываем привязку
            } else {
              _signOut();
            }
          },
        ),
        const Divider(),
        // ---

        SwitchListTile(
          title: Text(l10n.settingsNotifications),
          subtitle: Text(l10n.settingsNotificationsDesc),
          value: _notificationsEnabled,
          onChanged: _onNotificationChanged,
          secondary: const Icon(Icons.notifications_active_outlined),
        ),
        const Divider(),

        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: Text(l10n.settingsLanguage),
          trailing: DropdownButton<String>(
            value: displayLocale,
            onChanged: _onLanguageChanged,
            items: const [
              DropdownMenuItem(value: 'en', child: Text('English')),
              DropdownMenuItem(value: 'ru', child: Text('Русский')),
              DropdownMenuItem(value: 'es', child: Text('Español')),
            ],
          ),
        ),
        const Divider(),

        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text(l10n.settingsTheme),
        ),
        RadioListTile<AppTheme>(
          title: Text(l10n.themeRose),
          value: AppTheme.rose,
          groupValue: _currentTheme,
          onChanged: _onThemeSelected,
        ),
        RadioListTile<AppTheme>(
          title: Text(l10n.themeNight),
          value: AppTheme.night,
          groupValue: _currentTheme,
          onChanged: _onThemeSelected,
        ),
        RadioListTile<AppTheme>(
          title: Text(l10n.themeForest),
          value: AppTheme.forest,
          groupValue: _currentTheme,
          onChanged: _onThemeSelected,
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.sync_alt_outlined),
          title: Text(l10n.settingsCycleCalculationTitle),
          enabled: !_isPillTrackerEnabled,
        ),
        SwitchListTile(
          title: Text(l10n.settingsUseManualCalculation),
          subtitle: Text(l10n.settingsUseManualCalculationDesc),
          value: _useManualLength,
          activeColor: _isPillTrackerEnabled ? Colors.grey : null,
          onChanged: _isPillTrackerEnabled ? null : _onUseManualLengthChanged,
        ),
        ListTile(
          title: Text(l10n.settingsManualCycleLength),
          trailing: Text(l10n.settingsManualCycleLengthDays(_manualCycleLength)),
          onTap: _useManualLength && !_isPillTrackerEnabled ? _showManualLengthPicker : null,
          enabled: _useManualLength && !_isPillTrackerEnabled,
        ),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.help_outline_rounded),
          title: Text(l10n.settingsSupport),
          subtitle: Text(l10n.settingsSupportDesc),
          onTap: _launchSupportEmail,
        ),
      ],
    );
  }
}