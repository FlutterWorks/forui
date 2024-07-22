import 'package:flutter/widgets.dart';

// ValueWidgetBuilder + value

class FSelectGroupItem<T> {
  final T value;
  final ValueWidgetBuilder<bool> builder;

  const FSelectGroupItem({
    required this.value,
    required this.builder,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FSelectGroupItem && runtimeType == other.runtimeType && value == other.value && builder == other.builder;

  @override
  int get hashCode => value.hashCode ^ builder.hashCode;
}

class FSelectGroup<T> extends StatelessWidget {
  final List<FSelectGroupItem<T>> items;

  // gestureDetector = true -> will include a gesture detector for free.

  const FSelectGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
