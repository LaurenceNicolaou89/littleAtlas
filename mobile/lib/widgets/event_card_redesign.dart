import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';
import '../theme/design_tokens.dart';
import '../utils/formatters.dart';
import 'date_block.dart';
import 'info_pill.dart';
import 'live_badge.dart';

/// A redesigned event card for the feed — row layout with [DateBlock],
/// title, venue, time, and [InfoPill] badges.
///
/// Live events get a Rose Pink left border, enhanced shadow, and haptic
/// feedback on tap.
class EventCardRedesign extends StatelessWidget {
  const EventCardRedesign({
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

  /// Returns gradient colors for the [DateBlock] based on event type.
  List<Color> _dateBlockGradient() {
    switch (event.eventType?.toLowerCase()) {
      case 'cinema':
        return const [Color(0xFFFF7675), Color(0xFFE17055)];
      case 'theatre':
        return const [Color(0xFF74B9FF), Color(0xFF0984E3)];
      case 'workshop':
        return const [Color(0xFF00B894), Color(0xFF00CEC9)];
      case 'festival':
        return const [Color(0xFFA29BFE), Color(0xFF6C5CE7)];
      default:
        return const [AppColors.primary, AppColors.primaryLight];
    }
  }

  String _formatTimeAndVenue() {
    final timeFormat = DateFormat('HH:mm');
    final time = event.endDate != null
        ? '${timeFormat.format(event.startDate)} – '
            '${timeFormat.format(event.endDate!)}'
        : timeFormat.format(event.startDate);
    return '$time  ·  ${event.venueName}';
  }

  @override
  Widget build(BuildContext context) {
    final happeningNow = _isHappeningNow;
    final ageLabel = formatAgeRange(event.ageMin, event.ageMax);
    final distanceLabel = formatDistance(event.distanceM);

    return GestureDetector(
      onTap: () {
        if (happeningNow) {
          HapticFeedback.lightImpact();
        }
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.cardBorder,
          border: happeningNow
              ? const Border(
                  left: BorderSide(
                    color: AppColors.rosePink,
                    width: 4,
                  ),
                )
              : null,
          boxShadow: happeningNow ? AppShadows.liveEvent : AppShadows.card,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Date block ──────────────────────────────────────────────
            DateBlock(
              date: event.startDate,
              gradient: _dateBlockGradient(),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Info column ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row (with optional LiveBadge)
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (happeningNow) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const LiveBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Time + venue
                  Text(
                    _formatTimeAndVenue(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Info pills row
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      if (ageLabel.isNotEmpty)
                        InfoPill(
                          label: ageLabel,
                          backgroundColor: const Color(0xFFFFF0F6),
                          textColor: AppColors.rosePink,
                        ),
                      if (distanceLabel.isNotEmpty)
                        InfoPill(
                          label: distanceLabel,
                          icon: Icons.near_me,
                          backgroundColor: const Color(0xFFE0FFF9),
                          textColor: const Color(0xFF00B894),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
