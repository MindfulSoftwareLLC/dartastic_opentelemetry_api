// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

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
        HttpResource.requestMethod.key: 'POST'
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
        HttpResource.responseStatusCode.key: '200'
      });

      expect(responseAttrs.getString('http.response.header.content-type'),
          equals('application/json'));
      expect(
          responseAttrs.getString('http.response.status_code'), equals('200'));
    });

    // Test the base extension
    test('OTelSemanticExtension with different value types', () {
      // Test string values
      final stringEntry = ClientResource.clientAddress.toMapEntry('localhost');
      expect(stringEntry.key, equals('client.address'));
      expect(stringEntry.value, equals('localhost'));

      // Test integer values
      final intEntry = ClientResource.clientPort.toMapEntry(8080);
      expect(intEntry.key, equals('client.port'));
      expect(intEntry.value, equals(8080));

      // Test boolean values
      final boolEntry = ServiceResource.serviceName.toMapEntry(true);
      expect(boolEntry.key, equals('service.name'));
      expect(boolEntry.value, equals(true));

      // Test double values
      final doubleEntry = ProcessResource.processPid.toMapEntry(123.45);
      expect(doubleEntry.key, equals('process.pid'));
      expect(doubleEntry.value, equals(123.45));

      // Test list values
      final listEntry =
          DatabaseResource.dbSystem.toMapEntry(['mysql', 'postgres']);
      expect(listEntry.key, equals('db.system'));
      expect(listEntry.value, equals(['mysql', 'postgres']));

      // Test map values
      final mapEntry = HttpResource.httpRoute
          .toMapEntry({'path': '/api/v1', 'method': 'GET'});
      expect(mapEntry.key, equals('http.route'));
      expect(mapEntry.value, equals({'path': '/api/v1', 'method': 'GET'}));
    });

    tearDown(() {
      // Restore the original factory
      OTelFactory.otelFactory = originalFactory;
    });

    // Test the base extension
    test('OTelSemanticExtension toMapEntry', () {
      for (final resource in ClientResource.values) {
        final value = 'test-value-${resource.name}';
        final mapEntry = resource.toMapEntry(value);
        expect(mapEntry.key, equals(resource.key));
        expect(mapEntry.value, equals(value));
      }

      // Test with different value types
      final intValue = 42;
      expect(ClientResource.clientPort.toMapEntry(intValue).value,
          equals(intValue));

      final boolValue = true;
      expect(ClientResource.clientAddress.toMapEntry(boolValue).value,
          equals(boolValue));

      final listValue = [1, 2, 3];
      expect(ClientResource.clientAddress.toMapEntry(listValue).value,
          equals(listValue));
    });

    // Test each enum value's toString and key property
    test('ClientResource toString and key', () {
      for (final value in ClientResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(ClientResource.clientAddress.key, equals('client.address'));
      expect(ClientResource.clientPort.key, equals('client.port'));
    });

    test('CloudResource toString and key', () {
      for (final value in CloudResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(CloudResource.cloudProvider.key, equals('cloud.provider'));
      expect(CloudResource.cloudAccountId.key, equals('cloud.account.id'));
      expect(CloudResource.cloudRegion.key, equals('cloud.region'));
      expect(CloudResource.cloudAvailabilityZone.key,
          equals('cloud.availability_zone'));
      expect(CloudResource.cloudPlatform.key, equals('cloud.platform'));
    });

    test('ComputeUnitResource toString and key', () {
      for (final value in ComputeUnitResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(ComputeUnitResource.containerName.key, equals('container.name'));
      expect(ComputeUnitResource.containerId.key, equals('container.id'));
      expect(ComputeUnitResource.containerRuntime.key,
          equals('container.runtime'));
      expect(ComputeUnitResource.containerImageName.key,
          equals('container.image.name'));
      expect(ComputeUnitResource.containerImageTag.key,
          equals('container.image.tag'));
    });

    test('ComputeInstanceResource toString and key', () {
      for (final value in ComputeInstanceResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(ComputeInstanceResource.hostId.key, equals('host.id'));
      expect(ComputeInstanceResource.hostName.key, equals('host.name'));
      expect(ComputeInstanceResource.hostType.key, equals('host.type'));
      expect(
          ComputeInstanceResource.hostImageName.key, equals('host.image.name'));
      expect(ComputeInstanceResource.hostImageId.key, equals('host.image.id'));
      expect(ComputeInstanceResource.hostImageVersion.key,
          equals('host.image.version'));
    });

    test('DatabaseResource toString and key', () {
      for (final value in DatabaseResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(DatabaseResource.dbSystem.key, equals('db.system'));
      expect(DatabaseResource.dbConnectionString.key,
          equals('db.connection_string'));
      expect(DatabaseResource.dbUser.key, equals('db.user'));
      expect(DatabaseResource.dbName.key, equals('db.name'));
      expect(DatabaseResource.dbStatement.key, equals('db.statement'));
      expect(DatabaseResource.dbOperation.key, equals('db.operation'));
    });

    test('DeploymentResource toString and key', () {
      for (final value in DeploymentResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(DeploymentResource.deploymentId.key, equals('deployment.id'));
      expect(DeploymentResource.deploymentName.key, equals('deployment.name'));
      expect(DeploymentResource.deploymentEnvironmentName.key,
          equals('deployment.environment.name'));
    });

    test('DeviceResource toString and key', () {
      for (final value in DeviceResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(DeviceResource.deviceId.key, equals('device.id'));
      expect(DeviceResource.deviceModelIdentifier.key,
          equals('device.model.identifier'));
      expect(DeviceResource.deviceModelName.key, equals('device.model.name'));
      expect(
          DeviceResource.deviceManufacturer.key, equals('device.manufacturer'));
    });

    test('ErrorResource toString and key', () {
      for (final value in ErrorResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(ErrorResource.errorType.key, equals('error.type'));
    });

    test('EnvironmentResource toString and key', () {
      for (final value in EnvironmentResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(EnvironmentResource.deploymentEnvironment.key,
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

    test('FeatureFlagResource toString and key', () {
      for (final value in FeatureFlagResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(
          FeatureFlagResource.featureFlagKey.key, equals('feature_flag.key'));
      expect(FeatureFlagResource.featureFlagVariant.key,
          equals('feature_flag.variant'));
      expect(FeatureFlagResource.featureFlagProviderName.key,
          equals('feature_flag.provider_name'));
      expect(FeatureFlagResource.featureFlagContextId.key,
          equals('feature_flag.context.id'));
      expect(FeatureFlagResource.featureFlagEvaluationReason.key,
          equals('feature_flag.evaluation.reason'));
      expect(FeatureFlagResource.featureFlagEvaluationErrorMessage.key,
          equals('feature_flag.evaluation.error.message'));
      expect(FeatureFlagResource.featureFlagSetId.key,
          equals('feature_flag.set.id'));
      expect(FeatureFlagResource.featureFlagVersion.key,
          equals('feature_flag.version'));
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

    test('GenAIResource toString and key', () {
      for (final value in GenAIResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(GenAIResource.genAiOperationName.key,
          equals('gen_ai.operation.name'));
      expect(GenAIResource.genAiRequestEncodingFormats.key,
          equals('gen_ai.request.encoding_formats'));
      expect(GenAIResource.genAiRequestFrequencyPenalty.key,
          equals('gen_ai.request.frequency_penalty'));
      expect(GenAIResource.genAiRequestMaxTokens.key,
          equals('gen_ai.request.max_tokens'));
      expect(
          GenAIResource.genAiRequestModel.key, equals('gen_ai.request.model'));
      expect(GenAIResource.genAiRequestPresencePenalty.key,
          equals('gen_ai.request.presence_penalty'));
      expect(GenAIResource.genAiRequestSeed.key, equals('gen_ai.request.seed'));
    });

    test('GeneralResourceResource toString and key', () {
      for (final value in GeneralResourceResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(GeneralResourceResource.serviceName.key, equals('service.name'));
      expect(GeneralResourceResource.serviceVersion.key,
          equals('service.version'));
      expect(GeneralResourceResource.telemetrySdkName.key,
          equals('telemetry.sdk.name'));
      expect(GeneralResourceResource.telemetrySdkVersion.key,
          equals('telemetry.sdk.version'));
      expect(GeneralResourceResource.telemetryAutoVersion.key,
          equals('telemetry.auto.version'));
    });

    test('GraphQLResource toString and key', () {
      for (final value in GraphQLResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(GraphQLResource.graphqlDocument.key, equals('graphql.document'));
      expect(GraphQLResource.graphqlOperationName.key,
          equals('graphql.operation.name'));
      expect(GraphQLResource.graphqlOperationType.key,
          equals('graphql.operation.type'));
    });

    test('HostResource toString and key', () {
      for (final value in HostResource.values) {
        expect(value.toString(), equals(value.key));
      }
      // Test a subset of keys
      expect(HostResource.hostArch.key, equals('host.arch'));
      expect(HostResource.hostCpuCacheL2Size.key,
          equals('host.cpu.cache.l2.size'));
      expect(HostResource.hostCpuFamily.key, equals('host.cpu.family'));
      // Test all the remaining keys
      expect(HostResource.hostCpuModelId.key, equals('host.cpu.model.id'));
      expect(HostResource.hostCpuModelName.key, equals('host.cpu.model.name'));
      expect(HostResource.hostCpuStepping.key, equals('host.cpu.stepping'));
      expect(HostResource.hostCpuVendorId.key, equals('host.cpu.vendor.id'));
      expect(HostResource.hostId.key, equals('host.id'));
      expect(HostResource.hostImageId.key, equals('host.image.id'));
      expect(HostResource.hostImageName.key, equals('host.image.name'));
      expect(HostResource.hostImageVersion.key, equals('host.image.version'));
      expect(HostResource.hostName.key, equals('host.name'));
      expect(HostResource.hostType.key, equals('host.type'));
      expect(HostResource.hostMac.key, equals('host.mac'));
      expect(HostResource.hostIp.key, equals('host.ip'));
    });

    test('HttpResource toString and key', () {
      for (final value in HttpResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(HttpResource.httpConnectionState.key,
          equals('http.connection.state'));
      expect(HttpResource.requestMethod.key, equals('http.request.method'));
      expect(HttpResource.requestMethodOriginal.key,
          equals('http.request.method_original'));
      expect(HttpResource.requestResendCount.key,
          equals('http.request.resend_count'));
      expect(HttpResource.responseStatusCode.key,
          equals('http.response.status_code'));
      expect(HttpResource.httpRoute.key, equals('http.route'));
      expect(HttpResource.connectionState.key, equals('http.connection.state'));
      expect(HttpResource.requestSize.key, equals('http.request.size'));
      expect(
          HttpResource.requestBodySize.key, equals('http.request.body.size'));
      expect(HttpResource.responseSize.key, equals('http.response.size'));
      expect(
          HttpResource.responseBodySize.key, equals('http.response.body.size'));
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

    test('KubernetesResource toString and key', () {
      for (final value in KubernetesResource.values) {
        expect(value.toString(), equals(value.key));
      }
      // Test a subset of keys
      expect(KubernetesResource.k8sClusterName.key, equals('k8s.cluster.name'));
      expect(KubernetesResource.k8sPodName.key, equals('k8s.pod.name'));
      expect(KubernetesResource.k8sPodUid.key, equals('k8s.pod.uid'));
      // Test all remaining keys
      expect(KubernetesResource.k8sResourcepaceName.key,
          equals('k8s.Resourcepace.name'));
      expect(KubernetesResource.k8sContainerName.key,
          equals('k8s.container.name'));
      expect(KubernetesResource.k8sReplicaSetUid.key,
          equals('k8s.replicaset.uid'));
      expect(KubernetesResource.k8sReplicaSetName.key,
          equals('k8s.replicaset.name'));
      expect(KubernetesResource.k8sDeploymentUid.key,
          equals('k8s.deployment.uid'));
      expect(KubernetesResource.k8sDeploymentName.key,
          equals('k8s.deployment.name'));
      expect(KubernetesResource.k8sStatefulSetUid.key,
          equals('k8s.statefulset.uid'));
      expect(KubernetesResource.k8sStatefulSetName.key,
          equals('k8s.statefulset.name'));
      expect(
          KubernetesResource.k8sDaemonSetUid.key, equals('k8s.daemonset.uid'));
      expect(KubernetesResource.k8sDaemonSetName.key,
          equals('k8s.daemonset.name'));
      expect(KubernetesResource.k8sJobUid.key, equals('k8s.job.uid'));
      expect(KubernetesResource.k8sJobName.key, equals('k8s.job.name'));
      expect(KubernetesResource.k8sCronJobUid.key, equals('k8s.cronjob.uid'));
      expect(KubernetesResource.k8sCronJobName.key, equals('k8s.cronjob.name'));
    });

    test('MessagingResource toString and key', () {
      for (final value in MessagingResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(MessagingResource.messagingSystem.key, equals('messaging.system'));
      expect(MessagingResource.messagingDestination.key,
          equals('messaging.destination'));
      expect(MessagingResource.messagingDestinationKind.key,
          equals('messaging.destination_kind'));
      expect(MessagingResource.messagingTempDestination.key,
          equals('messaging.temp_destination'));
      expect(MessagingResource.messagingProtocol.key,
          equals('messaging.protocol'));
      expect(MessagingResource.messagingProtocolVersion.key,
          equals('messaging.protocol_version'));
    });

    test('NetworkResource toString and key', () {
      for (final value in NetworkResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(NetworkResource.networkType.key, equals('network.type'));
      expect(NetworkResource.networkCarrierName.key,
          equals('network.carrier.name'));
      expect(
          NetworkResource.networkCarrierMcc.key, equals('network.carrier.mcc'));
      expect(
          NetworkResource.networkCarrierMnc.key, equals('network.carrier.mnc'));
      expect(
          NetworkResource.networkCarrierIcc.key, equals('network.carrier.icc'));
    });

    test('OperatingSystemResource toString and key', () {
      for (final value in OperatingSystemResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(OperatingSystemResource.osType.key, equals('os.type'));
      expect(
          OperatingSystemResource.osDescription.key, equals('os.description'));
      expect(OperatingSystemResource.osName.key, equals('os.name'));
      expect(OperatingSystemResource.osVersion.key, equals('os.version'));
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

    test('RPCResource toString and key', () {
      for (final value in RPCResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(RPCResource.rpcSystem.key, equals('rpc.system'));
      expect(RPCResource.rpcService.key, equals('rpc.service'));
      expect(RPCResource.rpcMethod.key, equals('rpc.method'));
    });

    test('ServiceResource toString and key', () {
      for (final value in ServiceResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(ServiceResource.serviceName.key, equals('service.name'));
      expect(ServiceResource.serviceResourcepace.key,
          equals('service.Resourcepace'));
      expect(
          ServiceResource.serviceInstanceId.key, equals('service.instance.id'));
      expect(ServiceResource.serviceVersion.key, equals('service.version'));
    });

    test('SourceCodeResource toString and key', () {
      for (final value in SourceCodeResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(SourceCodeResource.codeFunctionName.key,
          equals('code.function.name'));
      expect(
          SourceCodeResource.codeResourcepace.key, equals('code.Resourcepace'));
      expect(SourceCodeResource.codeFilePath.key, equals('code.file.path'));
      expect(SourceCodeResource.codeLineNumber.key, equals('code.line.number'));
      expect(SourceCodeResource.codeColumnNumber.key,
          equals('code.column.number'));
      expect(SourceCodeResource.codeStacktrace.key, equals('code.stacktrace'));
    });

    test('TelemetryDistroResource toString and key', () {
      for (final value in TelemetryDistroResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(TelemetryDistroResource.distroName.key,
          equals('telemetry.distro.name'));
      expect(TelemetryDistroResource.distroVersion.key,
          equals('telemetry.distro.version'));
    });

    test('TelemetrySDKResource toString and key', () {
      for (final value in TelemetrySDKResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(TelemetrySDKResource.sdkName.key, equals('telemetry.sdk.name'));
      expect(TelemetrySDKResource.sdkLanguage.key,
          equals('telemetry.sdk.language'));
      expect(
          TelemetrySDKResource.sdkVersion.key, equals('telemetry.sdk.version'));
    });

    test('VersionResource toString and key', () {
      for (final value in VersionResource.values) {
        expect(value.toString(), equals(value.key));
      }
      expect(VersionResource.schemaUrl.key, equals('schema.url'));
    });

    test('Use OTelSemantics with attributesFromSemanticMap', () {
      // Test with a variety of semantic enum types
      final attrs = OTelAPI.attributesFromSemanticMap({
        ClientResource.clientAddress: '127.0.0.1',
        ClientResource.clientPort: '8080',
        ServiceResource.serviceName: 'test-service',
        HttpResource.requestMethod: 'GET',
        DatabaseResource.dbSystem: 'sqlite',
        SourceCodeResource.codeFunctionName: 'main',
        FileResource.filePath: '/path/to/file.txt',
        NetworkResource.networkType: 'wifi'
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

    test('Complete coverage for GenAIResource', () {
      // Test constructor and toString for GenAIResource
      for (final value in GenAIResource.values) {
        expect(value.toString(), equals(value.key));
        // Verify the key property
        expect(value.key, contains('gen_ai'));
        // Use toMapEntry
        final mapEntry = value.toMapEntry('ai-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('ai-value'));
      }
    });

    test('Complete coverage for HostResource', () {
      // Test constructor and toString for HostResource
      for (final value in HostResource.values) {
        expect(value.toString(), equals(value.key));
        // Verify the key property
        expect(value.key, contains('host'));
        // Use toMapEntry with different value types
        if (value == HostResource.hostCpuCacheL2Size) {
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

    test('Complete coverage for HttpResource', () {
      // Test constructor and toString for HttpResource
      for (final value in HttpResource.values) {
        expect(value.toString(), equals(value.key));
        // Verify the key property
        expect(value.key, contains('http'));
        // Use toMapEntry with appropriate value types
        if (value == HttpResource.responseStatusCode) {
          final mapEntry = value.toMapEntry(200);
          expect(mapEntry.key, equals(value.key));
          expect(mapEntry.value, equals(200));
        } else if (value == HttpResource.requestSize ||
            value == HttpResource.requestBodySize ||
            value == HttpResource.responseSize ||
            value == HttpResource.responseBodySize) {
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
      // Test KubernetesResource
      for (final value in KubernetesResource.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('k8s-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('k8s-value'));
      }

      // Test MessagingResource
      for (final value in MessagingResource.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('messaging-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('messaging-value'));
      }

      // Test NetworkResource
      for (final value in NetworkResource.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('network-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('network-value'));
      }

      // Test OperatingSystemResource
      for (final value in OperatingSystemResource.values) {
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

      // Test RPCResource
      for (final value in RPCResource.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('rpc-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('rpc-value'));
      }

      // Test ServiceResource
      for (final value in ServiceResource.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('service-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('service-value'));
      }

      // Test SourceCodeResource
      for (final value in SourceCodeResource.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('code-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('code-value'));
      }

      // Test TelemetryDistroResource
      for (final value in TelemetryDistroResource.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('distro-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('distro-value'));
      }

      // Test TelemetrySDKResource
      for (final value in TelemetrySDKResource.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('sdk-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('sdk-value'));
      }

      // Test VersionResource
      for (final value in VersionResource.values) {
        expect(value.toString(), equals(value.key));
        final mapEntry = value.toMapEntry('version-value');
        expect(mapEntry.key, equals(value.key));
        expect(mapEntry.value, equals('version-value'));
      }
    });
  });
}
