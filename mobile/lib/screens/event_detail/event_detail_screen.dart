import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/event.dart';
import '../../theme/design_tokens.dart';
import '../../utils/formatters.dart';
import '../../utils/launchers.dart';
import '../../widgets/date_block.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/info_pill.dart';
import '../../widgets/live_badge.dart';
import '../../widgets/section_header.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  // ── Helpers ─────────────────────────────────────────────────────────

  bool get _isHappeningNow {
    if (event.endDate == null) return false;
    final now = DateTime.now();
    return event.startDate.isBefore(now) && event.endDate!.isAfter(now);
  }

  /// Returns a pair of gradient colors based on [Event.eventType].
  List<Color> get _gradientColors {
    switch (event.eventType?.toLowerCase()) {
      case 'cinema':
        return const [Color(0xFFFF7675), Color(0xFFE17055)]; // coral
      case 'theatre':
        return const [Color(0xFF74B9FF), Color(0xFF0984E3)]; // blue
      case 'workshop':
        return const [Color(0xFF00B894), Color(0xFF00CEC9)]; // green
      case 'festival':
        return const [Color(0xFFA29BFE), Color(0xFF6C5CE7)]; // violet
      default:
        return const [Color(0xFFA29BFE), Color(0xFFFD79A8)]; // violet→pink
    }
  }

  String _formatTimeRange() {
    final timeFormat = DateFormat('HH:mm');
    if (event.endDate == null) {
      return timeFormat.format(event.startDate);
    }
    return '${timeFormat.format(event.startDate)}-${timeFormat.format(event.endDate!)}';
  }

  String _formatDateLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDay = DateTime(
      event.startDate.year,
      event.startDate.month,
      event.startDate.day,
    );

    if (eventDay == today) {
      return 'Today, ${_formatTimeRange()}';
    }
    final tomorrow = today.add(const Duration(days: 1));
    if (eventDay == tomorrow) {
      return 'Tomorrow, ${_formatTimeRange()}';
    }
    return '${DateFormat('EEEE, MMM d').format(event.startDate)}, '
        '${_formatTimeRange()}';
  }

  String _formatDuration() {
    if (event.endDate == null) return '';
    final diff = event.endDate!.difference(event.startDate);
    if (diff.inHours > 0) {
      final mins = diff.inMinutes % 60;
      if (mins > 0) {
        return '${diff.inHours}h ${mins}min';
      }
      return '${diff.inHours}h';
    }
    return '${diff.inMinutes}min';
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHero(context),
                  const SizedBox(height: AppSpacing.lg),

                  // Date/time card
                  _buildDateTimeCard(),
                  const SizedBox(height: AppSpacing.lg),

                  // Info pills
                  _buildInfoPills(),
                  const SizedBox(height: AppSpacing.xl),

                  // About
                  if (event.description.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: const SectionHeader(
                        title: 'ABOUT THIS EVENT',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        event.description,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // Venue
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: const SectionHeader(title: 'VENUE'),
                  ),
                  _buildVenueSection(),
                  const SizedBox(height: AppSpacing.xl),

                  // View source link
                  if (event.sourceUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: GestureDetector(
                        onTap: () => launchWebsite(event.sourceUrl!),
                        child: Row(
                          children: [
                            Icon(
                              Icons.open_in_new,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              l10n.viewSource,
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),

          // CTA button
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: GradientButton(
              label: l10n.getDirections,
              icon: Icons.near_me,
              onTap: () => launchDirections(
                event.lat ?? 0,
                event.lon ?? 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero ───────────────────────────────────────────────────────────

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background based on event type
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.event,
                size: 56,
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ),

          // Bottom gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),

          // Title + LiveBadge + category on gradient
          Positioned(
            bottom: AppSpacing.lg,
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isHappeningNow) ...[
                  const LiveBadge(),
                  const SizedBox(height: AppSpacing.sm),
                ],
                Text(
                  event.title,
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  (event.eventType ?? 'event')
                      .replaceAll('_', ' ')
                      .toUpperCase(),
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Back button — white circle, top-left
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.sm,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 18,
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date/Time Card ────────────────────────────────────────────────

  Widget _buildDateTimeCard() {
    final duration = _formatDuration();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.cardBorder,
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            DateBlock(
              date: event.startDate,
              gradient: const [AppColors.primary, AppColors.primaryLight],
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDateLabel(),
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (duration.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      duration,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info Pills ────────────────────────────────────────────────────

  Widget _buildInfoPills() {
    final pills = <Widget>[];

    // Age range pill — pink tint
    final ageText = formatAgeRange(event.ageMin, event.ageMax);
    if (ageText.isNotEmpty) {
      pills.add(
        InfoPill(
          label: ageText,
          icon: Icons.child_care,
          backgroundColor: const Color(0xFFFFF0F6),
          textColor: AppColors.rosePink,
        ),
      );
    }

    // Distance pill — green tint
    if (event.distanceM != null) {
      pills.add(
        InfoPill(
          label: formatDistance(event.distanceM),
          icon: Icons.near_me,
          backgroundColor: const Color(0xFFE0FFF9),
          textColor: AppColors.aquaTeal,
        ),
      );
    }

    if (pills.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: pills,
      ),
    );
  }

  // ── Venue Section ─────────────────────────────────────────────────

  Widget _buildVenueSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini-map placeholder
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: AppRadii.cardBorder,
              gradient: const LinearGradient(
                colors: [AppColors.divider, AppColors.primaryWash],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                event.venueName,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Venue name
          Text(
            event.venueName,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          // Address
          if (event.address != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              event.address!,
              style: GoogleFonts.nunito(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
