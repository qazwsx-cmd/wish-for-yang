import 'package:material_ui/material_ui.dart';

import '../features/settings/domain/app_settings.dart';

abstract final class BiliTheme {
  static const accent = Color(0xFFAA2A67);
  static const canvas = Color(0xFFFFF7FC);
  static const ink = Color(0xFF342038);

  static ThemeData light({
    AppFontPreference font = AppFontPreference.harmonyOsSans,
    String systemFontFamily = '',
  }) => _build(Brightness.light, font.resolveFamily(systemFontFamily));
  static ThemeData dark({
    AppFontPreference font = AppFontPreference.harmonyOsSans,
    String systemFontFamily = '',
  }) => _build(Brightness.dark, font.resolveFamily(systemFontFamily));

  static ThemeData _build(Brightness brightness, String? fontFamily) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? const Color(0xFF251A2D) : canvas;
    final foreground = dark ? const Color(0xFFFFEDF8) : ink;
    final muted = dark ? const Color(0xFFBAA0BD) : const Color(0xFF795D7D);
    final secondaryText = dark
        ? const Color(0xFFDDC4DE)
        : const Color(0xFF6D4C6D);
    final tertiaryText = dark
        ? const Color(0xFFC4A9C8)
        : const Color(0xFF795E7D);
    final panel = dark ? const Color(0xFF34243C) : const Color(0xFFFFEAF5);
    final border = dark ? const Color(0xFF5D4264) : const Color(0xFFEACFE3);
    final primary = dark ? const Color(0xFFFFA7D1) : accent;
    final secondary = dark ? const Color(0xFFDBBFFF) : const Color(0xFF68428D);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          onPrimary: dark ? const Color(0xFF48112F) : Colors.white,
          primaryContainer: dark
              ? const Color(0xFF55304B)
              : const Color(0xFFFFDDEC),
          onPrimaryContainer: primary,
          secondary: secondary,
          onSecondary: dark ? const Color(0xFF35204E) : Colors.white,
          secondaryContainer: dark
              ? const Color(0xFF473257)
              : const Color(0xFFEFE2FF),
          onSecondaryContainer: secondary,
          tertiary: dark ? const Color(0xFFA6DDD5) : const Color(0xFF386A65),
          surface: surface,
          onSurface: foreground,
          onSurfaceVariant: secondaryText,
          surfaceContainerLowest: dark
              ? const Color(0xFF211628)
              : const Color(0xFFFFFCFF),
          surfaceContainerLow: panel,
          surfaceContainer: panel,
          surfaceContainerHigh: dark
              ? const Color(0xFF412D49)
              : const Color(0xFFF7DDED),
          surfaceContainerHighest: dark
              ? const Color(0xFF4E3456)
              : const Color(0xFFEFD1E5),
          outline: muted,
          outlineVariant: border,
        );
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF1B1222)
          : const Color(0xFFFFEFF7),
      dividerColor: border,
      hoverColor: primary.withValues(alpha: 0.06),
      focusColor: primary.withValues(alpha: 0.12),
      splashColor: primary.withValues(alpha: 0.10),
    );
    const controlShape = StadiumBorder();
    final panelShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
      side: BorderSide(color: border),
    );
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: border),
    );
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: primary),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: TextStyle(
          color: primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 17 / 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: tertiaryText,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 17 / 12,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: primary.withValues(alpha: 0.17)),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? primary
                : secondaryText,
          ),
        ),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: panelShape,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: panelShape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: scheme.outline,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          side: BorderSide(color: border),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: panelShape,
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: controlShape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: controlShape,
          side: BorderSide(color: border),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: controlShape),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: controlShape,
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.secondaryContainer,
        side: BorderSide(color: border),
      ),
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(fontSize: 14),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          fontSize: 12,
          color: tertiaryText,
        ),
      ),
    );
  }
}
