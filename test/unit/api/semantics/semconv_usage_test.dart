// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Semconv usage', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('Practical use of HttpHeaderAttribute in traces', () {
      final headerAttribute = HttpHeaderAttribute.request('authorization');

      // Create attributes with the dynamic header key
      final attrs = Attributes.of({
        headerAttribute.key: 'Bearer token123',
        Http.httpRequestMethod.key: 'POST'
      });

      // Verify the header was set correctly
      expect(attrs.getString('http.request.header.authorization'),
          equals('Bearer token123'));
      expect(attrs.getString('http.request.method'), equals('POST'));

      // Test with response headers
      final responseHeaderAttribute =
          HttpHeaderAttribute.response('content-type');
      final responseAttrs = Attributes.of({
        responseHeaderAttribute.key: 'application/json',
        Http.httpResponseStatusCode.key: '200'
      });

      expect(responseAttrs.getString('http.response.header.content-type'),
          equals('application/json'));
      expect(
          responseAttrs.getString('http.response.status_code'), equals('200'));
    });

    test('HttpHeaderAttribute constructors', () {
      final requestHeader = HttpHeaderAttribute.request('content-type');
      expect(requestHeader.key, equals('http.request.header.content-type'));

      final responseHeader = HttpHeaderAttribute.response('content-type');
      expect(responseHeader.key, equals('http.response.header.content-type'));

      // Header names are lowercased
      final upperCaseHeader = HttpHeaderAttribute.request('Content-Type');
      expect(upperCaseHeader.key, equals('http.request.header.content-type'));

      final mixedCaseHeader = HttpHeaderAttribute.response('Content-Length');
      expect(
          mixedCaseHeader.key, equals('http.response.header.content-length'));

      final specialHeader = HttpHeaderAttribute.request('x-correlation-id');
      expect(specialHeader.key, equals('http.request.header.x-correlation-id'));
    });

    test('HttpHeaderAttribute is an OTelSemantic', () {
      // Since it extends OTelSemantic it can key a semantic map directly.
      final attrs = OTelAPI.attributesFromSemanticMap({
        HttpHeaderAttribute.request('traceparent'): '00-abc-def-01',
      });
      expect(attrs.getString('http.request.header.traceparent'),
          equals('00-abc-def-01'));
    });

    test('toMapEntry supports all attribute value types', () {
      final stringEntry = Client.clientAddress.toMapEntry('localhost');
      expect(stringEntry.key, equals('client.address'));
      expect(stringEntry.value, equals('localhost'));

      final intEntry = Client.clientPort.toMapEntry(8080);
      expect(intEntry.key, equals('client.port'));
      expect(intEntry.value, equals(8080));

      final boolEntry = Service.serviceName.toMapEntry(true);
      expect(boolEntry.key, equals('service.name'));
      expect(boolEntry.value, equals(true));

      final doubleEntry = ProcessAttributes.processPid.toMapEntry(123.45);
      expect(doubleEntry.key, equals('process.pid'));
      expect(doubleEntry.value, equals(123.45));

      final listEntry = Db.dbSystemName.toMapEntry(['mysql', 'postgres']);
      expect(listEntry.key, equals('db.system.name'));
      expect(listEntry.value, equals(['mysql', 'postgres']));

      final mapEntry =
          Http.httpRoute.toMapEntry({'path': '/api/v1', 'method': 'GET'});
      expect(mapEntry.key, equals('http.route'));
      expect(mapEntry.value, equals({'path': '/api/v1', 'method': 'GET'}));
    });

    test('Use OTelSemantics with attributesFromSemanticMap', () {
      // Mixed enum types in one map, typed values from value enums.
      final attrs = OTelAPI.attributesFromSemanticMap({
        Client.clientAddress: '127.0.0.1',
        Client.clientPort: '8080',
        Service.serviceName: 'test-service',
        Http.httpRequestMethod: HttpRequestMethod.get.value,
        Db.dbSystemName: DbSystemName.sqlite.value,
        Code.codeFunctionName: 'main',
        FileAttributes.filePath: '/path/to/file.txt',
        Network.networkConnectionType: NetworkConnectionType.wifi.value,
      });

      expect(attrs.getString('client.address'), equals('127.0.0.1'));
      expect(attrs.getString('client.port'), equals('8080'));
      expect(attrs.getString('service.name'), equals('test-service'));
      expect(attrs.getString('http.request.method'), equals('GET'));
      expect(attrs.getString('db.system.name'), equals('sqlite'));
      expect(attrs.getString('code.function.name'), equals('main'));
      expect(attrs.getString('file.path'), equals('/path/to/file.txt'));
      expect(attrs.getString('network.connection.type'), equals('wifi'));
    });

    test('attributesOf is typed on a single semconv enum', () {
      final attrs = OTelAPI.attributesOf<Http>({
        Http.httpRequestMethod: 'GET',
        Http.httpResponseStatusCode: 200,
      });

      expect(attrs.getString('http.request.method'), equals('GET'));
      expect(attrs.getInt('http.response.status_code'), equals(200));
    });

    test('entities wire identifying attributes to key enums', () {
      expect(AppEntity.app.name, equals('app'));
      expect(AppEntity.app.identifying, contains(App.appBuildId));
      expect(ServiceEntity.service.identifying, contains(Service.serviceName));

      // Every entity is enumerable through the registry index.
      expect(SemconvRegistry.allEntityEnums, isNotEmpty);
    });
  });
}
