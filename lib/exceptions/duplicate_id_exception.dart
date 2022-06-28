class DuplicateIdException implements Exception {
  final String message;

  DuplicateIdException(this.message);

  @override
  String toString() {
    return 'DuplicateIdException: $message';
  }
}