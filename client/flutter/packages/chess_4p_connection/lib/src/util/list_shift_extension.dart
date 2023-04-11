extension Shift<E> on List<E> {
  List<E> shift(int shift) {
    return [...getRange(shift, length), ...getRange(0, shift)];
  }
}