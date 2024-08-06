import 'package:flutter/cupertino.dart';
import 'package:sugar/collection.dart';

abstract class FSelectGroupController<T> extends ChangeNotifier {
  Set<T> _active;

  FSelectGroupController({required Set<T> active}) : _active = active;

  void select(T value);

  bool state(T value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FSelectGroupController && runtimeType == other.runtimeType && _active == other._active;

  @override
  int get hashCode => _active.hashCode;
}

final class FSelectGroupMultiController<T> extends FSelectGroupController<T> {
  final int? max;

  FSelectGroupMultiController({
    super.active = const {},
    this.max,
  }) : assert(max == null || max > 0, 'limit must be null or greater than 0');

  @override
  void select(T value) {
    if (_active.remove(value)) {
      notifyListeners();
      return;
    }

    if (max != null && _active.length >= max!) {
      return;
    }

    _active.add(value);
    notifyListeners();
  }

  @override
  bool state(T value) => _active.contains(value);

  Set<T> get active => {..._active};
}

final class FSelectGroupRadioController<T> extends FSelectGroupController<T> {
  FSelectGroupRadioController({super.active = const {}});

  @override
  void select(T value) {
    if (_active.contains(value)) {
      return;
    }

    _active
      ..clear()
      ..add(value);

    notifyListeners();
  }

  @override
  bool state(T value) => _active.contains(value);

  T get active => _active.first;
}
