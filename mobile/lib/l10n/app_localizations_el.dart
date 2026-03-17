// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Μικρός Άτλας';

  @override
  String get explore => 'Εξερεύνηση';

  @override
  String get search => 'Αναζήτηση';

  @override
  String get events => 'Εκδηλώσεις';

  @override
  String get settings => 'Ρυθμίσεις';

  @override
  String get language => 'Γλώσσα';

  @override
  String get nearbyPlaces => 'Κοντινά Μέρη';

  @override
  String get upcomingEvents => 'Επερχόμενες Εκδηλώσεις';

  @override
  String get noResults => 'Δεν βρέθηκαν αποτελέσματα';

  @override
  String get loading => 'Φόρτωση...';

  @override
  String get errorOccurred => 'Παρουσιάστηκε σφάλμα';

  @override
  String get retry => 'Επανάληψη';

  @override
  String get filters => 'Φίλτρα';

  @override
  String get category => 'Κατηγορία';

  @override
  String get indoor => 'Εσωτερικός χώρος';

  @override
  String get outdoor => 'Υπαίθριος χώρος';

  @override
  String get ageRange => 'Ηλικιακό Εύρος';

  @override
  String get distance => 'Απόσταση';

  @override
  String get weatherOutdoor => 'Υπέροχη μέρα για έξω!';

  @override
  String get weatherIndoor => 'Καλύτερα να μείνετε μέσα';

  @override
  String get weatherCaution => 'Προσοχή σε εξωτερικούς χώρους';

  @override
  String get allCategories => 'Όλες οι Κατηγορίες';

  @override
  String get viewOnMap => 'Προβολή στον Χάρτη';

  @override
  String get directions => 'Οδηγίες';

  @override
  String get call => 'Κλήση';

  @override
  String get website => 'Ιστοσελίδα';

  @override
  String get about => 'Σχετικά';

  @override
  String get version => 'Έκδοση';

  @override
  String get dataSources => 'Πηγές Δεδομένων';

  @override
  String get privacyPolicy => 'Πολιτική Απορρήτου';

  @override
  String get termsOfService => 'Όροι Χρήσης';

  @override
  String get dataSourcesDescription =>
      'Η εφαρμογή χρησιμοποιεί δεδομένα από τις ακόλουθες πηγές:';

  @override
  String get openStreetMap => 'OpenStreetMap';

  @override
  String get googlePlaces => 'Google Places';

  @override
  String get openWeatherMap => 'OpenWeatherMap';

  @override
  String get communityContributions => 'Συνεισφορές κοινότητας';

  @override
  String get close => 'Κλείσιμο';

  @override
  String get getDirections => 'Οδηγίες Πλοήγησης';

  @override
  String get amenities => 'Παροχές';

  @override
  String get details => 'Λεπτομέρειες';

  @override
  String get openNow => 'Ανοιχτό τώρα';

  @override
  String get closed => 'Κλειστό';

  @override
  String get noUpcomingEvents => 'Δεν υπάρχουν επερχόμενες εκδηλώσεις κοντά.';

  @override
  String get thisWeek => 'Αυτή την Εβδομάδα';

  @override
  String get thisMonth => 'Αυτόν τον Μήνα';

  @override
  String get all => 'Όλα';

  @override
  String get happeningNow => 'Σε εξέλιξη';

  @override
  String get today => 'ΣΗΜΕΡΑ';

  @override
  String get tomorrow => 'ΑΥΡΙΟ';

  @override
  String get viewSource => 'Προβολή Πηγής';

  @override
  String get event => 'Εκδήλωση';

  @override
  String get pullUpForNearby => 'Σύρετε πάνω για κοντινά μέρη';

  @override
  String get noPlacesNearby => 'Δεν υπάρχουν κοντινά μέρη';

  @override
  String get searchPlaces => 'Αναζήτηση μερών...';

  @override
  String get addFilter => 'Προσθήκη φίλτρου';

  @override
  String get clearAll => 'Καθαρισμός όλων';

  @override
  String placesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'μέρη',
      one: 'μέρος',
    );
    return '$count $_temp0 βρέθηκαν';
  }

  @override
  String get noPlacesFound => 'Δεν βρέθηκαν μέρη';

  @override
  String get tryAdjustingFilters => 'Δοκιμάστε να προσαρμόσετε τα φίλτρα σας.';

  @override
  String get reset => 'Επαναφορά';

  @override
  String get apply => 'Εφαρμογή';

  @override
  String get ageGroup => 'Ηλικιακή Ομάδα';

  @override
  String get type => 'Τύπος';

  @override
  String get both => 'Και τα δύο';

  @override
  String get categoryPlaygrounds => 'Παιδικές Χαρές';

  @override
  String get categoryParks => 'Πάρκα & Φύση';

  @override
  String get categoryRestaurants => 'Εστιατόρια';

  @override
  String get categoryEntertainment => 'Διασκέδαση';

  @override
  String get categoryCulture => 'Πολιτισμός & Εκπαίδευση';

  @override
  String get categorySports => 'Αθλήματα & Δραστηριότητες';

  @override
  String get categoryShopping => 'Αγορές';

  @override
  String get categoryBeaches => 'Παραλίες';

  @override
  String get ageInfant => 'Βρέφος (0-1)';

  @override
  String get ageToddler => 'Νήπιο (1-3)';

  @override
  String get agePreschool => 'Προσχολική (3-5)';

  @override
  String get ageSchoolAge => 'Σχολική Ηλικία (6-12)';

  @override
  String get amenityChangingTable => 'Αλλαξιέρα';

  @override
  String get amenityHighChair => 'Παιδικό Κάθισμα';

  @override
  String get amenityKidsMenu => 'Παιδικό Μενού';

  @override
  String get amenityStrollerAccess => 'Πρόσβαση Καροτσιού';

  @override
  String get amenityFencedArea => 'Περιφραγμένος Χώρος';

  @override
  String get amenityParking => 'Στάθμευση';

  @override
  String get amenityWheelchairAccess => 'Πρόσβαση Αναπηρικού Αμαξιδίου';

  @override
  String get amenityToilets => 'Τουαλέτες';
}
