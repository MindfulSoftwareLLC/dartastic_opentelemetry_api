// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// ignore_for_file: public_member_api_docs

/// OpenTelemetry Semantic Conventions - Dart Enums
library;

import 'package:dartastic_opentelemetry_api/src/api/semantics/semantics.dart';

/// Extension on OTelSemantic to provide utility methods.
extension OTelSemanticExtension on OTelSemantic {
  /// Converts this semantic attribute and its value to a MapEntry.
  ///
  /// This allows semantic attributes to be easily used with Dart's Map API.
  ///
  /// [value] The value to associate with this semantic attribute's key.
  /// Returns a MapEntry with this semantic's key and the provided value.
  MapEntry<String, Object> toMapEntry(Object value) => MapEntry(key, value);
}

// Client Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/client/)
enum ClientResource implements OTelSemantic {
  clientAddress("client.address"),
  clientPort("client.port");

  @override
  final String key;

  @override
  String toString() => key;

  const ClientResource(this.key);
}

// Cloud Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#cloud-provider)
enum CloudResource implements OTelSemantic {
  cloudProvider("cloud.provider"),
  cloudAccountId("cloud.account.id"),
  cloudRegion("cloud.region"),
  cloudAvailabilityZone("cloud.availability_zone"),
  cloudPlatform("cloud.platform");

  @override
  final String key;

  @override
  String toString() => key;

  const CloudResource(this.key);
}

// Compute Unit Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#compute-unit)
enum ComputeUnitResource implements OTelSemantic {
  containerName("container.name"),
  containerId("container.id"),
  containerRuntime("container.runtime"),
  containerImageName("container.image.name"),
  containerImageTag("container.image.tag");

  @override
  final String key;

  @override
  String toString() => key;

  const ComputeUnitResource(this.key);
}

// Compute Instance Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#compute-instance)
enum ComputeInstanceResource implements OTelSemantic {
  hostId("host.id"),
  hostName("host.name"),
  hostType("host.type"),
  hostImageName("host.image.name"),
  hostImageId("host.image.id"),
  hostImageVersion("host.image.version");

  @override
  final String key;

  @override
  String toString() => key;

  const ComputeInstanceResource(this.key);
}

enum DatabaseResource implements OTelSemantic {
  dbSystem("db.system"),
  dbConnectionString("db.connection_string"),
  dbUser("db.user"),
  dbName("db.name"),
  dbStatement("db.statement"),
  dbOperation("db.operation");

  @override
  final String key;

  @override
  String toString() => key;

  const DatabaseResource(this.key);
}

// Deployment Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#deployment)
enum DeploymentResource implements OTelSemantic {
  deploymentId("deployment.id"),
  deploymentName("deployment.name"),
  deploymentEnvironmentName("deployment.environment.name");

  @override
  final String key;

  @override
  String toString() => key;

  const DeploymentResource(this.key);
}

// Device Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#device)
enum DeviceResource implements OTelSemantic {
  deviceId("device.id"),
  deviceModelIdentifier("device.model.identifier"),
  deviceModelName("device.model.name"),
  deviceManufacturer("device.manufacturer");

  @override
  final String key;

  @override
  String toString() => key;

  const DeviceResource(this.key);
}

// Error Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/error/)
enum ErrorResource implements OTelSemantic {
  errorType("error.type");

  @override
  final String key;

  @override
  String toString() => key;

  const ErrorResource(this.key);
}

// Environment Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#environment)
enum EnvironmentResource implements OTelSemantic {
  deploymentEnvironment("deployment.environment");

  @override
  final String key;

  @override
  String toString() => key;

  const EnvironmentResource(this.key);
}

enum ExceptionResource implements OTelSemantic {
  exceptionType("exception.type"),
  exceptionMessage("exception.message"),
  exceptionStacktrace("exception.stacktrace");

  @override
  final String key;

  @override
  String toString() => key;

  const ExceptionResource(this.key);
}

/// OpenTelemetry Semantic Conventions - Feature Flag Attributes

// Feature Flag Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/feature-flag/)
enum FeatureFlagResource implements OTelSemantic {
  featureFlagKey("feature_flag.key"),
  featureFlagVariant("feature_flag.variant"),
  featureFlagProviderName("feature_flag.provider_name"),
  featureFlagContextId("feature_flag.context.id"),
  featureFlagEvaluationReason("feature_flag.evaluation.reason"),
  featureFlagEvaluationErrorMessage("feature_flag.evaluation.error.message"),
  featureFlagSetId("feature_flag.set.id"),
  featureFlagVersion("feature_flag.version");

  @override
  final String key;

  @override
  String toString() => key;

  const FeatureFlagResource(this.key);
}

/// OpenTelemetry Semantic Conventions - File Attributes

// File Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/file/)
enum FileResource implements OTelSemantic {
  filePath("file.path"),
  fileName("file.name"),
  fileExtension("file.extension"),
  fileSize("file.size"),
  fileCreated("file.created"),
  fileModified("file.modified"),
  fileAccessed("file.accessed"),
  fileChanged("file.changed"),
  fileOwnerId("file.owner.id"),
  fileOwnerName("file.owner.name"),
  fileGroupId("file.group.id"),
  fileGroupName("file.group.name"),
  fileMode("file.mode"),
  fileInode("file.inode"),
  fileAttributes("file.attributes"),
  fileSymbolicLinkTargetPath("file.symbolic_link.target_path"),
  fileForkName("file.fork_name"),
  fileDirectory("file.directory");

  @override
  final String key;

  @override
  String toString() => key;

  const FileResource(this.key);
}

/// OpenTelemetry Semantic Conventions - GenAI Attributes

// GenAI Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/gen-ai/)
enum GenAIResource implements OTelSemantic {
  genAiOperationName("gen_ai.operation.name"),
  genAiRequestEncodingFormats("gen_ai.request.encoding_formats"),
  genAiRequestFrequencyPenalty("gen_ai.request.frequency_penalty"),
  genAiRequestMaxTokens("gen_ai.request.max_tokens"),
  genAiRequestModel("gen_ai.request.model"),
  genAiRequestPresencePenalty("gen_ai.request.presence_penalty"),
  genAiRequestSeed("gen_ai.request.seed");

  @override
  final String key;

  @override
  String toString() => key;

  const GenAIResource(this.key);
}

enum GeneralResourceResource implements OTelSemantic {
  serviceName("service.name"),
  serviceVersion("service.version"),
  telemetrySdkName("telemetry.sdk.name"),
  telemetrySdkVersion("telemetry.sdk.version"),
  telemetryAutoVersion("telemetry.auto.version");

  @override
  final String key;

  @override
  String toString() => key;

  const GeneralResourceResource(this.key);
}

enum GraphQLResource implements OTelSemantic {
  graphqlDocument("graphql.document"),
  graphqlOperationName("graphql.operation.name"),
  graphqlOperationType("graphql.operation.type");

  @override
  final String key;

  @override
  String toString() => key;

  const GraphQLResource(this.key);
}

/// OpenTelemetry Semantic Conventions - Host Attributes

// Host Semantic Resource (experimental)
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/host/)
enum HostResource implements OTelSemantic {
  hostArch("host.arch"),
  hostCpuCacheL2Size("host.cpu.cache.l2.size"),
  hostCpuFamily("host.cpu.family"),
  hostCpuModelId("host.cpu.model.id"),
  hostCpuModelName("host.cpu.model.name"),
  hostCpuStepping("host.cpu.stepping"),
  hostCpuVendorId("host.cpu.vendor.id"),
  hostId("host.id"),
  hostImageId("host.image.id"),
  hostImageName("host.image.name"),
  hostImageVersion("host.image.version"),
  hostName("host.name"),
  hostType("host.type"),
  hostMac("host.mac"),
  hostIp("host.ip");

  @override
  final String key;

  @override
  String toString() => key;

  const HostResource(this.key);
}

// Enum for standard HTTP attributes
enum HttpResource implements OTelSemantic {
  httpConnectionState('http.connection.state'),
  requestMethod('http.request.method'),
  requestMethodOriginal('http.request.method_original'),
  requestResendCount('http.request.resend_count'),
  responseStatusCode('http.response.status_code'),
  httpRoute('http.route'),
  connectionState('http.connection.state'),
  requestSize('http.request.size'),
  requestBodySize('http.request.body.size'),
  responseSize('http.response.size'),
  responseBodySize('http.response.body.size');

  @override
  final String key;

  @override
  String toString() => key;

  const HttpResource(this.key);
}

/// Enum for HTTP header attributes with dynamic keys
/// Usage:
/// ```
/// String methodKey = HttpAttributes.requestMethod.key;
// ```
// methodKey will be 'http.request.method'
/// Utility class for creating OpenTelemetry HTTP header attribute keys.
///
/// This class provides a way to generate properly formatted HTTP header attribute keys
/// following the OpenTelemetry specification for HTTP headers.
class HttpHeaderAttribute {
  /// The OpenTelemetry attribute key for the HTTP header.
  final String key;

  /// Constructor for HTTP request headers
  /// Example usage: HttpHeaderAttribute.request('content-type')
  HttpHeaderAttribute.request(String headerName)
      : key = 'http.request.header.${headerName.toLowerCase()}';

  /// Constructor for HTTP response headers
  /// Example usage: HttpHeaderAttribute.response('content-type')
  HttpHeaderAttribute.response(String headerName)
      : key = 'http.response.header.${headerName.toLowerCase()}';
}

// Kubernetes Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#kubernetes)
enum KubernetesResource implements OTelSemantic {
  k8sClusterName("k8s.cluster.name"),
  k8sResourcepaceName("k8s.Resourcepace.name"),
  k8sPodName("k8s.pod.name"),
  k8sPodUid("k8s.pod.uid"),
  k8sContainerName("k8s.container.name"),
  k8sReplicaSetUid("k8s.replicaset.uid"),
  k8sReplicaSetName("k8s.replicaset.name"),
  k8sDeploymentUid("k8s.deployment.uid"),
  k8sDeploymentName("k8s.deployment.name"),
  k8sStatefulSetUid("k8s.statefulset.uid"),
  k8sStatefulSetName("k8s.statefulset.name"),
  k8sDaemonSetUid("k8s.daemonset.uid"),
  k8sDaemonSetName("k8s.daemonset.name"),
  k8sJobUid("k8s.job.uid"),
  k8sJobName("k8s.job.name"),
  k8sCronJobUid("k8s.cronjob.uid"),
  k8sCronJobName("k8s.cronjob.name");

  @override
  final String key;

  @override
  String toString() => key;

  const KubernetesResource(this.key);
}

enum MessagingResource implements OTelSemantic {
  messagingSystem("messaging.system"),
  messagingDestination("messaging.destination"),
  messagingDestinationKind("messaging.destination_kind"),
  messagingTempDestination("messaging.temp_destination"),
  messagingProtocol("messaging.protocol"),
  messagingProtocolVersion("messaging.protocol_version");

  @override
  final String key;

  @override
  String toString() => key;

  const MessagingResource(this.key);
}

enum NetworkResource implements OTelSemantic {
  networkType("network.type"),
  networkCarrierName("network.carrier.name"),
  networkCarrierMcc("network.carrier.mcc"),
  networkCarrierMnc("network.carrier.mnc"),
  networkCarrierIcc("network.carrier.icc");

  @override
  final String key;

  @override
  String toString() => key;

  const NetworkResource(this.key);
}

// Operating System Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#operating-system)
enum OperatingSystemResource implements OTelSemantic {
  osType("os.type"),
  osDescription("os.description"),
  osName("os.name"),
  osVersion("os.version");

  @override
  final String key;

  @override
  String toString() => key;

  const OperatingSystemResource(this.key);
}

// Process Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#process)
enum ProcessResource implements OTelSemantic {
  processPid("process.pid"),
  processExecutableName("process.executable.name"),
  processExecutablePath("process.executable.path"),
  processCommand("process.command"),
  processCommandLine("process.command_line"),
  processOwner("process.owner"),
  processRuntimeName("process.runtime.name"),
  processRuntimeVersion("process.runtime.version"),
  processRuntimeDescription("process.runtime.description");

  @override
  final String key;

  @override
  String toString() => key;

  const ProcessResource(this.key);
}

enum RPCResource implements OTelSemantic {
  rpcSystem("rpc.system"),
  rpcService("rpc.service"),
  rpcMethod("rpc.method");

  @override
  final String key;

  @override
  String toString() => key;

  const RPCResource(this.key);
}

// Service Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#service)
enum ServiceResource implements OTelSemantic {
  serviceName("service.name"),
  serviceResourcepace("service.Resourcepace"),
  serviceInstanceId("service.instance.id"),
  serviceVersion("service.version");

  @override
  final String key;

  @override
  String toString() => key;

  const ServiceResource(this.key);
}

// Source Code Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/general/attributes/)
enum SourceCodeResource implements OTelSemantic {
  codeFunctionName("code.function.name"),
  codeResourcepace("code.Resourcepace"),
  codeFilePath("code.file.path"),
  codeLineNumber("code.line.number"),
  codeColumnNumber("code.column.number"),
  codeStacktrace("code.stacktrace");

  @override
  final String key;

  @override
  String toString() => key;

  const SourceCodeResource(this.key);
}

// Telemetry Distro Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#telemetry-distro)
enum TelemetryDistroResource implements OTelSemantic {
  distroName("telemetry.distro.name"),
  distroVersion("telemetry.distro.version");

  @override
  final String key;

  @override
  String toString() => key;

  const TelemetryDistroResource(this.key);
}

// Telemetry SDK Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#telemetry-sdk)
enum TelemetrySDKResource implements OTelSemantic {
  sdkName("telemetry.sdk.name"),
  sdkLanguage("telemetry.sdk.language"),
  sdkVersion("telemetry.sdk.version");

  @override
  final String key;

  @override
  String toString() => key;

  const TelemetrySDKResource(this.key);
}

// Version Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#version-Resource)
enum VersionResource implements OTelSemantic {
  schemaUrl("schema.url");

  @override
  final String key;

  @override
  String toString() => key;

  const VersionResource(this.key);
}
