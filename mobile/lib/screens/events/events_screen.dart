import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/event.dart';
import '../../providers/events_provider.dart';
import '../../services/location_service.dart';
import '../../theme/design_tokens.dart';
import '../../widgets/branded_skeleton.dart';
import '../../widgets/event_card_redesign.dart';
import '../../widgets/gradient_button.dart';
import '../event_detail/event_detail_screen.dart';
import '../home/home_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final LocationService _locationService = LocationService();
  bool _initialLoadDone = false;

  static const _filters = ['thisWeek', 'thisMonth', 'all'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  Future<void> _loadEvents() async {
    final provider = context.read<EventsProvider>();
    if (!_initialLoadDone) {
      provider.setTimeFilter('thisWeek');
      _initialLoadDone = true;
    }
    final location = await _locationService.getCurrentLocation();
    await provider.fetchUpcoming(location.latitude, location.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<EventsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Screen title ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                l10n.events,
                style: GoogleFonts.nunito(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // ── Time filter pills ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _buildFilterPills(provider, l10n),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Body ───────────────────────────────────────────────────
            Expanded(child: _buildBody(provider, l10n)),
          ],
        ),
      ),
    );
  }

  // ── Filter pills row ──────────────────────────────────────────────────

  Widget _buildFilterPills(EventsProvider provider, AppLocalizations l10n) {
    final filterLabels = {
      'thisWeek': l10n.thisWeek,
      'thisMonth': l10n.thisMonth,
      'all': l10n.all,
    };

    return Row(
      children: _filters.map((filter) {
        final isSelected = provider.timeFilter == filter;
        return Padding(
          padding: const EdgeInsets.only(right: AppSpacing.sm),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              provider.setTimeFilter(filter);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.iconContainers),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.divider),
              ),
              child: Text(
                filterLabels[filter] ?? filter,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Body switcher ─────────────────────────────────────────────────────

  Widget _buildBody(EventsProvider provider, AppLocalizations l10n) {
    if (provider.isLoading) {
      return _buildSkeletonList();
    }

    if (provider.error != null) {
      return _buildErrorState(provider.error!, l10n);
    }

    if (provider.events.isEmpty) {
      return _buildEmptyState(l10n);
    }

    return RefreshIndicator(
      onRefresh: () async {
        HapticFeedback.lightImpact();
        await _loadEvents();
      },
      color: AppColors.primary,
      child: _buildDateGroupedFeed(provider.events, l10n),
    );
  }

  // ── Date-grouped feed ─────────────────────────────────────────────────

  Widget _buildDateGroupedFeed(List<Event> events, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateFormat = DateFormat('EEEE, MMM d');

    // Group events by date
    final Map<String, List<Event>> grouped = {};
    for (final event in events) {
      final eventDate = DateTime(
        event.startDate.year,
        event.startDate.month,
        event.startDate.day,
      );

      String label;
      if (eventDate == today) {
        label = l10n.today;
      } else if (eventDate == tomorrow) {
        label = l10n.tomorrow;
      } else {
        label = dateFormat.format(eventDate).toUpperCase();
      }

      grouped.putIfAbsent(label, () => []).add(event);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: 80,
      ),
      itemCount: grouped.length,
      itemBuilder: (context, sectionIndex) {
        final entry = grouped.entries.elementAt(sectionIndex);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: EdgeInsets.only(
                top: sectionIndex == 0 ? AppSpacing.sm : AppSpacing.xl,
                bottom: AppSpacing.sm,
              ),
              child: Text(
                entry.key,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // Event cards in this date group
            ...entry.value.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: EventCardRedesign(
                  event: event,
                  onTap: () => _navigateToDetail(event),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDetail(Event event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(event: event),
      ),
    );
  }

  // ── Skeleton loading ──────────────────────────────────────────────────

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: BrandedSkeleton(height: 100),
        );
      },
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.primaryWash,
            borderRadius: AppRadii.cardBorder,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Quiet week! Here are some places to explore anytime.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GradientButton(
                label: l10n.explore,
                icon: Icons.explore_rounded,
                onTap: () => HomeScreen.switchTab(context, 0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Error state ───────────────────────────────────────────────────────

  Widget _buildErrorState(String error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              error,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            GradientButton(
              label: l10n.retry,
              icon: Icons.refresh_rounded,
              onTap: _loadEvents,
            ),
          ],
        ),
      ),
    );
  }
}
