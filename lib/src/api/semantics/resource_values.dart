// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

/// OpenTelemetry Semantic Conventions — typed value enums.
///
/// The enums in [resource_semantics.dart] type-check attribute *keys*
/// against the OTel spec. This file does the same for the *values* of
/// attributes whose spec entry defines a closed set of valid strings
/// (e.g. `db.system.name` must be `postgresql` | `mysql` | …).
///
/// Use the `.value` getter when passing one of these to
/// `OTelAPI.attributesFromMap` / `OTelAPI.attributesFromSemanticMap`:
///
/// ```dart
/// OTelAPI.attributesFromSemanticMap({
///   Database.dbSystemName: DbSystem.postgresql.value,
///   Cloud.cloudProvider: CloudProvider.gcp.value,
/// });
/// ```
///
/// Spec ref: https://opentelemetry.io/docs/specs/semconv/attributes-registry/
library;

/// Marker on every value enum — exposes the on-wire string [value] and a
/// `toString()` that returns it. Modeled on the same shape as
/// `OTelSemantic`, but kept separate because these are *values*, not keys.
abstract interface class OTelSemanticValue {
  String get value;
}

mixin _OTelSemanticValueMixin implements OTelSemanticValue {
  @override
  String toString() => value;
}

// =============================================================================
// Cloud / provider value sets
// =============================================================================

/// Values for `cloud.provider`.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/registry/attributes/cloud/)
enum CloudProvider with _OTelSemanticValueMixin implements OTelSemanticValue {
  alibabaCloud('alibaba_cloud'),
  aws('aws'),
  azure('azure'),
  gcp('gcp'),
  heroku('heroku'),
  ibmCloud('ibm_cloud'),
  tencentCloud('tencent_cloud');

  @override
  final String value;
  const CloudProvider(this.value);
}

/// Values for `cloud.platform`. Subset of the largest registry namespace;
/// add what you need.
enum CloudPlatform with _OTelSemanticValueMixin implements OTelSemanticValue {
  awsEc2('aws_ec2'),
  awsEcs('aws_ecs'),
  awsEks('aws_eks'),
  awsLambda('aws_lambda'),
  awsAppRunner('aws_app_runner'),
  awsElasticBeanstalk('aws_elastic_beanstalk'),
  awsOpenshift('aws_openshift'),
  azureVm('azure_vm'),
  azureAks('azure_aks'),
  azureContainerApps('azure_container_apps'),
  azureContainerInstances('azure_container_instances'),
  azureFunctions('azure_functions'),
  azureAppService('azure_app_service'),
  azureOpenshift('azure_openshift'),
  gcpComputeEngine('gcp_compute_engine'),
  gcpKubernetesEngine('gcp_kubernetes_engine'),
  gcpCloudRun('gcp_cloud_run'),
  gcpCloudFunctions('gcp_cloud_functions'),
  gcpAppEngine('gcp_app_engine'),
  gcpOpenshift('gcp_openshift'),
  ibmCloudOpenshift('ibm_cloud_openshift'),
  herokuDyno('heroku_dyno'),
  alibabaCloudEcs('alibaba_cloud_ecs'),
  alibabaCloudFc('alibaba_cloud_fc'),
  alibabaCloudOpenshift('alibaba_cloud_openshift'),
  tencentCloudCvm('tencent_cloud_cvm'),
  tencentCloudEks('tencent_cloud_eks'),
  tencentCloudScf('tencent_cloud_scf');

  @override
  final String value;
  const CloudPlatform(this.value);
}

// =============================================================================
// Host / OS / architecture value sets
// =============================================================================

/// Values for `host.arch`.
enum HostArch with _OTelSemanticValueMixin implements OTelSemanticValue {
  amd64('amd64'),
  arm32('arm32'),
  arm64('arm64'),
  ia64('ia64'),
  ppc32('ppc32'),
  ppc64('ppc64'),
  s390x('s390x'),
  x86('x86');

  @override
  final String value;
  const HostArch(this.value);
}

/// Values for `os.type`.
enum OsType with _OTelSemanticValueMixin implements OTelSemanticValue {
  aix('aix'),
  darwin('darwin'),
  dragonflybsd('dragonflybsd'),
  freebsd('freebsd'),
  hpux('hpux'),
  linux('linux'),
  netbsd('netbsd'),
  openbsd('openbsd'),
  solaris('solaris'),
  windows('windows'),
  zOs('z_os');

  @override
  final String value;
  const OsType(this.value);
}

// =============================================================================
// HTTP value sets
// =============================================================================

/// Values for `http.request.method`.
enum HttpRequestMethod
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  connect('CONNECT'),
  delete('DELETE'),
  get('GET'),
  head('HEAD'),
  options('OPTIONS'),
  patch('PATCH'),
  post('POST'),
  put('PUT'),
  trace('TRACE'),
  other('_OTHER');

  @override
  final String value;
  const HttpRequestMethod(this.value);
}

/// Values for `http.connection.state`.
enum HttpConnectionState
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  active('active'),
  idle('idle');

  @override
  final String value;
  const HttpConnectionState(this.value);
}

// =============================================================================
// Network value sets
// =============================================================================

/// Values for `network.type`.
enum NetworkType with _OTelSemanticValueMixin implements OTelSemanticValue {
  ipv4('ipv4'),
  ipv6('ipv6');

  @override
  final String value;
  const NetworkType(this.value);
}

/// Values for `network.transport`.
enum NetworkTransport
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  tcp('tcp'),
  udp('udp'),
  pipe('pipe'),
  unix('unix'),
  quic('quic');

  @override
  final String value;
  const NetworkTransport(this.value);
}

/// Values for `network.connection.type` (Flutter mobile use).
enum NetworkConnectionType
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  cell('cell'),
  mobile('mobile'),
  wifi('wifi'),
  wired('wired'),
  unavailable('unavailable'),
  unknown('unknown');

  @override
  final String value;
  const NetworkConnectionType(this.value);
}

/// Values for `network.io.direction`.
enum NetworkIoDirection
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  receive('receive'),
  transmit('transmit');

  @override
  final String value;
  const NetworkIoDirection(this.value);
}

// =============================================================================
// Database value sets
// =============================================================================

/// Values for `db.system.name` / `db.system`. Closed-set per spec; subset
/// of the registry — extend if you need a system not listed.
enum DbSystem with _OTelSemanticValueMixin implements OTelSemanticValue {
  otherSql('other_sql'),
  mssql('mssql'),
  mssqlcompact('mssqlcompact'),
  mysql('mysql'),
  oracle('oracle'),
  db2('db2'),
  postgresql('postgresql'),
  redshift('redshift'),
  hive('hive'),
  cloudscape('cloudscape'),
  hsqldb('hsqldb'),
  progress('progress'),
  maxdb('maxdb'),
  hanadb('hanadb'),
  ingres('ingres'),
  firstsql('firstsql'),
  edb('edb'),
  cache('cache'),
  adabas('adabas'),
  firebird('firebird'),
  derby('derby'),
  filemaker('filemaker'),
  informix('informix'),
  instantdb('instantdb'),
  interbase('interbase'),
  mariadb('mariadb'),
  netezza('netezza'),
  pervasive('pervasive'),
  pointbase('pointbase'),
  sqlite('sqlite'),
  sybase('sybase'),
  teradata('teradata'),
  vertica('vertica'),
  h2('h2'),
  coldfusion('coldfusion'),
  cassandra('cassandra'),
  hbase('hbase'),
  mongodb('mongodb'),
  redis('redis'),
  couchbase('couchbase'),
  couchdb('couchdb'),
  cosmosdb('cosmosdb'),
  dynamodb('dynamodb'),
  neo4j('neo4j'),
  geode('geode'),
  elasticsearch('elasticsearch'),
  memcached('memcached'),
  cockroachdb('cockroachdb'),
  opensearch('opensearch'),
  clickhouse('clickhouse'),
  spanner('spanner'),
  trino('trino');

  @override
  final String value;
  const DbSystem(this.value);
}

/// Values for `db.client.connection.state`.
enum DbClientConnectionState
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  idle('idle'),
  used('used');

  @override
  final String value;
  const DbClientConnectionState(this.value);
}

/// Values for `cassandra.consistency.level`.
enum CassandraConsistencyLevel
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  all('all'),
  eachQuorum('each_quorum'),
  quorum('quorum'),
  localQuorum('local_quorum'),
  one('one'),
  two('two'),
  three('three'),
  localOne('local_one'),
  any('any'),
  serial('serial'),
  localSerial('local_serial');

  @override
  final String value;
  const CassandraConsistencyLevel(this.value);
}

/// Values for `azure.cosmosdb.connection.mode`.
enum AzureCosmosdbConnectionMode
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  gateway('gateway'),
  direct('direct');

  @override
  final String value;
  const AzureCosmosdbConnectionMode(this.value);
}

/// Values for `azure.cosmosdb.consistency.level`.
enum AzureCosmosdbConsistencyLevel
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  strong('Strong'),
  boundedStaleness('BoundedStaleness'),
  session('Session'),
  eventual('Eventual'),
  consistentPrefix('ConsistentPrefix');

  @override
  final String value;
  const AzureCosmosdbConsistencyLevel(this.value);
}

// =============================================================================
// Messaging value sets
// =============================================================================

/// Values for `messaging.system`. Subset of the registry.
enum MessagingSystem with _OTelSemanticValueMixin implements OTelSemanticValue {
  activemq('activemq'),
  awsSqs('aws_sqs'),
  eventgrid('eventgrid'),
  eventhubs('eventhubs'),
  servicebus('servicebus'),
  gcpPubsub('gcp_pubsub'),
  jms('jms'),
  kafka('kafka'),
  rabbitmq('rabbitmq'),
  rocketmq('rocketmq'),
  pulsar('pulsar');

  @override
  final String value;
  const MessagingSystem(this.value);
}

/// Values for `messaging.operation.type`.
enum MessagingOperation
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  publish('publish'),
  create('create'),
  receive('receive'),
  deliver('deliver'),
  settle('settle');

  @override
  final String value;
  const MessagingOperation(this.value);
}

// =============================================================================
// FaaS value sets
// =============================================================================

/// Values for `faas.trigger`.
enum FaasTrigger with _OTelSemanticValueMixin implements OTelSemanticValue {
  datasource('datasource'),
  http('http'),
  pubsub('pubsub'),
  timer('timer'),
  other('other');

  @override
  final String value;
  const FaasTrigger(this.value);
}

/// Values for `faas.invoked_provider`.
enum FaasInvokedProvider
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  alibabaCloud('alibaba_cloud'),
  aws('aws'),
  azure('azure'),
  gcp('gcp'),
  tencentCloud('tencent_cloud');

  @override
  final String value;
  const FaasInvokedProvider(this.value);
}

// =============================================================================
// RPC value sets
// =============================================================================

/// Values for `rpc.system`.
enum RpcSystem with _OTelSemanticValueMixin implements OTelSemanticValue {
  grpc('grpc'),
  javaRmi('java_rmi'),
  jsonrpc('jsonrpc'),
  dotnetWcf('dotnet_wcf'),
  apacheDubbo('apache_dubbo'),
  connectRpc('connect_rpc');

  @override
  final String value;
  const RpcSystem(this.value);
}

/// Values for `rpc.message.type`.
enum RpcMessageType with _OTelSemanticValueMixin implements OTelSemanticValue {
  sent('SENT'),
  received('RECEIVED');

  @override
  final String value;
  const RpcMessageType(this.value);
}

// =============================================================================
// GraphQL value sets
// =============================================================================

/// Values for `graphql.operation.type`.
enum GraphqlOperationType
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  query('query'),
  mutation('mutation'),
  subscription('subscription');

  @override
  final String value;
  const GraphqlOperationType(this.value);
}

// =============================================================================
// OpenTracing bridge / OTel-internal value sets
// =============================================================================

/// Values for `opentracing.ref_type`.
enum OpentracingRefType
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  childOf('child_of'),
  followsFrom('follows_from');

  @override
  final String value;
  const OpentracingRefType(this.value);
}

/// Values for `otel.status_code` (per spec, `UNSET` is implicit).
enum OtelStatusCode with _OTelSemanticValueMixin implements OTelSemanticValue {
  ok('OK'),
  error('ERROR');

  @override
  final String value;
  const OtelStatusCode(this.value);
}

/// Values for `otel.span.sampling_result`.
enum OtelSpanSamplingResult
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  drop('DROP'),
  recordOnly('RECORD_ONLY'),
  recordAndSample('RECORD_AND_SAMPLE');

  @override
  final String value;
  const OtelSpanSamplingResult(this.value);
}

// =============================================================================
// Telemetry SDK value sets
// =============================================================================

/// Values for `telemetry.sdk.language`.
enum TelemetrySdkLanguage
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  cpp('cpp'),
  dotnet('dotnet'),
  erlang('erlang'),
  go('go'),
  java('java'),
  nodejs('nodejs'),
  php('php'),
  python('python'),
  ruby('ruby'),
  rust('rust'),
  swift('swift'),
  webjs('webjs'),
  dart('dart'),
  kotlin('kotlin');

  @override
  final String value;
  const TelemetrySdkLanguage(this.value);
}

// =============================================================================
// System / process / disk / log value sets
// =============================================================================

/// Values for `system.cpu.state`.
enum SystemCpuState with _OTelSemanticValueMixin implements OTelSemanticValue {
  user('user'),
  system('system'),
  nice('nice'),
  idle('idle'),
  iowait('iowait'),
  interrupt('interrupt'),
  steal('steal');

  @override
  final String value;
  const SystemCpuState(this.value);
}

/// Values for `system.memory.state`.
enum SystemMemoryState
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  used('used'),
  free('free'),
  shared('shared'),
  buffers('buffers'),
  cached('cached'),
  slabReclaimable('slab_reclaimable'),
  slabUnreclaimable('slab_unreclaimable');

  @override
  final String value;
  const SystemMemoryState(this.value);
}

/// Values for `system.filesystem.state`.
enum SystemFilesystemState
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  used('used'),
  free('free'),
  reserved('reserved');

  @override
  final String value;
  const SystemFilesystemState(this.value);
}

/// Values for `system.filesystem.type`.
enum SystemFilesystemType
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  fat32('fat32'),
  exfat('exfat'),
  ntfs('ntfs'),
  refs('refs'),
  hfsplus('hfsplus'),
  ext4('ext4');

  @override
  final String value;
  const SystemFilesystemType(this.value);
}

/// Values for `system.paging.direction`.
enum SystemPagingDirection
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  pageIn('in'),
  pageOut('out');

  @override
  final String value;
  const SystemPagingDirection(this.value);
}

/// Values for `system.paging.state`.
enum SystemPagingState
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  used('used'),
  free('free');

  @override
  final String value;
  const SystemPagingState(this.value);
}

/// Values for `system.paging.type`.
enum SystemPagingType
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  major('major'),
  minor('minor');

  @override
  final String value;
  const SystemPagingType(this.value);
}

/// Values for `system.process.status`.
enum SystemProcessStatus
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  running('running'),
  sleeping('sleeping'),
  stopped('stopped'),
  defunct('defunct');

  @override
  final String value;
  const SystemProcessStatus(this.value);
}

/// Values for `disk.io.direction` / `system.disk.io.direction`.
enum DiskIoDirection with _OTelSemanticValueMixin implements OTelSemanticValue {
  read('read'),
  write('write');

  @override
  final String value;
  const DiskIoDirection(this.value);
}

/// Values for `log.iostream`.
enum LogIostream with _OTelSemanticValueMixin implements OTelSemanticValue {
  stdout('stdout'),
  stderr('stderr');

  @override
  final String value;
  const LogIostream(this.value);
}

// =============================================================================
// Mobile / app state value sets
// =============================================================================

/// Values for `ios.app.state` / `ios.state`.
enum IosAppState with _OTelSemanticValueMixin implements OTelSemanticValue {
  active('active'),
  inactive('inactive'),
  background('background'),
  foreground('foreground'),
  terminate('terminate');

  @override
  final String value;
  const IosAppState(this.value);
}

/// Values for `android.app.state` / `android.state`.
enum AndroidAppState with _OTelSemanticValueMixin implements OTelSemanticValue {
  created('created'),
  background('background'),
  foreground('foreground');

  @override
  final String value;
  const AndroidAppState(this.value);
}

// =============================================================================
// AWS / Azure value sets
// =============================================================================

/// Values for `aws.ecs.launchtype`.
enum AwsEcsLaunchType
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  ec2('ec2'),
  fargate('fargate');

  @override
  final String value;
  const AwsEcsLaunchType(this.value);
}

// =============================================================================
// CI/CD value sets
// =============================================================================

/// Values for `cicd.pipeline.run.state`.
enum CicdPipelineRunState
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  pending('pending'),
  executing('executing'),
  finalizing('finalizing');

  @override
  final String value;
  const CicdPipelineRunState(this.value);
}

/// Values for `cicd.pipeline.task.type`.
enum CicdPipelineTaskType
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  build('build'),
  deploy('deploy'),
  test('test');

  @override
  final String value;
  const CicdPipelineTaskType(this.value);
}

/// Values for `cicd.worker.state`.
enum CicdWorkerState with _OTelSemanticValueMixin implements OTelSemanticValue {
  available('available'),
  busy('busy'),
  offline('offline');

  @override
  final String value;
  const CicdWorkerState(this.value);
}

// =============================================================================
// Hardware value sets
// =============================================================================

/// Values for `hardware.type`.
enum HardwareType with _OTelSemanticValueMixin implements OTelSemanticValue {
  battery('battery'),
  cpu('cpu'),
  diskController('disk_controller'),
  enclosure('enclosure'),
  fan('fan'),
  gpu('gpu'),
  logicalDisk('logical_disk'),
  memory('memory'),
  network('network'),
  physicalDisk('physical_disk'),
  powerSupply('power_supply'),
  tapeDrive('tape_drive'),
  temperature('temperature'),
  voltage('voltage');

  @override
  final String value;
  const HardwareType(this.value);
}

// =============================================================================
// TLS / VCS / Test / Profile / GenAI value sets
// =============================================================================

/// Values for `tls.protocol.name`.
enum TlsProtocolName with _OTelSemanticValueMixin implements OTelSemanticValue {
  ssl('ssl'),
  tls('tls');

  @override
  final String value;
  const TlsProtocolName(this.value);
}

/// Values for `vcs.change.state`.
enum VcsChangeState with _OTelSemanticValueMixin implements OTelSemanticValue {
  open('open'),
  wip('wip'),
  closed('closed'),
  merged('merged');

  @override
  final String value;
  const VcsChangeState(this.value);
}

/// Values for `vcs.line_change.type`.
enum VcsLineChangeType
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  added('added'),
  removed('removed');

  @override
  final String value;
  const VcsLineChangeType(this.value);
}

/// Values for `vcs.ref.head.type` / `vcs.ref.base.type` / `vcs.repository.ref.type`.
enum VcsRefType with _OTelSemanticValueMixin implements OTelSemanticValue {
  branch('branch'),
  tag('tag');

  @override
  final String value;
  const VcsRefType(this.value);
}

/// Values for `test.case.result.status`.
enum TestCaseResultStatus
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  pass('pass'),
  fail('fail');

  @override
  final String value;
  const TestCaseResultStatus(this.value);
}

/// Values for `test.suite.run.status`.
enum TestSuiteRunStatus
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  success('success'),
  failure('failure'),
  timedOut('timed_out'),
  aborted('aborted'),
  skipped('skipped'),
  inProgress('in_progress');

  @override
  final String value;
  const TestSuiteRunStatus(this.value);
}

/// Values for `profile.frame.type`.
enum ProfileFrameType
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  cpython('cpython'),
  dotnet('dotnet'),
  go('go'),
  java('java'),
  nodejs('nodejs'),
  php('php'),
  perl('perl'),
  python('python'),
  ruby('ruby'),
  rust('rust');

  @override
  final String value;
  const ProfileFrameType(this.value);
}

/// Values for `gen_ai.operation.name`.
enum GenAiOperationName
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  chat('chat'),
  textCompletion('text_completion'),
  embeddings('embeddings'),
  generateContent('generate_content');

  @override
  final String value;
  const GenAiOperationName(this.value);
}

/// Values for `gen_ai.system`.
enum GenAiSystem with _OTelSemanticValueMixin implements OTelSemanticValue {
  anthropic('anthropic'),
  awsBedrock('aws.bedrock'),
  azureAiOpenai('azure.ai.openai'),
  cohere('cohere'),
  deepseek('deepseek'),
  gcpGenAi('gcp.gen_ai'),
  gcpGemini('gcp.gemini'),
  gcpVertexAi('gcp.vertex_ai'),
  groq('groq'),
  ibmWatsonxAi('ibm.watsonx.ai'),
  mistralAi('mistral_ai'),
  openai('openai'),
  perplexity('perplexity'),
  xai('xai');

  @override
  final String value;
  const GenAiSystem(this.value);
}

/// Values for `gen_ai.token.type`.
enum GenAiTokenType with _OTelSemanticValueMixin implements OTelSemanticValue {
  input('input'),
  completion('completion'),
  output('output');

  @override
  final String value;
  const GenAiTokenType(this.value);
}

// =============================================================================
// Source / process / container miscellaneous
// =============================================================================

/// Values for `container.cpu.state`.
enum ContainerCpuState
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  user('user'),
  system('system'),
  kernel('kernel');

  @override
  final String value;
  const ContainerCpuState(this.value);
}

/// Values for `process.context_switch_type`.
enum ProcessContextSwitchType
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  voluntary('voluntary'),
  involuntary('involuntary');

  @override
  final String value;
  const ProcessContextSwitchType(this.value);
}

/// Values for `process.paging.fault_type`.
enum ProcessPagingFaultType
    with _OTelSemanticValueMixin
    implements OTelSemanticValue {
  major('major'),
  minor('minor');

  @override
  final String value;
  const ProcessPagingFaultType(this.value);
}
