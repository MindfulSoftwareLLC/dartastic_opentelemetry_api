import 'attributes.dart';

class SignalInstanceKey {
  final String name;
  final String? version;
  final String? schemaUrl;
  final Attributes? attributes;

  SignalInstanceKey(this.name, this.version, this.schemaUrl, this.attributes);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignalInstanceKey) return false;
    return name == other.name &&
        version == other.version &&
        schemaUrl == other.schemaUrl &&
        attributes == other.attributes;
  }

  @override
  int get hashCode {
    return name.hashCode ^
    (version?.hashCode ?? 0) ^
    (schemaUrl?.hashCode ?? 0) ^
    (attributes?.hashCode ?? 0);
  }
}
