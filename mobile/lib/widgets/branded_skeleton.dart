import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Shape variants for skeleton placeholders.
enum SkeletonShape {
  /// Rounded rectangle (default card shape).
  card,

  /// Narrow rounded rectangle for text lines.
  textLine,

  /// Perfect circle.
  circle,
}

/// A shimmer-effect skeleton placeholder used while content is loading.
///
/// Renders a widget of the given [height] (and optional [width]) with a
/// sliding gradient animation. The [shape] parameter controls whether it
/// appears as a card, text line, or circle.
class BrandedSkeleton extends StatefulWidget {
  const BrandedSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = AppRadii.cards,
    this.shape = SkeletonShape.card,
  });

  /// Optional fixed width. When `null` the widget expands to fill available
  /// horizontal space.
  final double? width;

  /// Fixed height of the skeleton.
  final double height;

  /// Corner radius — ignored when [shape] is [SkeletonShape.circle].
  final double borderRadius;

  /// Visual shape of the skeleton placeholder.
  final SkeletonShape shape;

  @override
  State<BrandedSkeleton> createState() => _BrandedSkeletonState();
}

class _BrandedSkeletonState extends State<BrandedSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _slideAnimation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        final gradient = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: const [
            AppColors.primaryWash,
            Colors.white,
            AppColors.primaryWash,
          ],
          stops: [
            _clamp(_slideAnimation.value - 0.3),
            _clamp(_slideAnimation.value),
            _clamp(_slideAnimation.value + 0.3),
          ],
        );

        final ShapeBorder shape;
        switch (widget.shape) {
          case SkeletonShape.circle:
            shape = const CircleBorder();
          case SkeletonShape.textLine:
          case SkeletonShape.card:
            shape = RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            );
        }

        return Container(
          width: widget.shape == SkeletonShape.circle
              ? widget.height
              : widget.width,
          height: widget.height,
          decoration: ShapeDecoration(
            shape: shape,
            gradient: gradient,
          ),
        );
      },
    );
  }

  double _clamp(double value) => value.clamp(0.0, 1.0);
}
