import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app.dart';
import '../../models/event.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  Future<void> _launchDirections() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${event.lat},${event.lon}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchSourceUrl() async {
    if (event.sourceUrl == null) return;
    final urlString = event.sourceUrl!.startsWith('http')
        ? event.sourceUrl!
        : 'https://${event.sourceUrl!}';
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  String _formatDateRange() {
    final dateFormat = DateFormat('EEEE, MMM d, yyyy');
    final timeFormat = DateFormat('HH:mm');

    final isSameDay = event.startDate.year == event.endDate.year &&
        event.startDate.month == event.endDate.month &&
        event.startDate.day == event.endDate.day;

    if (isSameDay) {
      return '${dateFormat.format(event.startDate)}\n'
          '${timeFormat.format(event.startDate)} - ${timeFormat.format(event.endDate)}';
    }

    return '${dateFormat.format(event.startDate)} ${timeFormat.format(event.startDate)}\n'
        '${dateFormat.format(event.endDate)} ${timeFormat.format(event.endDate)}';
  }

  String _formatAgeRange(int? min, int? max) {
    if (min != null && max != null) return 'Ages $min-$max';
    if (min != null) return 'Ages $min+';
    if (max != null) return 'Ages 0-$max';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event title (H1)
            Text(
              event.title,
              style: textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),

            // Date and time with calendar icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: LittleAtlasApp.atlasGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatDateRange(),
                    style: textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Venue name and address with map pin icon
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.place,
                  size: 20,
                  color: LittleAtlasApp.atlasGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.venueName,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (event.address != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          event.address!,
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Age suitability with baby icon
            if (event.ageMin != null || event.ageMax != null) ...[
              Row(
                children: [
                  const Icon(
                    Icons.child_care,
                    size: 20,
                    color: LittleAtlasApp.atlasGreen,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatAgeRange(event.ageMin, event.ageMax),
                    style: textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Small map showing event location
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: IgnorePointer(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(event.lat, event.lon),
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.littleatlas.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(event.lat, event.lon),
                            width: 36,
                            height: 36,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFEC407A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.event,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description text
            if (event.description.isNotEmpty) ...[
              Text(
                event.description,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
            ],

            // Get Directions button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _launchDirections,
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LittleAtlasApp.atlasGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            // View Source link button
            if (event.sourceUrl != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _launchSourceUrl,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View Source'),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
