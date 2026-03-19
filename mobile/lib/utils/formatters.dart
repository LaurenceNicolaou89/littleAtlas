// Shared formatting utilities used across place and event widgets.

/// Returns a human-readable age range string, e.g. "Ages 3-5".
String formatAgeRange(int? min, int? max) {
  if (min != null && max != null) return 'Ages $min-$max';
  if (min != null) return 'Ages $min+';
  if (max != null) return 'Ages 0-$max';
  return '';
}

/// Formats a distance in meters to a human-readable string.
/// Values < 1000 m are shown as "N m", otherwise as "N.N km".
String formatDistance(double? meters) {
  if (meters == null) return '';
  if (meters < 1000) {
    return '${meters.round()} m';
  }
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
