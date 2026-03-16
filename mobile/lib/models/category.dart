import 'package:flutter/material.dart';

class Category {
  final int id;
  final String slug;
  final String name;
  final IconData icon;

  const Category({
    required this.id,
    required this.slug,
    required this.name,
    this.icon = Icons.place,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      slug: json['slug'] as String,
      name: json['name'] as String,
      icon: _iconFromString(json['icon'] as String?),
    );
  }

  static IconData _iconFromString(String? iconName) {
    switch (iconName) {
      case 'park':
        return Icons.park;
      case 'restaurant':
        return Icons.restaurant;
      case 'museum':
        return Icons.museum;
      case 'playground':
        return Icons.toys;
      case 'beach':
        return Icons.beach_access;
      case 'sports':
        return Icons.sports;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.local_activity;
      default:
        return Icons.place;
    }
  }
}
