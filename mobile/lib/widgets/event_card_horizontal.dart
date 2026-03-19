import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../theme/design_tokens.dart';
import '../utils/formatters.dart';
import 'live_badge.dart';

/// A compact horizontal event card (160×210 dp) for scrollable rows.
///
/// Shows a gradient image area with an optional [LiveBadge], followed by
/// the event name, time range, optional distance, and age pill.
class EventCardHorizontal extends StatelessWidget {
  const EventCardHorizontal({
    super.key,
    required this.event,
    required this.onTap,
  });

  final Event event;
  final VoidCallback onTap;

  bool get _isHappeningNow {
    if (event.endDate == null) return false;
    final now = DateTime.now();
    return event.startDate.isBefore(now) && event.endDate!.isAfter(now);
  }

  /// Returns a pair of gradient colors based on [Event.eventType].
  List<Color> get _gradientColors {
    switch (event.eventType?.toLowerCase()) {
      case 'cinema':
        return const [Color(0xFFFF7675), Color(0xFFE17055)]; // coral tones
      case 'theatre':
        return const [Color(0xFF74B9FF), Color(0xFF0984E3)]; // blue tones
      case 'workshop':
        return const [Color(0xFF00B894), Color(0xFF00CEC9)]; // green tones
      case 'festival':
        return const [Color(0xFFA29BFE), Color(0xFF6C5CE7)]; // violet tones
      default:
        return const [Color(0xFFA29BFE), Color(0xFFFD79A8)]; // violet→pink
    }
  }

  String _formatTimeRange() {
    final timeFormat = DateFormat('HH:mm');
    if (event.endDate == null) {
      return timeFormat.format(event.startDate);
    }
    return '${timeFormat.format(event.startDate)} – '
        '${timeFormat.format(event.endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    final happeningNow = _isHappeningNow;
    final ageLabel = formatAgeRange(event.ageMin, event.ageMax);
    final distanceLabel = formatDistance(event.distanceM);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 210,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.cardBorder,
          boxShadow: AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gradient image area ──────────────────────────────────────
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  if (happeningNow)
                    const Positioned(
                      left: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: LiveBadge(),
                    ),
                ],
              ),
            ),

            // ── Text area ───────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event name
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Time range
                    Text(
                      _formatTimeRange(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),

                    // Distance
                    if (distanceLabel.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        distanceLabel,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          color: AppColors.textTertiary,
                          height: 1.3,
                        ),
                      ),
                    ],

                    const Spacer(),

                    // Age pill
                    if (ageLabel.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryWash,
                          borderRadius:
                              BorderRadius.circular(AppRadii.chips),
                        ),
                        child: Text(
                          ageLabel,
                          style: GoogleFonts.nunito(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
