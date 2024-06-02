sealed class Result<T, E extends Exception> {
  final String? message;

  Result({this.message});

  bool get isSuccess => this is Success<T, E>;

  bool get isFailure => this is Failure<T, E>;

  T unwrap() {
    if (this is Success) {
      return (this as Success<T, E>).value;
    }
    throw (this as Failure).value;
  }

  S match<S>({
    required S Function(T value) onSuccess,
    required S Function(E value) onFailure,
  }) {
    if (isSuccess) {
      return onSuccess((this as Success<T, E>).value);
    } else {
      return onFailure((this as Failure<T, E>).value);
    }
  }
}

class Success<T, E extends Exception> extends Result<T, E> {
  final T value;

  Success(this.value, {super.message});
}

class Failure<T, E extends Exception> extends Result<T, E> {
  final E value;

  Failure(this.value, {super.message});
}
