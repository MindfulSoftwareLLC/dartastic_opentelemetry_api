// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'semantics.dart';

/// OpenTelemetry GenAI semantic-convention attribute keys.
///
/// Stable spec keys for AI/LLM telemetry, used by every GenAI-aware
/// integration. Follows
/// https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-spans/
/// — currently in the OTel "experimental" tier but the attribute
/// keys themselves are stable.
enum GenAi implements OTelSemantic {
  /// `gen_ai.system` — the GenAI provider (`openai`, `anthropic`,
  /// `google.gemini`, `cohere`, `mistral_ai`, `aws.bedrock`, …).
  /// Mirrors OTel's `GenAiSystemKey` enumeration values.
  system('gen_ai.system'),

  /// `gen_ai.operation.name` — the high-level operation
  /// (`chat`, `text_completion`, `embeddings`).
  operationName('gen_ai.operation.name'),

  /// `gen_ai.request.model` — the model identifier supplied in the
  /// request (e.g. `gpt-4o`, `claude-3-5-sonnet-20240620`).
  requestModel('gen_ai.request.model'),

  /// `gen_ai.request.max_tokens` — `max_tokens` from the request.
  requestMaxTokens('gen_ai.request.max_tokens'),

  /// `gen_ai.request.temperature`.
  requestTemperature('gen_ai.request.temperature'),

  /// `gen_ai.request.top_p`.
  requestTopP('gen_ai.request.top_p'),

  /// `gen_ai.request.top_k` (Anthropic / Gemini).
  requestTopK('gen_ai.request.top_k'),

  /// `gen_ai.request.frequency_penalty`.
  requestFrequencyPenalty('gen_ai.request.frequency_penalty'),

  /// `gen_ai.request.presence_penalty`.
  requestPresencePenalty('gen_ai.request.presence_penalty'),

  /// `gen_ai.request.stop_sequences` (joined with commas).
  requestStopSequences('gen_ai.request.stop_sequences'),

  /// `gen_ai.response.id` — provider-supplied response identifier.
  responseId('gen_ai.response.id'),

  /// `gen_ai.response.model` — the actual model the provider used
  /// (may differ from the requested model when the provider rewrites
  /// or aliases the identifier).
  responseModel('gen_ai.response.model'),

  /// `gen_ai.response.finish_reasons` — array (joined CSV) of
  /// finish reasons across the response's choices/messages.
  responseFinishReasons('gen_ai.response.finish_reasons'),

  /// `gen_ai.usage.input_tokens` — prompt / input token count.
  usageInputTokens('gen_ai.usage.input_tokens'),

  /// `gen_ai.usage.output_tokens` — completion / output token count.
  usageOutputTokens('gen_ai.usage.output_tokens');

  const GenAi(this.key);

  @override
  final String key;

  @override
  String toString() => key;
}

/// Standard span name for a GenAI chat call, per OTel semconv:
/// `<operation.name> <model>` (e.g. `chat gpt-4o`).
String genAiSpanName({
  required String operationName,
  required String model,
}) =>
    '$operationName $model';
