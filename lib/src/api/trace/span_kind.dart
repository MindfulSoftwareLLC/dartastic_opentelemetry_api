// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

/// Type of span. Can be used to specify additional relationships between spans
/// in addition to a parent/child relationship.
enum SpanKind {
  /// Default value. Indicates that the span represents an internal operation
  /// within an application.
  internal,

  /// Indicates that the span covers server-side handling of a synchronous RPC or
  /// other remote request.
  server,

  /// Indicates that the span describes a request to some remote service.
  client,

  /// Indicates that the span describes a producer sending a message to a broker.
  producer,

  /// Indicates that the span describes a consumer receiving a message from a broker.
  consumer
}
