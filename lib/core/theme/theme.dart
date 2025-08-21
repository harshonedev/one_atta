import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";

class AppTheme {
  static TextTheme poppinsTextTheme = GoogleFonts.poppinsTextTheme();
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff944a00),
      surfaceTint: Color(0xff944a00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffe67e22),
      onPrimaryContainer: Color(0xff502600),
      secondary: Color(0xff83532f),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfffebf92),
      onSecondaryContainer: Color(0xff794b28),
      tertiary: Color(0xff5a6400),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff93a111),
      onTertiaryContainer: Color(0xff2f3400),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff231a13),
      onSurfaceVariant: Color(0xff564337),
      outline: Color(0xff897365),
      outlineVariant: Color(0xffdcc1b1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e27),
      inversePrimary: Color(0xffffb783),
      primaryFixed: Color(0xffffdcc5),
      onPrimaryFixed: Color(0xff301400),
      primaryFixedDim: Color(0xffffb783),
      onPrimaryFixedVariant: Color(0xff713700),
      secondaryFixed: Color(0xffffdcc5),
      onSecondaryFixed: Color(0xff301400),
      secondaryFixedDim: Color(0xfff8b98d),
      onSecondaryFixedVariant: Color(0xff673c1a),
      tertiaryFixed: Color(0xffddec5d),
      onTertiaryFixed: Color(0xff1a1e00),
      tertiaryFixedDim: Color(0xffc1d044),
      onTertiaryFixedVariant: Color(0xff444b00),
      surfaceDim: Color(0xffe9d6cc),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ea),
      surfaceContainer: Color(0xfffeeadf),
      surfaceContainerHigh: Color(0xfff8e4da),
      surfaceContainerHighest: Color(0xfff2dfd4),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff582a00),
      surfaceTint: Color(0xff944a00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffaa5600),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff532c0b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff94623c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff343900),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff687300),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff180f09),
      onSurfaceVariant: Color(0xff443327),
      outline: Color(0xff624f42),
      outlineVariant: Color(0xff7e695b),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e27),
      inversePrimary: Color(0xffffb783),
      primaryFixed: Color(0xffaa5600),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff864300),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff94623c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff784a27),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff687300),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff515a00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd5c3b9),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfffff1ea),
      surfaceContainer: Color(0xfff8e4da),
      surfaceContainerHigh: Color(0xffecd9ce),
      surfaceContainerHighest: Color(0xffe0cec3),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff492100),
      surfaceTint: Color(0xff944a00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff743900),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff472203),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6a3f1c),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2a2f00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff464d00),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffff8f5),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff39291e),
      outlineVariant: Color(0xff584539),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff392e27),
      inversePrimary: Color(0xffffb783),
      primaryFixed: Color(0xff743900),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff532700),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6a3f1c),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff4f2908),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff464d00),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff303600),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc7b5ab),
      surfaceBright: Color(0xfffff8f5),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffffede4),
      surfaceContainer: Color(0xfff2dfd4),
      surfaceContainerHigh: Color(0xffe3d1c6),
      surfaceContainerHighest: Color(0xffd5c3b9),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb783),
      surfaceTint: Color(0xffffb783),
      onPrimary: Color(0xff4f2500),
      primaryContainer: Color(0xffe67e22),
      onPrimaryContainer: Color(0xff502600),
      secondary: Color(0xfff8b98d),
      onSecondary: Color(0xff4c2706),
      secondaryContainer: Color(0xff673c1a),
      onSecondaryContainer: Color(0xffe5a87d),
      tertiary: Color(0xffc1d044),
      onTertiary: Color(0xff2e3300),
      tertiaryContainer: Color(0xff93a111),
      onTertiaryContainer: Color(0xff2f3400),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff1a110b),
      onSurface: Color(0xfff2dfd4),
      onSurfaceVariant: Color(0xffdcc1b1),
      outline: Color(0xffa48c7d),
      outlineVariant: Color(0xff564337),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff2dfd4),
      inversePrimary: Color(0xff944a00),
      primaryFixed: Color(0xffffdcc5),
      onPrimaryFixed: Color(0xff301400),
      primaryFixedDim: Color(0xffffb783),
      onPrimaryFixedVariant: Color(0xff713700),
      secondaryFixed: Color(0xffffdcc5),
      onSecondaryFixed: Color(0xff301400),
      secondaryFixedDim: Color(0xfff8b98d),
      onSecondaryFixedVariant: Color(0xff673c1a),
      tertiaryFixed: Color(0xffddec5d),
      onTertiaryFixed: Color(0xff1a1e00),
      tertiaryFixedDim: Color(0xffc1d044),
      onTertiaryFixedVariant: Color(0xff444b00),
      surfaceDim: Color(0xff1a110b),
      surfaceBright: Color(0xff42372f),
      surfaceContainerLowest: Color(0xff150c07),
      surfaceContainerLow: Color(0xff231a13),
      surfaceContainer: Color(0xff271e17),
      surfaceContainerHigh: Color(0xff322821),
      surfaceContainerHighest: Color(0xff3e322b),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffd4b8),
      surfaceTint: Color(0xffffb783),
      onPrimary: Color(0xff3f1c00),
      primaryContainer: Color(0xffe67e22),
      onPrimaryContainer: Color(0xff110500),
      secondary: Color(0xffffd4b8),
      onSecondary: Color(0xff3f1c00),
      secondaryContainer: Color(0xffbc845c),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffd6e658),
      onTertiary: Color(0xff242800),
      tertiaryContainer: Color(0xff93a111),
      onTertiaryContainer: Color(0xff060800),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff1a110b),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfff3d7c6),
      outline: Color(0xffc6ad9d),
      outlineVariant: Color(0xffa38c7d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff2dfd4),
      inversePrimary: Color(0xff723800),
      primaryFixed: Color(0xffffdcc5),
      onPrimaryFixed: Color(0xff200b00),
      primaryFixedDim: Color(0xffffb783),
      onPrimaryFixedVariant: Color(0xff582a00),
      secondaryFixed: Color(0xffffdcc5),
      onSecondaryFixed: Color(0xff200b00),
      secondaryFixedDim: Color(0xfff8b98d),
      onSecondaryFixedVariant: Color(0xff532c0b),
      tertiaryFixed: Color(0xffddec5d),
      onTertiaryFixed: Color(0xff101300),
      tertiaryFixedDim: Color(0xffc1d044),
      onTertiaryFixedVariant: Color(0xff343900),
      surfaceDim: Color(0xff1a110b),
      surfaceBright: Color(0xff4e423a),
      surfaceContainerLowest: Color(0xff0d0603),
      surfaceContainerLow: Color(0xff251c15),
      surfaceContainer: Color(0xff30261f),
      surfaceContainerHigh: Color(0xff3b3029),
      surfaceContainerHighest: Color(0xff473b34),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffece2),
      surfaceTint: Color(0xffffb783),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffffb179),
      onPrimaryContainer: Color(0xff180700),
      secondary: Color(0xffffece2),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xfff4b58a),
      onSecondaryContainer: Color(0xff180700),
      tertiary: Color(0xffeafa69),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffbdcc40),
      onTertiaryContainer: Color(0xff0a0c00),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff1a110b),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffffece2),
      outlineVariant: Color(0xffd8bead),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff2dfd4),
      inversePrimary: Color(0xff723800),
      primaryFixed: Color(0xffffdcc5),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffffb783),
      onPrimaryFixedVariant: Color(0xff200b00),
      secondaryFixed: Color(0xffffdcc5),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xfff8b98d),
      onSecondaryFixedVariant: Color(0xff200b00),
      tertiaryFixed: Color(0xffddec5d),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffc1d044),
      onTertiaryFixedVariant: Color(0xff101300),
      surfaceDim: Color(0xff1a110b),
      surfaceBright: Color(0xff5a4e45),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff271e17),
      surfaceContainer: Color(0xff392e27),
      surfaceContainerHigh: Color(0xff453932),
      surfaceContainerHighest: Color(0xff51443c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: poppinsTextTheme,
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
