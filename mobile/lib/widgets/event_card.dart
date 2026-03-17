import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  static const Color _eventsPink = Color(0xFFEC407A);
  static const Color _happeningNowOrange = Color(0xFFFF9800);
  static const Color _happeningNowBg = Color(0xFFFFF3E0);

  bool get _isHappeningNow {
    final now = DateTime.now();
    return event.startDate.isBefore(now) && event.endDate.isAfter(now);
  }

  String _formatTimeRange() {
    final timeFormat = DateFormat('HH:mm');
    return '${timeFormat.format(event.startDate)} - ${timeFormat.format(event.endDate)}';
  }

  String _formatAgeRange(int? min, int? max) {
    if (min != null && max != null) return 'Ages $min-$max';
    if (min != null) return 'Ages $min+';
    if (max != null) return 'Ages 0-$max';
    return '';
  }

  String? _formatDistance() {
    if (event.distanceM == null) return null;
    return '${(event.distanceM! / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final happeningNow = _isHappeningNow;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final borderColor = happeningNow ? _happeningNowOrange : _eventsPink;
    final bgColor = happeningNow ? _happeningNowBg : LittleAtlasApp.surface;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              left: BorderSide(
                color: borderColor,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Happening now badge
              if (happeningNow) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _happeningNowOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Happening Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],

              // Event icon + title (H3)
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 20,
                    color: borderColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.title,
                      style: textTheme.headlineSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Time range (clock icon)
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: LittleAtlasApp.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTimeRange(),
                    style: textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Venue + distance (pin icon)
              Row(
                children: [
                  Icon(
                    Icons.place,
                    size: 16,
                    color: LittleAtlasApp.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      [
                        event.venueName,
                        if (_formatDistance() != null) _formatDistance(),
                      ].join(' \u2022 '),
                      style: textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Age range (baby icon)
              if (event.ageMin != null || event.ageMax != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.child_care,
                      size: 16,
                      color: LittleAtlasApp.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatAgeRange(event.ageMin, event.ageMax),
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
