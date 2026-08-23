// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

import 'dart:isolate';

import '../../util/otel_error_handler.dart';

export 'dart:isolate';

/// Runs a computation in a new isolate and returns the result.
/// This implementation uses the standard dart:isolate implementation.
Future<T> runIsolateComputation<T>(
    Future<T> Function() computation,
    Map<String, dynamic> serializedContext,
    Map<String, dynamic> serializedFactory,
    Function factoryFactory) async {
  return await Isolate.run(() async {
    // Actual implementation is in context.dart
    // This just re-exports dart:isolate for non-web platforms
    throw UnimplementedError(
        'runIsolateComputation should never be called directly');
  });
}

/// Runs [childMain] in a new isolate, first delivering the parent's
/// user-installed error handler ([OTelErrorHandling.installedHandler],
/// held by the parent's factory) to the child over an explicit port
/// handshake (api#94).
///
/// Defaults are never forwarded: the child resolves its own factory's
/// `defaultErrorHandler` once `OTelFactory.deserialize` has installed the
/// child factory — a custom factory reconstructs its default natively. A
/// handler whose captured state cannot cross the isolate boundary
/// degrades to the child default (reported through the parent's handler)
/// instead of failing the spawn. Handlers are copied, not shared: a
/// handler that must aggregate in the parent should capture a [SendPort]
/// and forward reports through it.
Future<T> runIsolateWithErrorHandlerBridge<T>(Future<T> Function() childMain) {
  final parentHandler = OTelErrorHandling.installedHandler;
  if (parentHandler == null) {
    return Isolate.run(childMain);
  }

  final fromChild = ReceivePort();
  final parentSend = fromChild.sendPort;
  final sub = fromChild.listen((message) {
    if (message is SendPort) {
      try {
        message.send(parentHandler);
      } catch (_) {
        // The handler's captured state is not sendable; the child keeps
        // its default handler. Surface the degradation to the parent's
        // handler so it is not silent.
        message.send(null);
        OTelErrorHandling.report(
          StateError(
            'OTel error handler could not be sent to a child isolate '
            '(it captures non-sendable state); the child isolate ran '
            'with the default handler. Capture a SendPort instead to '
            'aggregate reports across isolates.',
          ),
        );
      }
    }
  });

  return _spawnWithHandlerHandshake(parentSend, childMain)
      .whenComplete(() async {
    await sub.cancel();
    fromChild.close();
  });
}

// A top-level function so the closure sent to the child isolate captures
// only its (sendable) parameters. A local closure would share its context
// object with sibling locals like the parent's ReceivePort, making the
// whole message unsendable.
Future<T> _spawnWithHandlerHandshake<T>(
  SendPort parentSend,
  Future<T> Function() childMain,
) {
  return Isolate.run(() async {
    final handlerPort = ReceivePort();
    parentSend.send(handlerPort.sendPort);
    final received = await handlerPort.first;
    handlerPort.close();
    if (received is OTelErrorHandler) {
      // The child has no factory yet — childMain installs one via
      // OTelFactory.deserialize. Installing here buffers the handler,
      // and factory installation adopts it (the same pre-init path as
      // OTelAPI.setErrorHandler before initialize()).
      OTelErrorHandling.handler = received;
    }
    return childMain();
  });
}
