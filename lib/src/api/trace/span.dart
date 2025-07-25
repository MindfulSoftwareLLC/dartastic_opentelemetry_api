// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:meta/meta.dart';
import '../../../dartastic_opentelemetry_api.dart';

part 'span_create.dart';

/// The set of canonical status codes.
// ignore_for_file: constant_identifier_names
// Casing consistent with OTel spec, not Dart conventions
enum SpanStatusCode {
  /// The default status.
  Unset,

  /// The operation completed successfully.
  Ok,

  /// The operation contains an error.
  Error,
}

/// Span represents a single operation within a trace.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the TracerProvider from the SDK instead.
/// Spans can be nested to form a trace tree. Each trace contains a root span,
/// which typically describes the end-to-end latency, and zero or more sub-spans
/// for its sub-operations.
/// Any span that is created MUST also be ended. This is the responsibility of
/// the user. API implementations MAY leak memory or other resources (including,
/// for example, CPU time for periodic work that iterates all spans)
/// if the user forgot to end the span.
class APISpan {
  String _name;
  final SpanContext _spanContext;
  final SpanKind _spankind;
  final APISpan? _parentSpan;
  final InstrumentationScope _instrumentationScope;
  late final DateTime _startTime;
  DateTime? _endTime;
  Attributes _attributes;
  List<SpanEvent>? _spanEvents;
  List<SpanLink>? _spanLinks;
  SpanStatusCode? _spanStatusCode;
  String? _statusDescription;

  APISpan._({
    required String name,
    required InstrumentationScope instrumentationScope,
    required SpanContext spanContext,
    APISpan? parentSpan,
    SpanKind spanKind = SpanKind.internal,
    required Attributes attributes,
    List<SpanEvent>? spanEvents,
    List<SpanLink>? spanLinks,
    DateTime? startTime,
  })  : _name = name,
        _instrumentationScope = instrumentationScope,
        _spanContext = spanContext,
        _parentSpan = parentSpan,
        _spankind = spanKind,
        _attributes = attributes,
        _startTime = startTime ?? DateTime.now(),
        _spanLinks = spanLinks,
        _spanEvents = spanEvents {
    // Set initial status to unset per spec
    _spanStatusCode = SpanStatusCode.Unset;

    // Validate parent-child relationship
    if (parentSpan != null) {
      // Must inherit trace ID from parent
      if (spanContext.traceId != parentSpan.spanContext.traceId) {
        throw ArgumentError('Child span must inherit trace ID from parent');
      }
      // Parent's span ID must match our parent span ID
      if (spanContext.parentSpanId != parentSpan.spanContext.spanId) {
        throw ArgumentError('Parent span ID must match');
      }
    } else {
      // Root spans should have an invalid (all zeros) parent span ID
      if (spanContext.parentSpanId != null &&
          spanContext.parentSpanId!.bytes == SpanId.invalidSpanIdBytes) {
        throw ArgumentError(
            'Root spans must have invalid (all zeros) parent span ID or no parent span ID');
      }
    }
  }

  /// The name of this [APISpan].
  String get name => _name;

  /// Returns the id of this Span, if any.
  /// Root spans have no SpanId.
  SpanId get spanId => _spanContext.spanId;

  /// Returns the instrumentation scope for this span
  InstrumentationScope get instrumentationScope => _instrumentationScope;

  /// The start time of this [APISpan].
  DateTime get startTime => _startTime;

  /// The end time of this [APISpan].
  DateTime? get endTime => _endTime;

  /// Returns whether this span has been ended
  bool get isEnded => _endTime != null;

  /// The status of this [APISpan].
  SpanStatusCode get status => _spanStatusCode ?? SpanStatusCode.Unset;

  /// The status of this [APISpan].
  String? get statusDescription => _statusDescription;

  /// Returns the SpanContext associated with this Span, if any.
  /// Root spans have no SpanContext.
  SpanContext get spanContext => _spanContext;

  /// Returns whether this span context is valid
  /// A span context is valid when it has a non-zero traceId and a non-zero spanId.
  bool get isValid => spanContext.isValid;

  /// Returns the parent span, if any.
  /// Root spans have no parent.
  APISpan? get parentSpan => _parentSpan;

  /// Returns the parent span context, if any.
  /// Root spans have no parent span context.
  SpanContext? get parentSpanContext => _parentSpan?.spanContext;

  /// Returns the SpanKind of this Span.
  SpanKind get kind => _spankind;

  /// Returns an unmodifiable List of SpanEvents associated with this Span.
  List<SpanEvent>? get spanEvents =>
      _spanEvents == null ? null : List.unmodifiable(_spanEvents!);

  /// Returns the SpanLinks associated with this Span.
  List<SpanLink>? get spanLinks =>
      _spanLinks == null ? null : List.unmodifiable(_spanLinks!);

  /// Returns true if this Span is recording information like events, attributes, status, etc.
  bool get isRecording => !isEnded;

  /// Only exposed for testing.  Spans are not meant to be used to propagate
  /// information within a process. To prevent misuse, implementations
  /// SHOULD NOT provide access to a Span's attributes besides its SpanContext
  @visibleForTesting
  Attributes get attributes => _attributes;

  /// Sets the attributes, replacing all existing attributes since
  /// implementations SHOULD NOT provide access to a Span's attributes
  /// besides its SpanContext.
  /// Adding attributes at span creation is preferred to calling
  /// set attribute later, as samplers can only consider information already
  /// present during span creation.
  /// Ignored if isEnded
  set attributes(Attributes newAttributes) {
    if (!isEnded) {
      _attributes = newAttributes;
    }
  }

  /// Sets an attribute, replacing any existing attribute with the same name/key
  /// Adding attributes at span creation is preferred to calling
  /// set attribute later, as samplers can only consider information already
  /// present during span creation.
  /// Ignored if isEnded
  void setStringAttribute<T>(String name, String value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithStringAttribute(name, value);
    }
  }

  /// Sets an attribute, replacing any existing attribute with the same name/key
  /// Adding attributes at span creation is preferred to calling
  /// set attribute later, as samplers can only consider information already
  /// present during span creation.
  /// Ignored if isEnded
  void setBoolAttribute(String name, bool value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithBoolAttribute(name, value);
    }
  }

  /// Sets an attribute, replacing any existing attribute with the same name/key
  /// Adding attributes at span creation is preferred to calling
  /// set attribute later, as samplers can only consider information already
  /// present during span creation.
  /// Ignored if isEnded
  void setIntAttribute(String name, int value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithIntAttribute(name, value);
    }
  }

  /// Sets an attribute, replacing any existing attribute with the same name/key
  /// Adding attributes at span creation is preferred to calling
  /// set attribute later, as samplers can only consider information already
  /// present during span creation.
  /// Ignored if isEnded
  void setDoubleAttribute(String name, double value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithDoubleAttribute(name, value);
    }
  }

  /// Sets String attribute from a DateTime, replacing any existing attribute
  /// with the same name/key
  /// Adding attributes at span creation is preferred to calling
  /// set attribute later, as samplers can only consider information already
  /// present during span creation.
  /// Ignored if isEnded
  void setDateTimeAsStringAttribute(String name, DateTime value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithStringAttribute(
          name, Timestamp.dateTimeToString(value));
    }
  }

  /// Sets an attribute, replacing any existing attribute with the same name/key
  /// Adding attributes at span creation is preferred to calling
  /// set attribute later, as samplers can only consider information already
  /// present during span creation.
  /// Ignored if isEnded
  void setStringListAttribute<T>(String name, List<String> value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithStringListAttribute(name, value);
    }
  }

  /// Sets an attribute, replacing any existing attribute with the same name/key
  /// Adding attributes at span creation is preferred to calling
  /// set attribute later, as samplers can only consider information already
  /// present during span creation.
  /// Ignored if isEnded
  void setBoolListAttribute(String name, List<bool> value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithBoolListAttribute(name, value);
    }
  }

  /// Sets an attribute, replacing any existing attribute with the same name/key
  /// Adding attributes at span creation is preferred to calling
  /// set attribute later, as samplers can only consider information already
  /// present during span creation.
  /// Ignored if isEnded
  void setIntListAttribute(String name, List<int> value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithIntListAttribute(name, value);
    }
  }

  /// Sets an attribute, replacing any existing attribute with the same name/key
  /// Adding attributes at span creation is preferred to calling
  /// set attribute later, as samplers can only consider information already
  /// present during span creation.
  /// Ignored if isEnded
  void setDoubleListAttribute(String name, List<double> value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithDoubleListAttribute(name, value);
    }
  }

  /// Adds an event to the Span. Ignored if isEnded
  /// Note that the OpenTelemetry project documents certain
  /// "standard event names and keys" which have prescribed semantic meanings.
  /// See https://github.com/open-telemetry/semantic-conventions/blob/main/docs/README.md
  void addEvent(SpanEvent spanEvent) {
    if (!isEnded) {
      _spanEvents ??= [];
      _spanEvents!.add(spanEvent);
    }
  }

  /// Adds an event to the Span. Ignored if isEnded
  void addEventNow(String name, [Attributes? attributes]) {
    if (OTelFactory.otelFactory == null) {
      throw StateError('Call initialize() first.');
    }
    if (!isEnded) {
      _spanEvents ??= [];
      _spanEvents!.add(OTelFactory.otelFactory!.spanEventNow(name, attributes));
    }
  }

  /// Adds an events to the Span from a map of names and attributes. Ignored if isEnded
  void addEvents(Map<String, Attributes?> spanEvents) {
    if (OTelFactory.otelFactory == null) {
      throw StateError('Call initialize() first.');
    }
    if (!isEnded) {
      _spanEvents ??= [];
      spanEvents.forEach((name, attributes) => _spanEvents!
          .add(OTelFactory.otelFactory!.spanEventNow(name, attributes)));
    }
  }

  /// Adds a link to this Span.
  /// Ignored if the span is ended.
  /// [spanContext] the span context for the span
  void addLink(SpanContext spanContext, [Attributes? attributes]) {
    if (OTelFactory.otelFactory == null) {
      throw StateError('Call initialize() first.');
    }
    if (!isEnded) {
      _spanLinks ??= [];
      _spanLinks!.add(OTelFactory.otelFactory!
          .spanLink(spanContext, attributes: attributes));
    }
  }

  /// Adds a link to this Span.
  /// Ignored if the span is ended.
  void addSpanLink(SpanLink spanLink) {
    if (!isEnded) {
      _spanLinks ??= [];
      _spanLinks!.add(spanLink);
    }
  }

  /// Sets the status of the Span. Ignored if isEnded
  /// Setting `Status` with `StatusCode=Ok` will override any prior or future
  /// attempts to set span `Status` with `StatusCode=Error` or `StatusCode=Unset`
  /// [description] An optional description of the status.
  ///  An empty `Description` is equivalent with a not present one.
  ///  Attempts to set value Unset is ignored.
  /// [description] When [statusCode] is error, description should include the
  /// error's toString() if an exception is caught available.
  void setStatus(SpanStatusCode statusCode, [String? description]) {
    if (!isEnded) {
      if (statusCode == SpanStatusCode.Unset) {
        return;
      }
      if (statusCode == SpanStatusCode.Ok) {
        // OK always overwrites
        _spanStatusCode = statusCode;
        _statusDescription = null; // description is only for errors
      } else if (_spanStatusCode != SpanStatusCode.Ok) {
        // Can only change if not already OK
        _spanStatusCode = statusCode;
      }
      if (_spanStatusCode == SpanStatusCode.Error &&
          description != null &&
          description.isNotEmpty) {
          _statusDescription = description;
      }
    }
  }

  /// Updates the Span name.
  ///
  /// If the span has already ended this is ignored.
  void updateName(String name) {
    if (!isEnded) {
      _name = name;
    }
  }

  /// Record an exception for the span. Does NOT set the status.
  ///
  /// [exception] the exception object
  /// [stackTrace] The stack for the exception
  /// [attributes] additional attributes of the exception
  /// [escaped] SHOULD be set to true if the exception event is recorded at a point where it is known that the exception is escaping the scope of the span.
  void recordException(
    Object exception, {
    StackTrace? stackTrace,
    Attributes? attributes,
    bool? escaped,
  }) {
    if (!isRecording) return;

    var exceptionAttributeMap = <String, Object>{
      'exception.type': exception.runtimeType.toString(),
    };

    String? exceptionMessage;
    try {
      exceptionMessage = exception.toString();
    } catch (e) {
      exceptionMessage =
          'Exception when calling toString of span exception: $e';
    }

    exceptionAttributeMap['exception.message'] = exceptionMessage;

    if (stackTrace != null) {
      exceptionAttributeMap['exception.stacktrace'] = stackTrace.toString();
    }

    if (escaped != null) {
      exceptionAttributeMap['exception.escaped'] = escaped;
    }

    var recordAttributes = exceptionAttributeMap.toAttributes();
    if (attributes != null) {
      // Merge additional attributes, allowing them to override defaults
      recordAttributes = recordAttributes.copyWithAttributes(attributes);
    }

    addEventNow('exception', recordAttributes);
  }

  /// Marks the end of the Span execution.
  /// By default the end time is set to the calling time and
  /// the span status is [SpanStatusCode.Ok]
  ///
  /// Only the first call to end modifies the Span.
  void end({DateTime? endTime, SpanStatusCode? spanStatus}) {
    if (!isEnded) {
      _endTime = endTime ?? DateTime.now();
      // Only set status if no status has been set
      if (_spanStatusCode == null || _spanStatusCode == SpanStatusCode.Unset) {
        _spanStatusCode = spanStatus ?? SpanStatusCode.Ok;
      }
    }
  }

  /// Adds a string attribute to the span by merging with existing attributes.
  ///
  /// Adding attributes at span creation is preferred to calling this method later,
  /// as samplers can only consider information already present during span creation.
  ///
  /// @param attributes The attributes to add to this span
  /// @return void
  void addAttributeString(String key, String value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithStringAttribute(key, value);
    }
  }

  /// Adds a list of string attribute to the span by merging with existing attributes.
  ///
  /// Adding attributes at span creation is preferred to calling this method later,
  /// as samplers can only consider information already present during span creation.
  ///
  /// @param attributes The attributes to add to this span
  /// @return void
  void addAttributeStringList(String key, List<String> value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithStringListAttribute(key, value);
    }
  }

  /// Adds a boolean attribute to the span by merging with existing attributes.
  ///
  /// Adding attributes at span creation is preferred to calling this method later,
  /// as samplers can only consider information already present during span creation.
  ///
  /// @param attributes The attributes to add to this span
  /// @return void
  void addAttributeBool(String key, bool value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithBoolAttribute(key, value);
    }
  }

  /// Adds a list of bool attribute to the span by merging with existing attributes.
  ///
  /// Adding attributes at span creation is preferred to calling this method later,
  /// as samplers can only consider information already present during span creation.
  ///
  /// @param attributes The attributes to add to this span
  /// @return void
  void addAttributeBoolList(String key, List<bool> value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithBoolListAttribute(key, value);
    }
  }

  /// Adds a int attribute to the span by merging with existing attributes.
  ///
  /// Adding attributes at span creation is preferred to calling this method later,
  /// as samplers can only consider information already present during span creation.
  ///
  /// @param attributes The attributes to add to this span
  /// @return void
  void addAttributeInt(String key, int value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithIntAttribute(key, value);
    }
  }

  /// Adds a list of int attribute to the span by merging with existing attributes.
  ///
  /// Adding attributes at span creation is preferred to calling this method later,
  /// as samplers can only consider information already present during span creation.
  ///
  /// @param attributes The attributes to add to this span
  /// @return void
  void addAttributeIntList(String key, List<int> value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithIntListAttribute(key, value);
    }
  }

  /// Adds a double attribute to the span by merging with existing attributes.
  ///
  /// Adding attributes at span creation is preferred to calling this method later,
  /// as samplers can only consider information already present during span creation.
  ///
  /// @param attributes The attributes to add to this span
  /// @return void
  void addAttributeDouble(String key, double value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithDoubleAttribute(key, value);
    }
  }

  /// Adds a list of double attribute to the span by merging with existing attributes.
  ///
  /// Adding attributes at span creation is preferred to calling this method later,
  /// as samplers can only consider information already present during span creation.
  ///
  /// @param attributes The attributes to add to this span
  /// @return void
  void addAttributeDoubleList(String key, List<double> value) {
    if (!isEnded) {
      _attributes = _attributes.copyWithDoubleListAttribute(key, value);
    }
  }
  /// Adds multiple attributes to the span at once by merging with existing attributes.
  /// This is more efficient than calling individual attribute setters when you need to add
  /// multiple attributes.
  ///
  /// Adding attributes at span creation is preferred to calling this method later,
  /// as samplers can only consider information already present during span creation.
  ///
  /// @param attributes The attributes to add to this span
  /// @return void
  void addAttributes(Attributes attributes) {
    if (!isEnded) {
      _attributes = _attributes.copyWithAttributes(attributes);
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! APISpan) return false;

    // Two spans are equal if they have the same span context
    return _spanContext == other._spanContext;
  }

  @override
  int get hashCode => _spanContext.hashCode;

  @override
  String toString() {
    return 'APISpan{_name: $_name, _spanContext: $_spanContext, _spankind: $_spankind, _parentSpan: $_parentSpan, _instrumentationScope: $_instrumentationScope, _startTime: $_startTime, _endTime: $_endTime, _attributes: $_attributes, _spanEvents: $_spanEvents, _spanLinks: $_spanLinks, _spanStatusCode: $_spanStatusCode, _statusDescription: $_statusDescription}';
  }
}
