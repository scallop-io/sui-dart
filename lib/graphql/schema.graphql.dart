// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
class Input$AddressKey {
  factory Input$AddressKey({
    String? address,
    int? atCheckpoint,
    String? name,
    int? rootVersion,
  }) => Input$AddressKey._({
    if (address != null) r'address': address,
    if (atCheckpoint != null) r'atCheckpoint': atCheckpoint,
    if (name != null) r'name': name,
    if (rootVersion != null) r'rootVersion': rootVersion,
  });

  Input$AddressKey._(this._$data);

  factory Input$AddressKey.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('address')) {
      final l$address = data['address'];
      result$data['address'] = (l$address as String?);
    }
    if (data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = data['atCheckpoint'];
      result$data['atCheckpoint'] = (l$atCheckpoint as int?);
    }
    if (data.containsKey('name')) {
      final l$name = data['name'];
      result$data['name'] = (l$name as String?);
    }
    if (data.containsKey('rootVersion')) {
      final l$rootVersion = data['rootVersion'];
      result$data['rootVersion'] = (l$rootVersion as int?);
    }
    return Input$AddressKey._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get address => (_$data['address'] as String?);

  int? get atCheckpoint => (_$data['atCheckpoint'] as int?);

  String? get name => (_$data['name'] as String?);

  int? get rootVersion => (_$data['rootVersion'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('address')) {
      final l$address = address;
      result$data['address'] = l$address;
    }
    if (_$data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = atCheckpoint;
      result$data['atCheckpoint'] = l$atCheckpoint;
    }
    if (_$data.containsKey('name')) {
      final l$name = name;
      result$data['name'] = l$name;
    }
    if (_$data.containsKey('rootVersion')) {
      final l$rootVersion = rootVersion;
      result$data['rootVersion'] = l$rootVersion;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$AddressKey || runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (_$data.containsKey('address') != other._$data.containsKey('address')) {
      return false;
    }
    if (l$address != lOther$address) {
      return false;
    }
    final l$atCheckpoint = atCheckpoint;
    final lOther$atCheckpoint = other.atCheckpoint;
    if (_$data.containsKey('atCheckpoint') !=
        other._$data.containsKey('atCheckpoint')) {
      return false;
    }
    if (l$atCheckpoint != lOther$atCheckpoint) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (_$data.containsKey('name') != other._$data.containsKey('name')) {
      return false;
    }
    if (l$name != lOther$name) {
      return false;
    }
    final l$rootVersion = rootVersion;
    final lOther$rootVersion = other.rootVersion;
    if (_$data.containsKey('rootVersion') !=
        other._$data.containsKey('rootVersion')) {
      return false;
    }
    if (l$rootVersion != lOther$rootVersion) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$address = address;
    final l$atCheckpoint = atCheckpoint;
    final l$name = name;
    final l$rootVersion = rootVersion;
    return Object.hashAll([
      _$data.containsKey('address') ? l$address : const {},
      _$data.containsKey('atCheckpoint') ? l$atCheckpoint : const {},
      _$data.containsKey('name') ? l$name : const {},
      _$data.containsKey('rootVersion') ? l$rootVersion : const {},
    ]);
  }
}

class Input$CheckpointFilter {
  factory Input$CheckpointFilter({
    int? afterCheckpoint,
    int? atCheckpoint,
    int? atEpoch,
    int? beforeCheckpoint,
  }) => Input$CheckpointFilter._({
    if (afterCheckpoint != null) r'afterCheckpoint': afterCheckpoint,
    if (atCheckpoint != null) r'atCheckpoint': atCheckpoint,
    if (atEpoch != null) r'atEpoch': atEpoch,
    if (beforeCheckpoint != null) r'beforeCheckpoint': beforeCheckpoint,
  });

  Input$CheckpointFilter._(this._$data);

  factory Input$CheckpointFilter.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('afterCheckpoint')) {
      final l$afterCheckpoint = data['afterCheckpoint'];
      result$data['afterCheckpoint'] = (l$afterCheckpoint as int?);
    }
    if (data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = data['atCheckpoint'];
      result$data['atCheckpoint'] = (l$atCheckpoint as int?);
    }
    if (data.containsKey('atEpoch')) {
      final l$atEpoch = data['atEpoch'];
      result$data['atEpoch'] = (l$atEpoch as int?);
    }
    if (data.containsKey('beforeCheckpoint')) {
      final l$beforeCheckpoint = data['beforeCheckpoint'];
      result$data['beforeCheckpoint'] = (l$beforeCheckpoint as int?);
    }
    return Input$CheckpointFilter._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get afterCheckpoint => (_$data['afterCheckpoint'] as int?);

  int? get atCheckpoint => (_$data['atCheckpoint'] as int?);

  int? get atEpoch => (_$data['atEpoch'] as int?);

  int? get beforeCheckpoint => (_$data['beforeCheckpoint'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('afterCheckpoint')) {
      final l$afterCheckpoint = afterCheckpoint;
      result$data['afterCheckpoint'] = l$afterCheckpoint;
    }
    if (_$data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = atCheckpoint;
      result$data['atCheckpoint'] = l$atCheckpoint;
    }
    if (_$data.containsKey('atEpoch')) {
      final l$atEpoch = atEpoch;
      result$data['atEpoch'] = l$atEpoch;
    }
    if (_$data.containsKey('beforeCheckpoint')) {
      final l$beforeCheckpoint = beforeCheckpoint;
      result$data['beforeCheckpoint'] = l$beforeCheckpoint;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$CheckpointFilter || runtimeType != other.runtimeType) {
      return false;
    }
    final l$afterCheckpoint = afterCheckpoint;
    final lOther$afterCheckpoint = other.afterCheckpoint;
    if (_$data.containsKey('afterCheckpoint') !=
        other._$data.containsKey('afterCheckpoint')) {
      return false;
    }
    if (l$afterCheckpoint != lOther$afterCheckpoint) {
      return false;
    }
    final l$atCheckpoint = atCheckpoint;
    final lOther$atCheckpoint = other.atCheckpoint;
    if (_$data.containsKey('atCheckpoint') !=
        other._$data.containsKey('atCheckpoint')) {
      return false;
    }
    if (l$atCheckpoint != lOther$atCheckpoint) {
      return false;
    }
    final l$atEpoch = atEpoch;
    final lOther$atEpoch = other.atEpoch;
    if (_$data.containsKey('atEpoch') != other._$data.containsKey('atEpoch')) {
      return false;
    }
    if (l$atEpoch != lOther$atEpoch) {
      return false;
    }
    final l$beforeCheckpoint = beforeCheckpoint;
    final lOther$beforeCheckpoint = other.beforeCheckpoint;
    if (_$data.containsKey('beforeCheckpoint') !=
        other._$data.containsKey('beforeCheckpoint')) {
      return false;
    }
    if (l$beforeCheckpoint != lOther$beforeCheckpoint) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$afterCheckpoint = afterCheckpoint;
    final l$atCheckpoint = atCheckpoint;
    final l$atEpoch = atEpoch;
    final l$beforeCheckpoint = beforeCheckpoint;
    return Object.hashAll([
      _$data.containsKey('afterCheckpoint') ? l$afterCheckpoint : const {},
      _$data.containsKey('atCheckpoint') ? l$atCheckpoint : const {},
      _$data.containsKey('atEpoch') ? l$atEpoch : const {},
      _$data.containsKey('beforeCheckpoint') ? l$beforeCheckpoint : const {},
    ]);
  }
}

class Input$DynamicFieldName {
  factory Input$DynamicFieldName({
    String? bcs,
    String? literal,
    String? type,
  }) => Input$DynamicFieldName._({
    if (bcs != null) r'bcs': bcs,
    if (literal != null) r'literal': literal,
    if (type != null) r'type': type,
  });

  Input$DynamicFieldName._(this._$data);

  factory Input$DynamicFieldName.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('bcs')) {
      final l$bcs = data['bcs'];
      result$data['bcs'] = (l$bcs as String?);
    }
    if (data.containsKey('literal')) {
      final l$literal = data['literal'];
      result$data['literal'] = (l$literal as String?);
    }
    if (data.containsKey('type')) {
      final l$type = data['type'];
      result$data['type'] = (l$type as String?);
    }
    return Input$DynamicFieldName._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get bcs => (_$data['bcs'] as String?);

  String? get literal => (_$data['literal'] as String?);

  String? get type => (_$data['type'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('bcs')) {
      final l$bcs = bcs;
      result$data['bcs'] = l$bcs;
    }
    if (_$data.containsKey('literal')) {
      final l$literal = literal;
      result$data['literal'] = l$literal;
    }
    if (_$data.containsKey('type')) {
      final l$type = type;
      result$data['type'] = l$type;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$DynamicFieldName || runtimeType != other.runtimeType) {
      return false;
    }
    final l$bcs = bcs;
    final lOther$bcs = other.bcs;
    if (_$data.containsKey('bcs') != other._$data.containsKey('bcs')) {
      return false;
    }
    if (l$bcs != lOther$bcs) {
      return false;
    }
    final l$literal = literal;
    final lOther$literal = other.literal;
    if (_$data.containsKey('literal') != other._$data.containsKey('literal')) {
      return false;
    }
    if (l$literal != lOther$literal) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (_$data.containsKey('type') != other._$data.containsKey('type')) {
      return false;
    }
    if (l$type != lOther$type) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$bcs = bcs;
    final l$literal = literal;
    final l$type = type;
    return Object.hashAll([
      _$data.containsKey('bcs') ? l$bcs : const {},
      _$data.containsKey('literal') ? l$literal : const {},
      _$data.containsKey('type') ? l$type : const {},
    ]);
  }
}

class Input$EventFilter {
  factory Input$EventFilter({
    int? afterCheckpoint,
    int? atCheckpoint,
    int? beforeCheckpoint,
    String? module,
    String? sender,
    String? type,
  }) => Input$EventFilter._({
    if (afterCheckpoint != null) r'afterCheckpoint': afterCheckpoint,
    if (atCheckpoint != null) r'atCheckpoint': atCheckpoint,
    if (beforeCheckpoint != null) r'beforeCheckpoint': beforeCheckpoint,
    if (module != null) r'module': module,
    if (sender != null) r'sender': sender,
    if (type != null) r'type': type,
  });

  Input$EventFilter._(this._$data);

  factory Input$EventFilter.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('afterCheckpoint')) {
      final l$afterCheckpoint = data['afterCheckpoint'];
      result$data['afterCheckpoint'] = (l$afterCheckpoint as int?);
    }
    if (data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = data['atCheckpoint'];
      result$data['atCheckpoint'] = (l$atCheckpoint as int?);
    }
    if (data.containsKey('beforeCheckpoint')) {
      final l$beforeCheckpoint = data['beforeCheckpoint'];
      result$data['beforeCheckpoint'] = (l$beforeCheckpoint as int?);
    }
    if (data.containsKey('module')) {
      final l$module = data['module'];
      result$data['module'] = (l$module as String?);
    }
    if (data.containsKey('sender')) {
      final l$sender = data['sender'];
      result$data['sender'] = (l$sender as String?);
    }
    if (data.containsKey('type')) {
      final l$type = data['type'];
      result$data['type'] = (l$type as String?);
    }
    return Input$EventFilter._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get afterCheckpoint => (_$data['afterCheckpoint'] as int?);

  int? get atCheckpoint => (_$data['atCheckpoint'] as int?);

  int? get beforeCheckpoint => (_$data['beforeCheckpoint'] as int?);

  String? get module => (_$data['module'] as String?);

  String? get sender => (_$data['sender'] as String?);

  String? get type => (_$data['type'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('afterCheckpoint')) {
      final l$afterCheckpoint = afterCheckpoint;
      result$data['afterCheckpoint'] = l$afterCheckpoint;
    }
    if (_$data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = atCheckpoint;
      result$data['atCheckpoint'] = l$atCheckpoint;
    }
    if (_$data.containsKey('beforeCheckpoint')) {
      final l$beforeCheckpoint = beforeCheckpoint;
      result$data['beforeCheckpoint'] = l$beforeCheckpoint;
    }
    if (_$data.containsKey('module')) {
      final l$module = module;
      result$data['module'] = l$module;
    }
    if (_$data.containsKey('sender')) {
      final l$sender = sender;
      result$data['sender'] = l$sender;
    }
    if (_$data.containsKey('type')) {
      final l$type = type;
      result$data['type'] = l$type;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$EventFilter || runtimeType != other.runtimeType) {
      return false;
    }
    final l$afterCheckpoint = afterCheckpoint;
    final lOther$afterCheckpoint = other.afterCheckpoint;
    if (_$data.containsKey('afterCheckpoint') !=
        other._$data.containsKey('afterCheckpoint')) {
      return false;
    }
    if (l$afterCheckpoint != lOther$afterCheckpoint) {
      return false;
    }
    final l$atCheckpoint = atCheckpoint;
    final lOther$atCheckpoint = other.atCheckpoint;
    if (_$data.containsKey('atCheckpoint') !=
        other._$data.containsKey('atCheckpoint')) {
      return false;
    }
    if (l$atCheckpoint != lOther$atCheckpoint) {
      return false;
    }
    final l$beforeCheckpoint = beforeCheckpoint;
    final lOther$beforeCheckpoint = other.beforeCheckpoint;
    if (_$data.containsKey('beforeCheckpoint') !=
        other._$data.containsKey('beforeCheckpoint')) {
      return false;
    }
    if (l$beforeCheckpoint != lOther$beforeCheckpoint) {
      return false;
    }
    final l$module = module;
    final lOther$module = other.module;
    if (_$data.containsKey('module') != other._$data.containsKey('module')) {
      return false;
    }
    if (l$module != lOther$module) {
      return false;
    }
    final l$sender = sender;
    final lOther$sender = other.sender;
    if (_$data.containsKey('sender') != other._$data.containsKey('sender')) {
      return false;
    }
    if (l$sender != lOther$sender) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (_$data.containsKey('type') != other._$data.containsKey('type')) {
      return false;
    }
    if (l$type != lOther$type) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$afterCheckpoint = afterCheckpoint;
    final l$atCheckpoint = atCheckpoint;
    final l$beforeCheckpoint = beforeCheckpoint;
    final l$module = module;
    final l$sender = sender;
    final l$type = type;
    return Object.hashAll([
      _$data.containsKey('afterCheckpoint') ? l$afterCheckpoint : const {},
      _$data.containsKey('atCheckpoint') ? l$atCheckpoint : const {},
      _$data.containsKey('beforeCheckpoint') ? l$beforeCheckpoint : const {},
      _$data.containsKey('module') ? l$module : const {},
      _$data.containsKey('sender') ? l$sender : const {},
      _$data.containsKey('type') ? l$type : const {},
    ]);
  }
}

class Input$ObjectFilter {
  factory Input$ObjectFilter({
    String? owner,
    Enum$OwnerKind? ownerKind,
    String? type,
  }) => Input$ObjectFilter._({
    if (owner != null) r'owner': owner,
    if (ownerKind != null) r'ownerKind': ownerKind,
    if (type != null) r'type': type,
  });

  Input$ObjectFilter._(this._$data);

  factory Input$ObjectFilter.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('owner')) {
      final l$owner = data['owner'];
      result$data['owner'] = (l$owner as String?);
    }
    if (data.containsKey('ownerKind')) {
      final l$ownerKind = data['ownerKind'];
      result$data['ownerKind'] = l$ownerKind == null
          ? null
          : fromJson$Enum$OwnerKind((l$ownerKind as String));
    }
    if (data.containsKey('type')) {
      final l$type = data['type'];
      result$data['type'] = (l$type as String?);
    }
    return Input$ObjectFilter._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get owner => (_$data['owner'] as String?);

  Enum$OwnerKind? get ownerKind => (_$data['ownerKind'] as Enum$OwnerKind?);

  String? get type => (_$data['type'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('owner')) {
      final l$owner = owner;
      result$data['owner'] = l$owner;
    }
    if (_$data.containsKey('ownerKind')) {
      final l$ownerKind = ownerKind;
      result$data['ownerKind'] = l$ownerKind == null
          ? null
          : toJson$Enum$OwnerKind(l$ownerKind);
    }
    if (_$data.containsKey('type')) {
      final l$type = type;
      result$data['type'] = l$type;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ObjectFilter || runtimeType != other.runtimeType) {
      return false;
    }
    final l$owner = owner;
    final lOther$owner = other.owner;
    if (_$data.containsKey('owner') != other._$data.containsKey('owner')) {
      return false;
    }
    if (l$owner != lOther$owner) {
      return false;
    }
    final l$ownerKind = ownerKind;
    final lOther$ownerKind = other.ownerKind;
    if (_$data.containsKey('ownerKind') !=
        other._$data.containsKey('ownerKind')) {
      return false;
    }
    if (l$ownerKind != lOther$ownerKind) {
      return false;
    }
    final l$type = type;
    final lOther$type = other.type;
    if (_$data.containsKey('type') != other._$data.containsKey('type')) {
      return false;
    }
    if (l$type != lOther$type) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$owner = owner;
    final l$ownerKind = ownerKind;
    final l$type = type;
    return Object.hashAll([
      _$data.containsKey('owner') ? l$owner : const {},
      _$data.containsKey('ownerKind') ? l$ownerKind : const {},
      _$data.containsKey('type') ? l$type : const {},
    ]);
  }
}

class Input$ObjectKey {
  factory Input$ObjectKey({
    required String address,
    int? atCheckpoint,
    int? rootVersion,
    int? version,
  }) => Input$ObjectKey._({
    r'address': address,
    if (atCheckpoint != null) r'atCheckpoint': atCheckpoint,
    if (rootVersion != null) r'rootVersion': rootVersion,
    if (version != null) r'version': version,
  });

  Input$ObjectKey._(this._$data);

  factory Input$ObjectKey.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$address = data['address'];
    result$data['address'] = (l$address as String);
    if (data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = data['atCheckpoint'];
      result$data['atCheckpoint'] = (l$atCheckpoint as int?);
    }
    if (data.containsKey('rootVersion')) {
      final l$rootVersion = data['rootVersion'];
      result$data['rootVersion'] = (l$rootVersion as int?);
    }
    if (data.containsKey('version')) {
      final l$version = data['version'];
      result$data['version'] = (l$version as int?);
    }
    return Input$ObjectKey._(result$data);
  }

  Map<String, dynamic> _$data;

  String get address => (_$data['address'] as String);

  int? get atCheckpoint => (_$data['atCheckpoint'] as int?);

  int? get rootVersion => (_$data['rootVersion'] as int?);

  int? get version => (_$data['version'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$address = address;
    result$data['address'] = l$address;
    if (_$data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = atCheckpoint;
      result$data['atCheckpoint'] = l$atCheckpoint;
    }
    if (_$data.containsKey('rootVersion')) {
      final l$rootVersion = rootVersion;
      result$data['rootVersion'] = l$rootVersion;
    }
    if (_$data.containsKey('version')) {
      final l$version = version;
      result$data['version'] = l$version;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$ObjectKey || runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    final l$atCheckpoint = atCheckpoint;
    final lOther$atCheckpoint = other.atCheckpoint;
    if (_$data.containsKey('atCheckpoint') !=
        other._$data.containsKey('atCheckpoint')) {
      return false;
    }
    if (l$atCheckpoint != lOther$atCheckpoint) {
      return false;
    }
    final l$rootVersion = rootVersion;
    final lOther$rootVersion = other.rootVersion;
    if (_$data.containsKey('rootVersion') !=
        other._$data.containsKey('rootVersion')) {
      return false;
    }
    if (l$rootVersion != lOther$rootVersion) {
      return false;
    }
    final l$version = version;
    final lOther$version = other.version;
    if (_$data.containsKey('version') != other._$data.containsKey('version')) {
      return false;
    }
    if (l$version != lOther$version) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$address = address;
    final l$atCheckpoint = atCheckpoint;
    final l$rootVersion = rootVersion;
    final l$version = version;
    return Object.hashAll([
      l$address,
      _$data.containsKey('atCheckpoint') ? l$atCheckpoint : const {},
      _$data.containsKey('rootVersion') ? l$rootVersion : const {},
      _$data.containsKey('version') ? l$version : const {},
    ]);
  }
}

class Input$PackageCheckpointFilter {
  factory Input$PackageCheckpointFilter({
    int? afterCheckpoint,
    int? beforeCheckpoint,
  }) => Input$PackageCheckpointFilter._({
    if (afterCheckpoint != null) r'afterCheckpoint': afterCheckpoint,
    if (beforeCheckpoint != null) r'beforeCheckpoint': beforeCheckpoint,
  });

  Input$PackageCheckpointFilter._(this._$data);

  factory Input$PackageCheckpointFilter.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('afterCheckpoint')) {
      final l$afterCheckpoint = data['afterCheckpoint'];
      result$data['afterCheckpoint'] = (l$afterCheckpoint as int?);
    }
    if (data.containsKey('beforeCheckpoint')) {
      final l$beforeCheckpoint = data['beforeCheckpoint'];
      result$data['beforeCheckpoint'] = (l$beforeCheckpoint as int?);
    }
    return Input$PackageCheckpointFilter._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get afterCheckpoint => (_$data['afterCheckpoint'] as int?);

  int? get beforeCheckpoint => (_$data['beforeCheckpoint'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('afterCheckpoint')) {
      final l$afterCheckpoint = afterCheckpoint;
      result$data['afterCheckpoint'] = l$afterCheckpoint;
    }
    if (_$data.containsKey('beforeCheckpoint')) {
      final l$beforeCheckpoint = beforeCheckpoint;
      result$data['beforeCheckpoint'] = l$beforeCheckpoint;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$PackageCheckpointFilter ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$afterCheckpoint = afterCheckpoint;
    final lOther$afterCheckpoint = other.afterCheckpoint;
    if (_$data.containsKey('afterCheckpoint') !=
        other._$data.containsKey('afterCheckpoint')) {
      return false;
    }
    if (l$afterCheckpoint != lOther$afterCheckpoint) {
      return false;
    }
    final l$beforeCheckpoint = beforeCheckpoint;
    final lOther$beforeCheckpoint = other.beforeCheckpoint;
    if (_$data.containsKey('beforeCheckpoint') !=
        other._$data.containsKey('beforeCheckpoint')) {
      return false;
    }
    if (l$beforeCheckpoint != lOther$beforeCheckpoint) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$afterCheckpoint = afterCheckpoint;
    final l$beforeCheckpoint = beforeCheckpoint;
    return Object.hashAll([
      _$data.containsKey('afterCheckpoint') ? l$afterCheckpoint : const {},
      _$data.containsKey('beforeCheckpoint') ? l$beforeCheckpoint : const {},
    ]);
  }
}

class Input$PackageKey {
  factory Input$PackageKey({
    required String address,
    int? atCheckpoint,
    int? version,
  }) => Input$PackageKey._({
    r'address': address,
    if (atCheckpoint != null) r'atCheckpoint': atCheckpoint,
    if (version != null) r'version': version,
  });

  Input$PackageKey._(this._$data);

  factory Input$PackageKey.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$address = data['address'];
    result$data['address'] = (l$address as String);
    if (data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = data['atCheckpoint'];
      result$data['atCheckpoint'] = (l$atCheckpoint as int?);
    }
    if (data.containsKey('version')) {
      final l$version = data['version'];
      result$data['version'] = (l$version as int?);
    }
    return Input$PackageKey._(result$data);
  }

  Map<String, dynamic> _$data;

  String get address => (_$data['address'] as String);

  int? get atCheckpoint => (_$data['atCheckpoint'] as int?);

  int? get version => (_$data['version'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$address = address;
    result$data['address'] = l$address;
    if (_$data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = atCheckpoint;
      result$data['atCheckpoint'] = l$atCheckpoint;
    }
    if (_$data.containsKey('version')) {
      final l$version = version;
      result$data['version'] = l$version;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$PackageKey || runtimeType != other.runtimeType) {
      return false;
    }
    final l$address = address;
    final lOther$address = other.address;
    if (l$address != lOther$address) {
      return false;
    }
    final l$atCheckpoint = atCheckpoint;
    final lOther$atCheckpoint = other.atCheckpoint;
    if (_$data.containsKey('atCheckpoint') !=
        other._$data.containsKey('atCheckpoint')) {
      return false;
    }
    if (l$atCheckpoint != lOther$atCheckpoint) {
      return false;
    }
    final l$version = version;
    final lOther$version = other.version;
    if (_$data.containsKey('version') != other._$data.containsKey('version')) {
      return false;
    }
    if (l$version != lOther$version) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$address = address;
    final l$atCheckpoint = atCheckpoint;
    final l$version = version;
    return Object.hashAll([
      l$address,
      _$data.containsKey('atCheckpoint') ? l$atCheckpoint : const {},
      _$data.containsKey('version') ? l$version : const {},
    ]);
  }
}

class Input$TransactionFilter {
  factory Input$TransactionFilter({
    String? affectedAddress,
    String? affectedObject,
    int? afterCheckpoint,
    int? atCheckpoint,
    int? beforeCheckpoint,
    String? function,
    Enum$TransactionKindInput? kind,
    String? sentAddress,
  }) => Input$TransactionFilter._({
    if (affectedAddress != null) r'affectedAddress': affectedAddress,
    if (affectedObject != null) r'affectedObject': affectedObject,
    if (afterCheckpoint != null) r'afterCheckpoint': afterCheckpoint,
    if (atCheckpoint != null) r'atCheckpoint': atCheckpoint,
    if (beforeCheckpoint != null) r'beforeCheckpoint': beforeCheckpoint,
    if (function != null) r'function': function,
    if (kind != null) r'kind': kind,
    if (sentAddress != null) r'sentAddress': sentAddress,
  });

  Input$TransactionFilter._(this._$data);

  factory Input$TransactionFilter.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('affectedAddress')) {
      final l$affectedAddress = data['affectedAddress'];
      result$data['affectedAddress'] = (l$affectedAddress as String?);
    }
    if (data.containsKey('affectedObject')) {
      final l$affectedObject = data['affectedObject'];
      result$data['affectedObject'] = (l$affectedObject as String?);
    }
    if (data.containsKey('afterCheckpoint')) {
      final l$afterCheckpoint = data['afterCheckpoint'];
      result$data['afterCheckpoint'] = (l$afterCheckpoint as int?);
    }
    if (data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = data['atCheckpoint'];
      result$data['atCheckpoint'] = (l$atCheckpoint as int?);
    }
    if (data.containsKey('beforeCheckpoint')) {
      final l$beforeCheckpoint = data['beforeCheckpoint'];
      result$data['beforeCheckpoint'] = (l$beforeCheckpoint as int?);
    }
    if (data.containsKey('function')) {
      final l$function = data['function'];
      result$data['function'] = (l$function as String?);
    }
    if (data.containsKey('kind')) {
      final l$kind = data['kind'];
      result$data['kind'] = l$kind == null
          ? null
          : fromJson$Enum$TransactionKindInput((l$kind as String));
    }
    if (data.containsKey('sentAddress')) {
      final l$sentAddress = data['sentAddress'];
      result$data['sentAddress'] = (l$sentAddress as String?);
    }
    return Input$TransactionFilter._(result$data);
  }

  Map<String, dynamic> _$data;

  String? get affectedAddress => (_$data['affectedAddress'] as String?);

  String? get affectedObject => (_$data['affectedObject'] as String?);

  int? get afterCheckpoint => (_$data['afterCheckpoint'] as int?);

  int? get atCheckpoint => (_$data['atCheckpoint'] as int?);

  int? get beforeCheckpoint => (_$data['beforeCheckpoint'] as int?);

  String? get function => (_$data['function'] as String?);

  Enum$TransactionKindInput? get kind =>
      (_$data['kind'] as Enum$TransactionKindInput?);

  String? get sentAddress => (_$data['sentAddress'] as String?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('affectedAddress')) {
      final l$affectedAddress = affectedAddress;
      result$data['affectedAddress'] = l$affectedAddress;
    }
    if (_$data.containsKey('affectedObject')) {
      final l$affectedObject = affectedObject;
      result$data['affectedObject'] = l$affectedObject;
    }
    if (_$data.containsKey('afterCheckpoint')) {
      final l$afterCheckpoint = afterCheckpoint;
      result$data['afterCheckpoint'] = l$afterCheckpoint;
    }
    if (_$data.containsKey('atCheckpoint')) {
      final l$atCheckpoint = atCheckpoint;
      result$data['atCheckpoint'] = l$atCheckpoint;
    }
    if (_$data.containsKey('beforeCheckpoint')) {
      final l$beforeCheckpoint = beforeCheckpoint;
      result$data['beforeCheckpoint'] = l$beforeCheckpoint;
    }
    if (_$data.containsKey('function')) {
      final l$function = function;
      result$data['function'] = l$function;
    }
    if (_$data.containsKey('kind')) {
      final l$kind = kind;
      result$data['kind'] = l$kind == null
          ? null
          : toJson$Enum$TransactionKindInput(l$kind);
    }
    if (_$data.containsKey('sentAddress')) {
      final l$sentAddress = sentAddress;
      result$data['sentAddress'] = l$sentAddress;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$TransactionFilter || runtimeType != other.runtimeType) {
      return false;
    }
    final l$affectedAddress = affectedAddress;
    final lOther$affectedAddress = other.affectedAddress;
    if (_$data.containsKey('affectedAddress') !=
        other._$data.containsKey('affectedAddress')) {
      return false;
    }
    if (l$affectedAddress != lOther$affectedAddress) {
      return false;
    }
    final l$affectedObject = affectedObject;
    final lOther$affectedObject = other.affectedObject;
    if (_$data.containsKey('affectedObject') !=
        other._$data.containsKey('affectedObject')) {
      return false;
    }
    if (l$affectedObject != lOther$affectedObject) {
      return false;
    }
    final l$afterCheckpoint = afterCheckpoint;
    final lOther$afterCheckpoint = other.afterCheckpoint;
    if (_$data.containsKey('afterCheckpoint') !=
        other._$data.containsKey('afterCheckpoint')) {
      return false;
    }
    if (l$afterCheckpoint != lOther$afterCheckpoint) {
      return false;
    }
    final l$atCheckpoint = atCheckpoint;
    final lOther$atCheckpoint = other.atCheckpoint;
    if (_$data.containsKey('atCheckpoint') !=
        other._$data.containsKey('atCheckpoint')) {
      return false;
    }
    if (l$atCheckpoint != lOther$atCheckpoint) {
      return false;
    }
    final l$beforeCheckpoint = beforeCheckpoint;
    final lOther$beforeCheckpoint = other.beforeCheckpoint;
    if (_$data.containsKey('beforeCheckpoint') !=
        other._$data.containsKey('beforeCheckpoint')) {
      return false;
    }
    if (l$beforeCheckpoint != lOther$beforeCheckpoint) {
      return false;
    }
    final l$function = function;
    final lOther$function = other.function;
    if (_$data.containsKey('function') !=
        other._$data.containsKey('function')) {
      return false;
    }
    if (l$function != lOther$function) {
      return false;
    }
    final l$kind = kind;
    final lOther$kind = other.kind;
    if (_$data.containsKey('kind') != other._$data.containsKey('kind')) {
      return false;
    }
    if (l$kind != lOther$kind) {
      return false;
    }
    final l$sentAddress = sentAddress;
    final lOther$sentAddress = other.sentAddress;
    if (_$data.containsKey('sentAddress') !=
        other._$data.containsKey('sentAddress')) {
      return false;
    }
    if (l$sentAddress != lOther$sentAddress) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$affectedAddress = affectedAddress;
    final l$affectedObject = affectedObject;
    final l$afterCheckpoint = afterCheckpoint;
    final l$atCheckpoint = atCheckpoint;
    final l$beforeCheckpoint = beforeCheckpoint;
    final l$function = function;
    final l$kind = kind;
    final l$sentAddress = sentAddress;
    return Object.hashAll([
      _$data.containsKey('affectedAddress') ? l$affectedAddress : const {},
      _$data.containsKey('affectedObject') ? l$affectedObject : const {},
      _$data.containsKey('afterCheckpoint') ? l$afterCheckpoint : const {},
      _$data.containsKey('atCheckpoint') ? l$atCheckpoint : const {},
      _$data.containsKey('beforeCheckpoint') ? l$beforeCheckpoint : const {},
      _$data.containsKey('function') ? l$function : const {},
      _$data.containsKey('kind') ? l$kind : const {},
      _$data.containsKey('sentAddress') ? l$sentAddress : const {},
    ]);
  }
}

class Input$VersionFilter {
  factory Input$VersionFilter({int? afterVersion, int? beforeVersion}) =>
      Input$VersionFilter._({
        if (afterVersion != null) r'afterVersion': afterVersion,
        if (beforeVersion != null) r'beforeVersion': beforeVersion,
      });

  Input$VersionFilter._(this._$data);

  factory Input$VersionFilter.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('afterVersion')) {
      final l$afterVersion = data['afterVersion'];
      result$data['afterVersion'] = (l$afterVersion as int?);
    }
    if (data.containsKey('beforeVersion')) {
      final l$beforeVersion = data['beforeVersion'];
      result$data['beforeVersion'] = (l$beforeVersion as int?);
    }
    return Input$VersionFilter._(result$data);
  }

  Map<String, dynamic> _$data;

  int? get afterVersion => (_$data['afterVersion'] as int?);

  int? get beforeVersion => (_$data['beforeVersion'] as int?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('afterVersion')) {
      final l$afterVersion = afterVersion;
      result$data['afterVersion'] = l$afterVersion;
    }
    if (_$data.containsKey('beforeVersion')) {
      final l$beforeVersion = beforeVersion;
      result$data['beforeVersion'] = l$beforeVersion;
    }
    return result$data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Input$VersionFilter || runtimeType != other.runtimeType) {
      return false;
    }
    final l$afterVersion = afterVersion;
    final lOther$afterVersion = other.afterVersion;
    if (_$data.containsKey('afterVersion') !=
        other._$data.containsKey('afterVersion')) {
      return false;
    }
    if (l$afterVersion != lOther$afterVersion) {
      return false;
    }
    final l$beforeVersion = beforeVersion;
    final lOther$beforeVersion = other.beforeVersion;
    if (_$data.containsKey('beforeVersion') !=
        other._$data.containsKey('beforeVersion')) {
      return false;
    }
    if (l$beforeVersion != lOther$beforeVersion) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$afterVersion = afterVersion;
    final l$beforeVersion = beforeVersion;
    return Object.hashAll([
      _$data.containsKey('afterVersion') ? l$afterVersion : const {},
      _$data.containsKey('beforeVersion') ? l$beforeVersion : const {},
    ]);
  }
}

enum Enum$AddressTransactionRelationship {
  SENT,
  AFFECTED,
  $unknown;

  factory Enum$AddressTransactionRelationship.fromJson(String value) =>
      fromJson$Enum$AddressTransactionRelationship(value);

  String toJson() => toJson$Enum$AddressTransactionRelationship(this);
}

String toJson$Enum$AddressTransactionRelationship(
  Enum$AddressTransactionRelationship e,
) {
  switch (e) {
    case Enum$AddressTransactionRelationship.SENT:
      return r'SENT';
    case Enum$AddressTransactionRelationship.AFFECTED:
      return r'AFFECTED';
    case Enum$AddressTransactionRelationship.$unknown:
      return r'$unknown';
  }
}

Enum$AddressTransactionRelationship
fromJson$Enum$AddressTransactionRelationship(String value) {
  switch (value) {
    case r'SENT':
      return Enum$AddressTransactionRelationship.SENT;
    case r'AFFECTED':
      return Enum$AddressTransactionRelationship.AFFECTED;
    default:
      return Enum$AddressTransactionRelationship.$unknown;
  }
}

enum Enum$ConsensusObjectCancellationReason {
  CANCELLED_READ,
  CONGESTED,
  RANDOMNESS_UNAVAILABLE,
  UNKNOWN,
  $unknown;

  factory Enum$ConsensusObjectCancellationReason.fromJson(String value) =>
      fromJson$Enum$ConsensusObjectCancellationReason(value);

  String toJson() => toJson$Enum$ConsensusObjectCancellationReason(this);
}

String toJson$Enum$ConsensusObjectCancellationReason(
  Enum$ConsensusObjectCancellationReason e,
) {
  switch (e) {
    case Enum$ConsensusObjectCancellationReason.CANCELLED_READ:
      return r'CANCELLED_READ';
    case Enum$ConsensusObjectCancellationReason.CONGESTED:
      return r'CONGESTED';
    case Enum$ConsensusObjectCancellationReason.RANDOMNESS_UNAVAILABLE:
      return r'RANDOMNESS_UNAVAILABLE';
    case Enum$ConsensusObjectCancellationReason.UNKNOWN:
      return r'UNKNOWN';
    case Enum$ConsensusObjectCancellationReason.$unknown:
      return r'$unknown';
  }
}

Enum$ConsensusObjectCancellationReason
fromJson$Enum$ConsensusObjectCancellationReason(String value) {
  switch (value) {
    case r'CANCELLED_READ':
      return Enum$ConsensusObjectCancellationReason.CANCELLED_READ;
    case r'CONGESTED':
      return Enum$ConsensusObjectCancellationReason.CONGESTED;
    case r'RANDOMNESS_UNAVAILABLE':
      return Enum$ConsensusObjectCancellationReason.RANDOMNESS_UNAVAILABLE;
    case r'UNKNOWN':
      return Enum$ConsensusObjectCancellationReason.UNKNOWN;
    default:
      return Enum$ConsensusObjectCancellationReason.$unknown;
  }
}

enum Enum$ExecutionStatus {
  SUCCESS,
  FAILURE,
  $unknown;

  factory Enum$ExecutionStatus.fromJson(String value) =>
      fromJson$Enum$ExecutionStatus(value);

  String toJson() => toJson$Enum$ExecutionStatus(this);
}

String toJson$Enum$ExecutionStatus(Enum$ExecutionStatus e) {
  switch (e) {
    case Enum$ExecutionStatus.SUCCESS:
      return r'SUCCESS';
    case Enum$ExecutionStatus.FAILURE:
      return r'FAILURE';
    case Enum$ExecutionStatus.$unknown:
      return r'$unknown';
  }
}

Enum$ExecutionStatus fromJson$Enum$ExecutionStatus(String value) {
  switch (value) {
    case r'SUCCESS':
      return Enum$ExecutionStatus.SUCCESS;
    case r'FAILURE':
      return Enum$ExecutionStatus.FAILURE;
    default:
      return Enum$ExecutionStatus.$unknown;
  }
}

enum Enum$IntentScope {
  TRANSACTION_DATA,
  PERSONAL_MESSAGE,
  $unknown;

  factory Enum$IntentScope.fromJson(String value) =>
      fromJson$Enum$IntentScope(value);

  String toJson() => toJson$Enum$IntentScope(this);
}

String toJson$Enum$IntentScope(Enum$IntentScope e) {
  switch (e) {
    case Enum$IntentScope.TRANSACTION_DATA:
      return r'TRANSACTION_DATA';
    case Enum$IntentScope.PERSONAL_MESSAGE:
      return r'PERSONAL_MESSAGE';
    case Enum$IntentScope.$unknown:
      return r'$unknown';
  }
}

Enum$IntentScope fromJson$Enum$IntentScope(String value) {
  switch (value) {
    case r'TRANSACTION_DATA':
      return Enum$IntentScope.TRANSACTION_DATA;
    case r'PERSONAL_MESSAGE':
      return Enum$IntentScope.PERSONAL_MESSAGE;
    default:
      return Enum$IntentScope.$unknown;
  }
}

enum Enum$MoveAbility {
  COPY,
  DROP,
  KEY,
  STORE,
  $unknown;

  factory Enum$MoveAbility.fromJson(String value) =>
      fromJson$Enum$MoveAbility(value);

  String toJson() => toJson$Enum$MoveAbility(this);
}

String toJson$Enum$MoveAbility(Enum$MoveAbility e) {
  switch (e) {
    case Enum$MoveAbility.COPY:
      return r'COPY';
    case Enum$MoveAbility.DROP:
      return r'DROP';
    case Enum$MoveAbility.KEY:
      return r'KEY';
    case Enum$MoveAbility.STORE:
      return r'STORE';
    case Enum$MoveAbility.$unknown:
      return r'$unknown';
  }
}

Enum$MoveAbility fromJson$Enum$MoveAbility(String value) {
  switch (value) {
    case r'COPY':
      return Enum$MoveAbility.COPY;
    case r'DROP':
      return Enum$MoveAbility.DROP;
    case r'KEY':
      return Enum$MoveAbility.KEY;
    case r'STORE':
      return Enum$MoveAbility.STORE;
    default:
      return Enum$MoveAbility.$unknown;
  }
}

enum Enum$MoveVisibility {
  PUBLIC,
  PRIVATE,
  FRIEND,
  $unknown;

  factory Enum$MoveVisibility.fromJson(String value) =>
      fromJson$Enum$MoveVisibility(value);

  String toJson() => toJson$Enum$MoveVisibility(this);
}

String toJson$Enum$MoveVisibility(Enum$MoveVisibility e) {
  switch (e) {
    case Enum$MoveVisibility.PUBLIC:
      return r'PUBLIC';
    case Enum$MoveVisibility.PRIVATE:
      return r'PRIVATE';
    case Enum$MoveVisibility.FRIEND:
      return r'FRIEND';
    case Enum$MoveVisibility.$unknown:
      return r'$unknown';
  }
}

Enum$MoveVisibility fromJson$Enum$MoveVisibility(String value) {
  switch (value) {
    case r'PUBLIC':
      return Enum$MoveVisibility.PUBLIC;
    case r'PRIVATE':
      return Enum$MoveVisibility.PRIVATE;
    case r'FRIEND':
      return Enum$MoveVisibility.FRIEND;
    default:
      return Enum$MoveVisibility.$unknown;
  }
}

enum Enum$OwnerKind {
  ADDRESS,
  OBJECT,
  SHARED,
  IMMUTABLE,
  $unknown;

  factory Enum$OwnerKind.fromJson(String value) =>
      fromJson$Enum$OwnerKind(value);

  String toJson() => toJson$Enum$OwnerKind(this);
}

String toJson$Enum$OwnerKind(Enum$OwnerKind e) {
  switch (e) {
    case Enum$OwnerKind.ADDRESS:
      return r'ADDRESS';
    case Enum$OwnerKind.OBJECT:
      return r'OBJECT';
    case Enum$OwnerKind.SHARED:
      return r'SHARED';
    case Enum$OwnerKind.IMMUTABLE:
      return r'IMMUTABLE';
    case Enum$OwnerKind.$unknown:
      return r'$unknown';
  }
}

Enum$OwnerKind fromJson$Enum$OwnerKind(String value) {
  switch (value) {
    case r'ADDRESS':
      return Enum$OwnerKind.ADDRESS;
    case r'OBJECT':
      return Enum$OwnerKind.OBJECT;
    case r'SHARED':
      return Enum$OwnerKind.SHARED;
    case r'IMMUTABLE':
      return Enum$OwnerKind.IMMUTABLE;
    default:
      return Enum$OwnerKind.$unknown;
  }
}

enum Enum$RegulatedState {
  REGULATED,
  UNREGULATED,
  $unknown;

  factory Enum$RegulatedState.fromJson(String value) =>
      fromJson$Enum$RegulatedState(value);

  String toJson() => toJson$Enum$RegulatedState(this);
}

String toJson$Enum$RegulatedState(Enum$RegulatedState e) {
  switch (e) {
    case Enum$RegulatedState.REGULATED:
      return r'REGULATED';
    case Enum$RegulatedState.UNREGULATED:
      return r'UNREGULATED';
    case Enum$RegulatedState.$unknown:
      return r'$unknown';
  }
}

Enum$RegulatedState fromJson$Enum$RegulatedState(String value) {
  switch (value) {
    case r'REGULATED':
      return Enum$RegulatedState.REGULATED;
    case r'UNREGULATED':
      return Enum$RegulatedState.UNREGULATED;
    default:
      return Enum$RegulatedState.$unknown;
  }
}

enum Enum$SupplyState {
  BURN_ONLY,
  FIXED,
  $unknown;

  factory Enum$SupplyState.fromJson(String value) =>
      fromJson$Enum$SupplyState(value);

  String toJson() => toJson$Enum$SupplyState(this);
}

String toJson$Enum$SupplyState(Enum$SupplyState e) {
  switch (e) {
    case Enum$SupplyState.BURN_ONLY:
      return r'BURN_ONLY';
    case Enum$SupplyState.FIXED:
      return r'FIXED';
    case Enum$SupplyState.$unknown:
      return r'$unknown';
  }
}

Enum$SupplyState fromJson$Enum$SupplyState(String value) {
  switch (value) {
    case r'BURN_ONLY':
      return Enum$SupplyState.BURN_ONLY;
    case r'FIXED':
      return Enum$SupplyState.FIXED;
    default:
      return Enum$SupplyState.$unknown;
  }
}

enum Enum$TransactionKindInput {
  SYSTEM_TX,
  PROGRAMMABLE_TX,
  $unknown;

  factory Enum$TransactionKindInput.fromJson(String value) =>
      fromJson$Enum$TransactionKindInput(value);

  String toJson() => toJson$Enum$TransactionKindInput(this);
}

String toJson$Enum$TransactionKindInput(Enum$TransactionKindInput e) {
  switch (e) {
    case Enum$TransactionKindInput.SYSTEM_TX:
      return r'SYSTEM_TX';
    case Enum$TransactionKindInput.PROGRAMMABLE_TX:
      return r'PROGRAMMABLE_TX';
    case Enum$TransactionKindInput.$unknown:
      return r'$unknown';
  }
}

Enum$TransactionKindInput fromJson$Enum$TransactionKindInput(String value) {
  switch (value) {
    case r'SYSTEM_TX':
      return Enum$TransactionKindInput.SYSTEM_TX;
    case r'PROGRAMMABLE_TX':
      return Enum$TransactionKindInput.PROGRAMMABLE_TX;
    default:
      return Enum$TransactionKindInput.$unknown;
  }
}

enum Enum$WithdrawFrom {
  SENDER,
  SPONSOR,
  $unknown;

  factory Enum$WithdrawFrom.fromJson(String value) =>
      fromJson$Enum$WithdrawFrom(value);

  String toJson() => toJson$Enum$WithdrawFrom(this);
}

String toJson$Enum$WithdrawFrom(Enum$WithdrawFrom e) {
  switch (e) {
    case Enum$WithdrawFrom.SENDER:
      return r'SENDER';
    case Enum$WithdrawFrom.SPONSOR:
      return r'SPONSOR';
    case Enum$WithdrawFrom.$unknown:
      return r'$unknown';
  }
}

Enum$WithdrawFrom fromJson$Enum$WithdrawFrom(String value) {
  switch (value) {
    case r'SENDER':
      return Enum$WithdrawFrom.SENDER;
    case r'SPONSOR':
      return Enum$WithdrawFrom.SPONSOR;
    default:
      return Enum$WithdrawFrom.$unknown;
  }
}

enum Enum$ZkLoginIntentScope {
  TRANSACTION_DATA,
  PERSONAL_MESSAGE,
  $unknown;

  factory Enum$ZkLoginIntentScope.fromJson(String value) =>
      fromJson$Enum$ZkLoginIntentScope(value);

  String toJson() => toJson$Enum$ZkLoginIntentScope(this);
}

String toJson$Enum$ZkLoginIntentScope(Enum$ZkLoginIntentScope e) {
  switch (e) {
    case Enum$ZkLoginIntentScope.TRANSACTION_DATA:
      return r'TRANSACTION_DATA';
    case Enum$ZkLoginIntentScope.PERSONAL_MESSAGE:
      return r'PERSONAL_MESSAGE';
    case Enum$ZkLoginIntentScope.$unknown:
      return r'$unknown';
  }
}

Enum$ZkLoginIntentScope fromJson$Enum$ZkLoginIntentScope(String value) {
  switch (value) {
    case r'TRANSACTION_DATA':
      return Enum$ZkLoginIntentScope.TRANSACTION_DATA;
    case r'PERSONAL_MESSAGE':
      return Enum$ZkLoginIntentScope.PERSONAL_MESSAGE;
    default:
      return Enum$ZkLoginIntentScope.$unknown;
  }
}

enum Enum$__TypeKind {
  SCALAR,
  OBJECT,
  INTERFACE,
  UNION,
  ENUM,
  INPUT_OBJECT,
  LIST,
  NON_NULL,
  $unknown;

  factory Enum$__TypeKind.fromJson(String value) =>
      fromJson$Enum$__TypeKind(value);

  String toJson() => toJson$Enum$__TypeKind(this);
}

String toJson$Enum$__TypeKind(Enum$__TypeKind e) {
  switch (e) {
    case Enum$__TypeKind.SCALAR:
      return r'SCALAR';
    case Enum$__TypeKind.OBJECT:
      return r'OBJECT';
    case Enum$__TypeKind.INTERFACE:
      return r'INTERFACE';
    case Enum$__TypeKind.UNION:
      return r'UNION';
    case Enum$__TypeKind.ENUM:
      return r'ENUM';
    case Enum$__TypeKind.INPUT_OBJECT:
      return r'INPUT_OBJECT';
    case Enum$__TypeKind.LIST:
      return r'LIST';
    case Enum$__TypeKind.NON_NULL:
      return r'NON_NULL';
    case Enum$__TypeKind.$unknown:
      return r'$unknown';
  }
}

Enum$__TypeKind fromJson$Enum$__TypeKind(String value) {
  switch (value) {
    case r'SCALAR':
      return Enum$__TypeKind.SCALAR;
    case r'OBJECT':
      return Enum$__TypeKind.OBJECT;
    case r'INTERFACE':
      return Enum$__TypeKind.INTERFACE;
    case r'UNION':
      return Enum$__TypeKind.UNION;
    case r'ENUM':
      return Enum$__TypeKind.ENUM;
    case r'INPUT_OBJECT':
      return Enum$__TypeKind.INPUT_OBJECT;
    case r'LIST':
      return Enum$__TypeKind.LIST;
    case r'NON_NULL':
      return Enum$__TypeKind.NON_NULL;
    default:
      return Enum$__TypeKind.$unknown;
  }
}

enum Enum$__DirectiveLocation {
  QUERY,
  MUTATION,
  SUBSCRIPTION,
  FIELD,
  FRAGMENT_DEFINITION,
  FRAGMENT_SPREAD,
  INLINE_FRAGMENT,
  VARIABLE_DEFINITION,
  SCHEMA,
  SCALAR,
  OBJECT,
  FIELD_DEFINITION,
  ARGUMENT_DEFINITION,
  INTERFACE,
  UNION,
  ENUM,
  ENUM_VALUE,
  INPUT_OBJECT,
  INPUT_FIELD_DEFINITION,
  $unknown;

  factory Enum$__DirectiveLocation.fromJson(String value) =>
      fromJson$Enum$__DirectiveLocation(value);

  String toJson() => toJson$Enum$__DirectiveLocation(this);
}

String toJson$Enum$__DirectiveLocation(Enum$__DirectiveLocation e) {
  switch (e) {
    case Enum$__DirectiveLocation.QUERY:
      return r'QUERY';
    case Enum$__DirectiveLocation.MUTATION:
      return r'MUTATION';
    case Enum$__DirectiveLocation.SUBSCRIPTION:
      return r'SUBSCRIPTION';
    case Enum$__DirectiveLocation.FIELD:
      return r'FIELD';
    case Enum$__DirectiveLocation.FRAGMENT_DEFINITION:
      return r'FRAGMENT_DEFINITION';
    case Enum$__DirectiveLocation.FRAGMENT_SPREAD:
      return r'FRAGMENT_SPREAD';
    case Enum$__DirectiveLocation.INLINE_FRAGMENT:
      return r'INLINE_FRAGMENT';
    case Enum$__DirectiveLocation.VARIABLE_DEFINITION:
      return r'VARIABLE_DEFINITION';
    case Enum$__DirectiveLocation.SCHEMA:
      return r'SCHEMA';
    case Enum$__DirectiveLocation.SCALAR:
      return r'SCALAR';
    case Enum$__DirectiveLocation.OBJECT:
      return r'OBJECT';
    case Enum$__DirectiveLocation.FIELD_DEFINITION:
      return r'FIELD_DEFINITION';
    case Enum$__DirectiveLocation.ARGUMENT_DEFINITION:
      return r'ARGUMENT_DEFINITION';
    case Enum$__DirectiveLocation.INTERFACE:
      return r'INTERFACE';
    case Enum$__DirectiveLocation.UNION:
      return r'UNION';
    case Enum$__DirectiveLocation.ENUM:
      return r'ENUM';
    case Enum$__DirectiveLocation.ENUM_VALUE:
      return r'ENUM_VALUE';
    case Enum$__DirectiveLocation.INPUT_OBJECT:
      return r'INPUT_OBJECT';
    case Enum$__DirectiveLocation.INPUT_FIELD_DEFINITION:
      return r'INPUT_FIELD_DEFINITION';
    case Enum$__DirectiveLocation.$unknown:
      return r'$unknown';
  }
}

Enum$__DirectiveLocation fromJson$Enum$__DirectiveLocation(String value) {
  switch (value) {
    case r'QUERY':
      return Enum$__DirectiveLocation.QUERY;
    case r'MUTATION':
      return Enum$__DirectiveLocation.MUTATION;
    case r'SUBSCRIPTION':
      return Enum$__DirectiveLocation.SUBSCRIPTION;
    case r'FIELD':
      return Enum$__DirectiveLocation.FIELD;
    case r'FRAGMENT_DEFINITION':
      return Enum$__DirectiveLocation.FRAGMENT_DEFINITION;
    case r'FRAGMENT_SPREAD':
      return Enum$__DirectiveLocation.FRAGMENT_SPREAD;
    case r'INLINE_FRAGMENT':
      return Enum$__DirectiveLocation.INLINE_FRAGMENT;
    case r'VARIABLE_DEFINITION':
      return Enum$__DirectiveLocation.VARIABLE_DEFINITION;
    case r'SCHEMA':
      return Enum$__DirectiveLocation.SCHEMA;
    case r'SCALAR':
      return Enum$__DirectiveLocation.SCALAR;
    case r'OBJECT':
      return Enum$__DirectiveLocation.OBJECT;
    case r'FIELD_DEFINITION':
      return Enum$__DirectiveLocation.FIELD_DEFINITION;
    case r'ARGUMENT_DEFINITION':
      return Enum$__DirectiveLocation.ARGUMENT_DEFINITION;
    case r'INTERFACE':
      return Enum$__DirectiveLocation.INTERFACE;
    case r'UNION':
      return Enum$__DirectiveLocation.UNION;
    case r'ENUM':
      return Enum$__DirectiveLocation.ENUM;
    case r'ENUM_VALUE':
      return Enum$__DirectiveLocation.ENUM_VALUE;
    case r'INPUT_OBJECT':
      return Enum$__DirectiveLocation.INPUT_OBJECT;
    case r'INPUT_FIELD_DEFINITION':
      return Enum$__DirectiveLocation.INPUT_FIELD_DEFINITION;
    default:
      return Enum$__DirectiveLocation.$unknown;
  }
}

const possibleTypesMap = <String, Set<String>>{
  'Node': {
    'Address',
    'Checkpoint',
    'DynamicField',
    'Epoch',
    'MoveObject',
    'MovePackage',
    'Object',
    'Transaction',
  },
  'IAddressable': {
    'Address',
    'CoinMetadata',
    'DynamicField',
    'MoveObject',
    'MovePackage',
    'Object',
  },
  'IMoveObject': {'CoinMetadata', 'DynamicField', 'MoveObject'},
  'IObject': {
    'CoinMetadata',
    'DynamicField',
    'MoveObject',
    'MovePackage',
    'Object',
  },
  'Command': {
    'MakeMoveVecCommand',
    'MergeCoinsCommand',
    'MoveCallCommand',
    'PublishCommand',
    'SplitCoinsCommand',
    'TransferObjectsCommand',
    'UpgradeCommand',
    'OtherCommand',
  },
  'DynamicFieldValue': {'MoveObject', 'MoveValue'},
  'EndOfEpochTransactionKind': {
    'ChangeEpochTransaction',
    'AuthenticatorStateCreateTransaction',
    'AuthenticatorStateExpireTransaction',
    'RandomnessStateCreateTransaction',
    'CoinDenyListStateCreateTransaction',
    'StoreExecutionTimeObservationsTransaction',
    'BridgeStateCreateTransaction',
    'BridgeCommitteeInitTransaction',
    'AccumulatorRootCreateTransaction',
    'CoinRegistryCreateTransaction',
    'DisplayRegistryCreateTransaction',
    'AddressAliasStateCreateTransaction',
    'WriteAccumulatorStorageCostTransaction',
  },
  'IMoveDatatype': {'MoveDatatype', 'MoveEnum', 'MoveStruct'},
  'MultisigMemberPublicKey': {
    'Ed25519PublicKey',
    'Secp256K1PublicKey',
    'Secp256R1PublicKey',
    'PasskeyPublicKey',
    'ZkLoginPublicIdentifier',
  },
  'Owner': {
    'AddressOwner',
    'ObjectOwner',
    'Shared',
    'Immutable',
    'ConsensusAddressOwner',
  },
  'SignatureScheme': {
    'Ed25519Signature',
    'Secp256K1Signature',
    'Secp256R1Signature',
    'MultisigSignature',
    'ZkLoginSignature',
    'PasskeySignature',
  },
  'TransactionArgument': {'GasCoin', 'Input', 'TxResult'},
  'TransactionInput': {
    'Pure',
    'MoveValue',
    'OwnedOrImmutable',
    'SharedInput',
    'Receiving',
    'BalanceWithdraw',
  },
  'TransactionKind': {
    'GenesisTransaction',
    'ConsensusCommitPrologueTransaction',
    'ChangeEpochTransaction',
    'RandomnessStateUpdateTransaction',
    'AuthenticatorStateUpdateTransaction',
    'EndOfEpochTransaction',
    'ProgrammableTransaction',
    'ProgrammableSystemTransaction',
  },
  'UnchangedConsensusObject': {
    'ConsensusObjectRead',
    'MutateConsensusStreamEnded',
    'ReadConsensusStreamEnded',
    'ConsensusObjectCancelled',
    'PerEpochConfig',
  },
  'WithdrawalReservation': {'WithdrawMaxAmountU64'},
};
