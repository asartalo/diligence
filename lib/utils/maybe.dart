class Maybe<T> {
  final T? item;

  Maybe(this.item);

  A choice<A>(A Function() ifNull, A Function(T) ifAvailable) {
    return item == null ? ifNull() : ifAvailable(item as T);
  }
}
