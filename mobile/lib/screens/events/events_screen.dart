import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app.dart';
import '../../l10n/app_localizations.dart';
import '../../models/event.dart';
import '../../providers/events_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/event_card.dart';
import '../event_detail/event_detail_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LocationService _locationService = LocationService();
  bool _initialLoadDone = false;

  static const _filters = ['thisWeek', 'thisMonth', 'all'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadEvents());
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    final provider = context.read<EventsProvider>();
    provider.setTimeFilter(_filters[_tabController.index]);
  }

  Future<void> _loadEvents() async {
    final provider = context.read<EventsProvider>();
    // Set default filter to thisWeek on first load
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
    final filterLabels = [l10n.thisWeek, l10n.thisMonth, l10n.all];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.events),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: filterLabels
              .map((label) => Tab(text: label))
              .toList(),
        ),
      ),
      body: Consumer<EventsProvider>(
        builder: (context, provider, _) {
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
            onRefresh: _loadEvents,
            color: LittleAtlasApp.atlasGreen,
            child: _buildGroupedList(provider.events, l10n),
          );
        },
      ),
    );
  }

  // ── Grouped list with date headers ──────────────────────────────────

  Widget _buildGroupedList(List<Event> events, AppLocalizations l10n) {
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

    // Build flat list of headers + cards
    final items = <Widget>[];
    for (final entry in grouped.entries) {
      items.add(_buildDateHeader(entry.key));
      for (final event in entry.value) {
        items.add(
          EventCard(
            event: event,
            onTap: () => _navigateToDetail(event),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: items,
    );
  }

  Widget _buildDateHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 1.2,
          color: LittleAtlasApp.textSecondary,
        ),
      ),
    );
  }

  void _navigateToDetail(Event event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EventDetailScreen(event: event),
      ),
    );
  }

  // ── Skeleton loading ────────────────────────────────────────────────

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  // ── Empty state ─────────────────────────────────────────────────────

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: LittleAtlasApp.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noUpcomingEvents,
              style: TextStyle(
                fontSize: 16,
                color: LittleAtlasApp.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Error state ─────────────────────────────────────────────────────

  Widget _buildErrorState(String error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: LittleAtlasApp.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: LittleAtlasApp.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _loadEvents,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
