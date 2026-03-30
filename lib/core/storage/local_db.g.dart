// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $PendingOperationsTable extends PendingOperations
    with TableInfo<$PendingOperationsTable, PendingOperation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingOperationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationType,
    payload,
    createdAt,
    retryCount,
    status,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_operations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingOperation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingOperation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingOperation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
    );
  }

  @override
  $PendingOperationsTable createAlias(String alias) {
    return $PendingOperationsTable(attachedDatabase, alias);
  }
}

class PendingOperation extends DataClass
    implements Insertable<PendingOperation> {
  final int id;
  final String operationType;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  final String status;
  final String? errorMessage;
  const PendingOperation({
    required this.id,
    required this.operationType,
    required this.payload,
    required this.createdAt,
    required this.retryCount,
    required this.status,
    this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation_type'] = Variable<String>(operationType);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  PendingOperationsCompanion toCompanion(bool nullToAbsent) {
    return PendingOperationsCompanion(
      id: Value(id),
      operationType: Value(operationType),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory PendingOperation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingOperation(
      id: serializer.fromJson<int>(json['id']),
      operationType: serializer.fromJson<String>(json['operationType']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operationType': serializer.toJson<String>(operationType),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  PendingOperation copyWith({
    int? id,
    String? operationType,
    String? payload,
    DateTime? createdAt,
    int? retryCount,
    String? status,
    Value<String?> errorMessage = const Value.absent(),
  }) => PendingOperation(
    id: id ?? this.id,
    operationType: operationType ?? this.operationType,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    retryCount: retryCount ?? this.retryCount,
    status: status ?? this.status,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
  );
  PendingOperation copyWithCompanion(PendingOperationsCompanion data) {
    return PendingOperation(
      id: data.id.present ? data.id.value : this.id,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperation(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationType,
    payload,
    createdAt,
    retryCount,
    status,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingOperation &&
          other.id == this.id &&
          other.operationType == this.operationType &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage);
}

class PendingOperationsCompanion extends UpdateCompanion<PendingOperation> {
  final Value<int> id;
  final Value<String> operationType;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String> status;
  final Value<String?> errorMessage;
  const PendingOperationsCompanion({
    this.id = const Value.absent(),
    this.operationType = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  PendingOperationsCompanion.insert({
    this.id = const Value.absent(),
    required String operationType,
    required String payload,
    required DateTime createdAt,
    this.retryCount = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  }) : operationType = Value(operationType),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<PendingOperation> custom({
    Expression<int>? id,
    Expression<String>? operationType,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? status,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationType != null) 'operation_type': operationType,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  PendingOperationsCompanion copyWith({
    Value<int>? id,
    Value<String>? operationType,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? retryCount,
    Value<String>? status,
    Value<String?>? errorMessage,
  }) {
    return PendingOperationsCompanion(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingOperationsCompanion(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $CachedProductsTable extends CachedProducts
    with TableInfo<$CachedProductsTable, CachedProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uomMeta = const VerificationMeta('uom');
  @override
  late final GeneratedColumn<String> uom = GeneratedColumn<String>(
    'uom',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    name,
    barcode,
    uom,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_products';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedProduct> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('uom')) {
      context.handle(
        _uomMeta,
        uom.isAcceptableOrUnknown(data['uom']!, _uomMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedProduct(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      uom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uom'],
      ),
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedProductsTable createAlias(String alias) {
    return $CachedProductsTable(attachedDatabase, alias);
  }
}

class CachedProduct extends DataClass implements Insertable<CachedProduct> {
  final int id;
  final int productId;
  final String name;
  final String? barcode;
  final String? uom;
  final DateTime cachedAt;
  const CachedProduct({
    required this.id,
    required this.productId,
    required this.name,
    this.barcode,
    this.uom,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || uom != null) {
      map['uom'] = Variable<String>(uom);
    }
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedProductsCompanion toCompanion(bool nullToAbsent) {
    return CachedProductsCompanion(
      id: Value(id),
      productId: Value(productId),
      name: Value(name),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      uom: uom == null && nullToAbsent ? const Value.absent() : Value(uom),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedProduct.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedProduct(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      uom: serializer.fromJson<String?>(json['uom']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'name': serializer.toJson<String>(name),
      'barcode': serializer.toJson<String?>(barcode),
      'uom': serializer.toJson<String?>(uom),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedProduct copyWith({
    int? id,
    int? productId,
    String? name,
    Value<String?> barcode = const Value.absent(),
    Value<String?> uom = const Value.absent(),
    DateTime? cachedAt,
  }) => CachedProduct(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    name: name ?? this.name,
    barcode: barcode.present ? barcode.value : this.barcode,
    uom: uom.present ? uom.value : this.uom,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedProduct copyWithCompanion(CachedProductsCompanion data) {
    return CachedProduct(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      uom: data.uom.present ? data.uom.value : this.uom,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedProduct(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('uom: $uom, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, productId, name, barcode, uom, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedProduct &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.barcode == this.barcode &&
          other.uom == this.uom &&
          other.cachedAt == this.cachedAt);
}

class CachedProductsCompanion extends UpdateCompanion<CachedProduct> {
  final Value<int> id;
  final Value<int> productId;
  final Value<String> name;
  final Value<String?> barcode;
  final Value<String?> uom;
  final Value<DateTime> cachedAt;
  const CachedProductsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.barcode = const Value.absent(),
    this.uom = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedProductsCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required String name,
    this.barcode = const Value.absent(),
    this.uom = const Value.absent(),
    required DateTime cachedAt,
  }) : productId = Value(productId),
       name = Value(name),
       cachedAt = Value(cachedAt);
  static Insertable<CachedProduct> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<String>? name,
    Expression<String>? barcode,
    Expression<String>? uom,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (barcode != null) 'barcode': barcode,
      if (uom != null) 'uom': uom,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedProductsCompanion copyWith({
    Value<int>? id,
    Value<int>? productId,
    Value<String>? name,
    Value<String?>? barcode,
    Value<String?>? uom,
    Value<DateTime>? cachedAt,
  }) {
    return CachedProductsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      uom: uom ?? this.uom,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (uom.present) {
      map['uom'] = Variable<String>(uom.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedProductsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('uom: $uom, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $CachedLocationsTable extends CachedLocations
    with TableInfo<$CachedLocationsTable, CachedLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<int> locationId = GeneratedColumn<int>(
    'location_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completeNameMeta = const VerificationMeta(
    'completeName',
  );
  @override
  late final GeneratedColumn<String> completeName = GeneratedColumn<String>(
    'complete_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usageMeta = const VerificationMeta('usage');
  @override
  late final GeneratedColumn<String> usage = GeneratedColumn<String>(
    'usage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    locationId,
    name,
    completeName,
    usage,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedLocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_locationIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('complete_name')) {
      context.handle(
        _completeNameMeta,
        completeName.isAcceptableOrUnknown(
          data['complete_name']!,
          _completeNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completeNameMeta);
    }
    if (data.containsKey('usage')) {
      context.handle(
        _usageMeta,
        usage.isAcceptableOrUnknown(data['usage']!, _usageMeta),
      );
    } else if (isInserting) {
      context.missing(_usageMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedLocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}location_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      completeName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}complete_name'],
      )!,
      usage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedLocationsTable createAlias(String alias) {
    return $CachedLocationsTable(attachedDatabase, alias);
  }
}

class CachedLocation extends DataClass implements Insertable<CachedLocation> {
  final int id;
  final int locationId;
  final String name;
  final String completeName;
  final String usage;
  final DateTime cachedAt;
  const CachedLocation({
    required this.id,
    required this.locationId,
    required this.name,
    required this.completeName,
    required this.usage,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['location_id'] = Variable<int>(locationId);
    map['name'] = Variable<String>(name);
    map['complete_name'] = Variable<String>(completeName);
    map['usage'] = Variable<String>(usage);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedLocationsCompanion toCompanion(bool nullToAbsent) {
    return CachedLocationsCompanion(
      id: Value(id),
      locationId: Value(locationId),
      name: Value(name),
      completeName: Value(completeName),
      usage: Value(usage),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedLocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedLocation(
      id: serializer.fromJson<int>(json['id']),
      locationId: serializer.fromJson<int>(json['locationId']),
      name: serializer.fromJson<String>(json['name']),
      completeName: serializer.fromJson<String>(json['completeName']),
      usage: serializer.fromJson<String>(json['usage']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'locationId': serializer.toJson<int>(locationId),
      'name': serializer.toJson<String>(name),
      'completeName': serializer.toJson<String>(completeName),
      'usage': serializer.toJson<String>(usage),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedLocation copyWith({
    int? id,
    int? locationId,
    String? name,
    String? completeName,
    String? usage,
    DateTime? cachedAt,
  }) => CachedLocation(
    id: id ?? this.id,
    locationId: locationId ?? this.locationId,
    name: name ?? this.name,
    completeName: completeName ?? this.completeName,
    usage: usage ?? this.usage,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedLocation copyWithCompanion(CachedLocationsCompanion data) {
    return CachedLocation(
      id: data.id.present ? data.id.value : this.id,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      name: data.name.present ? data.name.value : this.name,
      completeName: data.completeName.present
          ? data.completeName.value
          : this.completeName,
      usage: data.usage.present ? data.usage.value : this.usage,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedLocation(')
          ..write('id: $id, ')
          ..write('locationId: $locationId, ')
          ..write('name: $name, ')
          ..write('completeName: $completeName, ')
          ..write('usage: $usage, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, locationId, name, completeName, usage, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedLocation &&
          other.id == this.id &&
          other.locationId == this.locationId &&
          other.name == this.name &&
          other.completeName == this.completeName &&
          other.usage == this.usage &&
          other.cachedAt == this.cachedAt);
}

class CachedLocationsCompanion extends UpdateCompanion<CachedLocation> {
  final Value<int> id;
  final Value<int> locationId;
  final Value<String> name;
  final Value<String> completeName;
  final Value<String> usage;
  final Value<DateTime> cachedAt;
  const CachedLocationsCompanion({
    this.id = const Value.absent(),
    this.locationId = const Value.absent(),
    this.name = const Value.absent(),
    this.completeName = const Value.absent(),
    this.usage = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  CachedLocationsCompanion.insert({
    this.id = const Value.absent(),
    required int locationId,
    required String name,
    required String completeName,
    required String usage,
    required DateTime cachedAt,
  }) : locationId = Value(locationId),
       name = Value(name),
       completeName = Value(completeName),
       usage = Value(usage),
       cachedAt = Value(cachedAt);
  static Insertable<CachedLocation> custom({
    Expression<int>? id,
    Expression<int>? locationId,
    Expression<String>? name,
    Expression<String>? completeName,
    Expression<String>? usage,
    Expression<DateTime>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (locationId != null) 'location_id': locationId,
      if (name != null) 'name': name,
      if (completeName != null) 'complete_name': completeName,
      if (usage != null) 'usage': usage,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  CachedLocationsCompanion copyWith({
    Value<int>? id,
    Value<int>? locationId,
    Value<String>? name,
    Value<String>? completeName,
    Value<String>? usage,
    Value<DateTime>? cachedAt,
  }) {
    return CachedLocationsCompanion(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      completeName: completeName ?? this.completeName,
      usage: usage ?? this.usage,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<int>(locationId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (completeName.present) {
      map['complete_name'] = Variable<String>(completeName.value);
    }
    if (usage.present) {
      map['usage'] = Variable<String>(usage.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedLocationsCompanion(')
          ..write('id: $id, ')
          ..write('locationId: $locationId, ')
          ..write('name: $name, ')
          ..write('completeName: $completeName, ')
          ..write('usage: $usage, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class $ScanHistoriesTable extends ScanHistories
    with TableInfo<$ScanHistoriesTable, ScanHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scannedCodeMeta = const VerificationMeta(
    'scannedCode',
  );
  @override
  late final GeneratedColumn<String> scannedCode = GeneratedColumn<String>(
    'scanned_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scanTypeMeta = const VerificationMeta(
    'scanType',
  );
  @override
  late final GeneratedColumn<String> scanType = GeneratedColumn<String>(
    'scan_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scannedAtMeta = const VerificationMeta(
    'scannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> scannedAt = GeneratedColumn<DateTime>(
    'scanned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
    'detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationType,
    scannedCode,
    scanType,
    userId,
    userName,
    scannedAt,
    status,
    detail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('scanned_code')) {
      context.handle(
        _scannedCodeMeta,
        scannedCode.isAcceptableOrUnknown(
          data['scanned_code']!,
          _scannedCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scannedCodeMeta);
    }
    if (data.containsKey('scan_type')) {
      context.handle(
        _scanTypeMeta,
        scanType.isAcceptableOrUnknown(data['scan_type']!, _scanTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_scanTypeMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    } else if (isInserting) {
      context.missing(_userNameMeta);
    }
    if (data.containsKey('scanned_at')) {
      context.handle(
        _scannedAtMeta,
        scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_scannedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(
        _detailMeta,
        detail.isAcceptableOrUnknown(data['detail']!, _detailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      scannedCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scanned_code'],
      )!,
      scanType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scan_type'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      )!,
      scannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scanned_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      detail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail'],
      ),
    );
  }

  @override
  $ScanHistoriesTable createAlias(String alias) {
    return $ScanHistoriesTable(attachedDatabase, alias);
  }
}

class ScanHistory extends DataClass implements Insertable<ScanHistory> {
  final int id;
  final String operationType;
  final String scannedCode;
  final String scanType;
  final int userId;
  final String userName;
  final DateTime scannedAt;
  final String status;
  final String? detail;
  const ScanHistory({
    required this.id,
    required this.operationType,
    required this.scannedCode,
    required this.scanType,
    required this.userId,
    required this.userName,
    required this.scannedAt,
    required this.status,
    this.detail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['operation_type'] = Variable<String>(operationType);
    map['scanned_code'] = Variable<String>(scannedCode);
    map['scan_type'] = Variable<String>(scanType);
    map['user_id'] = Variable<int>(userId);
    map['user_name'] = Variable<String>(userName);
    map['scanned_at'] = Variable<DateTime>(scannedAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || detail != null) {
      map['detail'] = Variable<String>(detail);
    }
    return map;
  }

  ScanHistoriesCompanion toCompanion(bool nullToAbsent) {
    return ScanHistoriesCompanion(
      id: Value(id),
      operationType: Value(operationType),
      scannedCode: Value(scannedCode),
      scanType: Value(scanType),
      userId: Value(userId),
      userName: Value(userName),
      scannedAt: Value(scannedAt),
      status: Value(status),
      detail: detail == null && nullToAbsent
          ? const Value.absent()
          : Value(detail),
    );
  }

  factory ScanHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanHistory(
      id: serializer.fromJson<int>(json['id']),
      operationType: serializer.fromJson<String>(json['operationType']),
      scannedCode: serializer.fromJson<String>(json['scannedCode']),
      scanType: serializer.fromJson<String>(json['scanType']),
      userId: serializer.fromJson<int>(json['userId']),
      userName: serializer.fromJson<String>(json['userName']),
      scannedAt: serializer.fromJson<DateTime>(json['scannedAt']),
      status: serializer.fromJson<String>(json['status']),
      detail: serializer.fromJson<String?>(json['detail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'operationType': serializer.toJson<String>(operationType),
      'scannedCode': serializer.toJson<String>(scannedCode),
      'scanType': serializer.toJson<String>(scanType),
      'userId': serializer.toJson<int>(userId),
      'userName': serializer.toJson<String>(userName),
      'scannedAt': serializer.toJson<DateTime>(scannedAt),
      'status': serializer.toJson<String>(status),
      'detail': serializer.toJson<String?>(detail),
    };
  }

  ScanHistory copyWith({
    int? id,
    String? operationType,
    String? scannedCode,
    String? scanType,
    int? userId,
    String? userName,
    DateTime? scannedAt,
    String? status,
    Value<String?> detail = const Value.absent(),
  }) => ScanHistory(
    id: id ?? this.id,
    operationType: operationType ?? this.operationType,
    scannedCode: scannedCode ?? this.scannedCode,
    scanType: scanType ?? this.scanType,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    scannedAt: scannedAt ?? this.scannedAt,
    status: status ?? this.status,
    detail: detail.present ? detail.value : this.detail,
  );
  ScanHistory copyWithCompanion(ScanHistoriesCompanion data) {
    return ScanHistory(
      id: data.id.present ? data.id.value : this.id,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      scannedCode: data.scannedCode.present
          ? data.scannedCode.value
          : this.scannedCode,
      scanType: data.scanType.present ? data.scanType.value : this.scanType,
      userId: data.userId.present ? data.userId.value : this.userId,
      userName: data.userName.present ? data.userName.value : this.userName,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
      status: data.status.present ? data.status.value : this.status,
      detail: data.detail.present ? data.detail.value : this.detail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanHistory(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('scannedCode: $scannedCode, ')
          ..write('scanType: $scanType, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('status: $status, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationType,
    scannedCode,
    scanType,
    userId,
    userName,
    scannedAt,
    status,
    detail,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanHistory &&
          other.id == this.id &&
          other.operationType == this.operationType &&
          other.scannedCode == this.scannedCode &&
          other.scanType == this.scanType &&
          other.userId == this.userId &&
          other.userName == this.userName &&
          other.scannedAt == this.scannedAt &&
          other.status == this.status &&
          other.detail == this.detail);
}

class ScanHistoriesCompanion extends UpdateCompanion<ScanHistory> {
  final Value<int> id;
  final Value<String> operationType;
  final Value<String> scannedCode;
  final Value<String> scanType;
  final Value<int> userId;
  final Value<String> userName;
  final Value<DateTime> scannedAt;
  final Value<String> status;
  final Value<String?> detail;
  const ScanHistoriesCompanion({
    this.id = const Value.absent(),
    this.operationType = const Value.absent(),
    this.scannedCode = const Value.absent(),
    this.scanType = const Value.absent(),
    this.userId = const Value.absent(),
    this.userName = const Value.absent(),
    this.scannedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.detail = const Value.absent(),
  });
  ScanHistoriesCompanion.insert({
    this.id = const Value.absent(),
    required String operationType,
    required String scannedCode,
    required String scanType,
    required int userId,
    required String userName,
    required DateTime scannedAt,
    required String status,
    this.detail = const Value.absent(),
  }) : operationType = Value(operationType),
       scannedCode = Value(scannedCode),
       scanType = Value(scanType),
       userId = Value(userId),
       userName = Value(userName),
       scannedAt = Value(scannedAt),
       status = Value(status);
  static Insertable<ScanHistory> custom({
    Expression<int>? id,
    Expression<String>? operationType,
    Expression<String>? scannedCode,
    Expression<String>? scanType,
    Expression<int>? userId,
    Expression<String>? userName,
    Expression<DateTime>? scannedAt,
    Expression<String>? status,
    Expression<String>? detail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationType != null) 'operation_type': operationType,
      if (scannedCode != null) 'scanned_code': scannedCode,
      if (scanType != null) 'scan_type': scanType,
      if (userId != null) 'user_id': userId,
      if (userName != null) 'user_name': userName,
      if (scannedAt != null) 'scanned_at': scannedAt,
      if (status != null) 'status': status,
      if (detail != null) 'detail': detail,
    });
  }

  ScanHistoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? operationType,
    Value<String>? scannedCode,
    Value<String>? scanType,
    Value<int>? userId,
    Value<String>? userName,
    Value<DateTime>? scannedAt,
    Value<String>? status,
    Value<String?>? detail,
  }) {
    return ScanHistoriesCompanion(
      id: id ?? this.id,
      operationType: operationType ?? this.operationType,
      scannedCode: scannedCode ?? this.scannedCode,
      scanType: scanType ?? this.scanType,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      scannedAt: scannedAt ?? this.scannedAt,
      status: status ?? this.status,
      detail: detail ?? this.detail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (scannedCode.present) {
      map['scanned_code'] = Variable<String>(scannedCode.value);
    }
    if (scanType.present) {
      map['scan_type'] = Variable<String>(scanType.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<DateTime>(scannedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('operationType: $operationType, ')
          ..write('scannedCode: $scannedCode, ')
          ..write('scanType: $scanType, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('scannedAt: $scannedAt, ')
          ..write('status: $status, ')
          ..write('detail: $detail')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDb extends GeneratedDatabase {
  _$LocalDb(QueryExecutor e) : super(e);
  $LocalDbManager get managers => $LocalDbManager(this);
  late final $PendingOperationsTable pendingOperations =
      $PendingOperationsTable(this);
  late final $CachedProductsTable cachedProducts = $CachedProductsTable(this);
  late final $CachedLocationsTable cachedLocations = $CachedLocationsTable(
    this,
  );
  late final $ScanHistoriesTable scanHistories = $ScanHistoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pendingOperations,
    cachedProducts,
    cachedLocations,
    scanHistories,
  ];
}

typedef $$PendingOperationsTableCreateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<int> id,
      required String operationType,
      required String payload,
      required DateTime createdAt,
      Value<int> retryCount,
      Value<String> status,
      Value<String?> errorMessage,
    });
typedef $$PendingOperationsTableUpdateCompanionBuilder =
    PendingOperationsCompanion Function({
      Value<int> id,
      Value<String> operationType,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> retryCount,
      Value<String> status,
      Value<String?> errorMessage,
    });

class $$PendingOperationsTableFilterComposer
    extends Composer<_$LocalDb, $PendingOperationsTable> {
  $$PendingOperationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingOperationsTableOrderingComposer
    extends Composer<_$LocalDb, $PendingOperationsTable> {
  $$PendingOperationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingOperationsTableAnnotationComposer
    extends Composer<_$LocalDb, $PendingOperationsTable> {
  $$PendingOperationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$PendingOperationsTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $PendingOperationsTable,
          PendingOperation,
          $$PendingOperationsTableFilterComposer,
          $$PendingOperationsTableOrderingComposer,
          $$PendingOperationsTableAnnotationComposer,
          $$PendingOperationsTableCreateCompanionBuilder,
          $$PendingOperationsTableUpdateCompanionBuilder,
          (
            PendingOperation,
            BaseReferences<
              _$LocalDb,
              $PendingOperationsTable,
              PendingOperation
            >,
          ),
          PendingOperation,
          PrefetchHooks Function()
        > {
  $$PendingOperationsTableTableManager(
    _$LocalDb db,
    $PendingOperationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingOperationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingOperationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingOperationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => PendingOperationsCompanion(
                id: id,
                operationType: operationType,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
                status: status,
                errorMessage: errorMessage,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operationType,
                required String payload,
                required DateTime createdAt,
                Value<int> retryCount = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
              }) => PendingOperationsCompanion.insert(
                id: id,
                operationType: operationType,
                payload: payload,
                createdAt: createdAt,
                retryCount: retryCount,
                status: status,
                errorMessage: errorMessage,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingOperationsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $PendingOperationsTable,
      PendingOperation,
      $$PendingOperationsTableFilterComposer,
      $$PendingOperationsTableOrderingComposer,
      $$PendingOperationsTableAnnotationComposer,
      $$PendingOperationsTableCreateCompanionBuilder,
      $$PendingOperationsTableUpdateCompanionBuilder,
      (
        PendingOperation,
        BaseReferences<_$LocalDb, $PendingOperationsTable, PendingOperation>,
      ),
      PendingOperation,
      PrefetchHooks Function()
    >;
typedef $$CachedProductsTableCreateCompanionBuilder =
    CachedProductsCompanion Function({
      Value<int> id,
      required int productId,
      required String name,
      Value<String?> barcode,
      Value<String?> uom,
      required DateTime cachedAt,
    });
typedef $$CachedProductsTableUpdateCompanionBuilder =
    CachedProductsCompanion Function({
      Value<int> id,
      Value<int> productId,
      Value<String> name,
      Value<String?> barcode,
      Value<String?> uom,
      Value<DateTime> cachedAt,
    });

class $$CachedProductsTableFilterComposer
    extends Composer<_$LocalDb, $CachedProductsTable> {
  $$CachedProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uom => $composableBuilder(
    column: $table.uom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedProductsTableOrderingComposer
    extends Composer<_$LocalDb, $CachedProductsTable> {
  $$CachedProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uom => $composableBuilder(
    column: $table.uom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedProductsTableAnnotationComposer
    extends Composer<_$LocalDb, $CachedProductsTable> {
  $$CachedProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get uom =>
      $composableBuilder(column: $table.uom, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedProductsTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $CachedProductsTable,
          CachedProduct,
          $$CachedProductsTableFilterComposer,
          $$CachedProductsTableOrderingComposer,
          $$CachedProductsTableAnnotationComposer,
          $$CachedProductsTableCreateCompanionBuilder,
          $$CachedProductsTableUpdateCompanionBuilder,
          (
            CachedProduct,
            BaseReferences<_$LocalDb, $CachedProductsTable, CachedProduct>,
          ),
          CachedProduct,
          PrefetchHooks Function()
        > {
  $$CachedProductsTableTableManager(_$LocalDb db, $CachedProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> uom = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => CachedProductsCompanion(
                id: id,
                productId: productId,
                name: name,
                barcode: barcode,
                uom: uom,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productId,
                required String name,
                Value<String?> barcode = const Value.absent(),
                Value<String?> uom = const Value.absent(),
                required DateTime cachedAt,
              }) => CachedProductsCompanion.insert(
                id: id,
                productId: productId,
                name: name,
                barcode: barcode,
                uom: uom,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $CachedProductsTable,
      CachedProduct,
      $$CachedProductsTableFilterComposer,
      $$CachedProductsTableOrderingComposer,
      $$CachedProductsTableAnnotationComposer,
      $$CachedProductsTableCreateCompanionBuilder,
      $$CachedProductsTableUpdateCompanionBuilder,
      (
        CachedProduct,
        BaseReferences<_$LocalDb, $CachedProductsTable, CachedProduct>,
      ),
      CachedProduct,
      PrefetchHooks Function()
    >;
typedef $$CachedLocationsTableCreateCompanionBuilder =
    CachedLocationsCompanion Function({
      Value<int> id,
      required int locationId,
      required String name,
      required String completeName,
      required String usage,
      required DateTime cachedAt,
    });
typedef $$CachedLocationsTableUpdateCompanionBuilder =
    CachedLocationsCompanion Function({
      Value<int> id,
      Value<int> locationId,
      Value<String> name,
      Value<String> completeName,
      Value<String> usage,
      Value<DateTime> cachedAt,
    });

class $$CachedLocationsTableFilterComposer
    extends Composer<_$LocalDb, $CachedLocationsTable> {
  $$CachedLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completeName => $composableBuilder(
    column: $table.completeName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usage => $composableBuilder(
    column: $table.usage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedLocationsTableOrderingComposer
    extends Composer<_$LocalDb, $CachedLocationsTable> {
  $$CachedLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completeName => $composableBuilder(
    column: $table.completeName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usage => $composableBuilder(
    column: $table.usage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedLocationsTableAnnotationComposer
    extends Composer<_$LocalDb, $CachedLocationsTable> {
  $$CachedLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get completeName => $composableBuilder(
    column: $table.completeName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get usage =>
      $composableBuilder(column: $table.usage, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedLocationsTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $CachedLocationsTable,
          CachedLocation,
          $$CachedLocationsTableFilterComposer,
          $$CachedLocationsTableOrderingComposer,
          $$CachedLocationsTableAnnotationComposer,
          $$CachedLocationsTableCreateCompanionBuilder,
          $$CachedLocationsTableUpdateCompanionBuilder,
          (
            CachedLocation,
            BaseReferences<_$LocalDb, $CachedLocationsTable, CachedLocation>,
          ),
          CachedLocation,
          PrefetchHooks Function()
        > {
  $$CachedLocationsTableTableManager(_$LocalDb db, $CachedLocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> locationId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> completeName = const Value.absent(),
                Value<String> usage = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
              }) => CachedLocationsCompanion(
                id: id,
                locationId: locationId,
                name: name,
                completeName: completeName,
                usage: usage,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int locationId,
                required String name,
                required String completeName,
                required String usage,
                required DateTime cachedAt,
              }) => CachedLocationsCompanion.insert(
                id: id,
                locationId: locationId,
                name: name,
                completeName: completeName,
                usage: usage,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedLocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $CachedLocationsTable,
      CachedLocation,
      $$CachedLocationsTableFilterComposer,
      $$CachedLocationsTableOrderingComposer,
      $$CachedLocationsTableAnnotationComposer,
      $$CachedLocationsTableCreateCompanionBuilder,
      $$CachedLocationsTableUpdateCompanionBuilder,
      (
        CachedLocation,
        BaseReferences<_$LocalDb, $CachedLocationsTable, CachedLocation>,
      ),
      CachedLocation,
      PrefetchHooks Function()
    >;
typedef $$ScanHistoriesTableCreateCompanionBuilder =
    ScanHistoriesCompanion Function({
      Value<int> id,
      required String operationType,
      required String scannedCode,
      required String scanType,
      required int userId,
      required String userName,
      required DateTime scannedAt,
      required String status,
      Value<String?> detail,
    });
typedef $$ScanHistoriesTableUpdateCompanionBuilder =
    ScanHistoriesCompanion Function({
      Value<int> id,
      Value<String> operationType,
      Value<String> scannedCode,
      Value<String> scanType,
      Value<int> userId,
      Value<String> userName,
      Value<DateTime> scannedAt,
      Value<String> status,
      Value<String?> detail,
    });

class $$ScanHistoriesTableFilterComposer
    extends Composer<_$LocalDb, $ScanHistoriesTable> {
  $$ScanHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scannedCode => $composableBuilder(
    column: $table.scannedCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scanType => $composableBuilder(
    column: $table.scanType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanHistoriesTableOrderingComposer
    extends Composer<_$LocalDb, $ScanHistoriesTable> {
  $$ScanHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scannedCode => $composableBuilder(
    column: $table.scannedCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scanType => $composableBuilder(
    column: $table.scanType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detail => $composableBuilder(
    column: $table.detail,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanHistoriesTableAnnotationComposer
    extends Composer<_$LocalDb, $ScanHistoriesTable> {
  $$ScanHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scannedCode => $composableBuilder(
    column: $table.scannedCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scanType =>
      $composableBuilder(column: $table.scanType, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<DateTime> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);
}

class $$ScanHistoriesTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $ScanHistoriesTable,
          ScanHistory,
          $$ScanHistoriesTableFilterComposer,
          $$ScanHistoriesTableOrderingComposer,
          $$ScanHistoriesTableAnnotationComposer,
          $$ScanHistoriesTableCreateCompanionBuilder,
          $$ScanHistoriesTableUpdateCompanionBuilder,
          (
            ScanHistory,
            BaseReferences<_$LocalDb, $ScanHistoriesTable, ScanHistory>,
          ),
          ScanHistory,
          PrefetchHooks Function()
        > {
  $$ScanHistoriesTableTableManager(_$LocalDb db, $ScanHistoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<String> scannedCode = const Value.absent(),
                Value<String> scanType = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> userName = const Value.absent(),
                Value<DateTime> scannedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> detail = const Value.absent(),
              }) => ScanHistoriesCompanion(
                id: id,
                operationType: operationType,
                scannedCode: scannedCode,
                scanType: scanType,
                userId: userId,
                userName: userName,
                scannedAt: scannedAt,
                status: status,
                detail: detail,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String operationType,
                required String scannedCode,
                required String scanType,
                required int userId,
                required String userName,
                required DateTime scannedAt,
                required String status,
                Value<String?> detail = const Value.absent(),
              }) => ScanHistoriesCompanion.insert(
                id: id,
                operationType: operationType,
                scannedCode: scannedCode,
                scanType: scanType,
                userId: userId,
                userName: userName,
                scannedAt: scannedAt,
                status: status,
                detail: detail,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScanHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $ScanHistoriesTable,
      ScanHistory,
      $$ScanHistoriesTableFilterComposer,
      $$ScanHistoriesTableOrderingComposer,
      $$ScanHistoriesTableAnnotationComposer,
      $$ScanHistoriesTableCreateCompanionBuilder,
      $$ScanHistoriesTableUpdateCompanionBuilder,
      (
        ScanHistory,
        BaseReferences<_$LocalDb, $ScanHistoriesTable, ScanHistory>,
      ),
      ScanHistory,
      PrefetchHooks Function()
    >;

class $LocalDbManager {
  final _$LocalDb _db;
  $LocalDbManager(this._db);
  $$PendingOperationsTableTableManager get pendingOperations =>
      $$PendingOperationsTableTableManager(_db, _db.pendingOperations);
  $$CachedProductsTableTableManager get cachedProducts =>
      $$CachedProductsTableTableManager(_db, _db.cachedProducts);
  $$CachedLocationsTableTableManager get cachedLocations =>
      $$CachedLocationsTableTableManager(_db, _db.cachedLocations);
  $$ScanHistoriesTableTableManager get scanHistories =>
      $$ScanHistoriesTableTableManager(_db, _db.scanHistories);
}
