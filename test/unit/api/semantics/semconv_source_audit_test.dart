// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

// Source-level audit of the generated semconv enums: `@Deprecated`
// annotations and `Stability:` doc lines cannot be reflected at runtime,
// so this test checks the generated source text against the generated
// registry fixture. VM-only (dart:io).
@TestOn('vm')
library;

import 'dart:io';

import 'package:test/test.dart';

import 'semconv/semconv_expected.g.dart';

/// Lines that belong to a member's doc/annotation block when walking
/// upward from the member declaration.
final _blockLine = RegExp(r"^\s*(///|@Deprecated\(|'|\))");

String _rootOf(String key) =>
    key.contains('.') ? key.split('.').first : 'other';

void main() {
  group('Semconv source audit', () {
    final cache = <String, List<String>>{};

    List<String> linesFor(String root) => cache.putIfAbsent(root, () {
          final file = File('lib/src/api/semantics/semconv/$root.dart');
          expect(file.existsSync(), isTrue,
              reason: 'missing generated file for namespace $root');
          return file.readAsLinesSync();
        });

    /// The doc + annotation block immediately above [key]'s member
    /// declaration. `dart format` may wrap a long declaration onto two
    /// lines, so match both the one-line and wrapped forms and walk up
    /// from the line that starts the declaration.
    String blockFor(String key) {
      final lines = linesFor(_rootOf(key));
      final oneLine =
          RegExp('^\\s+[a-zA-Z0-9\$]+\\(\'${RegExp.escape(key)}\'\\)[,;]\$');
      final wrapped = RegExp('^\\s+\'${RegExp.escape(key)}\'\\)[,;]\$');
      var idx = lines.indexWhere(oneLine.hasMatch);
      if (idx < 0) {
        idx = lines.indexWhere(wrapped.hasMatch);
        if (idx > 0) idx -= 1; // the `ident(` line above the wrapped key
      }
      expect(idx, greaterThanOrEqualTo(0),
          reason: 'no member found for key $key');
      final block = <String>[];
      for (var i = idx - 1; i >= 0 && _blockLine.hasMatch(lines[i]); i--) {
        block.add(lines[i]);
      }
      return block.join('\n');
    }

    test('every non-stable attribute documents its stability', () {
      semconvExpectedStabilityByKey.forEach((key, stability) {
        if (stability != 'stable') {
          expect(blockFor(key), contains('Stability: $stability'),
              reason: '$key must carry a "Stability: $stability" doc line');
        }
      });
    });

    test('exactly the registry-deprecated attributes carry @Deprecated', () {
      semconvExpectedStabilityByKey.forEach((key, _) {
        final deprecated = semconvExpectedDeprecatedKeys.contains(key);
        expect(blockFor(key).contains('@Deprecated('), deprecated,
            reason: deprecated
                ? '$key is deprecated in the registry but not annotated'
                : '$key is not deprecated in the registry but is annotated');
      });
    });
  });
}
