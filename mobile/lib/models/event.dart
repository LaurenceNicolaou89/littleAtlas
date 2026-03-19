class Event {
  final int id;
  final String title;
  final String description;
  final double? lat;
  final double? lon;
  final String venueName;
  final String? address;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isIndoor;
  final int? ageMin;
  final int? ageMax;
  final String? sourceUrl;
  final double? distanceM;
  final String? eventType;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    this.lat,
    this.lon,
    required this.venueName,
    this.address,
    required this.startDate,
    this.endDate,
    this.isIndoor = false,
    this.ageMin,
    this.ageMax,
    this.sourceUrl,
    this.distanceM,
    this.eventType,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lon: (json['lon'] as num?)?.toDouble(),
      venueName: json['venue_name'] as String? ?? '',
      address: json['address'] as String?,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'] as String)
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      isIndoor: json['is_indoor'] as bool? ?? false,
      ageMin: json['age_min'] as int?,
      ageMax: json['age_max'] as int?,
      sourceUrl: json['source_url'] as String?,
      distanceM: (json['distance_m'] as num?)?.toDouble(),
      eventType: json['event_type'] as String?,
    );
  }
}
