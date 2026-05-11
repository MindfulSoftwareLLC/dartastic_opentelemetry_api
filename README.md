# Dartastic OpenTelemetry API for Dart

[![Pub Version](https://img.shields.io/pub/v/dartastic_opentelemetry_api.svg)](https://pub.dev/packages/dartastic_opentelemetry_api)
[![CI](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/actions/workflows/dart.yml/badge.svg)](https://github.com/MindfulSoftwareLLC/dartastic_opentelemetry_api/actions/workflows/dart.yml)
[![codecov](https://codecov.io/gh/MindfulSoftwareLLC/dartastic_opentelemetry_api/graph/badge.svg)](https://codecov.io/gh/MindfulSoftwareLLC/dartastic_opentelemetry_api)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![OpenTelemetry API Specification](https://img.shields.io/badge/OpenTelemetry%20API-Specification-blueviolet)](https://opentelemetry.io/docs/specs/otel/)

A Dart implementation of the [OpenTelemetry](https://opentelemetry.io/) API that strictly adheres to the 
OpenTelemetry (OTel) specification. This package provides a vendor-neutral, implementation-agnostic API for 
observability instrumentation in Dart and Flutter applications.

## Overview

Developers generally do not code with the API, they code with the SDK via the OTel class. This OpenTelemetry API for Dart exists as a standalone library to strictly adhere to the OpenTelemetry specification 
which separates API and SDK concerns. The specification requires that the API can be dropped into an app without an SDK 
and it will work in a no-op fashion.

This API is rarely used without an SDK. The SDK for this API is implemented by 
`dartastic_opentelemetry`, the [Dartastic OpenTelemetry SDK](https://pub.dev/packages/dartastic_opentelemetry).
To instrument Dart apps, include the latest `dartastic_opentelemetry` and use its `OTel` class.

To instrument Flutter applications use the [Flutterrific OpenTelemetry SDK](https://pub.dev/packages/flutterrific_opentelemetry), 
`flutterrific_opentelemetry` to gain almost automatic instrumentation for app routes, error catching 
and web vitals metrics and much more. 

## Commercial Support

[Dartastic.io](https://dartastic.io) tools and services for Dart and Flutter teams shipping to production.
* **Dartastic.io Pro OTel**
  * Professionally supported version of this open source dartastic_opentelemetry package and dartastic_opentelemetry_api - and their future CNCF equivalents.
  * Professional OpenTelemetry libraries for Dart and Flutter
    * Keep PII out of your observability data.
    * Integrate OTel observability into common Dart and Flutter like shelf, dio and go_router.
* **Dartastic.io Pub Dev** [pub.dartastic.io](pub.dartastic.io) Privately share your packages and plugins with your team,
  partners and customers.
* **Dartastic.io Symbolizer** [symbolizer.dartastic.io](symbolizer.dartastic.io) Turn production errors into
  source code lines with a Web API call. Squash Dart and Flutter bugs fast and keep your source code artifacts private.
* **Dartastic.io Observability Cloud** - observability backends, customized for Dart and Flutter and integrated with Dartastic.io Symbolizer.
* Dart and Flutter OpenTelemetry support, training, consulting, integrations and upgrades.

## About the API - use the SDK

This `dartastic_opentelemetry_api` OTel API for Dart exists as a standalone library to strictly adhere to the
OpenTelemetry specification which separates API and the SDK. The specification
requires that the API can be dropped into an app without an SDK and it will work in a no-op fashion. 
You could include just `dartastic_opentelemetry_api` in your pubspec.yaml to get a no-op implementation
as required by the OTel specification, though this would be a rare use case. Typically, 
backend instrumenters will include `dartastic_opentelemetry` in their pubspec.yaml
and this dartastic_opentelemetry_api will be a transitive dependency.  Flutter instrumentation developers 
will include `flutterrific_opentelemetry`.

Another direct use for this library is for developers who write instrumentation libraries.  
This OpenTelemetry API is pluggable. You can create your own `OTelFactory` to
implement your own SDK implementation.  See the Dartastic OTel SDK's `OTelSDKFactory`
for an example.

## Features

- ✅ **Complete OpenTelemetry API implementation** for Dart
- ✅ **Strict adherence** to the OpenTelemetry specification
  - All MUST and SHOULD requirements are implemented
  - Most, if not all, MAY requirements are implemented
- ✅ **Supported signal types**:
  - Traces
  - Metrics
  - Logs
- ✅ **Fully typed API** with strong Dart type safety
- ✅ **Cross-platform compatibility** - works across all Dart environments (Servers, Mobile, Web, Desktop)
- ✅ **No-op implementation** for safely including in any application
- ✅ **Pluggable API design** - create your own SDK implementation using `OTelFactory`

## Getting Started

Typically, you wouldn't use this library and will use Dartastic OTel `dartastic_opentelemetry` 
or `flutterrific_opentelemetry` instead to  get a working OTel implementation in your 
Dart or Flutter application, respectively.  

### Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  dartastic_opentelemetry_api: ^1.0.0-beta.6
```

Then run:

```bash
dart pub get
```

### Using with an SDK

This API is rarely used without an SDK. For a fully functional OpenTelemetry implementation, use one of the following:

- **Dart Backend Applications**: Use the [Dartastic OTel SDK](https://pub.dev/packages/dartastic_opentelemetry).
  ```yaml
  dependencies:
    dartastic_opentelemetry: ^1.0.0
  ```

- **Flutter Applications**: Use the [Flutterific OTel SDK](https://pub.dev/packages/flutterrific_opentelemetry).
  ```yaml
  dependencies:
    flutterrific_opentelemetry: ^1.0.0
  ```

Each layer exports all the relevant classes to the next layer so you only have to include one library in your pubspec.yaml.

### Direct API Usage (No-op Mode)

If you need a no-op OpenTelemetry implementation (unusual but compliant with the OTel spec):

```yaml
dependencies:
  dartastic_opentelemetry_api: ^1.0.0-beta.6
```

## Usage

The entrypoint for almost all object creation is the `OTelAPI` class. Again this would be rarely used, instead
use the `OTel` class from `dartastic_opentelemetry` which has the same methods with addition methods
for SDK objects like `Resource` and `SpanProcessor`.

All public constructors are private except the `OTelAPIFactory`. Use `OTelAPI` to create API objects.
Convenience static factories such as `Attributes.of`, plus `copyWith`, `copyWithout`, and `toJson`
methods, are provided on objects such as `Attributes`, `Baggage`, and `Context`.

In order to strictly comply with the limited types the OpenTelemetry specification allows
for `Attribute`s there's no generic `OTelAPI.attribute<T>` creation method and instead, to provide a
typesafe API, there are 8 creation methods for `String`, `bool`, `int`, `double` and `List`s of those types,
i.e. `OTelAPI.attributeString('foo', 'bar')`, `OTelAPI.attributeIntList('baz', [1, 2, 3])`.

## Usage Examples

### Basic Tracing Example
This is a no-op when using `OTelAPI`. Use `OTel` from the SDK to record real traces.

Prefer typed enum keys over raw strings for attributes. The API ships enums for every
namespace in the [OTel semantic conventions](https://opentelemetry.io/docs/specs/semconv/)
(`HttpResource`, `UrlResource`, `ServerResource`, `DatabaseResource`, `UserSemantics`, etc.)
For app-specific attributes that aren't in a convention, define your own enum implementing
`OTelSemantic`.

```dart
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

/// Example-only attribute keys for things not in the OTel semantic
/// conventions. Rename this in your own code (e.g. `CheckoutAttribute`)
/// so the names reflect your domain.
enum ExampleAttribute implements OTelSemantic {
  operationSuccess('operation.success'),
  operationValue('operation.value'),
  retryCount('retry.count'),
  requestDuration('request.duration'),
  requestSuccess('request.success'),
  tags('tags');

  @override
  final String key;
  @override
  String toString() => key;
  const ExampleAttribute(this.key);
}

void main() {
  // Get a tracer.
  final tracer = OTelAPI.tracerProvider().getTracer('example-service');

  // tracer.startSpan() does NOT activate the span (per the OpenTelemetry
  // specification). Use tracer.withSpan to make a span active for a scope
  // so that any spans started inside are parented to it via the active
  // context. Use withSpanAsync for asynchronous scopes.
  final rootSpan = tracer.startSpan('main-operation');
  try {
    tracer.withSpan(rootSpan, () {
      rootSpan.setBoolAttribute(ExampleAttribute.operationSuccess.key, true);

      // Child span — parented to rootSpan via the active context. Wrap
      // each span in its own try/catch/finally so exceptions are recorded
      // on the right span and the span is always ended.
      final childSpan = tracer.startSpan('sub-operation');
      try {
        tracer.withSpan(childSpan, () {
          childSpan.setIntAttribute(ExampleAttribute.operationValue.key, 42);
        });
        childSpan.setStatus(SpanStatusCode.Ok);
      } catch (e, stackTrace) {
        // Per the OTel spec: recordException first, then setStatus(Error).
        childSpan.recordException(e, stackTrace: stackTrace);
        childSpan.setStatus(SpanStatusCode.Error, e.toString());
        rethrow;
      } finally {
        childSpan.end();
      }
    });
    rootSpan.setStatus(SpanStatusCode.Ok);
  } catch (e, stackTrace) {
    rootSpan.recordException(e, stackTrace: stackTrace);
    rootSpan.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    rootSpan.end();
  }
}
```

### Using Context and Baggage

```dart
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

void main() {
  // Create baggage with user info
  Baggage baggage = OTelAPI.baggageForMap({
    'userId': 'user-123',
    'tenant': 'example-tenant'
  });

  // Create a context with this baggage
  Context context = OTelAPI.context(baggage: baggage);
  
  // Activate the context for a scope. runSync uses Zones, so the baggage
  // propagates to nested code, including any async callbacks started inside.
  context.runSync(() {
    // Read baggage off the active context.
    final currentBaggage = Context.current.baggage;
    final userId = currentBaggage?.getEntry('userId')?.value;
  });
}
```

### Working with Attributes

```dart
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

void main() {

  // Using of
  Attributes equalToTheAbove = Attributes.of({
    'example_string_key': 'foo',
    'example_double_key': 42.1,
    'example_bool_list_key': [true, false, true],
    'example_int_list_key': [42, 43, 44],
  });

  // Using the typesafe API methods. Mix API convention enums (e.g.
  // ServiceResource) with your own enum (ExampleAttribute) for
  // non-convention keys — never use raw strings.
  Attributes attributes = OTelAPI.attributes([
    OTelAPI.attributeString(
        ServiceResource.serviceName.key, 'payment-processor'),
    OTelAPI.attributeInt(ExampleAttribute.retryCount.key, 3),
    OTelAPI.attributeDouble(ExampleAttribute.requestDuration.key, 0.125),
    OTelAPI.attributeBool(ExampleAttribute.requestSuccess.key, true),
    OTelAPI.attributeStringList(
        ExampleAttribute.tags.key, ['payment', 'critical']),
  ]);

  // Using attributesFromSemanticMap — same typed-enum principle, no
  // `.key` accessor on each entry. Mixes any combination of
  // OTel-spec semconv enums with your own ExampleAttribute-style enums.
  Attributes fromMap = OTelAPI.attributesFromSemanticMap({
    HttpResource.requestMethod: 'GET',
    UrlResource.urlFull: 'https://api.example.com/users',
    HttpResource.responseStatusCode: 200,
    DeploymentResource.deploymentEnvironmentName: 'production',
    UserSemantics.userRoles: ['admin', 'operator'],
  });
}
```

### Working with logging
This is a no-op when using `OTelAPI`. Use the OTel SDK to emit real logs.
```dart
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

final otelLoggerProvider = OTelAPI.loggerProvider();
final otelLogger = otelLoggerProvider.getLogger('dart-otel-api-faux-db-service');
final attrs = OTelAPI.attributesFromSemanticMap({
  DatabaseResource.dbOperation: 'update',
  DatabaseResource.dbCollectionName: 'orders',
  DatabaseResource.dbResponseReturnedRows: 3,
});

otelLogger.emit(
  eventName: 'order_update',
  severityNumber: Severity.INFO,
  body: 'Order update completed.',
  attributes: attrs,
);
```


See the `/example` folder for more complete examples.

## API Overview

### Main API Components

- **OTelAPI** - The main entry point for creating API objects
- **Tracer** - Creates spans for tracing operations
- **Span** - Represents a unit of work or operation
- **Context** - Carries execution metadata across API boundaries
- **Baggage** - Provides a mechanism to propagate key-value pairs alongside a context
- **Attributes** - Represent key-value pairs with a known set of value types

### Important OTelAPI Methods

The entrypoint for almost all object creation is the `OTelAPI` class. 
In real applications, you would typically use the `OTel` class from an SDK implementation.

```dart
// Get the tracer provider
TracerProvider provider = OTelAPI.tracerProvider();

// Create context
Context context = OTelAPI.context(baggage: baggage, spanContext: spanContext);

// Create attributes
Attribute attr1 = OTelAPI.attributeString('key', 'value');
Attribute attr2 = OTelAPI.attributeInt('count', 42);
Attributes attributes = OTelAPI.attributes([attr1, attr2]);

// Create baggage
Baggage baggage = OTelAPI.baggageForMap({'userId': 'user-123'});
```

## CNCF Contribution and Alignment

This project aims to align with Cloud Native Computing Foundation (CNCF) best practices:

- **Interoperability** - Works with the broader OpenTelemetry ecosystem
- **Specification compliance** - Strictly follows the OpenTelemetry specification
- **Vendor neutrality** - Provides a foundation for any OpenTelemetry SDK implementation


## For Instrumentation Library Developers

This API can be used directly by those writing instrumentation libraries. By coding against this API rather than a 
specific SDK implementation, your instrumentation will work with any compliant OpenTelemetry SDK.

To create your own SDK implementation, implement the `OTelFactory` interface. See the Dartastic OTel SDK's 
`OTelSDKFactory` for an example.

## AI Usage
Practically all code in Dartastic was originally generated by Claude.
EVERY character is reviewed by a human for compliance with the OTel spec. 
A vast amount of code was edited by hand.  
Tests may need improved quality.

## Additional Resources

- [OpenTelemetry Specification](https://opentelemetry.io/docs/specs/otel/)
- [Dartastic OTel SDK](https://pub.dev/packages/dartastic_opentelemetry) - For Dart backend applications
- [Flutterific OTel SDK](https://pub.dev/packages/flutterrific_opentelemetry) - For Flutter applications
- [Dartastic.io](https://dartastic.io/) - An OpenTelemetry backend for Dart and Flutter

## License

Apache 2.0 - See the [LICENSE](LICENSE) file for details.

## Acknowledgements

This Dart API, the Dartastic SDK, and Flutterific OTel are made with 💙 by Michael Bushe at [Mindful Software](https://mindfulsoftware.com).
