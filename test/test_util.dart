// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:test/expect.dart';

class IsBetween extends Matcher {
  final DateTime before;
  final DateTime after;

  const IsBetween(this.before, this.after);

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    final timestamp = item as DateTime;
    return timestamp.compareTo(before) >= 0 && timestamp.compareTo(after) <= 0;
  }

  @override
  Description describe(Description description) =>
      description.add('is between $before and $after');
}
