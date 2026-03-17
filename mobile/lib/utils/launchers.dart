import 'package:url_launcher/url_launcher.dart';

/// Opens Google Maps directions to the given coordinates.
Future<void> launchDirections(double lat, double lon) async {
  final url = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon',
  );
  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}

/// Initiates a phone call to the given number.
Future<void> launchPhone(String phone) async {
  final url = Uri.parse('tel:$phone');
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  }
}

/// Opens a URL in the external browser, prefixing https:// if needed.
Future<void> launchWebsite(String url) async {
  final urlString = url.startsWith('http') ? url : 'https://$url';
  final uri = Uri.parse(urlString);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
