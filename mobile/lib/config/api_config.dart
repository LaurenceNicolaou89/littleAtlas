class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = 'http://localhost:8000/api/v1';

  static const String places = '/places';
  static const String placesNearby = '/places';
  static const String placeDetail = '/places'; // append /{id}
  static const String events = '/events';
  static const String eventsUpcoming = '/events';
  static const String weather = '/weather';
  static const String categories = '/categories';
}
