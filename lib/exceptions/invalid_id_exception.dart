class InvalidIdException implements Exception {
  final String message;

  InvalidIdException(this.message);

  @override
  String toString() {
    return 'InvalidIdException: $message';
  }
}