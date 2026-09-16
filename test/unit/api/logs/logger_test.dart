// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

/// A List that counts element reads, so a test can prove whether the no-op
/// [APILogger.emit] walked the body or left it alone.
class _CountingList extends ListBase<int> {
  _CountingList(this._inner);

  final List<int> _inner;

  /// How many elements have been read.
  int reads = 0;

  @override
  int get length => _inner.length;

  @override
  set length(int newLength) => _inner.length = newLength;

  @override
  int operator [](int index) {
    reads++;
    return _inner[index];
  }

  @override
  void operator []=(int index, int value) => _inner[index] = value;
}

void main() {
  group('APILogger', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('creates logger with name', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(logger, isNotNull);
      expect(logger.name, equals('test-logger'));
      expect(logger.version, isNull);
      expect(logger.schemaUrl, isNull);
      expect(logger.attributes, isNull);
    });

    test('creates logger with name and version', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger(
        'test-logger',
        version: '1.2.3',
      );

      expect(logger, isNotNull);
      expect(logger.name, equals('test-logger'));
      expect(logger.version, equals('1.2.3'));
    });

    test('creates logger with name, version, and schemaUrl', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger(
        'test-logger',
        version: '1.2.3',
        schemaUrl: 'https://opentelemetry.io/schemas/1.4.0',
      );

      expect(logger, isNotNull);
      expect(logger.name, equals('test-logger'));
      expect(logger.version, equals('1.2.3'));
      expect(
          logger.schemaUrl, equals('https://opentelemetry.io/schemas/1.4.0'));
    });

    test('creates logger with attributes', () {
      final provider = OTelAPI.loggerProvider();
      final attributes = Attributes.of({
        'library.name': 'test-logger',
        'library.language': 'dart',
      });

      final logger = provider.getLogger(
        'test-logger',
        version: '1.2.3',
        attributes: attributes,
      );

      expect(logger, isNotNull);
      expect(logger.attributes, isNotNull);
      expect(logger.attributes?.toMap()['library.name']?.value.unwrap(),
          equals('test-logger'));
      expect(logger.attributes?.toMap()['library.language']?.value.unwrap(),
          equals('dart'));
    });

    test('enabled returns false for API logger', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      // API logger is always disabled (no-op)
      expect(logger.isEnabled(), isFalse);
    });

    test('emit does not throw with minimal parameters', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      // Should not throw - it's a no-op
      expect(logger.emit, returnsNormally);
    });

    test('emit does not throw with body', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(() => logger.emit(body: 'test log message'), returnsNormally);
    });

    test('emit does not throw with severity', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(
        () => logger.emit(
          severityNumber: Severity.INFO,
          severityText: 'INFO',
        ),
        returnsNormally,
      );
    });

    test('emit does not throw with timestamp', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');
      final now = DateTime.now();

      expect(
        () => logger.emit(
          timeStamp: now,
          observedTimestamp: now,
        ),
        returnsNormally,
      );
    });

    test('emit does not throw with context', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');
      final context = Context.current;

      expect(
        () => logger.emit(context: context),
        returnsNormally,
      );
    });

    test('emit does not throw with attributes', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');
      final attributes = Attributes.of({
        'key1': 'value1',
        'key2': 123,
      });

      expect(
        () => logger.emit(attributes: attributes),
        returnsNormally,
      );
    });

    test('emit does not throw with event name', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(
        () => logger.emit(eventName: 'test.event'),
        returnsNormally,
      );
    });

    test('emit does not throw with all parameters', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');
      final now = DateTime.now();
      final context = Context.current;
      final attributes = Attributes.of({
        'key1': 'value1',
        'key2': 123,
        'key3': true,
      });

      expect(
        () => logger.emit(
          timeStamp: now,
          observedTimestamp: now,
          context: context,
          severityNumber: Severity.WARN,
          severityText: 'WARN',
          body: 'This is a warning message',
          attributes: attributes,
          eventName: 'test.warning.event',
        ),
        returnsNormally,
      );
    });

    test('emit accepts different body types', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      // String body
      expect(() => logger.emit(body: 'string body'), returnsNormally);

      // Number body
      expect(() => logger.emit(body: 42), returnsNormally);

      // Boolean body
      expect(() => logger.emit(body: true), returnsNormally);

      // Map body
      expect(() => logger.emit(body: {'key': 'value'}), returnsNormally);

      // List body
      expect(() => logger.emit(body: ['item1', 'item2']), returnsNormally);
    });

    test('emit with different severity levels', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(
          () => logger.emit(severityNumber: Severity.TRACE), returnsNormally);
      expect(
          () => logger.emit(severityNumber: Severity.DEBUG), returnsNormally);
      expect(() => logger.emit(severityNumber: Severity.INFO), returnsNormally);
      expect(() => logger.emit(severityNumber: Severity.WARN), returnsNormally);
      expect(
          () => logger.emit(severityNumber: Severity.ERROR), returnsNormally);
      expect(
          () => logger.emit(severityNumber: Severity.FATAL), returnsNormally);
    });

    // logs/noop.md: the No-Op Logger accepts the parameters and does nothing.
    // No record is produced without an SDK, so there is nothing an
    // unrepresentable body could corrupt, and reporting it would charge users
    // with no SDK installed for a diagnosis they cannot act on.
    test('no-op emit reports nothing, whatever the body', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      expect(() => logger.emit(body: () {}), returnsNormally);
      expect(() => logger.emit(body: 'fine'), returnsNormally);
      expect(() => logger.emit(body: {'k': 1}), returnsNormally);
      expect(logger.emit, returnsNormally);

      expect(reported, isEmpty);
    });

    test('no-op emit does not traverse the body', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');
      final body = _CountingList([1, 2, 3]);

      logger.emit(body: body);
      expect(body.reads, isZero, reason: 'the no-op never read the body');

      // The SDK-facing helper does read it, which is the difference.
      APILogger.bodyToAnyValue(body);
      expect(body.reads, greaterThan(0));
    });

    test('bodyToAnyValue reports and drops an unrepresentable body', () {
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      // The helper an SDK calls still reports: there the record is real.
      expect(APILogger.bodyToAnyValue(() {}), isNull);
      expect(reported, hasLength(1));
      expect(reported.single, isA<ArgumentError>());
    });

    test('bodyToAnyValue converts a plain value', () {
      expect(APILogger.bodyToAnyValue(null), isNull);
      expect(APILogger.bodyToAnyValue('s'), equals(const AnyValueString('s')));
      expect(APILogger.bodyToAnyValue(1), equals(const AnyValueInt(1)));
      expect(APILogger.bodyToAnyValue({'k': 1}),
          equals(AnyValueMap({'k': const AnyValueInt(1)})));
    });

    // LogRecord.body is an AnyValue?, so emit(body: record.body) is the
    // natural way to forward a record. Re-wrapping it would report it as
    // unsupported and drop it.
    test('bodyToAnyValue passes an AnyValue through unchanged', () {
      final reported = <Object>[];
      OTelAPI.setErrorHandler((e, _) => reported.add(e));
      addTearDown(() => OTelAPI.setErrorHandler(null));

      final body = AnyValueMap({'k': const AnyValueString('v')});
      expect(identical(APILogger.bodyToAnyValue(body), body), isTrue);

      const scalar = AnyValueString('s');
      expect(identical(APILogger.bodyToAnyValue(scalar), scalar), isTrue);

      const nullValue = AnyValueNull();
      expect(identical(APILogger.bodyToAnyValue(nullValue), nullValue), isTrue);

      expect(reported, isEmpty);
    });

    test('multiple emit calls do not interfere', () {
      final provider = OTelAPI.loggerProvider();
      final logger = provider.getLogger('test-logger');

      expect(
        () {
          logger.emit(body: 'message 1', severityNumber: Severity.INFO);
          logger.emit(body: 'message 2', severityNumber: Severity.WARN);
          logger.emit(body: 'message 3', severityNumber: Severity.ERROR);
        },
        returnsNormally,
      );
    });
  });
}
