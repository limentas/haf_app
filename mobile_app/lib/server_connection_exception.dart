class ServerConnectionException implements Exception {
  String cause;
  ServerConnectionException(this.cause);
}
