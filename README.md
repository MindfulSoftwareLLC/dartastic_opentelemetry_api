# Dartastic OpenTelemetry API for Dart

[![Pub Version](https://img.shields.io/pub/v/dartastic_opentelemetry_api.svg)](https://pub.dev/packages/dartastic_opentelemetry_api)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![OpenTelemetry API Specification](https://img.shields.io/badge/OpenTelemetry%20API-Specification-blueviolet)](https://opentelemetry.io/docs/specs/otel/)

A Dart implementation of the [OpenTelemetry](https://opentelemetry.io/) API that strictly adheres to the 
OpenTelemetry (OTel) specification. This package provides a vendor-neutral, implementation-agnostic API for telemetry 
instrumentation in Dart and Flutter applications.

## Overview

This OpenTelemetry API for Dart exists as a standalone library to strictly adhere to the OpenTelemetry specification 
which separates API and SDK concerns. The specification requires that the API can be dropped into an app without an SDK 
and it will work in a no-op fashion.

This API is rarely used without an SDK. The SDK for this API is implemented by 
`dartastic_opentelemetry`, the [Dartastic OpenTelemetry SDK](https://pub.dev/packages/dartastic_opentelemetry).
To instrument Dart apps, include the latest `dartastic_opentelemetry` and use its `OTel` class.

To instrument Flutter applications use the [Flutterrific OpenTelemetry SDK](https://pub.dev/packages/flutterrific_opentelemetry), 
`flutterrific_opentelemetry` to gain almost automatic instrumentation for app routes, error catching 
and web vitals metrics and much more. 

[Dartastic.io](https://dartastic.io) provides OpenTelemetry Observability backends for Flutter apps, Dart backends and 
any other service or process that produces OpenTelemetry. Dartastic.io is an observability background built on 
open standards, catering specifically to Flutter and Dart applications with custom dashboards and the ability to show Dart source code lines
and function calls from production errors and logs. Dartastic.io comes with a generous data parameters, various levels of free, paid and enterprise support and 
additional pro library features that are not available in the open source offering including telemetry 
that integrates with native code and Real-Time User Monitoring of Flutter apps, training and consulting. 

This `dartastic_opentelemetry_api` OTel API for Dart exists as a standalone library to strictly adhere to the
OpenTelemetry specification which separates API and the SDK. The specification
requires that the API can be dropped into an app without an SDK and it will work in a no-op fashion. 
You could include just `dartastic_opentelemetry_api` in your pubspec.yaml top get a no-op implementation
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
  - Metric 
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
  dartastic_opentelemetry_api: ^0.8.8
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
  dartastic_opentelemetry_api: ^0.8.8
```

## Usage

The entrypoint for almost all object creation is the `OTelAPI` class. Again this would be rarely used, instead
use the `OTel` class from `dartastic_opentelemetry` which has the same methods with addition methods
for SDK objects like `Resource` and `SpanProcessor`.

All public constructors are private except the `OTelAPIFactory`.  Use the `OTelAPI` to create API objects. Some
convenience functions such as `Attributes.of` and `copyWith`, `copyWithout` and `toJson` methods on objects such 
as `Attributes`, `Baggage`, and `Context` 

In order to strictly comply with the limited types the OpenTelemetry specification allows
for `Attribute`s there's no generic `OTelAPI.attribute<T>` creation method and instead, to provide a
typesafe API, there are 8 creation methods for `String`, `bool`, `int`, `double` and `List`s of those types,
i.e. `OTelAPI.attributeString('foo', 'bar')`, `OTelAPI.attributeIntList('baz', [1, 2, 3])`.

## Usage Examples

### Basic Tracing Example

```dart
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

void main() {
  // Create a tracer
  final tracer = OTelAPI.tracerProvider().getTracer('example-service');
  
  // Create and use a span
  Span rootSpan = tracer.startSpan('main-operation');
  try {
    // Your business logic here
    rootSpan.setBoolAttribute('operation.success', true);
    
    // Create a child span for a sub-operation
    Span childSpan = tracer.startSpan('sub-operation');
    try {
      // Sub-operation logic
      childSpan.setIntAttribute('operation.value', 42);
    } finally {
      childSpan.end();
    }
  } catch (e, stackTrace) {
    // Record the error
    rootSpan
      ..setStatus(SpanStatusCode.error, e.toString())
      ..recordException(e, stackTrace: stackTrace);
    rethrow;
  } finally {
    rootSpan.setStatus(SpanStatusCode.Ok);
    // Always end the span
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
  
  // Make this the current context
  Context.current = context;
  
  // Later, retrieve baggage from current context
  Baggage currentBaggage = Baggage.fromContext(Context.current);
  String? userId = currentBaggage.getEntry('userId')?.value;
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

  // Using the typesafe API methods
  Attributes attributes = OTelAPI.attributes([
    OTelAPI.attributeString('service.name', 'payment-processor'),
    OTelAPI.attributeInt('retry.count', 3),
    OTelAPI.attributeDouble('request.duration', 0.125),
    OTelAPI.attributeBool('request.success', true),
    OTelAPI.attributeStringList('tags', ['payment', 'critical']),
  ]);
  
  // Using Map extension
  Attributes fromMap = <String, Object>{
    'http.method': 'GET',
    'http.url': 'https://api.example.com/users',
    'http.status_code': 200,
    'environment': 'production',
    'user.roles': ['admin', 'operator'],
  }.toAttributes();
  
}
```

### Working with logging
```dart
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

final loggerProvider = OTelAPI.loggerProvider();
final logger = loggerProvider.getLogger('dart-otel-api-example-service');
logger.emit(body: "some log here!", attributes: equalToTheAbove, context: Context.current);
```


See the `/example` folder for more complete examples.

## API Overview

### Main API Components

- **OTelAPI** - The main entry point for creating API objects
- **Tracer** - Creates spans for tracing operations
- **Span** - Represents a unit of work or operation
- **Context** - Carries execution metadata across API boundaries
- **Baggage** - Provides a mechanism to propagate key-value pairs alongside a context
- **Attributes** - Represent keyvalue pairs with a known set of value types

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

## Commercial Support

[Dartastic.io](https://dartastic.io) provides an OpenTelemetry Observability backend for Flutter apps, Dart backends, 
and any other service or process that produces OpenTelemetry data. Dartastic.io is built on open standards, specifically catering to Flutter and Dart applications with the ability to show Dart source code lines and function calls from production errors and logs.

Dartastic.io offers:
- A generous free tier 
- Custom dashboards for Flutter OTel
- Facilities to get a source stack trace from production errors
- Various levels of free, paid, and enterprise support
- Private packages with advanced features not available in the open source offering
- Native code integration and Real-Time User Monitoring for Flutter apps

## For Instrumentation Library Developers

This API can be used directly by those writing instrumentation libraries. By coding against this API rather than a 
specific SDK implementation, your instrumentation will work with any compliant OpenTelemetry SDK.

To create your own SDK implementation, implement the `OTelFactory` interface. See the Dartastic OTel SDK's 
`OTelSDKFactory` for an example.

## AI Usage
Practically all code in Dartastic was originally generated by using Claude.
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
