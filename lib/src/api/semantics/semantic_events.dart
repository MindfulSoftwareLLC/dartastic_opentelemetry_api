// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

/// OpenTelemetry semantic-convention event names.
///
/// Events live alongside spans and log records — every emitted log
/// record either carries an `event.name` matching one of the spec-
/// standardized names below, or is plain free-form. The `exception`
/// event is also the canonical span-event name (set via
/// `Span.recordException` under the hood).
///
/// Source: model/*/events.yaml in
/// https://github.com/open-telemetry/semantic-conventions
library;

/// Base interface for event-name enums.
abstract interface class OTelEvent {
  /// The on-wire event name (e.g. `exception`, `feature_flag.evaluation`).
  String get name;
}

/// All spec-defined event names from the OTel semantic conventions.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/general/events/)
enum SemanticEvent implements OTelEvent {
  /// `exception` — the span event recorded by `Span.recordException`,
  /// also a top-level log event. Stable.
  exception('exception'),

  /// `feature_flag.evaluation` — emitted on every feature-flag check.
  /// Stable.
  featureFlagEvaluation('feature_flag.evaluation'),

  /// `browser.web_vital` — Core Web Vitals (LCP, FID, CLS, etc.) sampled
  /// from `package:web`-based clients. Stable.
  browserWebVital('browser.web_vital'),

  /// `azure.resource.log` — bridges Azure resource logs into the
  /// OTel logs signal. Stable.
  azureResourceLog('azure.resource.log'),

  /// `gen_ai.client.inference.operation.details` — full request/response
  /// detail for a generative-AI inference operation. Stable.
  genAiClientInferenceOperationDetails(
      'gen_ai.client.inference.operation.details'),

  /// `gen_ai.evaluation.result` — outcome of a GenAI evaluation (RAG,
  /// guardrails, etc.). Stable.
  genAiEvaluationResult('gen_ai.evaluation.result'),

  /// `faas.invocation.exception` — exception thrown during a FaaS
  /// invocation. Stable.
  faasInvocationException('faas.invocation.exception'),

  /// `http.client.request.exception` — exception thrown from an HTTP
  /// client request. Stable.
  httpClientRequestException('http.client.request.exception'),

  /// `http.server.request.exception` — exception thrown handling an
  /// HTTP server request. Stable.
  httpServerRequestException('http.server.request.exception'),

  /// `rpc.client.call.exception` — exception from an outbound RPC call.
  /// Stable.
  rpcClientCallException('rpc.client.call.exception'),

  /// `rpc.server.call.exception` — exception handling an inbound RPC call.
  /// Stable.
  rpcServerCallException('rpc.server.call.exception'),

  /// `messaging.create.exception` — exception during messaging create
  /// (publish-side). Stable.
  messagingCreateException('messaging.create.exception'),

  /// `messaging.send.exception` — exception during messaging send.
  /// Stable.
  messagingSendException('messaging.send.exception'),

  /// `messaging.process.exception` — exception during messaging process
  /// (consumer-side handling). Stable.
  messagingProcessException('messaging.process.exception'),

  /// `messaging.receive.exception` — exception during messaging receive
  /// (consumer-side fetch). Stable.
  messagingReceiveException('messaging.receive.exception'),

  /// `messaging.settle.exception` — exception during messaging settle
  /// (ack/nack). Stable.
  messagingSettleException('messaging.settle.exception');

  @override
  final String name;

  const SemanticEvent(this.name);

  @override
  String toString() => name;
}
