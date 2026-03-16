import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.MMMd();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(
          '${event.venueName} \u2022 ${dateFormat.format(event.startDate)}',
        ),
        trailing: event.isIndoor
            ? const Icon(Icons.home, size: 20)
            : const Icon(Icons.wb_sunny, size: 20),
        onTap: onTap,
      ),
    );
  }
}
