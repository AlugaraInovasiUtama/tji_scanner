import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'local_db.g.dart';

// ─── Tables ────────────────────────────────────────────────────────────────

class PendingOperations extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operationType => text()(); // putaway, picking, etc.
  TextColumn get payload => text()(); // JSON payload
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending, syncing, failed, synced
  TextColumn get errorMessage => text().nullable()();
}

class CachedProducts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().unique()();
  TextColumn get name => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get uom => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();
}

class CachedLocations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get locationId => integer().unique()();
  TextColumn get name => text()();
  TextColumn get completeName => text()();
  TextColumn get usage => text()(); // internal, customer, supplier, etc.
  DateTimeColumn get cachedAt => dateTime()();
}

class ScanHistories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operationType => text()();
  TextColumn get scannedCode => text()();
  TextColumn get scanType => text()(); // box, pallet, rack
  IntColumn get userId => integer()();
  TextColumn get userName => text()();
  DateTimeColumn get scannedAt => dateTime()();
  TextColumn get status => text()(); // success, failed
  TextColumn get detail => text().nullable()();
}

// ─── Database ──────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [PendingOperations, CachedProducts, CachedLocations, ScanHistories],
)
class LocalDb extends _$LocalDb {
  LocalDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── Pending Operations ──
  Future<List<PendingOperation>> getPendingOperations() =>
      (select(pendingOperations)
            ..where((t) => t.status.isIn(['pending', 'failed']))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  Future<int> insertPendingOperation(PendingOperationsCompanion entry) =>
      into(pendingOperations).insert(entry);

  Future<void> markAsSynced(int id) => (update(pendingOperations)
        ..where((t) => t.id.equals(id)))
      .write(PendingOperationsCompanion(status: Value('synced')));

  Future<void> markAsFailed(int id, String errorMsg) =>
      (update(pendingOperations)..where((t) => t.id.equals(id))).write(
        PendingOperationsCompanion(
          status: const Value('failed'),
          errorMessage: Value(errorMsg),
          retryCount: Value(0),
        ),
      );

  Future<void> incrementRetry(int id) async {
    final op = await (select(pendingOperations)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (op == null) return;
    await (update(pendingOperations)..where((t) => t.id.equals(id))).write(
      PendingOperationsCompanion(retryCount: Value(op.retryCount + 1)),
    );
  }

  // ── Scan History ──
  Future<int> insertScanHistory(ScanHistoriesCompanion entry) =>
      into(scanHistories).insert(entry);

  Future<List<ScanHistory>> getRecentHistory({int limit = 50}) =>
      (select(scanHistories)
            ..orderBy([(t) => OrderingTerm.desc(t.scannedAt)])
            ..limit(limit))
          .get();

  Future<void> clearOldHistory(DateTime before) =>
      (delete(scanHistories)..where((t) => t.scannedAt.isSmallerThanValue(before)))
          .go();

  // ── Cached Products ──
  Future<CachedProduct?> getCachedProduct(int productId) =>
      (select(cachedProducts)..where((t) => t.productId.equals(productId)))
          .getSingleOrNull();

  Future<void> upsertProduct(CachedProductsCompanion entry) =>
      into(cachedProducts).insertOnConflictUpdate(entry);

  // ── Cached Locations ──
  Future<CachedLocation?> getCachedLocation(int locationId) =>
      (select(cachedLocations)..where((t) => t.locationId.equals(locationId)))
          .getSingleOrNull();

  Future<void> upsertLocation(CachedLocationsCompanion entry) =>
      into(cachedLocations).insertOnConflictUpdate(entry);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tji_scanner.db'));
    return NativeDatabase.createInBackground(file);
  });
}
