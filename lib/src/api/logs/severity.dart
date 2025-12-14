enum Severity {
  UNSPECIFIED(0, SeverityLevel.UNSPECIFIED),
  TRACE(1, SeverityLevel.TRACE),
  TRACE2(2, SeverityLevel.TRACE),
  TRACE3(3, SeverityLevel.TRACE),
  TRACE4(4, SeverityLevel.TRACE),
  DEBUG(5, SeverityLevel.DEBUG),
  DEBUG2(6, SeverityLevel.DEBUG),
  DEBUG3(7, SeverityLevel.DEBUG),
  DEBUG4(8, SeverityLevel.DEBUG),
  INFO(9, SeverityLevel.INFO),
  INFO2(10, SeverityLevel.INFO),
  INFO3(11, SeverityLevel.INFO),
  INFO4(12, SeverityLevel.INFO),
  WARN(13, SeverityLevel.WARN),
  WARN2(14, SeverityLevel.WARN),
  WARN3(15, SeverityLevel.WARN),
  WARN4(16, SeverityLevel.WARN),
  ERROR(17, SeverityLevel.ERROR),
  ERROR2(18, SeverityLevel.ERROR),
  ERROR3(19, SeverityLevel.ERROR),
  ERROR4(20, SeverityLevel.ERROR),
  FATAL(21, SeverityLevel.FATAL),
  FATAL2(22, SeverityLevel.FATAL),
  FATAL3(23, SeverityLevel.FATAL),
  FATAL4(24, SeverityLevel.FATAL);

  final SeverityLevel logLevel;
  final int severityNumber;

  const Severity(this.severityNumber, this.logLevel);

  @override
  String toString() => "${super.toString()}(${this.logLevel.toString()})";

  int compareTo(Severity other) =>
      severityNumber.compareTo(other.severityNumber);

  bool operator <(Severity other) =>
      severityNumber < other.severityNumber;

  bool operator <=(Severity other) =>
      severityNumber <= other.severityNumber;

  bool operator >(Severity other) =>
      severityNumber > other.severityNumber;

  bool operator >=(Severity other) =>
      severityNumber >= other.severityNumber;
}

enum SeverityLevel {
  UNSPECIFIED,
  TRACE,
  DEBUG,
  INFO,
  WARN,
  ERROR,
  FATAL,
}
