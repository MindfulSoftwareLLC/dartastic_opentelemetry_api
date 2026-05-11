// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

/// OpenTelemetry semantic-convention metric instrument names.
///
/// Generated from the OTel semconv spec
/// (https://opentelemetry.io/docs/specs/semconv/general/metrics/).
/// Each enum below mirrors a top-level metric namespace and each entry
/// exposes the on-wire metric [name], the spec-assigned [instrument]
/// kind, and the OTel [unit] string.
///
/// Language-specific metric namespaces (`jvm.*`, `go.*`, `nodejs.*`,
/// `cpython.*`, `v8js.*`, `kestrel.*`, `aspnetcore.*`, `signalr.*`,
/// `openshift.*`, `nfs.*`) are intentionally omitted — Dart apps
/// don't emit them.
library;

/// The four OTel instrument kinds.
enum SemanticInstrument { counter, upDownCounter, histogram, gauge }

/// Base interface for metric-name enums.
abstract interface class OTelMetric {
  /// The on-wire metric name (e.g. `http.server.request.duration`).
  String get name;

  /// The OTel instrument kind the spec assigns to this metric.
  SemanticInstrument get instrument;

  /// OTel unit string (UCUM-style: `s` for seconds, `By` for bytes,
  /// `{request}` for a counted entity, `1` for dimensionless).
  String get unit;
}

/// `cicd.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/cicd/cicd-metrics/)
enum CicdMetric implements OTelMetric {
  /// The number of pipeline runs currently active in the system by state.
  pipelineRunActive(
      'cicd.pipeline.run.active', SemanticInstrument.upDownCounter, '{run}'),

  /// Duration of a pipeline run grouped by pipeline, state and result.
  pipelineRunDuration(
      'cicd.pipeline.run.duration', SemanticInstrument.histogram, 's'),

  /// The number of errors encountered in pipeline runs (eg.
  pipelineRunErrors(
      'cicd.pipeline.run.errors', SemanticInstrument.counter, '{error}'),

  /// The number of errors in a component of the CICD system (eg.
  systemErrors('cicd.system.errors', SemanticInstrument.counter, '{error}'),

  /// The number of workers on the CICD system by state.
  workerCount('cicd.worker.count', SemanticInstrument.upDownCounter, '{count}'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const CicdMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `container.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/container/container-metrics/)
enum ContainerMetric implements OTelMetric {
  /// Total CPU time consumed.
  cpuTime('container.cpu.time', SemanticInstrument.counter, 's'),

  /// Container's CPU usage, measured in cpus.
  cpuUsage('container.cpu.usage', SemanticInstrument.gauge, '{cpu}'),

  /// Disk bytes for the container.
  diskIo('container.disk.io', SemanticInstrument.counter, 'By'),

  /// Container filesystem available bytes.
  filesystemAvailable(
      'container.filesystem.available', SemanticInstrument.upDownCounter, 'By'),

  /// Container filesystem capacity.
  filesystemCapacity(
      'container.filesystem.capacity', SemanticInstrument.upDownCounter, 'By'),

  /// Container filesystem usage.
  filesystemUsage(
      'container.filesystem.usage', SemanticInstrument.upDownCounter, 'By'),

  /// Container memory available.
  memoryAvailable(
      'container.memory.available', SemanticInstrument.upDownCounter, 'By'),

  /// Container memory paging faults.
  memoryPagingFaults(
      'container.memory.paging.faults', SemanticInstrument.counter, '{fault}'),

  /// Container memory RSS.
  memoryRss('container.memory.rss', SemanticInstrument.upDownCounter, 'By'),

  /// Memory usage of the container.
  memoryUsage('container.memory.usage', SemanticInstrument.counter, 'By'),

  /// Container memory working set.
  memoryWorkingSet(
      'container.memory.working_set', SemanticInstrument.upDownCounter, 'By'),

  /// Network bytes for the container.
  networkIo('container.network.io', SemanticInstrument.counter, 'By'),

  /// The time the container has been running.
  uptime('container.uptime', SemanticInstrument.gauge, 's'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const ContainerMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `db.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/db/db-metrics/)
enum DbMetric implements OTelMetric {
  /// The number of connections that are currently in state described by the `state` a….
  clientConnectionCount('db.client.connection.count',
      SemanticInstrument.upDownCounter, '{connection}'),

  /// The time it took to create a new connection.
  clientConnectionCreateTime(
      'db.client.connection.create_time', SemanticInstrument.histogram, 's'),

  /// The maximum number of idle open connections allowed.
  clientConnectionIdleMax('db.client.connection.idle.max',
      SemanticInstrument.upDownCounter, '{connection}'),

  /// The minimum number of idle open connections allowed.
  clientConnectionIdleMin('db.client.connection.idle.min',
      SemanticInstrument.upDownCounter, '{connection}'),

  /// The maximum number of open connections allowed.
  clientConnectionMax('db.client.connection.max',
      SemanticInstrument.upDownCounter, '{connection}'),

  /// The number of current pending requests for an open connection.
  clientConnectionPendingRequests('db.client.connection.pending_requests',
      SemanticInstrument.upDownCounter, '{request}'),

  /// The number of connection timeouts that have occurred trying to obtain a connecti….
  clientConnectionTimeouts(
      'db.client.connection.timeouts', SemanticInstrument.counter, '{timeout}'),

  /// The time between borrowing a connection and returning it to the pool.
  clientConnectionUseTime(
      'db.client.connection.use_time', SemanticInstrument.histogram, 's'),

  /// The time it took to obtain an open connection from the pool.
  clientConnectionWaitTime(
      'db.client.connection.wait_time', SemanticInstrument.histogram, 's'),

  /// Duration of database client operations.
  clientOperationDuration(
      'db.client.operation.duration', SemanticInstrument.histogram, 's'),

  /// The actual number of records returned by the database operation.
  clientResponseReturnedRows('db.client.response.returned_rows',
      SemanticInstrument.histogram, '{row}'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const DbMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `dns.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/dns/dns-metrics/)
enum DnsMetric implements OTelMetric {
  /// Measures the time taken to perform a DNS lookup.
  lookupDuration('dns.lookup.duration', SemanticInstrument.histogram, 's'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const DnsMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `faas.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/faas/faas-metrics/)
enum FaasMetric implements OTelMetric {
  /// Number of invocation cold starts.
  coldstarts('faas.coldstarts', SemanticInstrument.counter, '{coldstart}'),

  /// Distribution of CPU usage per invocation.
  cpuUsage('faas.cpu_usage', SemanticInstrument.histogram, 's'),

  /// Number of invocation errors.
  errors('faas.errors', SemanticInstrument.counter, '{error}'),

  /// Measures the duration of the function's initialization, such as a cold start.
  initDuration('faas.init_duration', SemanticInstrument.histogram, 's'),

  /// Number of successful invocations.
  invocations('faas.invocations', SemanticInstrument.counter, '{invocation}'),

  /// Measures the duration of the function's logic execution.
  invokeDuration('faas.invoke_duration', SemanticInstrument.histogram, 's'),

  /// Distribution of max memory usage per invocation.
  memUsage('faas.mem_usage', SemanticInstrument.histogram, 'By'),

  /// Distribution of net I/O usage per invocation.
  netIo('faas.net_io', SemanticInstrument.histogram, 'By'),

  /// Number of invocation timeouts.
  timeouts('faas.timeouts', SemanticInstrument.counter, '{timeout}'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const FaasMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `gen-ai.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-metrics/)
enum GenAiMetric implements OTelMetric {
  /// GenAI operation duration.
  clientOperationDuration(
      'gen_ai.client.operation.duration', SemanticInstrument.histogram, 's'),

  /// >.
  clientOperationTimePerOutputChunk(
      'gen_ai.client.operation.time_per_output_chunk',
      SemanticInstrument.histogram,
      's'),

  /// Time to receive the first chunk, measured from when the client issues the genera….
  clientOperationTimeToFirstChunk('gen_ai.client.operation.time_to_first_chunk',
      SemanticInstrument.histogram, 's'),

  /// Number of input and output tokens used.
  clientTokenUsage(
      'gen_ai.client.token.usage', SemanticInstrument.histogram, '{token}'),

  /// Generative AI server request duration such as time-to-last byte or last output t….
  serverRequestDuration(
      'gen_ai.server.request.duration', SemanticInstrument.histogram, 's'),

  /// Time per output token generated after the first token for successful responses.
  serverTimePerOutputToken(
      'gen_ai.server.time_per_output_token', SemanticInstrument.histogram, 's'),

  /// Time to generate first token for successful responses.
  serverTimeToFirstToken(
      'gen_ai.server.time_to_first_token', SemanticInstrument.histogram, 's'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const GenAiMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `http.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/http/http-metrics/)
enum HttpMetric implements OTelMetric {
  /// Number of active HTTP requests.
  clientActiveRequests('http.client.active_requests',
      SemanticInstrument.upDownCounter, '{request}'),

  /// The duration of the successfully established outbound HTTP connections.
  clientConnectionDuration(
      'http.client.connection.duration', SemanticInstrument.histogram, 's'),

  /// Number of outbound HTTP connections that are currently active or idle on the cli….
  clientOpenConnections('http.client.open_connections',
      SemanticInstrument.upDownCounter, '{connection}'),

  /// Size of HTTP client request bodies.
  clientRequestBodySize(
      'http.client.request.body.size', SemanticInstrument.histogram, 'By'),

  /// Duration of HTTP client requests.
  clientRequestDuration(
      'http.client.request.duration', SemanticInstrument.histogram, 's'),

  /// Size of HTTP client response bodies.
  clientResponseBodySize(
      'http.client.response.body.size', SemanticInstrument.histogram, 'By'),

  /// Number of active HTTP server requests.
  serverActiveRequests('http.server.active_requests',
      SemanticInstrument.upDownCounter, '{request}'),

  /// Size of HTTP server request bodies.
  serverRequestBodySize(
      'http.server.request.body.size', SemanticInstrument.histogram, 'By'),

  /// Duration of HTTP server requests.
  serverRequestDuration(
      'http.server.request.duration', SemanticInstrument.histogram, 's'),

  /// Size of HTTP server response bodies.
  serverResponseBodySize(
      'http.server.response.body.size', SemanticInstrument.histogram, 'By'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const HttpMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `k8s.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/k8s/k8s-metrics/)
enum K8sMetric implements OTelMetric {
  /// Maximum CPU resource limit currently configured for a running container.
  containerCpuLimitCurrent('k8s.container.cpu.limit.current',
      SemanticInstrument.upDownCounter, '{cpu}'),

  /// Maximum CPU resource limit as defined by the container spec.
  containerCpuLimitDesired('k8s.container.cpu.limit.desired',
      SemanticInstrument.upDownCounter, '{cpu}'),

  /// The ratio of container CPU usage to its current CPU limit.
  containerCpuLimitUtilization(
      'k8s.container.cpu.limit.utilization', SemanticInstrument.gauge, '1'),

  /// CPU resource requested currently configured for a running container.
  containerCpuRequestCurrent('k8s.container.cpu.request.current',
      SemanticInstrument.upDownCounter, '{cpu}'),

  /// CPU resource requested as defined by the container spec.
  containerCpuRequestDesired('k8s.container.cpu.request.desired',
      SemanticInstrument.upDownCounter, '{cpu}'),

  /// The ratio of container CPU usage to its current CPU request.
  containerCpuRequestUtilization(
      'k8s.container.cpu.request.utilization', SemanticInstrument.gauge, '1'),

  /// Maximum ephemeral storage resource limit set for the container.
  containerEphemeralStorageLimit('k8s.container.ephemeral_storage.limit',
      SemanticInstrument.upDownCounter, 'By'),

  /// Ephemeral storage resource requested for the container.
  containerEphemeralStorageRequest('k8s.container.ephemeral_storage.request',
      SemanticInstrument.upDownCounter, 'By'),

  /// Maximum memory resource limit currently configured for a running container.
  containerMemoryLimitCurrent('k8s.container.memory.limit.current',
      SemanticInstrument.upDownCounter, 'By'),

  /// Maximum memory resource limit as defined by the container spec.
  containerMemoryLimitDesired('k8s.container.memory.limit.desired',
      SemanticInstrument.upDownCounter, 'By'),

  /// Memory resource request currently configured for a running container.
  containerMemoryRequestCurrent('k8s.container.memory.request.current',
      SemanticInstrument.upDownCounter, 'By'),

  /// Memory resource requested as defined by the container spec.
  containerMemoryRequestDesired('k8s.container.memory.request.desired',
      SemanticInstrument.upDownCounter, 'By'),

  /// >.
  containerReady(
      'k8s.container.ready', SemanticInstrument.upDownCounter, '{container}'),

  /// Describes how many times the container has restarted (since the last counter res….
  containerRestartCount('k8s.container.restart.count',
      SemanticInstrument.upDownCounter, '{restart}'),

  /// Describes the number of K8s containers that are currently in a state for a given….
  containerStatusReason('k8s.container.status.reason',
      SemanticInstrument.upDownCounter, '{container}'),

  /// Describes the number of K8s containers that are currently in a given state.
  containerStatusState('k8s.container.status.state',
      SemanticInstrument.upDownCounter, '{container}'),

  /// Maximum storage resource limit set for the container.
  containerStorageLimit(
      'k8s.container.storage.limit', SemanticInstrument.upDownCounter, 'By'),

  /// Storage resource requested for the container.
  containerStorageRequest(
      'k8s.container.storage.request', SemanticInstrument.upDownCounter, 'By'),

  /// The number of actively running jobs for a cronjob.
  cronjobJobActive(
      'k8s.cronjob.job.active', SemanticInstrument.upDownCounter, '{job}'),

  /// Number of nodes that are running at least 1 daemon pod and are supposed to run t….
  daemonsetNodeCurrentScheduled('k8s.daemonset.node.current_scheduled',
      SemanticInstrument.upDownCounter, '{node}'),

  /// Number of nodes that should be running the daemon pod (including nodes currently….
  daemonsetNodeDesiredScheduled('k8s.daemonset.node.desired_scheduled',
      SemanticInstrument.upDownCounter, '{node}'),

  /// Number of nodes that are running the daemon pod, but are not supposed to run the….
  daemonsetNodeMisscheduled('k8s.daemonset.node.misscheduled',
      SemanticInstrument.upDownCounter, '{node}'),

  /// Number of nodes that should be running the daemon pod and have one or more of th….
  daemonsetNodeReady(
      'k8s.daemonset.node.ready', SemanticInstrument.upDownCounter, '{node}'),

  /// Total number of available replica pods (ready for at least minReadySeconds) targ….
  deploymentPodAvailable('k8s.deployment.pod.available',
      SemanticInstrument.upDownCounter, '{pod}'),

  /// Number of desired replica pods in this deployment.
  deploymentPodDesired(
      'k8s.deployment.pod.desired', SemanticInstrument.upDownCounter, '{pod}'),

  /// Target average utilization, in percentage, for CPU resource in HPA config.
  hpaMetricTargetCpuAverageUtilization(
      'k8s.hpa.metric.target.cpu.average_utilization',
      SemanticInstrument.gauge,
      '1'),

  /// Target average value for CPU resource in HPA config.
  hpaMetricTargetCpuAverageValue('k8s.hpa.metric.target.cpu.average_value',
      SemanticInstrument.gauge, '{cpu}'),

  /// Target value for CPU resource in HPA config.
  hpaMetricTargetCpuValue(
      'k8s.hpa.metric.target.cpu.value', SemanticInstrument.gauge, '{cpu}'),

  /// Current number of replica pods managed by this horizontal pod autoscaler, as las….
  hpaPodCurrent(
      'k8s.hpa.pod.current', SemanticInstrument.upDownCounter, '{pod}'),

  /// Desired number of replica pods managed by this horizontal pod autoscaler, as las….
  hpaPodDesired(
      'k8s.hpa.pod.desired', SemanticInstrument.upDownCounter, '{pod}'),

  /// The upper limit for the number of replica pods to which the autoscaler can scale….
  hpaPodMax('k8s.hpa.pod.max', SemanticInstrument.upDownCounter, '{pod}'),

  /// The lower limit for the number of replica pods to which the autoscaler can scale….
  hpaPodMin('k8s.hpa.pod.min', SemanticInstrument.upDownCounter, '{pod}'),

  /// The number of pending and actively running pods for a job.
  jobPodActive('k8s.job.pod.active', SemanticInstrument.upDownCounter, '{pod}'),

  /// The desired number of successfully finished pods the job should be run with.
  jobPodDesiredSuccessful('k8s.job.pod.desired_successful',
      SemanticInstrument.upDownCounter, '{pod}'),

  /// The number of pods which reached phase Failed for a job.
  jobPodFailed('k8s.job.pod.failed', SemanticInstrument.upDownCounter, '{pod}'),

  /// The max desired number of pods the job should run at any given time.
  jobPodMaxParallel(
      'k8s.job.pod.max_parallel', SemanticInstrument.upDownCounter, '{pod}'),

  /// The number of pods which reached phase Succeeded for a job.
  jobPodSuccessful(
      'k8s.job.pod.successful', SemanticInstrument.upDownCounter, '{pod}'),

  /// Describes number of K8s namespaces that are currently in a given phase.
  namespacePhase(
      'k8s.namespace.phase', SemanticInstrument.upDownCounter, '{namespace}'),

  /// Describes the condition of a particular Node.
  nodeConditionStatus(
      'k8s.node.condition.status', SemanticInstrument.upDownCounter, '{node}'),

  /// Amount of cpu allocatable on the node.
  nodeCpuAllocatable(
      'k8s.node.cpu.allocatable', SemanticInstrument.upDownCounter, '{cpu}'),

  /// Total CPU time consumed.
  nodeCpuTime('k8s.node.cpu.time', SemanticInstrument.counter, 's'),

  /// Node's CPU usage, measured in cpus.
  nodeCpuUsage('k8s.node.cpu.usage', SemanticInstrument.gauge, '{cpu}'),

  /// Amount of ephemeral-storage allocatable on the node.
  nodeEphemeralStorageAllocatable('k8s.node.ephemeral_storage.allocatable',
      SemanticInstrument.upDownCounter, 'By'),

  /// Node filesystem available bytes.
  nodeFilesystemAvailable(
      'k8s.node.filesystem.available', SemanticInstrument.upDownCounter, 'By'),

  /// Node filesystem capacity.
  nodeFilesystemCapacity(
      'k8s.node.filesystem.capacity', SemanticInstrument.upDownCounter, 'By'),

  /// Node filesystem usage.
  nodeFilesystemUsage(
      'k8s.node.filesystem.usage', SemanticInstrument.upDownCounter, 'By'),

  /// Amount of memory allocatable on the node.
  nodeMemoryAllocatable(
      'k8s.node.memory.allocatable', SemanticInstrument.upDownCounter, 'By'),

  /// Node memory available.
  nodeMemoryAvailable(
      'k8s.node.memory.available', SemanticInstrument.upDownCounter, 'By'),

  /// Node memory paging faults.
  nodeMemoryPagingFaults(
      'k8s.node.memory.paging.faults', SemanticInstrument.counter, '{fault}'),

  /// Node memory RSS.
  nodeMemoryRss('k8s.node.memory.rss', SemanticInstrument.upDownCounter, 'By'),

  /// Memory usage of the Node.
  nodeMemoryUsage('k8s.node.memory.usage', SemanticInstrument.gauge, 'By'),

  /// Node memory working set.
  nodeMemoryWorkingSet(
      'k8s.node.memory.working_set', SemanticInstrument.upDownCounter, 'By'),

  /// Node network errors.
  nodeNetworkErrors(
      'k8s.node.network.errors', SemanticInstrument.counter, '{error}'),

  /// Network bytes for the Node.
  nodeNetworkIo('k8s.node.network.io', SemanticInstrument.counter, 'By'),

  /// Amount of pods allocatable on the node.
  nodePodAllocatable(
      'k8s.node.pod.allocatable', SemanticInstrument.upDownCounter, '{pod}'),

  /// Node's system container CPU time.
  nodeSystemContainerCpuTime(
      'k8s.node.system_container.cpu.time', SemanticInstrument.counter, 's'),

  /// Node's system container CPU usage, measured in cpus.
  nodeSystemContainerCpuUsage(
      'k8s.node.system_container.cpu.usage', SemanticInstrument.gauge, '{cpu}'),

  /// Node's system container memory usage.
  nodeSystemContainerMemoryUsage('k8s.node.system_container.memory.usage',
      SemanticInstrument.upDownCounter, 'By'),

  /// The amount of working set memory.
  nodeSystemContainerMemoryWorkingSet(
      'k8s.node.system_container.memory.working_set',
      SemanticInstrument.upDownCounter,
      'By'),

  /// The time the Node has been running.
  nodeUptime('k8s.node.uptime', SemanticInstrument.gauge, 's'),

  /// Number of PersistentVolumes in a given phase.
  persistentvolumeStatusPhase('k8s.persistentvolume.status.phase',
      SemanticInstrument.upDownCounter, '{persistentvolume}'),

  /// The storage capacity of the PersistentVolume.
  persistentvolumeStorageCapacity('k8s.persistentvolume.storage.capacity',
      SemanticInstrument.upDownCounter, 'By'),

  /// Number of PersistentVolumeClaims in a given phase.
  persistentvolumeclaimStatusPhase('k8s.persistentvolumeclaim.status.phase',
      SemanticInstrument.upDownCounter, '{persistentvolumeclaim}'),

  /// The actual storage capacity provisioned for the PersistentVolumeClaim.
  persistentvolumeclaimStorageCapacity(
      'k8s.persistentvolumeclaim.storage.capacity',
      SemanticInstrument.upDownCounter,
      'By'),

  /// The storage requested by the PersistentVolumeClaim.
  persistentvolumeclaimStorageRequest(
      'k8s.persistentvolumeclaim.storage.request',
      SemanticInstrument.upDownCounter,
      'By'),

  /// Total CPU time consumed.
  podCpuTime('k8s.pod.cpu.time', SemanticInstrument.counter, 's'),

  /// Pod's CPU usage, measured in cpus.
  podCpuUsage('k8s.pod.cpu.usage', SemanticInstrument.gauge, '{cpu}'),

  /// Pod filesystem available bytes.
  podFilesystemAvailable(
      'k8s.pod.filesystem.available', SemanticInstrument.upDownCounter, 'By'),

  /// Pod filesystem capacity.
  podFilesystemCapacity(
      'k8s.pod.filesystem.capacity', SemanticInstrument.upDownCounter, 'By'),

  /// Pod filesystem usage.
  podFilesystemUsage(
      'k8s.pod.filesystem.usage', SemanticInstrument.upDownCounter, 'By'),

  /// Pod memory available.
  podMemoryAvailable(
      'k8s.pod.memory.available', SemanticInstrument.upDownCounter, 'By'),

  /// Pod memory paging faults.
  podMemoryPagingFaults(
      'k8s.pod.memory.paging.faults', SemanticInstrument.counter, '{fault}'),

  /// Pod memory RSS.
  podMemoryRss('k8s.pod.memory.rss', SemanticInstrument.upDownCounter, 'By'),

  /// Memory usage of the Pod.
  podMemoryUsage('k8s.pod.memory.usage', SemanticInstrument.gauge, 'By'),

  /// Pod memory working set.
  podMemoryWorkingSet(
      'k8s.pod.memory.working_set', SemanticInstrument.upDownCounter, 'By'),

  /// Pod network errors.
  podNetworkErrors(
      'k8s.pod.network.errors', SemanticInstrument.counter, '{error}'),

  /// Network bytes for the Pod.
  podNetworkIo('k8s.pod.network.io', SemanticInstrument.counter, 'By'),

  /// Describes number of K8s Pods that are currently in a given phase.
  podStatusPhase(
      'k8s.pod.status.phase', SemanticInstrument.upDownCounter, '{pod}'),

  /// Describes the number of K8s Pods that are currently in a state for a given reaso….
  podStatusReason(
      'k8s.pod.status.reason', SemanticInstrument.upDownCounter, '{pod}'),

  /// The time the Pod has been running.
  podUptime('k8s.pod.uptime', SemanticInstrument.gauge, 's'),

  /// Pod volume storage space available.
  podVolumeAvailable(
      'k8s.pod.volume.available', SemanticInstrument.upDownCounter, 'By'),

  /// Pod volume total capacity.
  podVolumeCapacity(
      'k8s.pod.volume.capacity', SemanticInstrument.upDownCounter, 'By'),

  /// The total inodes in the filesystem of the Pod's volume.
  podVolumeInodeCount('k8s.pod.volume.inode.count',
      SemanticInstrument.upDownCounter, '{inode}'),

  /// The free inodes in the filesystem of the Pod's volume.
  podVolumeInodeFree(
      'k8s.pod.volume.inode.free', SemanticInstrument.upDownCounter, '{inode}'),

  /// The inodes used by the filesystem of the Pod's volume.
  podVolumeInodeUsed(
      'k8s.pod.volume.inode.used', SemanticInstrument.upDownCounter, '{inode}'),

  /// Pod volume usage.
  podVolumeUsage(
      'k8s.pod.volume.usage', SemanticInstrument.upDownCounter, 'By'),

  /// Total number of available replica pods (ready for at least minReadySeconds) targ….
  replicasetPodAvailable('k8s.replicaset.pod.available',
      SemanticInstrument.upDownCounter, '{pod}'),

  /// Number of desired replica pods in this replicaset.
  replicasetPodDesired(
      'k8s.replicaset.pod.desired', SemanticInstrument.upDownCounter, '{pod}'),

  /// Total number of available replica pods (ready for at least minReadySeconds) targ….
  replicationcontrollerPodAvailable('k8s.replicationcontroller.pod.available',
      SemanticInstrument.upDownCounter, '{pod}'),

  /// Number of desired replica pods in this replication controller.
  replicationcontrollerPodDesired('k8s.replicationcontroller.pod.desired',
      SemanticInstrument.upDownCounter, '{pod}'),

  /// |.
  resourcequotaCpuLimitHard('k8s.resourcequota.cpu.limit.hard',
      SemanticInstrument.upDownCounter, '{cpu}'),

  /// |.
  resourcequotaCpuLimitUsed('k8s.resourcequota.cpu.limit.used',
      SemanticInstrument.upDownCounter, '{cpu}'),

  /// |.
  resourcequotaCpuRequestHard('k8s.resourcequota.cpu.request.hard',
      SemanticInstrument.upDownCounter, '{cpu}'),

  /// |.
  resourcequotaCpuRequestUsed('k8s.resourcequota.cpu.request.used',
      SemanticInstrument.upDownCounter, '{cpu}'),

  /// |.
  resourcequotaEphemeralStorageLimitHard(
      'k8s.resourcequota.ephemeral_storage.limit.hard',
      SemanticInstrument.upDownCounter,
      'By'),

  /// |.
  resourcequotaEphemeralStorageLimitUsed(
      'k8s.resourcequota.ephemeral_storage.limit.used',
      SemanticInstrument.upDownCounter,
      'By'),

  /// |.
  resourcequotaEphemeralStorageRequestHard(
      'k8s.resourcequota.ephemeral_storage.request.hard',
      SemanticInstrument.upDownCounter,
      'By'),

  /// |.
  resourcequotaEphemeralStorageRequestUsed(
      'k8s.resourcequota.ephemeral_storage.request.used',
      SemanticInstrument.upDownCounter,
      'By'),

  /// |.
  resourcequotaHugepageCountRequestHard(
      'k8s.resourcequota.hugepage_count.request.hard',
      SemanticInstrument.upDownCounter,
      '{hugepage}'),

  /// |.
  resourcequotaHugepageCountRequestUsed(
      'k8s.resourcequota.hugepage_count.request.used',
      SemanticInstrument.upDownCounter,
      '{hugepage}'),

  /// |.
  resourcequotaMemoryLimitHard('k8s.resourcequota.memory.limit.hard',
      SemanticInstrument.upDownCounter, 'By'),

  /// |.
  resourcequotaMemoryLimitUsed('k8s.resourcequota.memory.limit.used',
      SemanticInstrument.upDownCounter, 'By'),

  /// |.
  resourcequotaMemoryRequestHard('k8s.resourcequota.memory.request.hard',
      SemanticInstrument.upDownCounter, 'By'),

  /// |.
  resourcequotaMemoryRequestUsed('k8s.resourcequota.memory.request.used',
      SemanticInstrument.upDownCounter, 'By'),

  /// |.
  resourcequotaObjectCountHard('k8s.resourcequota.object_count.hard',
      SemanticInstrument.upDownCounter, '{object}'),

  /// |.
  resourcequotaObjectCountUsed('k8s.resourcequota.object_count.used',
      SemanticInstrument.upDownCounter, '{object}'),

  /// |.
  resourcequotaPersistentvolumeclaimCountHard(
      'k8s.resourcequota.persistentvolumeclaim_count.hard',
      SemanticInstrument.upDownCounter,
      '{persistentvolumeclaim}'),

  /// |.
  resourcequotaPersistentvolumeclaimCountUsed(
      'k8s.resourcequota.persistentvolumeclaim_count.used',
      SemanticInstrument.upDownCounter,
      '{persistentvolumeclaim}'),

  /// |.
  resourcequotaStorageRequestHard('k8s.resourcequota.storage.request.hard',
      SemanticInstrument.upDownCounter, 'By'),

  /// |.
  resourcequotaStorageRequestUsed('k8s.resourcequota.storage.request.used',
      SemanticInstrument.upDownCounter, 'By'),

  /// Number of endpoints for a service by condition and address type.
  serviceEndpointCount(
      'k8s.service.endpoint.count', SemanticInstrument.gauge, '{endpoint}'),

  /// Number of load balancer ingress points (external IPs/hostnames) assigned to the ….
  serviceLoadBalancerIngressCount('k8s.service.load_balancer.ingress.count',
      SemanticInstrument.gauge, '{ingress}'),

  /// The number of replica pods created by the statefulset controller from the statef….
  statefulsetPodCurrent(
      'k8s.statefulset.pod.current', SemanticInstrument.upDownCounter, '{pod}'),

  /// Number of desired replica pods in this statefulset.
  statefulsetPodDesired(
      'k8s.statefulset.pod.desired', SemanticInstrument.upDownCounter, '{pod}'),

  /// The number of replica pods created for this statefulset with a Ready Condition.
  statefulsetPodReady(
      'k8s.statefulset.pod.ready', SemanticInstrument.upDownCounter, '{pod}'),

  /// Number of replica pods created by the statefulset controller from the statefulse….
  statefulsetPodUpdated(
      'k8s.statefulset.pod.updated', SemanticInstrument.upDownCounter, '{pod}'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const K8sMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `mcp.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/mcp/mcp-metrics/)
enum McpMetric implements OTelMetric {
  /// >.
  clientOperationDuration(
      'mcp.client.operation.duration', SemanticInstrument.histogram, 's'),

  /// The duration of the MCP session as observed on the MCP client.
  clientSessionDuration(
      'mcp.client.session.duration', SemanticInstrument.histogram, 's'),

  /// >.
  serverOperationDuration(
      'mcp.server.operation.duration', SemanticInstrument.histogram, 's'),

  /// The duration of the MCP session as observed on the MCP server.
  serverSessionDuration(
      'mcp.server.session.duration', SemanticInstrument.histogram, 's'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const McpMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `messaging.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/messaging/messaging-metrics/)
enum MessagingMetric implements OTelMetric {
  /// Number of messages that were delivered to the application.
  clientConsumedMessages('messaging.client.consumed.messages',
      SemanticInstrument.counter, '{message}'),

  /// Duration of messaging operation initiated by a producer or consumer client.
  clientOperationDuration(
      'messaging.client.operation.duration', SemanticInstrument.histogram, 's'),

  /// Number of messages producer attempted to send to the broker.
  clientSentMessages('messaging.client.sent.messages',
      SemanticInstrument.counter, '{message}'),

  /// Duration of processing operation.
  processDuration(
      'messaging.process.duration', SemanticInstrument.histogram, 's'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const MessagingMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `otel.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/otel/otel-metrics/)
enum OtelMetric implements OTelMetric {
  /// The number of log records for which the export has finished, either successful o….
  sdkExporterLogExported('otel.sdk.exporter.log.exported',
      SemanticInstrument.counter, '{log_record}'),

  /// The number of log records which were passed to the exporter, but that have not b….
  sdkExporterLogInflight('otel.sdk.exporter.log.inflight',
      SemanticInstrument.upDownCounter, '{log_record}'),

  /// The number of metric data points for which the export has finished, either succe….
  sdkExporterMetricDataPointExported(
      'otel.sdk.exporter.metric_data_point.exported',
      SemanticInstrument.counter,
      '{data_point}'),

  /// The number of metric data points which were passed to the exporter, but that hav….
  sdkExporterMetricDataPointInflight(
      'otel.sdk.exporter.metric_data_point.inflight',
      SemanticInstrument.upDownCounter,
      '{data_point}'),

  /// The duration of exporting a batch of telemetry records.
  sdkExporterOperationDuration('otel.sdk.exporter.operation.duration',
      SemanticInstrument.histogram, 's'),

  /// The number of spans for which the export has finished, either successful or fail….
  sdkExporterSpanExported(
      'otel.sdk.exporter.span.exported', SemanticInstrument.counter, '{span}'),

  /// The number of spans which were passed to the exporter, but that have not been ex….
  sdkExporterSpanInflight('otel.sdk.exporter.span.inflight',
      SemanticInstrument.upDownCounter, '{span}'),

  /// The number of logs submitted to enabled SDK Loggers.
  sdkLogCreated(
      'otel.sdk.log.created', SemanticInstrument.counter, '{log_record}'),

  /// The duration of the collect operation of the metric reader.
  sdkMetricReaderCollectionDuration(
      'otel.sdk.metric_reader.collection.duration',
      SemanticInstrument.histogram,
      's'),

  /// The number of log records for which the processing has finished, either successf….
  sdkProcessorLogProcessed('otel.sdk.processor.log.processed',
      SemanticInstrument.counter, '{log_record}'),

  /// The maximum number of log records the queue of a given instance of an SDK Log Re….
  sdkProcessorLogQueueCapacity('otel.sdk.processor.log.queue.capacity',
      SemanticInstrument.upDownCounter, '{log_record}'),

  /// The number of log records in the queue of a given instance of an SDK log process….
  sdkProcessorLogQueueSize('otel.sdk.processor.log.queue.size',
      SemanticInstrument.upDownCounter, '{log_record}'),

  /// The number of spans for which the processing has finished, either successful or ….
  sdkProcessorSpanProcessed('otel.sdk.processor.span.processed',
      SemanticInstrument.counter, '{span}'),

  /// The maximum number of spans the queue of a given instance of an SDK span process….
  sdkProcessorSpanQueueCapacity('otel.sdk.processor.span.queue.capacity',
      SemanticInstrument.upDownCounter, '{span}'),

  /// The number of spans in the queue of a given instance of an SDK span processor.
  sdkProcessorSpanQueueSize('otel.sdk.processor.span.queue.size',
      SemanticInstrument.upDownCounter, '{span}'),

  /// The number of created spans with `recording=true` for which the end operation ha….
  sdkSpanLive('otel.sdk.span.live', SemanticInstrument.upDownCounter, '{span}'),

  /// The number of created spans.
  sdkSpanStarted('otel.sdk.span.started', SemanticInstrument.counter, '{span}'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const OtelMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `process.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/process/process-metrics/)
enum ProcessMetric implements OTelMetric {
  /// Number of times the process has been context switched.
  contextSwitches('process.context_switches', SemanticInstrument.counter,
      '{context_switch}'),

  /// Total CPU seconds broken down by different CPU modes.
  cpuTime('process.cpu.time', SemanticInstrument.counter, 's'),

  /// Difference in process.
  cpuUtilization('process.cpu.utilization', SemanticInstrument.gauge, '1'),

  /// Disk bytes transferred.
  diskIo('process.disk.io', SemanticInstrument.counter, 'By'),

  /// The amount of physical memory in use.
  memoryUsage('process.memory.usage', SemanticInstrument.upDownCounter, 'By'),

  /// The amount of committed virtual memory.
  memoryVirtual(
      'process.memory.virtual', SemanticInstrument.upDownCounter, 'By'),

  /// Network bytes transferred.
  networkIo('process.network.io', SemanticInstrument.counter, 'By'),

  /// Number of page faults the process has made.
  pagingFaults('process.paging.faults', SemanticInstrument.counter, '{fault}'),

  /// Process threads count.
  threadCount(
      'process.thread.count', SemanticInstrument.upDownCounter, '{thread}'),

  /// Number of unix file descriptors in use by the process.
  unixFileDescriptorCount('process.unix.file_descriptor.count',
      SemanticInstrument.upDownCounter, '{file_descriptor}'),

  /// The time the process has been running.
  uptime('process.uptime', SemanticInstrument.gauge, 's'),

  /// Number of handles held by the process.
  windowsHandleCount('process.windows.handle.count',
      SemanticInstrument.upDownCounter, '{handle}'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const ProcessMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `rpc.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/rpc/rpc-metrics/)
enum RpcMetric implements OTelMetric {
  /// Measures the duration of an outgoing Remote Procedure Call (RPC).
  clientCallDuration(
      'rpc.client.call.duration', SemanticInstrument.histogram, 's'),

  /// Measures the duration of an incoming Remote Procedure Call (RPC).
  serverCallDuration(
      'rpc.server.call.duration', SemanticInstrument.histogram, 's'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const RpcMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `system.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/system/system-metrics/)
enum SystemMetric implements OTelMetric {
  /// Operating frequency of the logical CPU in Hertz.
  cpuFrequency('system.cpu.frequency', SemanticInstrument.gauge, 'Hz'),

  /// Reports the number of logical (virtual) processor cores created by the operating….
  cpuLogicalCount(
      'system.cpu.logical.count', SemanticInstrument.upDownCounter, '{cpu}'),

  /// Reports the number of actual physical processor cores on the hardware.
  cpuPhysicalCount(
      'system.cpu.physical.count', SemanticInstrument.upDownCounter, '{cpu}'),

  /// Seconds each logical CPU spent on each mode.
  cpuTime('system.cpu.time', SemanticInstrument.counter, 's'),

  /// For each logical CPU, the utilization is calculated as the change in cumulative ….
  cpuUtilization('system.cpu.utilization', SemanticInstrument.gauge, '1'),

  /// Disk bytes transferred.
  diskIo('system.disk.io', SemanticInstrument.counter, 'By'),

  /// Time disk spent activated.
  diskIoTime('system.disk.io_time', SemanticInstrument.counter, 's'),

  /// The total storage capacity of the disk.
  diskLimit('system.disk.limit', SemanticInstrument.upDownCounter, 'By'),

  /// The number of disk reads/writes merged into single physical disk access operatio….
  diskMerged('system.disk.merged', SemanticInstrument.counter, '{operation}'),

  /// Sum of the time each operation took to complete.
  diskOperationTime(
      'system.disk.operation_time', SemanticInstrument.counter, 's'),

  /// Disk operations count.
  diskOperations(
      'system.disk.operations', SemanticInstrument.counter, '{operation}'),

  /// The total storage capacity of the filesystem.
  filesystemLimit(
      'system.filesystem.limit', SemanticInstrument.upDownCounter, 'By'),

  /// Reports a filesystem's space usage across different states.
  filesystemUsage(
      'system.filesystem.usage', SemanticInstrument.upDownCounter, 'By'),

  /// Fraction of filesystem bytes used.
  filesystemUtilization(
      'system.filesystem.utilization', SemanticInstrument.gauge, '1'),

  /// Total virtual memory available in the system.
  memoryLimit('system.memory.limit', SemanticInstrument.upDownCounter, 'By'),

  /// An estimate of how much memory is available for starting new applications, witho….
  memoryLinuxAvailable(
      'system.memory.linux.available', SemanticInstrument.upDownCounter, 'By'),

  /// Total number of hugepages available.
  memoryLinuxHugepagesLimit('system.memory.linux.hugepages.limit',
      SemanticInstrument.upDownCounter, '{page}'),

  /// System hugepage size in bytes.
  memoryLinuxHugepagesPageSize('system.memory.linux.hugepages.page_size',
      SemanticInstrument.upDownCounter, 'By'),

  /// Number of reserved hugepages.
  memoryLinuxHugepagesReserved('system.memory.linux.hugepages.reserved',
      SemanticInstrument.upDownCounter, '{page}'),

  /// Number of surplus hugepages.
  memoryLinuxHugepagesSurplus('system.memory.linux.hugepages.surplus',
      SemanticInstrument.upDownCounter, '{page}'),

  /// Number of hugepages in use by state.
  memoryLinuxHugepagesUsage('system.memory.linux.hugepages.usage',
      SemanticInstrument.upDownCounter, '{page}'),

  /// Percentage of hugepages in use by state.
  memoryLinuxHugepagesUtilization('system.memory.linux.hugepages.utilization',
      SemanticInstrument.gauge, '1'),

  /// Shared memory used (mostly by tmpfs).
  memoryLinuxShared(
      'system.memory.linux.shared', SemanticInstrument.upDownCounter, 'By'),

  /// Reports the memory used by the Linux kernel for managing caches of frequently us….
  memoryLinuxSlabUsage(
      'system.memory.linux.slab.usage', SemanticInstrument.upDownCounter, 'By'),

  /// Reports memory in use by state.
  memoryUsage('system.memory.usage', SemanticInstrument.upDownCounter, 'By'),

  /// Percentage of memory bytes in use.
  memoryUtilization('system.memory.utilization', SemanticInstrument.gauge, '1'),

  /// The number of connections.
  networkConnectionCount('system.network.connection.count',
      SemanticInstrument.upDownCounter, '{connection}'),

  /// Count of network errors detected.
  networkErrors('system.network.errors', SemanticInstrument.counter, '{error}'),

  /// The number of bytes transmitted and received.
  networkIo('system.network.io', SemanticInstrument.counter, 'By'),

  /// The number of packets transferred.
  networkPacketCount(
      'system.network.packet.count', SemanticInstrument.counter, '{packet}'),

  /// Count of packets that are dropped or discarded even though there was no error.
  networkPacketDropped(
      'system.network.packet.dropped', SemanticInstrument.counter, '{packet}'),

  /// The number of page faults.
  pagingFaults('system.paging.faults', SemanticInstrument.counter, '{fault}'),

  /// The number of paging operations.
  pagingOperations(
      'system.paging.operations', SemanticInstrument.counter, '{operation}'),

  /// Unix swap or windows pagefile usage.
  pagingUsage('system.paging.usage', SemanticInstrument.upDownCounter, 'By'),

  /// Swap (unix) or pagefile (windows) utilization.
  pagingUtilization('system.paging.utilization', SemanticInstrument.gauge, '1'),

  /// Total number of processes in each state.
  processCount(
      'system.process.count', SemanticInstrument.upDownCounter, '{process}'),

  /// Total number of processes created over uptime of the host.
  processCreated(
      'system.process.created', SemanticInstrument.counter, '{process}'),

  /// The time the system has been running.
  uptime('system.uptime', SemanticInstrument.gauge, 's'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const SystemMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}

/// `vcs.*` metric instruments.
/// [Spec](https://opentelemetry.io/docs/specs/semconv/vcs/vcs-metrics/)
enum VcsMetric implements OTelMetric {
  /// The number of changes (pull requests/merge requests/changelists) in a repository….
  changeCount('vcs.change.count', SemanticInstrument.upDownCounter, '{change}'),

  /// The time duration a change (pull request/merge request/changelist) has been in a….
  changeDuration('vcs.change.duration', SemanticInstrument.gauge, 's'),

  /// The amount of time since its creation it took a change (pull request/merge reque….
  changeTimeToApproval(
      'vcs.change.time_to_approval', SemanticInstrument.gauge, 's'),

  /// The amount of time since its creation it took a change (pull request/merge reque….
  changeTimeToMerge('vcs.change.time_to_merge', SemanticInstrument.gauge, 's'),

  /// The number of unique contributors to a repository.
  contributorCount(
      'vcs.contributor.count', SemanticInstrument.gauge, '{contributor}'),

  /// The number of refs of type branch or tag in a repository.
  refCount('vcs.ref.count', SemanticInstrument.upDownCounter, '{ref}'),

  /// The number of lines added/removed in a ref (branch) relative to the ref from the….
  refLinesDelta('vcs.ref.lines_delta', SemanticInstrument.gauge, '{line}'),

  /// The number of revisions (commits) a ref (branch) is ahead/behind the branch from….
  refRevisionsDelta(
      'vcs.ref.revisions_delta', SemanticInstrument.gauge, '{revision}'),

  /// Time a ref (branch) created from the default branch (trunk) has existed.
  refTime('vcs.ref.time', SemanticInstrument.gauge, 's'),

  /// The number of repositories in an organization.
  repositoryCount(
      'vcs.repository.count', SemanticInstrument.upDownCounter, '{repository}'),
  ;

  @override
  final String name;
  @override
  final SemanticInstrument instrument;
  @override
  final String unit;

  const VcsMetric(this.name, this.instrument, this.unit);

  @override
  String toString() => name;
}
