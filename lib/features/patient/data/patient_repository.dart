import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers.dart';

final patientRepositoryProvider = Provider(
  (ref) => PatientRepository(ref.watch(databaseProvider)),
);

final patientsStreamProvider = StreamProvider<List<Patient>>((ref) {
  return ref.watch(patientRepositoryProvider).watchPatients();
});

class PatientRepository {
  final AppDatabase _db;
  PatientRepository(this._db);

  Stream<List<Patient>> watchPatients() {
    return (_db.select(
      _db.patients,
    )..orderBy([(t) => OrderingTerm(expression: t.fullName)])).watch();
  }

  Future<int> addPatient(PatientsCompanion patient) {
    return _db.into(_db.patients).insert(patient);
  }

  Future<Patient> getPatientById(int id) {
    return (_db.select(
      _db.patients,
    )..where((t) => t.id.equals(id))).getSingle();
  }
}
