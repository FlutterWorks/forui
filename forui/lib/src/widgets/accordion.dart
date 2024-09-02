import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:forui/forui.dart';
import 'package:forui/src/foundation/tappable.dart';
import 'package:forui/src/foundation/util.dart';
import 'package:meta/meta.dart';

class FAccordion extends StatefulWidget {
  /// The divider's style. Defaults to the appropriate style in [FThemeData.dividerStyles].
  final FAccordionStyle? style;
  final String title;
  final bool initiallyExpanded;
  final VoidCallback onExpanded;
  final double childHeight;
  final double removeChildAnimationPercentage;
  final Widget child;

  const FAccordion({
    required this.child,
    required this.childHeight,
    required this.initiallyExpanded,
    required this.onExpanded,
    this.title = '',
    this.style,
    this.removeChildAnimationPercentage = 0,
    super.key,
  });

  @override
  _FAccordionState createState() => _FAccordionState();
}

class _FAccordionState extends State<FAccordion> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  bool _isExpanded = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      value: _isExpanded ? 1.0 : 0.0,
      vsync: this,
    );
    animation = Tween<double>(
      begin: 0,
      end: 100,
    ).animate(
      CurvedAnimation(
        curve: Curves.ease,
        parent: controller,
      ),
    )..addListener(() {
        setState(() {});
      });

    _isExpanded ? controller.forward() : controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? context.theme.accordionStyle;
    return Column(
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: FTappable(
            onPress: () {
              if (_isExpanded) {
                controller.reverse();
              } else {
                controller.forward();
              }
              setState(() => _isExpanded = !_isExpanded);
              widget.onExpanded();
            },
            child: Container(
              padding: style.padding,
              child: Row(
                children: [
                  Expanded(
                    child: merge(
                      // TODO: replace with DefaultTextStyle.merge when textHeightBehavior has been added.
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                      style: TextStyle(decoration: _hovered ? TextDecoration.underline : TextDecoration.none),
                      child: Text(
                        widget.title,
                        style: style.title,
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: (animation.value / 100 * -180 + 90) * math.pi / 180.0,
                    child: FAssets.icons.chevronRight(
                      height: 20,
                      colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: animation.value / 100.0 * widget.childHeight,
          child: animation.value >= widget.removeChildAnimationPercentage ? widget.child : Container(),
        ),
        FDivider(
          style: context.theme.dividerStyles.horizontal
              .copyWith(padding: EdgeInsets.zero, color: context.theme.colorScheme.border),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

/// The [FAccordion] styles.
final class FAccordionStyle with Diagnosticable {
  /// The horizontal divider's style.
  final TextStyle title;

  /// The vertical divider's style.
  final EdgeInsets padding;

  /// Creates a [FAccordionStyle].
  FAccordionStyle({required this.title, required this.padding});

  /// Creates a [FDividerStyles] that inherits its properties from [colorScheme] and [style].
  FAccordionStyle.inherit({required FColorScheme colorScheme, required FStyle style, required FTypography typography})
      : title = typography.base.copyWith(
          fontWeight: FontWeight.w500,
        ),
        padding = const EdgeInsets.symmetric(vertical: 15);

  /// Returns a copy of this [FAccordionStyle] with the given properties replaced.
  @useResult
  FAccordionStyle copyWith({
    TextStyle? title,
    EdgeInsets? padding,
  }) =>
      FAccordionStyle(
        title: title ?? this.title,
        padding: padding ?? this.padding,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('padding', padding));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FAccordionStyle && runtimeType == other.runtimeType && title == other.title && padding == other.padding;

  @override
  int get hashCode => title.hashCode ^ padding.hashCode;
}
