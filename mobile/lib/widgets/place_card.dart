import 'package:flutter/material.dart';

import '../models/place.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(place.name),
        subtitle: Text(place.category),
        trailing: place.distanceM != null
            ? Text('${(place.distanceM! / 1000).toStringAsFixed(1)} km')
            : null,
        onTap: onTap,
      ),
    );
  }
}
