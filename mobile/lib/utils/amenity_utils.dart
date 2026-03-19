import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Maps amenity slugs to their display icon.
const Map<String, IconData> amenityIcons = {
  'changing_table': Icons.baby_changing_station,
  'high_chair': Icons.chair,
  'kids_menu': Icons.restaurant_menu,
  'stroller_access': Icons.accessible,
  'fenced_area': Icons.fence,
  'parking': Icons.local_parking,
  'wheelchair_access': Icons.wheelchair_pickup,
  'nursing_room': Icons.child_friendly,
  'shade': Icons.umbrella,
  'water_fountain': Icons.water_drop,
  'toilets': Icons.wc,
  'wifi': Icons.wifi,
};

/// Returns localized amenity label for the given slug.
String amenityLabel(String slug, AppLocalizations l10n) {
  switch (slug) {
    case 'changing_table':
      return l10n.amenityChangingTable;
    case 'high_chair':
      return l10n.amenityHighChair;
    case 'kids_menu':
      return l10n.amenityKidsMenu;
    case 'stroller_access':
      return l10n.amenityStrollerAccess;
    case 'fenced_area':
      return l10n.amenityFencedArea;
    case 'parking':
      return l10n.amenityParking;
    case 'wheelchair_access':
      return l10n.amenityWheelchairAccess;
    case 'nursing_room':
      return l10n.amenityNursingRoom;
    case 'shade':
      return l10n.amenityShade;
    case 'water_fountain':
      return l10n.amenityWaterFountain;
    case 'toilets':
      return l10n.amenityToilets;
    case 'wifi':
      return l10n.amenityWifi;
    default:
      return slug.replaceAll('_', ' ');
  }
}
