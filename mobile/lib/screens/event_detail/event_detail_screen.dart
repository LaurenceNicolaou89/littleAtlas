import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../app.dart';
import '../../l10n/app_localizations.dart';
import '../../models/event.dart';
import '../../utils/formatters.dart';
import '../../utils/launchers.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.event),
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

            // Age suitability with baby icon — using shared formatter
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
                    formatAgeRange(event.ageMin, event.ageMax),
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
                                color: LittleAtlasApp.atlasGreen, // Finding #18
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

            // Get Directions button — using shared launcher
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => launchDirections(event.lat, event.lon),
                icon: const Icon(Icons.directions),
                label: Text(l10n.getDirections),
                style: ElevatedButton.styleFrom(
                  backgroundColor: LittleAtlasApp.atlasGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            // View Source link button — using shared launcher
            if (event.sourceUrl != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => launchWebsite(event.sourceUrl!),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(l10n.viewSource),
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
