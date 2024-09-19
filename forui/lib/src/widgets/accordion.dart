import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:meta/meta.dart';

import 'package:forui/forui.dart';
import 'package:forui/src/foundation/tappable.dart';
import 'package:forui/src/foundation/util.dart';

/// A controller that controls which sections are shown and hidden.
base class FAccordionController extends ChangeNotifier {
  /// The duration of the expansion and collapse animations.
  final Duration animationDuration;
  final List<({AnimationController controller, Animation animation})> _controllers;
  final Set<int> _expanded;
  final int _min;
  final int? _max;

  /// Creates a [FAccordionController].
  ///
  /// The [min] and [max] values are the minimum and maximum number of selections allowed. Defaults to no minimum or maximum.
  ///
  /// # Contract:
  /// * Throws [AssertionError] if [min] < 0.
  /// * Throws [AssertionError] if [max] < 0.
  /// * Throws [AssertionError] if [min] > [max].
  FAccordionController({
    int min = 0,
    int? max,
    this.animationDuration = const Duration(milliseconds: 500),
  })  : _min = min,
        _max = max,
        _controllers = [],
        _expanded = {},
        assert(min >= 0, 'The min value must be greater than or equal to 0.'),
        assert(max == null || max >= 0, 'The max value must be greater than or equal to 0.'),
        assert(max == null || min <= max, 'The max value must be greater than or equal to the min value.');

  /// Adds an item to the accordion.
  // ignore: avoid_positional_boolean_parameters
  void addItem(int index, AnimationController controller, Animation animation, bool initiallyExpanded) {
    _controllers.add((controller: controller, animation: animation));
    if (initiallyExpanded) {
      _expanded.add(index);
    }
  }

  /// Removes an item from the accordion.
  void removeItem(int index) {
    _controllers.removeAt(index);
    _expanded.remove(index);
  }

  /// Convenience method for toggling the current expanded status.
  ///
  /// This method should typically not be called while the widget tree is being rebuilt.
  Future<void> toggle(int index) async {
    if (_controllers[index].controller.value == 1) {
      if (_expanded.length <= _min) {
        return;
      }
      _expanded.remove(index);
      await collapse(index);
    } else {
      if (_max != null && _expanded.length >= _max) {
        return;
      }
      _expanded.add(index);
      await expand(index);
    }
    notifyListeners();
  }

  /// Shows the content in the accordion.
  ///
  /// This method should typically not be called while the widget tree is being rebuilt.
  Future<void> expand(int index) async {
    final controller = _controllers[index].controller;
    await controller.forward();
    notifyListeners();
  }

  /// Hides the content in the accordion.
  ///
  /// This method should typically not be called while the widget tree is being rebuilt.
  Future<void> collapse(int index) async {
    final controller = _controllers[index].controller;
    await controller.reverse();
    notifyListeners();
  }
}

/// An [FAccordionController] that allows one section to be expanded at a time.
final class FRadioAccordionController extends FAccordionController {
  /// Creates a [FRadioAccordionController].
  FRadioAccordionController({
    super.animationDuration,
    super.min,
    int super.max = 1,
  });

  @override
  void addItem(int index, AnimationController controller, Animation animation, bool initiallyExpanded) {
    if (_expanded.length > _max!) {
      super.addItem(index, controller, animation, false);
    } else {
      super.addItem(index, controller, animation, initiallyExpanded);
    }
  }

  @override
  Future<void> toggle(int index) async {
    final toggle = <Future>[];
    if (_expanded.length > _min) {
      if (!_expanded.contains(index) && _expanded.length >= _max!) {
        toggle.add(collapse(_expanded.first));
        _expanded.remove(_expanded.first);
      }
    }
    toggle.add(super.toggle(index));
    await Future.wait(toggle);
  }
}

/// A vertically stacked set of interactive headings that each reveal a section of content.
class FAccordion extends StatefulWidget {
  /// The controller.
  ///
  /// See:
  /// * [FRadioAccordionController] for a single radio like selection.
  /// * [FAccordionController] for default multiple selections.
  final FAccordionController? controller;

  /// The items.
  final List<FAccordionItem> items;

  /// The style. Defaults to [FThemeData.accordionStyle].
  final FAccordionStyle? style;

  /// Creates a [FAccordion].
  const FAccordion({
    required this.items,
    this.controller,
    this.style,
    super.key,
  });

  @override
  State<FAccordion> createState() => _FAccordionState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('controller', controller))
      ..add(DiagnosticsProperty('style', style))
      ..add(IterableProperty('items', items));
  }
}

class _FAccordionState extends State<FAccordion> {
  late final FAccordionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? FRadioAccordionController(min: 1, max: 2);
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? context.theme.accordionStyle;
    return Column(
      children: [
        for (final (index, widget) in widget.items.indexed)
          _Item(
            style: style,
            index: index,
            item: widget,
            controller: _controller,
          ),
      ],
    );
  }
}

/// An item that represents a header in a [FAccordion].
class FAccordionItem {
  /// The title.
  final Widget title;

  /// The child.
  final Widget child;

  /// Whether the item is initially expanded.
  final bool initiallyExpanded;

  /// Creates an [FAccordionItem].
  FAccordionItem({required this.title, required this.child, this.initiallyExpanded = false});
}

/// An interactive heading that reveals a section of content.
///
/// See:
/// * https://forui.dev/docs/accordion for working examples.
class _Item extends StatefulWidget {
  /// The accordion's style. Defaults to [FThemeData.accordionStyle].
  final FAccordionStyle style;

  /// The accordion's controller.
  final FAccordionController controller;

  final FAccordionItem item;

  final int index;

  /// Creates an [_Item].
  const _Item({
    required this.style,
    required this.index,
    required this.item,
    required this.controller,
  });

  @override
  State<_Item> createState() => _ItemState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('style', style))
      ..add(DiagnosticsProperty('controller', controller))
      ..add(DiagnosticsProperty('item', item))
      ..add(IntProperty('index', index));
  }
}

class _ItemState extends State<_Item> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expand;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.controller.animationDuration,
      value: widget.item.initiallyExpanded ? 1.0 : 0.0,
      vsync: this,
    );
    _expand = Tween<double>(
      begin: 0,
      end: 100,
    ).animate(
      CurvedAnimation(
        curve: Curves.ease,
        parent: _controller,
      ),
    );
    widget.controller.addItem(widget.index, _controller, _expand, widget.item.initiallyExpanded);
  }

  @override
  void didUpdateWidget(covariant _Item old) {
    super.didUpdateWidget(old);
    if (widget.controller != old.controller) {
      _controller = AnimationController(
        duration: widget.controller.animationDuration,
        value: widget.item.initiallyExpanded ? 1.0 : 0.0,
        vsync: this,
      );
      _expand = Tween<double>(
        begin: 0,
        end: 100,
      ).animate(
        CurvedAnimation(
          curve: Curves.ease,
          parent: _controller,
        ),
      );

      old.controller.removeItem(old.index);
      widget.controller.addItem(widget.index, _controller, _expand, widget.item.initiallyExpanded);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.controller._controllers[widget.index].animation,
        builder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FTappable(
              onPress: () => widget.controller.toggle(widget.index),
              child: MouseRegion(
                onEnter: (_) => setState(() => _hovered = true),
                onExit: (_) => setState(() => _hovered = false),
                child: Container(
                  padding: widget.style.titlePadding,
                  child: Row(
                    children: [
                      Expanded(
                        child: merge(
                          // TODO: replace with DefaultTextStyle.merge when textHeightBehavior has been added.
                          textHeightBehavior: const TextHeightBehavior(
                            applyHeightToFirstAscent: false,
                            applyHeightToLastDescent: false,
                          ),
                          style: widget.style.titleTextStyle
                              .copyWith(decoration: _hovered ? TextDecoration.underline : TextDecoration.none),
                          child: widget.item.title,
                        ),
                      ),
                      Transform.rotate(
                        //TODO: Should I be getting the percentage value from the controller or from its local state?
                        angle: (_expand.value / 100 * -180 + 90) * math.pi / 180.0,

                        child: widget.style.icon,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // We use a combination of a custom render box & clip rect to avoid visual oddities. This is caused by
            // RenderPaddings (created by Paddings in the child) shrinking the constraints by the given padding, causing the
            // child to layout at a smaller size while the amount of padding remains the same.
            _Expandable(
              //TODO: Should I be getting the percentage value from the controller or from its local state?
              percentage: _expand.value / 100,
              child: ClipRect(
                //TODO: Should I be getting the percentage value from the controller or from its local state?
                clipper: _Clipper(percentage: _expand.value / 100),
                child: Padding(
                  padding: widget.style.contentPadding,
                  child: DefaultTextStyle(style: widget.style.childTextStyle, child: widget.item.child),
                ),
              ),
            ),
            FDivider(
              style: context.theme.dividerStyles.horizontal
                  .copyWith(padding: EdgeInsets.zero, color: widget.style.dividerColor),
            ),
          ],
        ),
      );
}

class _Expandable extends SingleChildRenderObjectWidget {
  final double _percentage;

  const _Expandable({
    required Widget child,
    required double percentage,
  })  : _percentage = percentage,
        super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => _ExpandableBox(percentage: _percentage);

  @override
  void updateRenderObject(BuildContext context, _ExpandableBox renderObject) {
    renderObject.percentage = _percentage;
  }
}

class _ExpandableBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  double _percentage;

  _ExpandableBox({
    required double percentage,
  }) : _percentage = percentage;

  @override
  void performLayout() {
    if (child case final child?) {
      child.layout(constraints.normalize(), parentUsesSize: true);
      size = Size(child.size.width, child.size.height * _percentage);
    } else {
      size = constraints.smallest;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child case final child?) {
      context.paintChild(child, offset);
    }
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (size.contains(position) && child!.hitTest(result, position: position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }

    return false;
  }

  double get percentage => _percentage;

  set percentage(double value) {
    if (_percentage == value) {
      return;
    }

    _percentage = value;
    markNeedsLayout();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('percentage', percentage));
  }
}

class _Clipper extends CustomClipper<Rect> {
  final double percentage;

  _Clipper({required this.percentage});

  @override
  Rect getClip(Size size) => Offset.zero & Size(size.width, size.height * percentage);

  @override
  bool shouldReclip(covariant _Clipper oldClipper) => oldClipper.percentage != percentage;
}

/// The [_Item] styles.
final class FAccordionStyle with Diagnosticable {
  /// The title's text style.
  final TextStyle titleTextStyle;

  /// The child's default text style.
  final TextStyle childTextStyle;

  /// The padding of the title.
  final EdgeInsets titlePadding;

  /// The padding of the content.
  final EdgeInsets contentPadding;

  /// The icon.
  final SvgPicture icon;

  /// The divider's color.
  final Color dividerColor;

  /// Creates a [FAccordionStyle].
  FAccordionStyle({
    required this.titleTextStyle,
    required this.childTextStyle,
    required this.titlePadding,
    required this.contentPadding,
    required this.icon,
    required this.dividerColor,
  });

  /// Creates a [FDividerStyles] that inherits its properties from [colorScheme].
  FAccordionStyle.inherit({required FColorScheme colorScheme, required FTypography typography})
      : titleTextStyle = typography.base.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.foreground,
        ),
        childTextStyle = typography.sm.copyWith(
          color: colorScheme.foreground,
        ),
        titlePadding = const EdgeInsets.symmetric(vertical: 15),
        contentPadding = const EdgeInsets.only(bottom: 15),
        icon = FAssets.icons.chevronRight(
          height: 20,
          colorFilter: ColorFilter.mode(colorScheme.primary, BlendMode.srcIn),
        ),
        dividerColor = colorScheme.border;

  /// Returns a copy of this [FAccordionStyle] with the given properties replaced.
  @useResult
  FAccordionStyle copyWith({
    TextStyle? titleTextStyle,
    TextStyle? childTextStyle,
    EdgeInsets? titlePadding,
    EdgeInsets? contentPadding,
    SvgPicture? icon,
    Color? dividerColor,
  }) =>
      FAccordionStyle(
        titleTextStyle: titleTextStyle ?? this.titleTextStyle,
        childTextStyle: childTextStyle ?? this.childTextStyle,
        titlePadding: titlePadding ?? this.titlePadding,
        contentPadding: contentPadding ?? this.contentPadding,
        icon: icon ?? this.icon,
        dividerColor: dividerColor ?? this.dividerColor,
      );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('title', titleTextStyle))
      ..add(DiagnosticsProperty('childTextStyle', childTextStyle))
      ..add(DiagnosticsProperty('padding', titlePadding))
      ..add(DiagnosticsProperty('contentPadding', contentPadding))
      ..add(ColorProperty('dividerColor', dividerColor));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FAccordionStyle &&
          runtimeType == other.runtimeType &&
          titleTextStyle == other.titleTextStyle &&
          childTextStyle == other.childTextStyle &&
          titlePadding == other.titlePadding &&
          contentPadding == other.contentPadding &&
          icon == other.icon &&
          dividerColor == other.dividerColor;

  @override
  int get hashCode =>
      titleTextStyle.hashCode ^
      childTextStyle.hashCode ^
      titlePadding.hashCode ^
      contentPadding.hashCode ^
      icon.hashCode ^
      dividerColor.hashCode;
}
