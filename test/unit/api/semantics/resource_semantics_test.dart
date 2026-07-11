// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Resource Semantics Tests', () {
    late OTelFactory originalFactory;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      // Store the original factory
      originalFactory = OTelFactory.otelFactory!;
    });

    test('Practical use of HttpHeaderAttribute in traces', () {
      final headerAttribute = HttpHeaderAttribute.request('authorization');

      // Create attributes with the dynamic header key
      final attrs = Attributes.of({
        headerAttribute.key: 'Bearer token123',
        Http.requestMethod.key: 'POST'
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
        Http.responseStatusCode.key: '200'
      });

      expect(responseAttrs.getString('http.response.header.content-type'),
          equals('application/json'));
      expect(
          responseAttrs.getString('http.response.status_code'), equals('200'));
    });

    // Test the base extension
    test('OTelSemanticExtension with different value types', () {
      // Test string values
      final stringEntry = Client.clientAddress.toMapEntry('localhost');
      expect(stringEntry.key, equals('client.address'));
      expect(stringEntry.value, equals('localhost'));

      // Test integer values
      final intEntry = Client.clientPort.toMapEntry(8080);
      expect(intEntry.key, equals('client.port'));
      expect(intEntry.value, equals(8080));

      // Test boolean values
      final boolEntry = Service.serviceName.toMapEntry(true);
      expect(boolEntry.key, equals('service.name'));
      expect(boolEntry.value, equals(true));

      // Test double values
      final doubleEntry = ProcessResource.processPid.toMapEntry(123.45);
      expect(doubleEntry.key, equals('process.pid'));
      expect(doubleEntry.value, equals(123.45));

      // Test list values
      final listEntry = Database.dbSystem.toMapEntry(['mysql', 'postgres']);
      expect(listEntry.key, equals('db.system'));
      expect(listEntry.value, equals(['mysql', 'postgres']));

      // Test map values
      final mapEntry =
          Http.httpRoute.toMapEntry({'path': '/api/v1', 'method': 'GET'});
      expect(mapEntry.key, equals('http.route'));
      expect(mapEntry.value, equals({'path': '/api/v1', 'method': 'GET'}));
    });

    tearDown(() {
      // Restore the original factory
      OTelFactory.otelFactory = originalFactory;
    });

    // Test the base extension
    test('OTelSemanticExtension toMapEntry', () {
      for (final resource in Client.values) {
        final value = 'test-value-${resource.name}';
        final mapEntry = resource.toMapEntry(value);
        expect(mapEntry.key, equals(resource.key));
        expect(mapEntry.value, equals(value));
      }

      // Test with different value types
      final intValue = 42;
      expect(Client.clientPort.toMapEntry(intValue).value, equals(intValue));

      final boolValue = true;
      expect(
          Client.clientAddress.toMapEntry(boolValue).value, equals(boolValue));

      final listValue = [1, 2, 3];
      expect(
          Client.clientAddress.toMapEntry(listValue).value, equals(listValue));
    });

    // Test each enum value's toString and key property
    test('Client toString and key', () {
      for (final value in Client.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(Client.clientAddress.key, equals('client.address'));
      expect(Client.clientPort.key, equals('client.port'));
    });

    test('Cloud toString and key', () {
      for (final value in Cloud.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(Cloud.cloudProvider.key, equals('cloud.provider'));
      expect(Cloud.cloudAccountId.key, equals('cloud.account.id'));
      expect(Cloud.cloudRegion.key, equals('cloud.region'));
      expect(
          Cloud.cloudAvailabilityZone.key, equals('cloud.availability_zone'));
      expect(Cloud.cloudPlatform.key, equals('cloud.platform'));
    });

    test('ComputeUnit toString and key', () {
      for (final value in ComputeUnit.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(ComputeUnit.containerName.key, equals('container.name'));
      expect(ComputeUnit.containerId.key, equals('container.id'));
      expect(ComputeUnit.containerRuntime.key, equals('container.runtime'));
      expect(
          ComputeUnit.containerImageName.key, equals('container.image.name'));
      expect(ComputeUnit.containerImageTag.key, equals('container.image.tag'));
    });

    test('ComputeInstance toString and key', () {
      for (final value in ComputeInstance.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(ComputeInstance.hostId.key, equals('host.id'));
      expect(ComputeInstance.hostName.key, equals('host.name'));
      expect(ComputeInstance.hostType.key, equals('host.type'));
      expect(ComputeInstance.hostImageName.key, equals('host.image.name'));
      expect(ComputeInstance.hostImageId.key, equals('host.image.id'));
      expect(
          ComputeInstance.hostImageVersion.key, equals('host.image.version'));
    });

    test('Database toString and key', () {
      for (final value in Database.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(Database.dbSystem.key, equals('db.system'));
      expect(Database.dbConnectionString.key, equals('db.connection_string'));
      expect(Database.dbUser.key, equals('db.user'));
      expect(Database.dbName.key, equals('db.name'));
      expect(Database.dbStatement.key, equals('db.statement'));
      expect(Database.dbOperation.key, equals('db.operation'));
    });

    test('Deployment toString and key', () {
      for (final value in Deployment.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(Deployment.deploymentId.key, equals('deployment.id'));
      expect(Deployment.deploymentName.key, equals('deployment.name'));
      expect(Deployment.deploymentEnvironmentName.key,
          equals('deployment.environment.name'));
    });

    test('Device toString and key', () {
      for (final value in Device.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(Device.deviceId.key, equals('device.id'));
      expect(
          Device.deviceModelIdentifier.key, equals('device.model.identifier'));
      expect(Device.deviceModelName.key, equals('device.model.name'));
      expect(Device.deviceManufacturer.key, equals('device.manufacturer'));
    });

    test('ErrorResource toString and key', () {
      for (final value in ErrorResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(ErrorResource.errorType.key, equals('error.type'));
    });

    test('Environment toString and key', () {
      for (final value in Environment.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(Environment.deploymentEnvironment.key,
          equals('deployment.environment'));
    });

    test('ExceptionResource toString and key', () {
      for (final value in ExceptionResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(ExceptionResource.exceptionType.key, equals('exception.type'));
      expect(
          ExceptionResource.exceptionMessage.key, equals('exception.message'));
      expect(ExceptionResource.exceptionStacktrace.key,
          equals('exception.stacktrace'));
    });

    test('FeatureFlag toString and key', () {
      for (final value in FeatureFlag.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(FeatureFlag.featureFlagKey.key, equals('feature_flag.key'));
      expect(
          FeatureFlag.featureFlagVariant.key, equals('feature_flag.variant'));
      expect(FeatureFlag.featureFlagProviderName.key,
          equals('feature_flag.provider_name'));
      expect(FeatureFlag.featureFlagContextId.key,
          equals('feature_flag.context.id'));
      expect(FeatureFlag.featureFlagEvaluationReason.key,
          equals('feature_flag.evaluation.reason'));
      expect(FeatureFlag.featureFlagEvaluationErrorMessage.key,
          equals('feature_flag.evaluation.error.message'));
      expect(FeatureFlag.featureFlagSetId.key, equals('feature_flag.set.id'));
      expect(
          FeatureFlag.featureFlagVersion.key, equals('feature_flag.version'));
    });

    test('FileResource toString and key', () {
      for (final value in FileResource.values) {
        expect(value.toString(), equals(value.key));
      }
      // Test a subset of keys
      expect(FileResource.filePath.key, equals('file.path'));
      expect(FileResource.fileName.key, equals('file.name'));
      expect(FileResource.fileExtension.key, equals('file.extension'));
      expect(FileResource.fileSize.key, equals('file.size'));
      // Test all the remaining keys
      expect(FileResource.fileCreated.key, equals('file.created'));
      expect(FileResource.fileModified.key, equals('file.modified'));
      expect(FileResource.fileAccessed.key, equals('file.accessed'));
      expect(FileResource.fileChanged.key, equals('file.changed'));
      expect(FileResource.fileOwnerId.key, equals('file.owner.id'));
      expect(FileResource.fileOwnerName.key, equals('file.owner.name'));
      expect(FileResource.fileGroupId.key, equals('file.group.id'));
      expect(FileResource.fileGroupName.key, equals('file.group.name'));
      expect(FileResource.fileMode.key, equals('file.mode'));
      expect(FileResource.fileInode.key, equals('file.inode'));
      expect(FileResource.fileAttributes.key, equals('file.attributes'));
      expect(FileResource.fileSymbolicLinkTargetPath.key,
          equals('file.symbolic_link.target_path'));
      expect(FileResource.fileForkName.key, equals('file.fork_name'));
      expect(FileResource.fileDirectory.key, equals('file.directory'));
    });

    test('GenAI toString and key', () {
      for (final value in GenAI.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(GenAI.genAiOperationName.key, equals('gen_ai.operation.name'));
      expect(GenAI.genAiRequestEncodingFormats.key,
          equals('gen_ai.request.encoding_formats'));
      expect(GenAI.genAiRequestFrequencyPenalty.key,
          equals('gen_ai.request.frequency_penalty'));
      expect(
          GenAI.genAiRequestMaxTokens.key, equals('gen_ai.request.max_tokens'));
      expect(GenAI.genAiRequestModel.key, equals('gen_ai.request.model'));
      expect(GenAI.genAiRequestPresencePenalty.key,
          equals('gen_ai.request.presence_penalty'));
      expect(GenAI.genAiRequestSeed.key, equals('gen_ai.request.seed'));
    });

    test('General toString and key', () {
      for (final value in General.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(General.serviceName.key, equals('service.name'));
      expect(General.serviceVersion.key, equals('service.version'));
      expect(General.telemetrySdkName.key, equals('telemetry.sdk.name'));
      expect(General.telemetrySdkVersion.key, equals('telemetry.sdk.version'));
      expect(
          General.telemetryAutoVersion.key, equals('telemetry.auto.version'));
    });

    test('GraphQL toString and key', () {
      for (final value in GraphQL.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(GraphQL.graphqlDocument.key, equals('graphql.document'));
      expect(
          GraphQL.graphqlOperationName.key, equals('graphql.operation.name'));
      expect(
          GraphQL.graphqlOperationType.key, equals('graphql.operation.type'));
    });

    test('Host toString and key', () {
      for (final value in Host.values) {
        expect(value.toString(), equals(value.key));
      }
      // Test a subset of keys
      expect(Host.hostArch.key, equals('host.arch'));
      expect(Host.hostCpuCacheL2Size.key, equals('host.cpu.cache.l2.size'));
      expect(Host.hostCpuFamily.key, equals('host.cpu.family'));
      // Test all the remaining keys
      expect(Host.hostCpuModelId.key, equals('host.cpu.model.id'));
      expect(Host.hostCpuModelName.key, equals('host.cpu.model.name'));
      expect(Host.hostCpuStepping.key, equals('host.cpu.stepping'));
      expect(Host.hostCpuVendorId.key, equals('host.cpu.vendor.id'));
      expect(Host.hostId.key, equals('host.id'));
      expect(Host.hostImageId.key, equals('host.image.id'));
      expect(Host.hostImageName.key, equals('host.image.name'));
      expect(Host.hostImageVersion.key, equals('host.image.version'));
      expect(Host.hostName.key, equals('host.name'));
      expect(Host.hostType.key, equals('host.type'));
      expect(Host.hostMac.key, equals('host.mac'));
      expect(Host.hostIp.key, equals('host.ip'));
    });

    test('Http toString and key', () {
      for (final value in Http.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(Http.httpConnectionState.key, equals('http.connection.state'));
      expect(Http.requestMethod.key, equals('http.request.method'));
      expect(Http.requestMethodOriginal.key,
          equals('http.request.method_original'));
      expect(Http.requestResendCount.key, equals('http.request.resend_count'));
      expect(Http.responseStatusCode.key, equals('http.response.status_code'));
      expect(Http.httpRoute.key, equals('http.route'));
      expect(Http.connectionState.key, equals('http.connection.state'));
      expect(Http.requestSize.key, equals('http.request.size'));
      expect(Http.requestBodySize.key, equals('http.request.body.size'));
      expect(Http.responseSize.key, equals('http.response.size'));
      expect(Http.responseBodySize.key, equals('http.response.body.size'));
    });

    test('HttpHeaderAttribute constructors', () {
      // Test lowercase header names
      final requestHeader = HttpHeaderAttribute.request('content-type');
      expect(requestHeader.key, equals('http.request.header.content-type'));

      final responseHeader = HttpHeaderAttribute.response('content-type');
      expect(responseHeader.key, equals('http.response.header.content-type'));

      // Test uppercase header names
      final upperCaseHeader = HttpHeaderAttribute.request('Content-Type');
      expect(upperCaseHeader.key, equals('http.request.header.content-type'));

      // Test mixed case header names
      final mixedCaseHeader = HttpHeaderAttribute.response('Content-Length');
      expect(
          mixedCaseHeader.key, equals('http.response.header.content-length'));

      // Test with special characters
      final specialHeader = HttpHeaderAttribute.request('x-correlation-id');
      expect(specialHeader.key, equals('http.request.header.x-correlation-id'));

      // Test with empty string
      final emptyHeader = HttpHeaderAttribute.request('');
      expect(emptyHeader.key, equals('http.request.header.'));

      // Test with spaces
      final spaceHeader = HttpHeaderAttribute.response('cache control');
      expect(spaceHeader.key, equals('http.response.header.cache control'));

      // Test with numbers
      final numericHeader = HttpHeaderAttribute.request('x-rate-limit-123');
      expect(numericHeader.key, equals('http.request.header.x-rate-limit-123'));

      // Test with symbols
      final symbolHeader = HttpHeaderAttribute.response('x-api-key+version');
      expect(
          symbolHeader.key, equals('http.response.header.x-api-key+version'));

      // Test unicode characters
      final unicodeHeader = HttpHeaderAttribute.request('x-language-código');
      expect(
          unicodeHeader.key, equals('http.request.header.x-language-código'));
    });

    test('Kubernetes toString and key', () {
      for (final value in Kubernetes.values) {
        expect(value.toString(), equals(value.key));
      }
      // Test a subset of keys
      expect(Kubernetes.k8sClusterName.key, equals('k8s.cluster.name'));
      expect(Kubernetes.k8sPodName.key, equals('k8s.pod.name'));
      expect(Kubernetes.k8sPodUid.key, equals('k8s.pod.uid'));
      // Test all remaining keys
      expect(
          Kubernetes.k8sResourcepaceName.key, equals('k8s.Resourcepace.name'));
      expect(Kubernetes.k8sContainerName.key, equals('k8s.container.name'));
      expect(Kubernetes.k8sReplicaSetUid.key, equals('k8s.replicaset.uid'));
      expect(Kubernetes.k8sReplicaSetName.key, equals('k8s.replicaset.name'));
      expect(Kubernetes.k8sDeploymentUid.key, equals('k8s.deployment.uid'));
      expect(Kubernetes.k8sDeploymentName.key, equals('k8s.deployment.name'));
      expect(Kubernetes.k8sStatefulSetUid.key, equals('k8s.statefulset.uid'));
      expect(Kubernetes.k8sStatefulSetName.key, equals('k8s.statefulset.name'));
      expect(Kubernetes.k8sDaemonSetUid.key, equals('k8s.daemonset.uid'));
      expect(Kubernetes.k8sDaemonSetName.key, equals('k8s.daemonset.name'));
      expect(Kubernetes.k8sJobUid.key, equals('k8s.job.uid'));
      expect(Kubernetes.k8sJobName.key, equals('k8s.job.name'));
      expect(Kubernetes.k8sCronJobUid.key, equals('k8s.cronjob.uid'));
      expect(Kubernetes.k8sCronJobName.key, equals('k8s.cronjob.name'));
    });

    test('Messaging toString and key', () {
      for (final value in Messaging.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(Messaging.messagingSystem.key, equals('messaging.system'));
      expect(
          Messaging.messagingDestination.key, equals('messaging.destination'));
      expect(Messaging.messagingDestinationKind.key,
          equals('messaging.destination_kind'));
      expect(Messaging.messagingTempDestination.key,
          equals('messaging.temp_destination'));
      expect(Messaging.messagingProtocol.key, equals('messaging.protocol'));
      expect(Messaging.messagingProtocolVersion.key,
          equals('messaging.protocol_version'));
    });

    test('Network toString and key', () {
      for (final value in Network.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(Network.networkType.key, equals('network.type'));
      expect(Network.networkCarrierName.key, equals('network.carrier.name'));
      expect(Network.networkCarrierMcc.key, equals('network.carrier.mcc'));
      expect(Network.networkCarrierMnc.key, equals('network.carrier.mnc'));
      expect(Network.networkCarrierIcc.key, equals('network.carrier.icc'));
    });

    test('OperatingSystem toString and key', () {
      for (final value in OperatingSystem.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(OperatingSystem.osType.key, equals('os.type'));
      expect(OperatingSystem.osDescription.key, equals('os.description'));
      expect(OperatingSystem.osName.key, equals('os.name'));
      expect(OperatingSystem.osVersion.key, equals('os.version'));
    });

    test('ProcessResource toString and key', () {
      for (final value in ProcessResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(ProcessResource.processPid.key, equals('process.pid'));
      expect(ProcessResource.processExecutableName.key,
          equals('process.executable.name'));
      expect(ProcessResource.processExecutablePath.key,
          equals('process.executable.path'));
      expect(ProcessResource.processCommand.key, equals('process.command'));
      expect(ProcessResource.processCommandLine.key,
          equals('process.command_line'));
      expect(ProcessResource.processOwner.key, equals('process.owner'));
      expect(ProcessResource.processRuntimeName.key,
          equals('process.runtime.name'));
      expect(ProcessResource.processRuntimeVersion.key,
          equals('process.runtime.version'));
      expect(ProcessResource.processRuntimeDescription.key,
          equals('process.runtime.description'));
    });

    test('RPC toString and key', () {
      for (final value in RPC.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(RPC.rpcSystem.key, equals('rpc.system'));
      expect(RPC.rpcService.key, equals('rpc.service'));
      expect(RPC.rpcMethod.key, equals('rpc.method'));
    });

    test('Service toString and key', () {
      for (final value in Service.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(Service.serviceName.key, equals('service.name'));
      expect(Service.serviceInstanceId.key, equals('service.instance.id'));
      expect(Service.serviceVersion.key, equals('service.version'));
    });

    test('Service exposes service.namespace per OTel semconv', () {
      // A find/replace of "Name" → "Resource" once mangled the
      // `serviceNamespace('service.namespace')` entry into
      // `serviceResourcepace('service.Resourcepace')`. This test asserts
      // the spec-correct key is present, looking up via the enum's
      // values list so it compiles against any name the entry happens
      // to have.
      final allKeys = Service.values.map((e) => e.key).toList();
      expect(
        allKeys,
        contains('service.namespace'),
        reason: 'Service must expose the OTel-spec key `service.namespace`. '
            'Found keys: $allKeys',
      );
    });

    test('SourceCode toString and key', () {
      for (final value in SourceCode.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(SourceCode.codeFunctionName.key, equals('code.function.name'));
      expect(SourceCode.codeResourcepace.key, equals('code.Resourcepace'));
      expect(SourceCode.codeFilePath.key, equals('code.file.path'));
      expect(SourceCode.codeLineNumber.key, equals('code.line.number'));
      expect(SourceCode.codeColumnNumber.key, equals('code.column.number'));
      expect(SourceCode.codeStacktrace.key, equals('code.stacktrace'));
    });

    test('TelemetryDistro toString and key', () {
      for (final value in TelemetryDistro.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(TelemetryDistro.distroName.key, equals('telemetry.distro.name'));
      expect(TelemetryDistro.distroVersion.key,
          equals('telemetry.distro.version'));
    });

    test('TelemetrySDK toString and key', () {
      for (final value in TelemetrySDK.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(TelemetrySDK.sdkName.key, equals('telemetry.sdk.name'));
      expect(TelemetrySDK.sdkLanguage.key, equals('telemetry.sdk.language'));
      expect(TelemetrySDK.sdkVersion.key, equals('telemetry.sdk.version'));
    });

    test('Version toString and key', () {
      for (final value in Version.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(Version.schemaUrl.key, equals('schema.url'));
    });

    test('Use OTelSemantics with attributesFromSemanticMap', () {
      // Test with a variety of semantic enum types
      final attrs = OTelAPI.attributesFromSemanticMap({
        Client.clientAddress: '127.0.0.1',
        Client.clientPort: '8080',
        Service.serviceName: 'test-service',
        Http.requestMethod: 'GET',
        Database.dbSystem: 'sqlite',
        SourceCode.codeFunctionName: 'main',
        FileResource.filePath: '/path/to/file.txt',
        Network.networkType: 'wifi'
      });

      expect(attrs.getString('client.address'), equals('127.0.0.1'));
      expect(attrs.getString('client.port'), equals('8080'));
      expect(attrs.getString('service.name'), equals('test-service'));
      expect(attrs.getString('http.request.method'), equals('GET'));
      expect(attrs.getString('db.system'), equals('sqlite'));
      expect(attrs.getString('code.function.name'), equals('main'));
      expect(attrs.getString('file.path'), equals('/path/to/file.txt'));
      expect(attrs.getString('network.type'), equals('wifi'));
    });

    test('Complete coverage for FileResource', () {
      // Test all FileResource values
      for (final value in FileResource.values) {
        expect(value.toString(), equals(value.key));
        // Use toMapEntry for each value
        final mapEntry = value.toMapEntry('test-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('test-value'));
      }
    });

    test('Complete coverage for GenAI', () {
      // Test constructor and toString for GenAI
      for (final value in GenAI.values) {
        expect(value.toString(), equals(value.key));
        // Verify the key property
        expect(value.key, contains('gen_ai'));
        // Use toMapEntry
        final mapEntry = value.toMapEntry('ai-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('ai-value'));
      }
    });

    test('Complete coverage for Host', () {
      // Test constructor and toString for Host
      for (final value in Host.values) {
        expect(value.toString(), equals(value.key));
        // Verify the key property
        expect(value.key, contains('host'));
        // Use toMapEntry with different value types
        if (value == Host.hostCpuCacheL2Size) {
          final mapEntry = value.toMapEntry(1024);
          expect(mapEntry.key, equals(value.key));
          expect(mapEntry.value, equals(1024));
        } else {
          final mapEntry = value.toMapEntry('host-value');
          expect(mapEntry.key, equals(value.key));
          expect(mapEntry.value, equals('host-value'));
        }
      }
    });

    test('Complete coverage for Http', () {
      // Test constructor and toString for Http
      for (final value in Http.values) {
        expect(value.toString(), equals(value.key));
        // Verify the key property
        expect(value.key, contains('http'));
        // Use toMapEntry with appropriate value types
        if (value == Http.responseStatusCode) {
          final mapEntry = value.toMapEntry(200);
          expect(mapEntry.key, equals(value.key));
          expect(mapEntry.value, equals(200));
        } else if (value == Http.requestSize ||
            value == Http.requestBodySize ||
            value == Http.responseSize ||
            value == Http.responseBodySize) {
          final mapEntry = value.toMapEntry(1024);
          expect(mapEntry.key, equals(value.key));
          expect(mapEntry.value, equals(1024));
        } else {
          final mapEntry = value.toMapEntry('http-value');
          expect(mapEntry.key, equals(value.key));
          expect(mapEntry.value, equals('http-value'));
        }
      }
    });

    test('Complete coverage for all remaining resource enums', () {
      // Test Kubernetes
      for (final value in Kubernetes.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('k8s-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('k8s-value'));
      }

      // Test Messaging
      for (final value in Messaging.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('messaging-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('messaging-value'));
      }

      // Test Network
      for (final value in Network.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('network-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('network-value'));
      }

      // Test OperatingSystem
      for (final value in OperatingSystem.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('os-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('os-value'));
      }

      // Test ProcessResource
      for (final value in ProcessResource.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('process-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('process-value'));
      }

      // Test RPC
      for (final value in RPC.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('rpc-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('rpc-value'));
      }

      // Test Service
      for (final value in Service.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('service-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('service-value'));
      }

      // Test SourceCode
      for (final value in SourceCode.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('code-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('code-value'));
      }

      // Test TelemetryDistro
      for (final value in TelemetryDistro.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('distro-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('distro-value'));
      }

      // Test TelemetrySDK
      for (final value in TelemetrySDK.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('sdk-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('sdk-value'));
      }

      // Test Version
      for (final value in Version.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('version-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('version-value'));
      }
    });
  });
}
