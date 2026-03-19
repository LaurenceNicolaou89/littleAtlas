import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../theme/design_tokens.dart';

/// A compact 56×56 dp gradient block displaying month, day, and weekday.
class DateBlock extends StatelessWidget {
  const DateBlock({
    super.key,
    required this.date,
    this.gradient,
  });

  final DateTime date;

  /// Defaults to [AppColors.primary, AppColors.primaryLight] if not provided.
  final List<Color>? gradient;

  @override
  Widget build(BuildContext context) {
    final colors = gradient ?? [AppColors.primary, AppColors.primaryLight];
    final month = DateFormat('MMM').format(date).toUpperCase();
    final day = date.day.toString();
    final weekday = DateFormat('E').format(date).toUpperCase();

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: AppRadii.dateBlockBorder,
        gradient: LinearGradient(colors: colors),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            month,
            style: GoogleFonts.nunito(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: Colors.white.withAlpha(217), // 85 %
              height: 1.2,
            ),
          ),
          Text(
            day,
            style: GoogleFonts.nunito(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          Text(
            weekday,
            style: GoogleFonts.nunito(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(217), // 85 %
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
