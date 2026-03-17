class ApiConfig {
  const ApiConfig._();

  // TODO(production): Replace with flutter_dotenv for environment-specific
  // configuration (e.g. dotenv.env['API_BASE_URL']).
  static const String baseUrl = 'http://localhost:8000/api/v1';

  static const String places = '/places';
  static const String placesNearby = '/places/nearby';
  static const String placeDetail = '/places'; // append /{id}
  static const String events = '/events';
  static const String eventsUpcoming = '/events/upcoming';
  static const String weather = '/weather';
  static const String categories = '/categories';
}
