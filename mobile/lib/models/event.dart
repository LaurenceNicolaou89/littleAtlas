class Event {
  final int id;
  final String title;
  final String description;
  final double lat;
  final double lon;
  final String venueName;
  final String? address;
  final DateTime startDate;
  final DateTime endDate;
  final bool isIndoor;
  final int? ageMin;
  final int? ageMax;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.lat,
    required this.lon,
    required this.venueName,
    this.address,
    required this.startDate,
    required this.endDate,
    this.isIndoor = false,
    this.ageMin,
    this.ageMax,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      venueName: json['venue_name'] as String? ?? '',
      address: json['address'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isIndoor: json['is_indoor'] as bool? ?? false,
      ageMin: json['age_min'] as int?,
      ageMax: json['age_max'] as int?,
    );
  }
}
