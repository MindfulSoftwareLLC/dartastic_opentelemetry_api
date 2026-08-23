// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

/// Candidate `app.*` attribute keys. See `candidates.dart` for the contract:
/// everything here is unstable and staged for upstream contribution.
library;

import 'package:meta/meta.dart';

import '../semantics_base.dart';

/// Candidate `app.*` keys with no registry equivalent.
///
/// The registry already covers a large part of the mobile surface —
/// `app.build_id`, `app.installation.id`, `app.crash.id`, `app.jank.*`,
/// `app.screen.*` and `app.widget.*`, plus the `app.crash`, `app.jank`,
/// `app.screen.click` and `app.widget.click` events. Use those. These are the
/// gaps that remain.
@experimental
enum AppCandidate implements OTelSemantic {
  /// How the application was started.
  ///
  /// App start is one of the most-reported mobile RUM measurements and the
  /// registry has no attribute for it. Values: [AppStartTypeValue].
  appStartType('app.start.type'),

  /// Correlates every span and event belonging to a single application
  /// launch, the way `session.id` correlates a session.
  appLaunchId('app.launch.id'),

  /// The `app.screen.id` of the screen the user came from.
  ///
  /// Named to mirror the registry's own `session.previous_id`, which solves
  /// the identical problem one level up.
  appScreenPreviousId('app.screen.previous_id'),

  /// The `app.screen.name` of the screen the user came from.
  appScreenPreviousName('app.screen.previous_name'),

  /// Direction of a swipe or drag. Values: [AppGestureDirectionValue].
  ///
  /// The registry describes taps (`app.screen.click`, `app.widget.click`,
  /// `app.screen.coordinate.x`/`.y`) but has nothing for directional
  /// gestures, which on touch platforms are a large share of interaction.
  appGestureDirection('app.gesture.direction'),

  /// Horizontal distance of a gesture, in the same coordinate space as the
  /// registry's `app.screen.coordinate.x`.
  appGestureDeltaX('app.gesture.delta.x'),

  /// Vertical distance of a gesture, in the same coordinate space as the
  /// registry's `app.screen.coordinate.y`.
  appGestureDeltaY('app.gesture.delta.y');

  @override
  final String key;

  const AppCandidate(this.key);

  @override
  String toString() => key;
}

/// Candidate values for `app.start.type`.
///
/// Cold/warm/hot is the vocabulary both Android and iOS documentation use,
/// so it is the one most likely to survive review.
@experimental
enum AppStartTypeValue implements OTelSemanticValue {
  /// The process did not exist and had to be created.
  cold('cold'),

  /// The process existed but the application had to be recreated.
  warm('warm'),

  /// The application was already resident and was brought to the foreground.
  hot('hot');

  @override
  final String value;

  const AppStartTypeValue(this.value);

  @override
  String toString() => value;
}

/// Candidate values for `app.gesture.direction`.
@experimental
enum AppGestureDirectionValue implements OTelSemanticValue {
  /// Toward the top of the screen.
  up('up'),

  /// Toward the bottom of the screen.
  down('down'),

  /// Toward the left of the screen.
  left('left'),

  /// Toward the right of the screen.
  right('right');

  @override
  final String value;

  const AppGestureDirectionValue(this.value);

  @override
  String toString() => value;
}
