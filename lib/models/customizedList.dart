// ignore_for_file: avoid_renaming_method_parameters

import 'dart:collection';

class CustomizedList<E> extends ListBase<E> {
  List innerList = List.empty(growable: true);

  @override
  int get length => innerList.length;

  @override
  set length(int length) {
    innerList.length = length;
  }

  @override
  void operator []=(int index, E value) {
    innerList[index] = value;
  }

  @override
  E operator [](int index) => innerList[index];

  // Though not strictly necessary, for performance reasons
  // you should implement add and addAll.

  @override
  void add(E value) => innerList.add(value);

  @override
  void addAll(Iterable<E> all) => innerList.addAll(all);
}
