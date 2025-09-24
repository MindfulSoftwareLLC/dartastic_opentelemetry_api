// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'dart:js_interop';

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
// Using package:web instead of deprecated dart:html
import 'package:web/web.dart';

/// This example demonstrates using the OpenTelemetry API in a web application.
/// Note that this uses the API only (which is a no-op), in a real application,
/// you would typically also use the SDK to export telemetry data.
void main() {
  // Initialize the API with a default endpoint (will be ignored as API-only)
  OTelAPI.initialize(endpoint: 'http://localhost:4317');

  // Get the output div using package:web's document.querySelector
  final outputDiv = document.querySelector('#output');
  if (outputDiv == null) {
    console.error('Could not find output div'.toJS);
    return;
  }

  // Create a simple event handler
  document.querySelector('#traceButton')?.addEventListener(
        'click',
        ((Event event) {
          // Clear the output
          outputDiv.textContent = '';

          // Get a tracer
          final tracer = OTelAPI.tracerProvider().getTracer('web-demo');

          // Start a span
          final span = tracer.startSpan('web-button-click');

          // Add some attributes to the span
          span.attributes = OTelAPI.attributesFromMap({
            'user.action': 'button_click',
            'app.type': 'web_demo',
            'timestamp': DateTime.now().toIso8601String(),
          });

          // Log an event
          span.addEventNow(
              'processing', OTelAPI.attributesFromMap({'status': 'started'}));

          // Simulate some work
          Future<void>.delayed(const Duration(milliseconds: 500)).then((_) {
            // Log another event
            span.addEventNow('processing',
                OTelAPI.attributesFromMap({'status': 'completed'}));

            // End the span
            span.end();

            // Output span information
            appendParagraph(outputDiv, 'Span created: ${span.name}');
            appendParagraph(outputDiv, 'Trace ID: ${span.spanContext.traceId}');
            appendParagraph(outputDiv, 'Span ID: ${span.spanContext.spanId}');
            appendParagraph(outputDiv, 'Start time: ${span.startTime}');
            appendParagraph(outputDiv, 'End time: ${span.endTime}');
            appendParagraph(outputDiv, 'Status: ${span.status}');
          });
        }).toJS,
      );
}

/// Helper function to create and append a paragraph element
void appendParagraph(Element parent, String text) {
  final p = document.createElement('p');
  p.textContent = text;
  parent.append(p);
}
