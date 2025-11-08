part of 'logger.dart';

class LoggerCreate {
  /// Creates a Tracer, only accessible within library
  static APILogger create({
    required String name,
    String? version,
    String? schemaUrl,
    Attributes? attributes,
  }) {
    return APILogger._(
      name: name,
      version: version,
      schemaUrl: schemaUrl,
      attributes: attributes,
    );
  }
}