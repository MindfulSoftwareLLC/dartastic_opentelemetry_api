// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Non-OTelSemantic Resource Classes', () {
    group('FeatureFlagResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(FeatureFlagResource.featureFlagKey.key, equals('feature_flag.key'));
        expect(FeatureFlagResource.featureFlagVariant.key, equals('feature_flag.variant'));
        expect(FeatureFlagResource.featureFlagProviderName.key, equals('feature_flag.provider_name'));
        expect(FeatureFlagResource.featureFlagContextId.key, equals('feature_flag.context.id'));
        expect(FeatureFlagResource.featureFlagEvaluationReason.key, equals('feature_flag.evaluation.reason'));
        expect(FeatureFlagResource.featureFlagEvaluationErrorMessage.key, equals('feature_flag.evaluation.error.message'));
        expect(FeatureFlagResource.featureFlagSetId.key, equals('feature_flag.set.id'));
        expect(FeatureFlagResource.featureFlagVersion.key, equals('feature_flag.version'));
      });

      test('toString should return the key value', () {
        expect(FeatureFlagResource.featureFlagKey.toString(), equals('feature_flag.key'));
        expect(FeatureFlagResource.featureFlagVariant.toString(), equals('feature_flag.variant'));
      });
    });

    group('FileResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(FileResource.filePath.key, equals('file.path'));
        expect(FileResource.fileName.key, equals('file.name'));
        expect(FileResource.fileExtension.key, equals('file.extension'));
        expect(FileResource.fileSize.key, equals('file.size'));
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
        expect(FileResource.fileSymbolicLinkTargetPath.key, equals('file.symbolic_link.target_path'));
        expect(FileResource.fileForkName.key, equals('file.fork_name'));
        expect(FileResource.fileDirectory.key, equals('file.directory'));
      });

      test('toString should return the key value', () {
        expect(FileResource.filePath.toString(), equals('file.path'));
        expect(FileResource.fileName.toString(), equals('file.name'));
      });
    });

    group('HostResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(HostResource.hostArch.key, equals('host.arch'));
        expect(HostResource.hostCpuCacheL2Size.key, equals('host.cpu.cache.l2.size'));
        expect(HostResource.hostCpuFamily.key, equals('host.cpu.family'));
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

      test('toString should return the key value', () {
        expect(HostResource.hostArch.toString(), equals('host.arch'));
        expect(HostResource.hostId.toString(), equals('host.id'));
      });
    });

    group('GenAIResource', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(GenAIResource.genAiOperationName.key, equals('gen_ai.operation.name'));
        expect(GenAIResource.genAiRequestEncodingFormats.key, equals('gen_ai.request.encoding_formats'));
        expect(GenAIResource.genAiRequestFrequencyPenalty.key, equals('gen_ai.request.frequency_penalty'));
        expect(GenAIResource.genAiRequestMaxTokens.key, equals('gen_ai.request.max_tokens'));
        expect(GenAIResource.genAiRequestModel.key, equals('gen_ai.request.model'));
        expect(GenAIResource.genAiRequestPresencePenalty.key, equals('gen_ai.request.presence_penalty'));
        expect(GenAIResource.genAiRequestSeed.key, equals('gen_ai.request.seed'));
      });

      test('toString should return the key value', () {
        expect(GenAIResource.genAiOperationName.toString(), equals('gen_ai.operation.name'));
        expect(GenAIResource.genAiRequestModel.toString(), equals('gen_ai.request.model'));
      });
    });
  });
}
