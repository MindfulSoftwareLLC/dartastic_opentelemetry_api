// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('Non-OTelSemantic Resource Classes', () {
    group('FeatureFlag', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
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

      test('toString should return the key value', () {
        expect(
            FeatureFlag.featureFlagKey.toString(), equals('feature_flag.key'));
        expect(FeatureFlag.featureFlagVariant.toString(),
            equals('feature_flag.variant'));
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
        expect(FileResource.fileSymbolicLinkTargetPath.key,
            equals('file.symbolic_link.target_path'));
        expect(FileResource.fileForkName.key, equals('file.fork_name'));
        expect(FileResource.fileDirectory.key, equals('file.directory'));
      });

      test('toString should return the key value', () {
        expect(FileResource.filePath.toString(), equals('file.path'));
        expect(FileResource.fileName.toString(), equals('file.name'));
      });
    });

    group('Host', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(Host.hostArch.key, equals('host.arch'));
        expect(Host.hostCpuCacheL2Size.key, equals('host.cpu.cache.l2.size'));
        expect(Host.hostCpuFamily.key, equals('host.cpu.family'));
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

      test('toString should return the key value', () {
        expect(Host.hostArch.toString(), equals('host.arch'));
        expect(Host.hostId.toString(), equals('host.id'));
      });
    });

    group('GenAI', () {
      test('should have correct keys for all values', () {
        // Test each value explicitly
        expect(GenAI.genAiOperationName.key, equals('gen_ai.operation.name'));
        expect(GenAI.genAiRequestEncodingFormats.key,
            equals('gen_ai.request.encoding_formats'));
        expect(GenAI.genAiRequestFrequencyPenalty.key,
            equals('gen_ai.request.frequency_penalty'));
        expect(GenAI.genAiRequestMaxTokens.key,
            equals('gen_ai.request.max_tokens'));
        expect(GenAI.genAiRequestModel.key, equals('gen_ai.request.model'));
        expect(GenAI.genAiRequestPresencePenalty.key,
            equals('gen_ai.request.presence_penalty'));
        expect(GenAI.genAiRequestSeed.key, equals('gen_ai.request.seed'));
      });

      test('toString should return the key value', () {
        expect(GenAI.genAiOperationName.toString(),
            equals('gen_ai.operation.name'));
        expect(
            GenAI.genAiRequestModel.toString(), equals('gen_ai.request.model'));
      });
    });
  });
}
