class Place {
  final int id;
  final String name;
  final String description;
  final double lat;
  final double lon;
  final String category;
  final double? distanceM;
  final bool isIndoor;
  final int? ageMin;
  final int? ageMax;
  final List<String> amenities;
  final List<String> photos;
  final String? address;
  final String? phone;
  final String? website;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.lat,
    required this.lon,
    required this.category,
    this.distanceM,
    this.isIndoor = false,
    this.ageMin,
    this.ageMax,
    this.amenities = const [],
    this.photos = const [],
    this.address,
    this.phone,
    this.website,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      category: json['category'] as String? ?? '',
      distanceM: (json['distance_m'] as num?)?.toDouble(),
      isIndoor: json['is_indoor'] as bool? ?? false,
      ageMin: json['age_min'] as int?,
      ageMax: json['age_max'] as int?,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
    );
  }
}
