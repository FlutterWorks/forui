
import 'package:flutter/cupertino.dart';

abstract class FSelectGroupController<T> extends ValueNotifier<T> {
  FSelectGroupController(T value) : super(value);

  void onPress(int index);

  bool contains(int index);
}

abstract class FCalendarController<T> extends ValueNotifier<T> {
  /// Creates a [FCalendarController] with the given initial [value].
  FCalendarController(super._value);

  /// Called when the given [date] in a [FCalendarPickerType.day] picker is pressed.
  ///
  /// [date] is always in UTC timezone and truncated to the nearest date.
  void onPress(DateTime date);

  /// Returns true if the given [date] is selected.
  bool contains(DateTime date);
}