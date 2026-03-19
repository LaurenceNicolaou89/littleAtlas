import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Little Atlas — Soft Modern Design Tokens
// ---------------------------------------------------------------------------
// All visual constants for the app live here. Widget code should reference
// these tokens instead of hard-coding colors, radii, spacing, or shadows.
// ---------------------------------------------------------------------------

// ── Colors ──────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // Primary — Atlas Violet
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5A4BD1);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryWash = Color(0xFFF0EDFF);

  // Accent
  static const Color rosePink = Color(0xFFFD79A8);
  static const Color aquaTeal = Color(0xFF00CEC9);
  static const Color honeyGold = Color(0xFFFDCB6E);
  static const Color coralRed = Color(0xFFFF7675);

  // Category
  static const Color catPlaygrounds = Color(0xFFFF9F43);
  static const Color catParks = Color(0xFF00B894);
  static const Color catRestaurants = Color(0xFFE17055);
  static const Color catEntertainment = Color(0xFF6C5CE7);
  static const Color catCulture = Color(0xFF74B9FF);
  static const Color catSports = Color(0xFF00CEC9);
  static const Color catEvents = Color(0xFFFD79A8);

  // Surfaces & neutrals
  static const Color background = Color(0xFFFBF9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textTertiary = Color(0xFFB2BEC3);
  static const Color divider = Color(0xFFDFE6E9);

  // Status
  static const Color statusOpen = Color(0xFF00B894);
  static const Color statusClosed = Color(0xFFFF7675);
  static const Color statusHappeningNow = Color(0xFFFD79A8);
  static const Color statusWarning = Color(0xFFFDCB6E);

  /// Resolve a category slug to its design-token color.
  static Color categoryColor(String slug) {
    switch (slug) {
      case 'playground':
      case 'outdoor_playground':
        return catPlaygrounds;
      case 'park':
      case 'parks':
        return catParks;
      case 'restaurant':
      case 'restaurants':
        return catRestaurants;
      case 'entertainment':
        return catEntertainment;
      case 'culture':
      case 'museum':
        return catCulture;
      case 'sports':
        return catSports;
      case 'events':
      case 'event':
        return catEvents;
      default:
        return primary;
    }
  }
}

// ── Weather Gradients ───────────────────────────────────────────────────────

class WeatherGradient {
  final Color start;
  final Color end;
  final Color text;

  const WeatherGradient({
    required this.start,
    required this.end,
    required this.text,
  });

  LinearGradient toLinearGradient() => LinearGradient(
        colors: [start, end],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}

class WeatherGradients {
  WeatherGradients._();

  static const WeatherGradient outdoor = WeatherGradient(
    start: Color(0xFFFFEAA7),
    end: Color(0xFFFDCB6E),
    text: Color(0xFF6C5100),
  );

  static const WeatherGradient indoor = WeatherGradient(
    start: Color(0xFFDFE6E9),
    end: Color(0xFFA29BFE),
    text: Color(0xFF2D3436),
  );

  static const WeatherGradient caution = WeatherGradient(
    start: Color(0xFFFFECD2),
    end: Color(0xFFFAB1A0),
    text: Color(0xFF6C3A00),
  );
}

// ── Spacing ─────────────────────────────────────────────────────────────────

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

// ── Border Radii ────────────────────────────────────────────────────────────

class AppRadii {
  AppRadii._();

  static const double cards = 18;
  static const double buttons = 14;
  static const double chips = 20;
  static const double sheet = 24;
  static const double searchBar = 24;
  static const double dateBlock = 14;
  static const double navBar = 20;
  static const double thumbnails = 14;
  static const double weatherHero = 18;
  static const double badges = 10;
  static const double iconContainers = 12;

  // Pre-built BorderRadius helpers
  static final BorderRadius cardBorder = BorderRadius.circular(cards);
  static final BorderRadius buttonBorder = BorderRadius.circular(buttons);
  static final BorderRadius chipBorder = BorderRadius.circular(chips);
  static final BorderRadius sheetBorder =
      const BorderRadius.vertical(top: Radius.circular(sheet));
  static final BorderRadius searchBarBorder = BorderRadius.circular(searchBar);
  static final BorderRadius dateBlockBorder = BorderRadius.circular(dateBlock);
  static final BorderRadius thumbnailBorder =
      BorderRadius.circular(thumbnails);
  static final BorderRadius weatherHeroBorder =
      BorderRadius.circular(weatherHero);
  static final BorderRadius badgeBorder = BorderRadius.circular(badges);
  static final BorderRadius iconContainerBorder =
      BorderRadius.circular(iconContainers);
}

// ── Shadows ─────────────────────────────────────────────────────────────────

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      offset: Offset(0, 3),
      blurRadius: 12,
      color: Color(0x0F6C5CE7), // rgba(108,92,231,0.06)
    ),
  ];

  static const List<BoxShadow> nav = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 16,
      color: Color(0x1A000000), // rgba(0,0,0,0.1)
    ),
  ];

  /// Weather shadow uses the gradient's start color at 25 % opacity.
  static List<BoxShadow> weather(Color gradientColor) => [
        BoxShadow(
          offset: const Offset(0, 3),
          blurRadius: 12,
          color: gradientColor.withAlpha(64), // 25 %
        ),
      ];

  static const List<BoxShadow> button = [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 14,
      color: Color(0x4D6C5CE7), // rgba(108,92,231,0.3)
    ),
  ];

  static const List<BoxShadow> liveEvent = [
    BoxShadow(
      offset: Offset(0, 3),
      blurRadius: 12,
      color: Color(0x1FFD79A8), // rgba(253,121,168,0.12)
    ),
  ];
}
