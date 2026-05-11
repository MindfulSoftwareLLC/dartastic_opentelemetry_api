// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

/// OpenTelemetry Semantic Conventions - Dart Enums
library;

import 'semantics.dart';

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
  clientAddress('client.address'),
  clientPort('client.port');

  @override
  final String key;

  @override
  String toString() => key;

  const ClientResource(this.key);
}

// Cloud Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#cloud-provider)
enum CloudResource implements OTelSemantic {
  cloudProvider('cloud.provider'),
  cloudAccountId('cloud.account.id'),
  cloudRegion('cloud.region'),
  cloudAvailabilityZone('cloud.availability_zone'),
  cloudPlatform('cloud.platform');

  @override
  final String key;

  @override
  String toString() => key;

  const CloudResource(this.key);
}

// Compute Unit Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#compute-unit)
/// Covers the OTel container.* registry — see
/// https://opentelemetry.io/docs/specs/semconv/attributes-registry/container/.
enum ComputeUnitResource implements OTelSemantic {
  containerName('container.name'),
  containerId('container.id'),
  containerRuntime('container.runtime'),
  containerImageName('container.image.name'),
  // `container.image.tag` is the singular legacy form; the current
  // spec uses the pluralized `container.image.tags` (List<String>).
  containerImageTag('container.image.tag'),
  containerImageTags('container.image.tags'),
  containerImageId('container.image.id'),
  containerImageRepoDigests('container.image.repo_digests'),
  containerCommand('container.command'),
  containerCommandArgs('container.command_args'),
  containerCommandLine('container.command_line'),
  containerCsiPluginName('container.csi.plugin.name'),
  containerCsiVolumeId('container.csi.volume.id'),
  containerLabels('container.labels');

  @override
  final String key;

  @override
  String toString() => key;

  const ComputeUnitResource(this.key);
}

// Compute Instance Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#compute-instance)
enum ComputeInstanceResource implements OTelSemantic {
  hostId('host.id'),
  hostName('host.name'),
  hostType('host.type'),
  hostImageName('host.image.name'),
  hostImageId('host.image.id'),
  hostImageVersion('host.image.version');

  @override
  final String key;

  @override
  String toString() => key;

  const ComputeInstanceResource(this.key);
}

enum DatabaseResource implements OTelSemantic {
  // Legacy / pre-stable keys — retained for backward compatibility.
  dbSystem('db.system'),
  dbConnectionString('db.connection_string'),
  dbUser('db.user'),
  dbName('db.name'),
  dbStatement('db.statement'),
  dbOperation('db.operation'),
  // Current OTel semconv (replaces deprecated `db.sql.table`).
  dbCollectionName('db.collection.name'),
  // Current OTel semconv for "rows returned by the operation".
  dbResponseReturnedRows('db.response.returned_rows'),
  // Current OTel semconv keys (replace the legacy entries above; the
  // legacy keys are kept for consumers still emitting them).
  dbSystemName('db.system.name'),
  dbNamespace('db.namespace'),
  dbOperationName('db.operation.name'),
  dbOperationBatchSize('db.operation.batch.size'),
  dbQueryText('db.query.text'),
  dbQuerySummary('db.query.summary'),
  dbResponseStatusCode('db.response.status_code'),
  dbStoredProcedureName('db.stored_procedure.name'),
  dbClientConnectionState('db.client.connection.state'),
  dbClientConnectionPoolName('db.client.connection.pool.name'),
  dbClientConnectionUsedState('db.client.connection.used.state');

  @override
  final String key;

  @override
  String toString() => key;

  const DatabaseResource(this.key);
}

// Deployment Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#deployment)
enum DeploymentResource implements OTelSemantic {
  deploymentId('deployment.id'),
  deploymentName('deployment.name'),
  deploymentEnvironmentName('deployment.environment.name');

  @override
  final String key;

  @override
  String toString() => key;

  const DeploymentResource(this.key);
}

// Device Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#device)
enum DeviceResource implements OTelSemantic {
  deviceId('device.id'),
  deviceModelIdentifier('device.model.identifier'),
  deviceModelName('device.model.name'),
  deviceManufacturer('device.manufacturer');

  @override
  final String key;

  @override
  String toString() => key;

  const DeviceResource(this.key);
}

// Error Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/error/)
enum ErrorResource implements OTelSemantic {
  errorType('error.type');

  @override
  final String key;

  @override
  String toString() => key;

  const ErrorResource(this.key);
}

// Environment Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#environment)
enum EnvironmentResource implements OTelSemantic {
  deploymentEnvironment('deployment.environment');

  @override
  final String key;

  @override
  String toString() => key;

  const EnvironmentResource(this.key);
}

enum ExceptionResource implements OTelSemantic {
  exceptionType('exception.type'),
  exceptionMessage('exception.message'),
  exceptionStacktrace('exception.stacktrace');

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
  featureFlagKey('feature_flag.key'),
  featureFlagVariant('feature_flag.variant'),
  featureFlagProviderName('feature_flag.provider_name'),
  featureFlagContextId('feature_flag.context.id'),
  featureFlagEvaluationReason('feature_flag.evaluation.reason'),
  featureFlagEvaluationErrorMessage('feature_flag.evaluation.error.message'),
  featureFlagSetId('feature_flag.set.id'),
  featureFlagVersion('feature_flag.version');

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
  filePath('file.path'),
  fileName('file.name'),
  fileExtension('file.extension'),
  fileSize('file.size'),
  fileCreated('file.created'),
  fileModified('file.modified'),
  fileAccessed('file.accessed'),
  fileChanged('file.changed'),
  fileOwnerId('file.owner.id'),
  fileOwnerName('file.owner.name'),
  fileGroupId('file.group.id'),
  fileGroupName('file.group.name'),
  fileMode('file.mode'),
  fileInode('file.inode'),
  fileAttributes('file.attributes'),
  fileSymbolicLinkTargetPath('file.symbolic_link.target_path'),
  fileForkName('file.fork_name'),
  fileDirectory('file.directory');

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
  genAiOperationName('gen_ai.operation.name'),
  genAiRequestEncodingFormats('gen_ai.request.encoding_formats'),
  genAiRequestFrequencyPenalty('gen_ai.request.frequency_penalty'),
  genAiRequestMaxTokens('gen_ai.request.max_tokens'),
  genAiRequestModel('gen_ai.request.model'),
  genAiRequestPresencePenalty('gen_ai.request.presence_penalty'),
  genAiRequestSeed('gen_ai.request.seed');

  @override
  final String key;

  @override
  String toString() => key;

  const GenAIResource(this.key);
}

enum GeneralResourceResource implements OTelSemantic {
  serviceName('service.name'),
  serviceVersion('service.version'),
  telemetrySdkName('telemetry.sdk.name'),
  telemetrySdkVersion('telemetry.sdk.version'),
  telemetryAutoVersion('telemetry.auto.version');

  @override
  final String key;

  @override
  String toString() => key;

  const GeneralResourceResource(this.key);
}

enum GraphQLResource implements OTelSemantic {
  graphqlDocument('graphql.document'),
  graphqlOperationName('graphql.operation.name'),
  graphqlOperationType('graphql.operation.type');

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
  hostArch('host.arch'),
  hostCpuCacheL2Size('host.cpu.cache.l2.size'),
  hostCpuFamily('host.cpu.family'),
  hostCpuModelId('host.cpu.model.id'),
  hostCpuModelName('host.cpu.model.name'),
  hostCpuStepping('host.cpu.stepping'),
  hostCpuVendorId('host.cpu.vendor.id'),
  hostId('host.id'),
  hostImageId('host.image.id'),
  hostImageName('host.image.name'),
  hostImageVersion('host.image.version'),
  hostName('host.name'),
  hostType('host.type'),
  hostMac('host.mac'),
  hostIp('host.ip');

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
  k8sClusterName('k8s.cluster.name'),
  k8sResourcepaceName('k8s.Resourcepace.name'),
  k8sPodName('k8s.pod.name'),
  k8sPodUid('k8s.pod.uid'),
  k8sContainerName('k8s.container.name'),
  k8sReplicaSetUid('k8s.replicaset.uid'),
  k8sReplicaSetName('k8s.replicaset.name'),
  k8sDeploymentUid('k8s.deployment.uid'),
  k8sDeploymentName('k8s.deployment.name'),
  k8sStatefulSetUid('k8s.statefulset.uid'),
  k8sStatefulSetName('k8s.statefulset.name'),
  k8sDaemonSetUid('k8s.daemonset.uid'),
  k8sDaemonSetName('k8s.daemonset.name'),
  k8sJobUid('k8s.job.uid'),
  k8sJobName('k8s.job.name'),
  k8sCronJobUid('k8s.cronjob.uid'),
  k8sCronJobName('k8s.cronjob.name');

  @override
  final String key;

  @override
  String toString() => key;

  const KubernetesResource(this.key);
}

enum MessagingResource implements OTelSemantic {
  messagingSystem('messaging.system'),
  messagingDestination('messaging.destination'),
  messagingDestinationKind('messaging.destination_kind'),
  messagingTempDestination('messaging.temp_destination'),
  messagingProtocol('messaging.protocol'),
  messagingProtocolVersion('messaging.protocol_version');

  @override
  final String key;

  @override
  String toString() => key;

  const MessagingResource(this.key);
}

enum NetworkResource implements OTelSemantic {
  networkType('network.type'),
  networkCarrierName('network.carrier.name'),
  networkCarrierMcc('network.carrier.mcc'),
  networkCarrierMnc('network.carrier.mnc'),
  networkCarrierIcc('network.carrier.icc'),
  networkProtocolName('network.protocol.name'),
  networkProtocolVersion('network.protocol.version'),
  networkTransport('network.transport');

  @override
  final String key;

  @override
  String toString() => key;

  const NetworkResource(this.key);
}

// Operating System Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#operating-system)
enum OperatingSystemResource implements OTelSemantic {
  osType('os.type'),
  osDescription('os.description'),
  osName('os.name'),
  osVersion('os.version');

  @override
  final String key;

  @override
  String toString() => key;

  const OperatingSystemResource(this.key);
}

// Process Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#process)
enum ProcessResource implements OTelSemantic {
  processPid('process.pid'),
  processExecutableName('process.executable.name'),
  processExecutablePath('process.executable.path'),
  processCommand('process.command'),
  processCommandLine('process.command_line'),
  processOwner('process.owner'),
  processRuntimeName('process.runtime.name'),
  processRuntimeVersion('process.runtime.version'),
  processRuntimeDescription('process.runtime.description');

  @override
  final String key;

  @override
  String toString() => key;

  const ProcessResource(this.key);
}

enum RPCResource implements OTelSemantic {
  rpcSystem('rpc.system'),
  rpcService('rpc.service'),
  rpcMethod('rpc.method');

  @override
  final String key;

  @override
  String toString() => key;

  const RPCResource(this.key);
}

// Server Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/server/)
enum ServerResource implements OTelSemantic {
  serverAddress('server.address'),
  serverPort('server.port');

  @override
  final String key;

  @override
  String toString() => key;

  const ServerResource(this.key);
}

// URL Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/url/)
enum UrlResource implements OTelSemantic {
  urlScheme('url.scheme'),
  urlPath('url.path'),
  urlQuery('url.query'),
  urlFragment('url.fragment'),
  urlFull('url.full'),
  urlOriginal('url.original'),
  urlTemplate('url.template'),
  urlDomain('url.domain'),
  urlPort('url.port'),
  urlSubdomain('url.subdomain'),
  urlRegisteredDomain('url.registered_domain'),
  urlTopLevelDomain('url.top_level_domain');

  @override
  final String key;

  @override
  String toString() => key;

  const UrlResource(this.key);
}

// Service Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#service)
enum ServiceResource implements OTelSemantic {
  serviceName('service.name'),
  serviceNamespace('service.namespace'),
  serviceInstanceId('service.instance.id'),
  serviceVersion('service.version');

  @override
  final String key;

  @override
  String toString() => key;

  const ServiceResource(this.key);
}

// Source Code Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/general/attributes/)
enum SourceCodeResource implements OTelSemantic {
  codeFunctionName('code.function.name'),
  codeResourcepace('code.Resourcepace'),
  codeFilePath('code.file.path'),
  codeLineNumber('code.line.number'),
  codeColumnNumber('code.column.number'),
  codeStacktrace('code.stacktrace');

  @override
  final String key;

  @override
  String toString() => key;

  const SourceCodeResource(this.key);
}

// Telemetry Distro Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#telemetry-distro)
enum TelemetryDistroResource implements OTelSemantic {
  distroName('telemetry.distro.name'),
  distroVersion('telemetry.distro.version');

  @override
  final String key;

  @override
  String toString() => key;

  const TelemetryDistroResource(this.key);
}

// Telemetry SDK Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#telemetry-sdk)
enum TelemetrySDKResource implements OTelSemantic {
  sdkName('telemetry.sdk.name'),
  sdkLanguage('telemetry.sdk.language'),
  sdkVersion('telemetry.sdk.version');

  @override
  final String key;

  @override
  String toString() => key;

  const TelemetrySDKResource(this.key);
}

// User Agent Semantic Conventions
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/user-agent/)
enum UserAgentResource implements OTelSemantic {
  userAgentOriginal('user_agent.original'),
  userAgentName('user_agent.name'),
  userAgentVersion('user_agent.version');

  @override
  final String key;

  @override
  String toString() => key;

  const UserAgentResource(this.key);
}

// =============================================================================
// Additional semantic-convention enums — comprehensive coverage of the
// OTel attribute registry (https://opentelemetry.io/docs/specs/semconv/attributes-registry/).
//
// Each enum below mirrors a top-level namespace in the registry. Keys
// are reproduced verbatim from the spec so they survive cross-tool
// matching. Enums are ordered alphabetically by registry namespace.
// =============================================================================

/// Android-specific attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/android/)
enum AndroidResource implements OTelSemantic {
  androidOsApiLevel('android.os.api_level'),
  androidAppState('android.app.state'),
  androidState('android.state');

  @override
  final String key;
  @override
  String toString() => key;
  const AndroidResource(this.key);
}

/// Software-artifact / supply-chain attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/artifact/)
enum ArtifactResource implements OTelSemantic {
  artifactAttestationFilename('artifact.attestation.filename'),
  artifactAttestationHash('artifact.attestation.hash'),
  artifactAttestationId('artifact.attestation.id'),
  artifactFilename('artifact.filename'),
  artifactHash('artifact.hash'),
  artifactPurl('artifact.purl'),
  artifactVersion('artifact.version');

  @override
  final String key;
  @override
  String toString() => key;
  const ArtifactResource(this.key);
}

/// AWS-specific attributes (ECS, EKS, Lambda, S3, DynamoDB, etc.).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/aws/)
enum AwsResource implements OTelSemantic {
  awsRequestId('aws.request_id'),
  // ECS
  awsEcsClusterArn('aws.ecs.cluster.arn'),
  awsEcsContainerArn('aws.ecs.container.arn'),
  awsEcsLaunchType('aws.ecs.launchtype'),
  awsEcsTaskArn('aws.ecs.task.arn'),
  awsEcsTaskFamily('aws.ecs.task.family'),
  awsEcsTaskId('aws.ecs.task.id'),
  awsEcsTaskRevision('aws.ecs.task.revision'),
  // EKS
  awsEksClusterArn('aws.eks.cluster.arn'),
  // Lambda
  awsLambdaInvokedArn('aws.lambda.invoked_arn'),
  // CloudWatch Logs
  awsLogGroupArns('aws.log.group.arns'),
  awsLogGroupNames('aws.log.group.names'),
  awsLogStreamArns('aws.log.stream.arns'),
  awsLogStreamNames('aws.log.stream.names'),
  // S3
  awsS3Bucket('aws.s3.bucket'),
  awsS3CopySource('aws.s3.copy_source'),
  awsS3Delete('aws.s3.delete'),
  awsS3Key('aws.s3.key'),
  awsS3PartNumber('aws.s3.part_number'),
  awsS3UploadId('aws.s3.upload_id'),
  // DynamoDB
  awsDynamodbTableNames('aws.dynamodb.table_names'),
  awsDynamodbConsumedCapacity('aws.dynamodb.consumed_capacity'),
  awsDynamodbItemCollectionMetrics('aws.dynamodb.item_collection_metrics'),
  awsDynamodbProvisionedReadCapacity('aws.dynamodb.provisioned_read_capacity'),
  awsDynamodbProvisionedWriteCapacity(
      'aws.dynamodb.provisioned_write_capacity'),
  awsDynamodbAttributesToGet('aws.dynamodb.attributes_to_get'),
  awsDynamodbProjection('aws.dynamodb.projection'),
  awsDynamodbLimit('aws.dynamodb.limit'),
  awsDynamodbAttributeDefinitions('aws.dynamodb.attribute_definitions'),
  awsDynamodbCount('aws.dynamodb.count'),
  awsDynamodbScannedCount('aws.dynamodb.scanned_count'),
  awsDynamodbIndexName('aws.dynamodb.index_name'),
  awsDynamodbSelect('aws.dynamodb.select'),
  awsDynamodbExclusiveStartTable('aws.dynamodb.exclusive_start_table'),
  awsDynamodbGlobalSecondaryIndexes('aws.dynamodb.global_secondary_indexes'),
  awsDynamodbLocalSecondaryIndexes('aws.dynamodb.local_secondary_indexes'),
  awsDynamodbTotalSegments('aws.dynamodb.total_segments'),
  awsDynamodbSegment('aws.dynamodb.segment'),
  awsDynamodbTableCount('aws.dynamodb.table_count');

  @override
  final String key;
  @override
  String toString() => key;
  const AwsResource(this.key);
}

/// Azure-specific attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/azure/)
enum AzureResource implements OTelSemantic {
  azureClientId('azure.client.id'),
  azureCosmosdbConnectionMode('azure.cosmosdb.connection.mode'),
  azureCosmosdbConsistencyLevel('azure.cosmosdb.consistency.level'),
  azureCosmosdbOperationContactedRegions(
      'azure.cosmosdb.operation.contacted_regions'),
  azureCosmosdbOperationRequestCharge(
      'azure.cosmosdb.operation.request_charge'),
  azureCosmosdbRequestBodySize('azure.cosmosdb.request.body.size'),
  azureCosmosdbResponseSubStatusCode('azure.cosmosdb.response.sub_status_code'),
  // Legacy az.* namespace, kept because many SDKs still emit it.
  azNamespace('az.namespace'),
  azServiceRequestId('az.service_request_id');

  @override
  final String key;
  @override
  String toString() => key;
  const AzureResource(this.key);
}

/// Browser-specific attributes (set by web/Flutter-Web resource detector).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/browser/)
enum BrowserResource implements OTelSemantic {
  browserBrands('browser.brands'),
  browserLanguage('browser.language'),
  browserMobile('browser.mobile'),
  browserPlatform('browser.platform');

  @override
  final String key;
  @override
  String toString() => key;
  const BrowserResource(this.key);
}

/// Cassandra-specific attributes (used alongside `db.*`).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/cassandra/)
enum CassandraResource implements OTelSemantic {
  cassandraConsistencyLevel('cassandra.consistency.level'),
  cassandraCoordinatorDc('cassandra.coordinator.dc'),
  cassandraCoordinatorId('cassandra.coordinator.id'),
  cassandraPageSize('cassandra.page.size'),
  cassandraQueryIdempotent('cassandra.query.idempotent'),
  cassandraSpeculativeExecutionCount('cassandra.speculative_execution.count');

  @override
  final String key;
  @override
  String toString() => key;
  const CassandraResource(this.key);
}

/// CI/CD pipeline attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/cicd/)
enum CicdResource implements OTelSemantic {
  cicdPipelineName('cicd.pipeline.name'),
  cicdPipelineRunId('cicd.pipeline.run.id'),
  cicdPipelineRunState('cicd.pipeline.run.state'),
  cicdPipelineRunUrlFull('cicd.pipeline.run.url.full'),
  cicdPipelineTaskName('cicd.pipeline.task.name'),
  cicdPipelineTaskRunId('cicd.pipeline.task.run.id'),
  cicdPipelineTaskRunUrlFull('cicd.pipeline.task.run.url.full'),
  cicdPipelineTaskType('cicd.pipeline.task.type'),
  cicdSystemComponent('cicd.system.component'),
  cicdWorkerId('cicd.worker.id'),
  cicdWorkerName('cicd.worker.name'),
  cicdWorkerState('cicd.worker.state'),
  cicdWorkerUrlFull('cicd.worker.url.full');

  @override
  final String key;
  @override
  String toString() => key;
  const CicdResource(this.key);
}

/// CloudEvents (https://cloudevents.io) attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/cloudevents/)
enum CloudEventsResource implements OTelSemantic {
  cloudEventsEventId('cloudevents.event_id'),
  cloudEventsEventSource('cloudevents.event_source'),
  cloudEventsEventSpecVersion('cloudevents.event_spec_version'),
  cloudEventsEventSubject('cloudevents.event_subject'),
  cloudEventsEventType('cloudevents.event_type');

  @override
  final String key;
  @override
  String toString() => key;
  const CloudEventsResource(this.key);
}

/// Cloud Foundry attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/cloudfoundry/)
enum CloudfoundryResource implements OTelSemantic {
  cloudfoundryAppId('cloudfoundry.app.id'),
  cloudfoundryAppInstanceId('cloudfoundry.app.instance.id'),
  cloudfoundryAppName('cloudfoundry.app.name'),
  cloudfoundryOrgId('cloudfoundry.org.id'),
  cloudfoundryOrgName('cloudfoundry.org.name'),
  cloudfoundryProcessId('cloudfoundry.process.id'),
  cloudfoundryProcessType('cloudfoundry.process.type'),
  cloudfoundrySpaceId('cloudfoundry.space.id'),
  cloudfoundrySpaceName('cloudfoundry.space.name'),
  cloudfoundrySystemId('cloudfoundry.system.id'),
  cloudfoundrySystemInstanceId('cloudfoundry.system.instance.id');

  @override
  final String key;
  @override
  String toString() => key;
  const CloudfoundryResource(this.key);
}

/// Source code attributes (set on spans, log records, exceptions).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/code/)
enum CodeResource implements OTelSemantic {
  codeColumnNumber('code.column.number'),
  codeFilePath('code.file.path'),
  codeFunctionName('code.function.name'),
  codeLineNumber('code.line.number'),
  codeNamespace('code.namespace'),
  codeStacktrace('code.stacktrace');

  @override
  final String key;
  @override
  String toString() => key;
  const CodeResource(this.key);
}

/// Destination of a network connection. Mirror of `ServerResource` for
/// outbound non-HTTP connections (databases, gRPC, etc.).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/destination/)
enum DestinationResource implements OTelSemantic {
  destinationAddress('destination.address'),
  destinationPort('destination.port');

  @override
  final String key;
  @override
  String toString() => key;
  const DestinationResource(this.key);
}

/// DNS query attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/dns/)
enum DnsResource implements OTelSemantic {
  dnsQuestionName('dns.question.name'),
  dnsAnswers('dns.answers');

  @override
  final String key;
  @override
  String toString() => key;
  const DnsResource(this.key);
}

/// Elasticsearch-specific attributes (used alongside `db.*`).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/elasticsearch/)
enum ElasticsearchResource implements OTelSemantic {
  elasticsearchClusterName('elasticsearch.cluster.name'),
  elasticsearchNodeName('elasticsearch.node.name'),
  elasticsearchNodeVersion('elasticsearch.node.version');

  @override
  final String key;
  @override
  String toString() => key;
  const ElasticsearchResource(this.key);
}

/// End-user identity attributes. Separate from `user.*` per spec —
/// `enduser.*` is set by services about the end user they're serving.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/enduser/)
enum EnduserResource implements OTelSemantic {
  enduserId('enduser.id'),
  enduserRole('enduser.role'),
  enduserScope('enduser.scope');

  @override
  final String key;
  @override
  String toString() => key;
  const EnduserResource(this.key);
}

/// Event-record attributes (used by the logs signal).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/event/)
enum EventResource implements OTelSemantic {
  eventName('event.name');

  @override
  final String key;
  @override
  String toString() => key;
  const EventResource(this.key);
}

/// Function-as-a-Service attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/faas/)
enum FaasResource implements OTelSemantic {
  faasColdstart('faas.coldstart'),
  faasCron('faas.cron'),
  faasDocumentCollection('faas.document.collection'),
  faasDocumentName('faas.document.name'),
  faasDocumentOperation('faas.document.operation'),
  faasDocumentTime('faas.document.time'),
  faasInstance('faas.instance'),
  faasInvocationId('faas.invocation_id'),
  faasInvokedName('faas.invoked_name'),
  faasInvokedProvider('faas.invoked_provider'),
  faasInvokedRegion('faas.invoked_region'),
  faasMaxMemory('faas.max_memory'),
  faasName('faas.name'),
  faasTime('faas.time'),
  faasTrigger('faas.trigger'),
  faasVersion('faas.version');

  @override
  final String key;
  @override
  String toString() => key;
  const FaasResource(this.key);
}

/// GCP-specific attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/gcp/)
enum GcpResource implements OTelSemantic {
  gcpClientService('gcp.client.service'),
  gcpCloudRunJobExecution('gcp.cloud_run.job.execution'),
  gcpCloudRunJobTaskIndex('gcp.cloud_run.job.task_index'),
  gcpGceInstanceHostname('gcp.gce.instance.hostname'),
  gcpGceInstanceName('gcp.gce.instance.name');

  @override
  final String key;
  @override
  String toString() => key;
  const GcpResource(this.key);
}

/// Geographic-location attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/geo/)
enum GeoResource implements OTelSemantic {
  geoContinentCode('geo.continent.code'),
  geoCountryIsoCode('geo.country.iso_code'),
  geoLocalityName('geo.locality.name'),
  geoLocationLat('geo.location.lat'),
  geoLocationLon('geo.location.lon'),
  geoPostalCode('geo.postal_code'),
  geoRegionIsoCode('geo.region.iso_code');

  @override
  final String key;
  @override
  String toString() => key;
  const GeoResource(this.key);
}

/// Hardware-component attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/hardware/)
enum HardwareResource implements OTelSemantic {
  hardwareId('hardware.id'),
  hardwareName('hardware.name'),
  hardwareParent('hardware.parent'),
  hardwareSerialNumber('hardware.serial_number'),
  hardwareType('hardware.type'),
  hardwareVendor('hardware.vendor'),
  hardwareModel('hardware.model');

  @override
  final String key;
  @override
  String toString() => key;
  const HardwareResource(this.key);
}

/// Heroku platform attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/heroku/)
enum HerokuResource implements OTelSemantic {
  herokuAppId('heroku.app.id'),
  herokuReleaseCommit('heroku.release.commit'),
  herokuReleaseCreationTimestamp('heroku.release.creation_timestamp');

  @override
  final String key;
  @override
  String toString() => key;
  const HerokuResource(this.key);
}

/// iOS-specific attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/ios/)
enum IosResource implements OTelSemantic {
  iosAppState('ios.app.state'),
  iosState('ios.state');

  @override
  final String key;
  @override
  String toString() => key;
  const IosResource(this.key);
}

/// Log-record attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/log/)
enum LogResource implements OTelSemantic {
  logIostream('log.iostream'),
  logFileName('log.file.name'),
  logFileNameResolved('log.file.name_resolved'),
  logFilePath('log.file.path'),
  logFilePathResolved('log.file.path_resolved'),
  logRecordOriginal('log.record.original'),
  logRecordUid('log.record.uid');

  @override
  final String key;
  @override
  String toString() => key;
  const LogResource(this.key);
}

/// OCI image attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/oci/)
enum OciResource implements OTelSemantic {
  ociManifestDigest('oci.manifest.digest');

  @override
  final String key;
  @override
  String toString() => key;
  const OciResource(this.key);
}

/// OpenTracing-bridge attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/opentracing/)
enum OpentracingResource implements OTelSemantic {
  opentracingRefType('opentracing.ref_type');

  @override
  final String key;
  @override
  String toString() => key;
  const OpentracingResource(this.key);
}

/// OpenTelemetry-internal attributes (instrumentation scope, etc.).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/otel/)
enum OtelResource implements OTelSemantic {
  otelScopeName('otel.scope.name'),
  otelScopeVersion('otel.scope.version'),
  otelStatusCode('otel.status_code'),
  otelStatusDescription('otel.status_description'),
  otelSpanSamplingResult('otel.span.sampling_result'),
  // Deprecated in current spec but still emitted by some backends.
  otelLibraryName('otel.library.name'),
  otelLibraryVersion('otel.library.version');

  @override
  final String key;
  @override
  String toString() => key;
  const OtelResource(this.key);
}

/// Peer-service attribute (cross-service correlation).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/peer/)
enum PeerResource implements OTelSemantic {
  peerService('peer.service');

  @override
  final String key;
  @override
  String toString() => key;
  const PeerResource(this.key);
}

/// Profiling-signal attributes (experimental).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/profile/)
enum ProfileResource implements OTelSemantic {
  profileFrameType('profile.frame.type');

  @override
  final String key;
  @override
  String toString() => key;
  const ProfileResource(this.key);
}

/// Source of a network connection. Mirror of `ClientResource` for
/// inbound non-HTTP connections.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/source/)
enum SourceResource implements OTelSemantic {
  sourceAddress('source.address'),
  sourcePort('source.port');

  @override
  final String key;
  @override
  String toString() => key;
  const SourceResource(this.key);
}

/// System-level metrics attributes (CPU, memory, disk, network, filesystem).
/// Used by the SDK's auto-collected runtime metrics.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/system/)
enum SystemResource implements OTelSemantic {
  systemCpuLogicalNumber('system.cpu.logical_number'),
  systemCpuState('system.cpu.state'),
  systemDevice('system.device'),
  systemDiskIoDirection('system.disk.io.direction'),
  systemFilesystemMode('system.filesystem.mode'),
  systemFilesystemMountpoint('system.filesystem.mountpoint'),
  systemFilesystemState('system.filesystem.state'),
  systemFilesystemType('system.filesystem.type'),
  systemMemoryState('system.memory.state'),
  systemNetworkState('system.network.state'),
  systemPagingDirection('system.paging.direction'),
  systemPagingState('system.paging.state'),
  systemPagingType('system.paging.type'),
  systemProcessStatus('system.process.status');

  @override
  final String key;
  @override
  String toString() => key;
  const SystemResource(this.key);
}

/// Test framework / test result attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/test/)
enum TestResource implements OTelSemantic {
  testCaseName('test.case.name'),
  testCaseResultStatus('test.case.result.status'),
  testSuiteName('test.suite.name'),
  testSuiteRunStatus('test.suite.run.status');

  @override
  final String key;
  @override
  String toString() => key;
  const TestResource(this.key);
}

/// Thread-of-execution attributes (used by exceptions, logs).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/thread/)
enum ThreadResource implements OTelSemantic {
  threadId('thread.id'),
  threadName('thread.name');

  @override
  final String key;
  @override
  String toString() => key;
  const ThreadResource(this.key);
}

/// TLS connection attributes.
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/tls/)
enum TlsResource implements OTelSemantic {
  tlsCipher('tls.cipher'),
  tlsCurve('tls.curve'),
  tlsEstablished('tls.established'),
  tlsNextProtocol('tls.next_protocol'),
  tlsProtocolName('tls.protocol.name'),
  tlsProtocolVersion('tls.protocol.version'),
  tlsResumed('tls.resumed'),
  tlsClientCertificate('tls.client.certificate'),
  tlsClientCertificateChain('tls.client.certificate_chain'),
  tlsClientHashMd5('tls.client.hash.md5'),
  tlsClientHashSha1('tls.client.hash.sha1'),
  tlsClientHashSha256('tls.client.hash.sha256'),
  tlsClientIssuer('tls.client.issuer'),
  tlsClientJa3('tls.client.ja3'),
  tlsClientNotAfter('tls.client.not_after'),
  tlsClientNotBefore('tls.client.not_before'),
  tlsClientSubject('tls.client.subject'),
  tlsClientSupportedCiphers('tls.client.supported_ciphers'),
  tlsServerCertificate('tls.server.certificate'),
  tlsServerCertificateChain('tls.server.certificate_chain'),
  tlsServerHashMd5('tls.server.hash.md5'),
  tlsServerHashSha1('tls.server.hash.sha1'),
  tlsServerHashSha256('tls.server.hash.sha256'),
  tlsServerIssuer('tls.server.issuer'),
  tlsServerJa3s('tls.server.ja3s'),
  tlsServerNotAfter('tls.server.not_after'),
  tlsServerNotBefore('tls.server.not_before'),
  tlsServerSubject('tls.server.subject');

  @override
  final String key;
  @override
  String toString() => key;
  const TlsResource(this.key);
}

/// Version-control-system attributes (source repository info).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/vcs/)
enum VcsResource implements OTelSemantic {
  vcsRepositoryUrlFull('vcs.repository.url.full'),
  vcsRepositoryRefName('vcs.repository.ref.name'),
  vcsRepositoryRefRevision('vcs.repository.ref.revision'),
  vcsRepositoryRefType('vcs.repository.ref.type'),
  vcsRepositoryChangeId('vcs.repository.change.id'),
  vcsRepositoryChangeTitle('vcs.repository.change.title'),
  vcsRefHeadName('vcs.ref.head.name'),
  vcsRefHeadRevision('vcs.ref.head.revision'),
  vcsRefHeadType('vcs.ref.head.type'),
  vcsRefBaseName('vcs.ref.base.name'),
  vcsRefBaseRevision('vcs.ref.base.revision'),
  vcsRefBaseType('vcs.ref.base.type'),
  vcsChangeId('vcs.change.id'),
  vcsChangeTitle('vcs.change.title'),
  vcsChangeState('vcs.change.state'),
  vcsLineChangeType('vcs.line_change.type'),
  vcsOwnerName('vcs.owner.name'),
  vcsProviderName('vcs.provider.name');

  @override
  final String key;
  @override
  String toString() => key;
  const VcsResource(this.key);
}

/// Web engine attributes (servlet container, framework).
/// [Specification](https://opentelemetry.io/docs/specs/semconv/attributes-registry/webengine/)
enum WebengineResource implements OTelSemantic {
  webengineDescription('webengine.description'),
  webengineName('webengine.name'),
  webengineVersion('webengine.version');

  @override
  final String key;
  @override
  String toString() => key;
  const WebengineResource(this.key);
}

// Version Semantic Resource
/// [Specification](https://opentelemetry.io/docs/specs/semconv/resource/#version-Resource)
enum VersionResource implements OTelSemantic {
  schemaUrl('schema.url');

  @override
  final String key;

  @override
  String toString() => key;

  const VersionResource(this.key);
}
