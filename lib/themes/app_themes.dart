// Файл: lib/themes/app_themes.dart

import 'package:flutter/material.dart';

// Enum для тем (остается у вас в services/settings_service.dart или где-то)
enum AppTheme {
  rose,
  night,
  forest
}

class AppThemes {

  static ThemeData getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.rose:
        return _roseTheme;
      case AppTheme.night:
        return _nightTheme;
      case AppTheme.forest:
        return _forestTheme;
    }
  }

  static String themeToString(AppTheme theme) {
    return theme.toString().split('.').last;
  }

  static AppTheme stringToTheme(String? themeString) {
    switch (themeString) {
      case 'night':
        return AppTheme.night;
      case 'forest':
        return AppTheme.forest;
      case 'rose':
      default:
        return AppTheme.rose;
    }
  }

  // --- 💡 ТЕМА ROSE (СВЕТЛАЯ) 💡 ---
  static final ThemeData _roseTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Nunito',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFFE91E63), // Яркий розовый
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFDDEB), // Светло-розовый фон
      onPrimaryContainer: Color(0xFF7A002E), // Темный текст на светло-розовом
      secondary: Color(0xFF6750A4), // Фиолетовый (для акцентов)
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFEADDFF), // Светло-фиолетовый фон
      onSecondaryContainer: Color(0xFF22005D), // Темный текст на светло-фиолетовом
      tertiary: Color(0xFF7D5260), // Третичный цвет (розово-коричневый)
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFD8E4), // Светлый третичный фон
      onTertiaryContainer: Color(0xFF31111D), // Темный текст на третичном фоне
      error: Color(0xFFBA1A1A), // Цвет ошибки
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6), // Фон для ошибок
      onErrorContainer: Color(0xFF410002), // Текст на фоне ошибок
      background: Color(0xFFFFF7F9), // Очень-очень светлый розовый фон
      onBackground: Color(0xFF201A1B), // Почти черный текст
      surface: Color(0xFFFFF7F9), // Фон поверхностей
      onSurface: Color(0xFF201A1B), // Текст на поверхностях
      surfaceVariant: Color(0xFFF2DDE1), // Вариант поверхности
      onSurfaceVariant: Color(0xFF514347), // Текст на варианте поверхности
      outline: Color(0xFF837377), // Цвет контуров
      outlineVariant: Color(0xFFD5C2C6), // Вариант контура
      shadow: Color(0xFF000000), // Тень
      scrim: Color(0xFF000000), // Затенение
      inverseSurface: Color(0xFF362F30), // Инвертированная поверхность
      onInverseSurface: Color(0xFFFAEEEF), // Текст на инвертированной поверхности
      inversePrimary: Color(0xFFFFB1C8), // Инвертированный основной цвет
      surfaceTint: Color(0xFFE91E63), // Оттенок поверхности
    ),
    useMaterial3: true,
  );

  // --- 💡 ТЕМА NIGHT (ТЕМНАЯ) 💡 ---
  static final ThemeData _nightTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Nunito',
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF66D9EF), // Яркий бирюзовый
      onPrimary: Color(0xFF00363F),
      primaryContainer: Color(0xFF004F58), // Темный бирюзовый фон
      onPrimaryContainer: Color(0xFFB9EEFF), // Светлый текст на темном бирюзовом
      secondary: Color(0xFFD0BCFF), // Светлая лаванда
      onSecondary: Color(0xFF381E72),
      secondaryContainer: Color(0xFF4F378A), // Темная лаванда фон
      onSecondaryContainer: Color(0xFFEADDFF), // Светлый текст на темной лаванде
      tertiary: Color(0xFFEFB8C8), // Третичный цвет (розовый)
      onTertiary: Color(0xFF492532),
      tertiaryContainer: Color(0xFF633B48), // Темный третичный фон
      onTertiaryContainer: Color(0xFFFFD8E4), // Светлый текст на третичном фоне
      error: Color(0xFFFFB4AB), // Цвет ошибки
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A), // Фон для ошибок
      onErrorContainer: Color(0xFFFFDAD6), // Текст на фоне ошибок
      background: Color(0xFF191C1D), // Очень-очень темный
      onBackground: Color(0xFFE1E3E3), // Светло-серый текст
      surface: Color(0xFF191C1D), // Фон поверхностей
      onSurface: Color(0xFFE1E3E3), // Текст на поверхностях
      surfaceVariant: Color(0xFF3F484A), // Вариант поверхности
      onSurfaceVariant: Color(0xFFBFC8CA), // Текст на варианте поверхности
      outline: Color(0xFF899294), // Цвет контуров
      outlineVariant: Color(0xFF3F484A), // Вариант контура
      shadow: Color(0xFF000000), // Тень
      scrim: Color(0xFF000000), // Затенение
      inverseSurface: Color(0xFFE1E3E3), // Инвертированная поверхность
      onInverseSurface: Color(0xFF191C1D), // Текст на инвертированной поверхности
      inversePrimary: Color(0xFF006874), // Инвертированный основной цвет
      surfaceTint: Color(0xFF66D9EF), // Оттенок поверхности
    ),
    useMaterial3: true,
  );

  // --- 💡 ТЕМА FOREST (ЗЕЛЕНАЯ) 💡 ---
  static final ThemeData _forestTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Nunito',
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF386A1F), // Темно-зеленый
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFB8F397), // Светло-зеленый фон
      onPrimaryContainer: Color(0xFF072100), // Очень темный текст на светло-зеленом
      secondary: Color(0xFF55624C), // Приглушенный серо-зеленый
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD9E7CB), // Очень светлый серо-зеленый фон
      onSecondaryContainer: Color(0xFF131F0D), // Темный текст
      tertiary: Color(0xFF386666), // Третичный цвет (зелено-синий)
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFBBEBEB), // Светлый третичный фон
      onTertiaryContainer: Color(0xFF002020), // Темный текст на третичном фоне
      error: Color(0xFFBA1A1A), // Цвет ошибки
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6), // Фон для ошибок
      onErrorContainer: Color(0xFF410002), // Текст на фоне ошибок
      background: Color(0xFFFCFDF6), // Почти белый фон
      onBackground: Color(0xFF1A1C18), // Почти черный текст
      surface: Color(0xFFFCFDF6), // Фон поверхностей
      onSurface: Color(0xFF1A1C18), // Текст на поверхностях
      surfaceVariant: Color(0xFFDFE4D7), // Вариант поверхности
      onSurfaceVariant: Color(0xFF43483E), // Текст на варианте поверхности
      outline: Color(0xFF73796E), // Цвет контуров
      outlineVariant: Color(0xFFC3C8BC), // Вариант контура
      shadow: Color(0xFF000000), // Тень
      scrim: Color(0xFF000000), // Затенение
      inverseSurface: Color(0xFF2F312D), // Инвертированная поверхность
      onInverseSurface: Color(0xFFF1F1EA), // Текст на инвертированной поверхности
      inversePrimary: Color(0xFF9DD97E), // Инвертированный основной цвет
      surfaceTint: Color(0xFF386A1F), // Оттенок поверхности
    ),
    useMaterial3: true,
  );

  // Дополнительные методы для удобства
  static List<AppTheme> get availableThemes => [
    AppTheme.rose,
    AppTheme.night,
    AppTheme.forest,
  ];

  static String getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.rose:
        return 'Rose';
      case AppTheme.night:
        return 'Night';
      case AppTheme.forest:
        return 'Forest';
    }
  }

  static Color getThemePreviewColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.rose:
        return const Color(0xFFE91E63);
      case AppTheme.night:
        return const Color(0xFF66D9EF);
      case AppTheme.forest:
        return const Color(0xFF386A1F);
    }
  }
}