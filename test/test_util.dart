// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:test/expect.dart';

class IsBetween extends Matcher {
  final DateTime before;
  final DateTime after;

  const IsBetween(this.before, this.after);

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    final timestamp = item as DateTime;
    return timestamp.isAfter(before) && timestamp.isBefore(after);
  }

  @override
  Description describe(Description description) =>
      description.add('is between $before and $after');
}
