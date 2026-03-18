enum WeatherMode { outdoor, indoor, caution }

class Weather {
  final double temp;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double uvIndex;
  final WeatherMode mode;

  const Weather({
    required this.temp,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.mode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      humidity: (json['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (json['uv_index'] as num?)?.toDouble() ?? 0.0,
      mode: _parseMode(json['weather_mode'] as String?),
    );
  }

  static WeatherMode _parseMode(String? mode) {
    switch (mode) {
      case 'outdoor':
        return WeatherMode.outdoor;
      case 'indoor':
        return WeatherMode.indoor;
      case 'caution':
        return WeatherMode.caution;
      default:
        return WeatherMode.outdoor;
    }
  }
}
