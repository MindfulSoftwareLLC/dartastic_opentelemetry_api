// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.


// Test script to validate the tenant format implementation
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

void main() {
  print('Initializing OTelAPI...');
  OTelAPI.initialize(
    endpoint: 'http://localhost:4317', 
    serviceName: 'test-service',
    serviceVersion: '1.0.0',
  );
  
  print('\nTesting tenant format key validation...');
  
  final testKey = 'tenant@vendor';
  final traceState = OTelAPI.traceState({testKey: 'value'});
  
  print('Created TraceState with key: $testKey');
  print('TraceState entries: ${traceState.entries}');
  print('Value for key: ${traceState.get(testKey)}');
  print('Is key present: ${traceState.get(testKey) != null}');
  
  if (traceState.get(testKey) == 'value') {
    print('SUCCESS: Tenant format key is correctly handled!');
  } else {
    print('FAILURE: Tenant format key is rejected or not stored correctly!');
  }
}
