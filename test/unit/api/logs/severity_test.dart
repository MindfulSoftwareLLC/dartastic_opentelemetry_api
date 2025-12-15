import 'package:test/test.dart';
import 'package:dartastic_opentelemetry_api/src/api/logs/severity.dart';

void main() {
  group('Severity', () {
    test('has correct severity numbers', () {
      expect(Severity.UNSPECIFIED.severityNumber, equals(0));
      expect(Severity.TRACE.severityNumber, equals(1));
      expect(Severity.TRACE2.severityNumber, equals(2));
      expect(Severity.TRACE3.severityNumber, equals(3));
      expect(Severity.TRACE4.severityNumber, equals(4));
      expect(Severity.DEBUG.severityNumber, equals(5));
      expect(Severity.DEBUG2.severityNumber, equals(6));
      expect(Severity.DEBUG3.severityNumber, equals(7));
      expect(Severity.DEBUG4.severityNumber, equals(8));
      expect(Severity.INFO.severityNumber, equals(9));
      expect(Severity.INFO2.severityNumber, equals(10));
      expect(Severity.INFO3.severityNumber, equals(11));
      expect(Severity.INFO4.severityNumber, equals(12));
      expect(Severity.WARN.severityNumber, equals(13));
      expect(Severity.WARN2.severityNumber, equals(14));
      expect(Severity.WARN3.severityNumber, equals(15));
      expect(Severity.WARN4.severityNumber, equals(16));
      expect(Severity.ERROR.severityNumber, equals(17));
      expect(Severity.ERROR2.severityNumber, equals(18));
      expect(Severity.ERROR3.severityNumber, equals(19));
      expect(Severity.ERROR4.severityNumber, equals(20));
      expect(Severity.FATAL.severityNumber, equals(21));
      expect(Severity.FATAL2.severityNumber, equals(22));
      expect(Severity.FATAL3.severityNumber, equals(23));
      expect(Severity.FATAL4.severityNumber, equals(24));
    });

    test('has correct log levels', () {
      expect(Severity.UNSPECIFIED.logLevel, equals(SeverityLevel.UNSPECIFIED));
      expect(Severity.TRACE.logLevel, equals(SeverityLevel.TRACE));
      expect(Severity.TRACE2.logLevel, equals(SeverityLevel.TRACE));
      expect(Severity.TRACE3.logLevel, equals(SeverityLevel.TRACE));
      expect(Severity.TRACE4.logLevel, equals(SeverityLevel.TRACE));
      expect(Severity.DEBUG.logLevel, equals(SeverityLevel.DEBUG));
      expect(Severity.DEBUG2.logLevel, equals(SeverityLevel.DEBUG));
      expect(Severity.DEBUG3.logLevel, equals(SeverityLevel.DEBUG));
      expect(Severity.DEBUG4.logLevel, equals(SeverityLevel.DEBUG));
      expect(Severity.INFO.logLevel, equals(SeverityLevel.INFO));
      expect(Severity.INFO2.logLevel, equals(SeverityLevel.INFO));
      expect(Severity.INFO3.logLevel, equals(SeverityLevel.INFO));
      expect(Severity.INFO4.logLevel, equals(SeverityLevel.INFO));
      expect(Severity.WARN.logLevel, equals(SeverityLevel.WARN));
      expect(Severity.WARN2.logLevel, equals(SeverityLevel.WARN));
      expect(Severity.WARN3.logLevel, equals(SeverityLevel.WARN));
      expect(Severity.WARN4.logLevel, equals(SeverityLevel.WARN));
      expect(Severity.ERROR.logLevel, equals(SeverityLevel.ERROR));
      expect(Severity.ERROR2.logLevel, equals(SeverityLevel.ERROR));
      expect(Severity.ERROR3.logLevel, equals(SeverityLevel.ERROR));
      expect(Severity.ERROR4.logLevel, equals(SeverityLevel.ERROR));
      expect(Severity.FATAL.logLevel, equals(SeverityLevel.FATAL));
      expect(Severity.FATAL2.logLevel, equals(SeverityLevel.FATAL));
      expect(Severity.FATAL3.logLevel, equals(SeverityLevel.FATAL));
      expect(Severity.FATAL4.logLevel, equals(SeverityLevel.FATAL));
    });

    test('toString includes log level', () {
      expect(Severity.UNSPECIFIED.toString(), contains('UNSPECIFIED'));
      expect(Severity.TRACE.toString(), contains('TRACE'));
      expect(Severity.DEBUG.toString(), contains('DEBUG'));
      expect(Severity.INFO.toString(), contains('INFO'));
      expect(Severity.WARN.toString(), contains('WARN'));
      expect(Severity.ERROR.toString(), contains('ERROR'));
      expect(Severity.FATAL.toString(), contains('FATAL'));
    });

    test('compareTo works correctly', () {
      expect(Severity.TRACE.compareTo(Severity.DEBUG), lessThan(0));
      expect(Severity.DEBUG.compareTo(Severity.INFO), lessThan(0));
      expect(Severity.INFO.compareTo(Severity.WARN), lessThan(0));
      expect(Severity.WARN.compareTo(Severity.ERROR), lessThan(0));
      expect(Severity.ERROR.compareTo(Severity.FATAL), lessThan(0));
      expect(Severity.INFO.compareTo(Severity.INFO), equals(0));
      expect(Severity.FATAL.compareTo(Severity.ERROR), greaterThan(0));
    });

    test('< operator works correctly', () {
      expect(Severity.UNSPECIFIED < Severity.TRACE, isTrue);
      expect(Severity.TRACE < Severity.DEBUG, isTrue);
      expect(Severity.DEBUG < Severity.INFO, isTrue);
      expect(Severity.INFO < Severity.WARN, isTrue);
      expect(Severity.WARN < Severity.ERROR, isTrue);
      expect(Severity.ERROR < Severity.FATAL, isTrue);
      expect(Severity.INFO < Severity.INFO, isFalse);
      expect(Severity.FATAL < Severity.ERROR, isFalse);
    });

    test('<= operator works correctly', () {
      expect(Severity.TRACE <= Severity.DEBUG, isTrue);
      expect(Severity.INFO <= Severity.INFO, isTrue);
      expect(Severity.INFO <= Severity.WARN, isTrue);
      expect(Severity.FATAL <= Severity.ERROR, isFalse);
    });

    test('> operator works correctly', () {
      expect(Severity.FATAL > Severity.ERROR, isTrue);
      expect(Severity.ERROR > Severity.WARN, isTrue);
      expect(Severity.WARN > Severity.INFO, isTrue);
      expect(Severity.INFO > Severity.DEBUG, isTrue);
      expect(Severity.DEBUG > Severity.TRACE, isTrue);
      expect(Severity.TRACE > Severity.UNSPECIFIED, isTrue);
      expect(Severity.INFO > Severity.INFO, isFalse);
      expect(Severity.TRACE > Severity.DEBUG, isFalse);
    });

    test('>= operator works correctly', () {
      expect(Severity.FATAL >= Severity.ERROR, isTrue);
      expect(Severity.INFO >= Severity.INFO, isTrue);
      expect(Severity.WARN >= Severity.INFO, isTrue);
      expect(Severity.TRACE >= Severity.DEBUG, isFalse);
    });

    test('severity numbers within same level are ordered', () {
      expect(Severity.TRACE < Severity.TRACE2, isTrue);
      expect(Severity.TRACE2 < Severity.TRACE3, isTrue);
      expect(Severity.TRACE3 < Severity.TRACE4, isTrue);

      expect(Severity.DEBUG < Severity.DEBUG2, isTrue);
      expect(Severity.DEBUG2 < Severity.DEBUG3, isTrue);
      expect(Severity.DEBUG3 < Severity.DEBUG4, isTrue);

      expect(Severity.INFO < Severity.INFO2, isTrue);
      expect(Severity.INFO2 < Severity.INFO3, isTrue);
      expect(Severity.INFO3 < Severity.INFO4, isTrue);

      expect(Severity.WARN < Severity.WARN2, isTrue);
      expect(Severity.WARN2 < Severity.WARN3, isTrue);
      expect(Severity.WARN3 < Severity.WARN4, isTrue);

      expect(Severity.ERROR < Severity.ERROR2, isTrue);
      expect(Severity.ERROR2 < Severity.ERROR3, isTrue);
      expect(Severity.ERROR3 < Severity.ERROR4, isTrue);

      expect(Severity.FATAL < Severity.FATAL2, isTrue);
      expect(Severity.FATAL2 < Severity.FATAL3, isTrue);
      expect(Severity.FATAL3 < Severity.FATAL4, isTrue);
    });

    test('all severities are unique', () {
      final severities = Severity.values;
      final severityNumbers = severities.map((s) => s.severityNumber).toSet();
      expect(severityNumbers.length, equals(severities.length));
    });
  });

  group('SeverityLevel', () {
    test('has all expected levels', () {
      expect(SeverityLevel.values, contains(SeverityLevel.UNSPECIFIED));
      expect(SeverityLevel.values, contains(SeverityLevel.TRACE));
      expect(SeverityLevel.values, contains(SeverityLevel.DEBUG));
      expect(SeverityLevel.values, contains(SeverityLevel.INFO));
      expect(SeverityLevel.values, contains(SeverityLevel.WARN));
      expect(SeverityLevel.values, contains(SeverityLevel.ERROR));
      expect(SeverityLevel.values, contains(SeverityLevel.FATAL));
    });

    test('has exactly 7 levels', () {
      expect(SeverityLevel.values.length, equals(7));
    });
  });
}
