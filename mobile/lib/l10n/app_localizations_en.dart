// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Little Atlas';

  @override
  String get explore => 'Explore';

  @override
  String get search => 'Search';

  @override
  String get events => 'Events';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get nearbyPlaces => 'Nearby Places';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get noResults => 'No results found';

  @override
  String get loading => 'Loading...';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get filters => 'Filters';

  @override
  String get category => 'Category';

  @override
  String get indoor => 'Indoor';

  @override
  String get outdoor => 'Outdoor';

  @override
  String get ageRange => 'Age Range';

  @override
  String get distance => 'Distance';

  @override
  String get weatherOutdoor => 'Great day to be outside!';

  @override
  String get weatherIndoor => 'Better to stay indoors';

  @override
  String get weatherCaution => 'Be cautious outdoors';

  @override
  String get allCategories => 'All Categories';

  @override
  String get viewOnMap => 'View on Map';

  @override
  String get directions => 'Directions';

  @override
  String get call => 'Call';

  @override
  String get website => 'Website';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get dataSources => 'Data Sources';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get dataSourcesDescription =>
      'This app uses data from the following sources:';

  @override
  String get openStreetMap => 'OpenStreetMap';

  @override
  String get googlePlaces => 'Google Places';

  @override
  String get openWeatherMap => 'OpenWeatherMap';

  @override
  String get communityContributions => 'Community contributions';

  @override
  String get close => 'Close';

  @override
  String get getDirections => 'Get Directions';

  @override
  String get amenities => 'Amenities';

  @override
  String get details => 'Details';

  @override
  String get openNow => 'Open now';

  @override
  String get closed => 'Closed';

  @override
  String get noUpcomingEvents => 'No upcoming events nearby.';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get all => 'All';

  @override
  String get happeningNow => 'Happening Now';

  @override
  String get today => 'TODAY';

  @override
  String get tomorrow => 'TOMORROW';

  @override
  String get viewSource => 'View Source';

  @override
  String get event => 'Event';

  @override
  String get pullUpForNearby => 'Pull up for nearby places';

  @override
  String get noPlacesNearby => 'No places nearby';

  @override
  String get searchPlaces => 'Search places...';

  @override
  String get addFilter => 'Add filter';

  @override
  String get clearAll => 'Clear all';

  @override
  String placesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'places',
      one: 'place',
    );
    return '$count $_temp0 found';
  }

  @override
  String get noPlacesFound => 'No places found';

  @override
  String get tryAdjustingFilters => 'Try adjusting your filters.';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get ageGroup => 'Age Group';

  @override
  String get type => 'Type';

  @override
  String get both => 'Both';

  @override
  String get categoryPlaygrounds => 'Playgrounds';

  @override
  String get categoryParks => 'Parks & Nature';

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryCulture => 'Culture & Education';

  @override
  String get categorySports => 'Sports & Activities';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryBeaches => 'Beaches';

  @override
  String get ageInfant => 'Infant (0-1)';

  @override
  String get ageToddler => 'Toddler (1-3)';

  @override
  String get agePreschool => 'Preschool (3-5)';

  @override
  String get ageSchoolAge => 'School Age (6-12)';

  @override
  String get amenityChangingTable => 'Changing Table';

  @override
  String get amenityHighChair => 'High Chair';

  @override
  String get amenityKidsMenu => 'Kids Menu';

  @override
  String get amenityStrollerAccess => 'Stroller Access';

  @override
  String get amenityFencedArea => 'Fenced Area';

  @override
  String get amenityParking => 'Parking';

  @override
  String get amenityWheelchairAccess => 'Wheelchair Access';

  @override
  String get amenityToilets => 'Toilets';

  @override
  String get amenityNursingRoom => 'Nursing Room';

  @override
  String get amenityShade => 'Shade';

  @override
  String get amenityWaterFountain => 'Water Fountain';

  @override
  String get amenityWifi => 'WiFi';
}
