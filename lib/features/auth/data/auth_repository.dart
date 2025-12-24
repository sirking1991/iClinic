import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(ref.watch(databaseProvider)),
);

class AuthRepository {
  final AppDatabase _db;
  AuthRepository(this._db);

  Future<Doctor?> getDoctor() {
    return _db.select(_db.doctors).getSingleOrNull();
  }

  Future<void> setupAccount(
    String name,
    String specialization,
    String pin,
  ) async {
    await _db
        .into(_db.doctors)
        .insert(
          DoctorsCompanion.insert(
            fullName: name,
            specialization: Value(specialization),
            pin: pin,
          ),
        );
  }

  Future<void> updateAccount({
    String? name,
    String? specialization,
    String? pin,
  }) async {
    final doctor = await getDoctor();
    if (doctor == null) return;

    await (_db.update(_db.doctors)..where((t) => t.id.equals(doctor.id))).write(
      DoctorsCompanion(
        fullName: name != null ? Value(name) : const Value.absent(),
        specialization: specialization != null
            ? Value(specialization)
            : const Value.absent(),
        pin: pin != null ? Value(pin) : const Value.absent(),
      ),
    );
  }

  Stream<Doctor?> watchDoctor() {
    return _db.select(_db.doctors).watchSingleOrNull();
  }
}

final doctorProvider = StreamProvider<Doctor?>((ref) {
  return ref.watch(authRepositoryProvider).watchDoctor();
});

final authStateProvider = FutureProvider<bool>((ref) async {
  final doctor = await ref.watch(authRepositoryProvider).getDoctor();
  return doctor != null;
});
