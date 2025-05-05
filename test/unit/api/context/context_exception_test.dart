// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'dart:async';

import 'package:dartastic_opentelemetry_api/src/api/context/context.dart';
import 'package:dartastic_opentelemetry_api/src/api/otel_api.dart';
import 'package:test/test.dart';

void main() {
  group('Context Exception Handling', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('handles exception in async operation', () async {
      Context.current = OTelAPI.context();
      final error = Exception('Test error');

      try {
        await Context.current.run(() async {
          throw error;
        });
        // ignore: dead_code
        fail('Expected exception to be thrown');
      } catch (e) {
        expect(e, equals(error));
      }
    });

    test('maintains context after exception in nested operations', () async {
      final key = OTelAPI.contextKey<String>('test-key');
      final originalContext = OTelAPI.context().copyWith(key, 'test-value');
      Context.current = originalContext;
      var operationCount = 0;

      try {
        await originalContext.run(() async {
          operationCount++;
          await Context.current.run(() async {
            operationCount++;
            throw Exception('Nested error');
          });
        });
        // ignore: dead_code
        fail('Expected exception to be thrown');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Nested error'));
        expect(operationCount, equals(2));
        expect(Context.current.get(key), equals('test-value'));
      }
    });

    test('handles multiple exceptions in parallel operations', () async {
      final context = OTelAPI.context();
      Context.current = context;
      final futures = <Future<void>>[];

      for (var i = 0; i < 3; i++) {
        futures.add(
          context.run(() async {
            await Future<void>.delayed(const Duration(milliseconds: 10));
            throw Exception('Error $i');
          }),
        );
      }

      var caughtCount = 0;
      await Future.wait(
        futures.map((f) => f.catchError((Object e) {
              expect(e, isA<Exception>());
              expect(e.toString(), matches(r'Error \d'));
              caughtCount++;
            })),
      );

      expect(caughtCount, equals(3));
      expect(Context.current, equals(context));
    });

    test('restores context after error in runIsolate', () async {
      final key = OTelAPI.contextKey<String>('test-key');
      final context = OTelAPI.context().copyWith(key, 'test-value');
      Context.current = context;

      await context.run(() async {
        try {
          await context.runIsolate(() async {
            throw Exception('Isolate error');
          });
          // ignore: dead_code
          fail('Expected exception to be thrown');
        } catch (e) {
          expect(e, isA<Exception>());
          expect(e.toString(), contains('Isolate error'));
          expect(Context.current.get(key), equals('test-value'));
        }
      });
    });

    test('handles timeout in async operation with context', () async {
      final key = OTelAPI.contextKey<String>('test-key');
      Context.current = OTelAPI.context().copyWith(key, 'test-value');
      expect(Context.current.get(key), equals('test-value'));

      try {
        await Context.current.run(() async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return null;
        }).timeout(const Duration(milliseconds: 50));
        fail('Expected timeout exception');
      } catch (e) {
        expect(e, isA<TimeoutException>());
        expect(Context.current.get(key), equals('test-value'));
      }
    });
  });
}
