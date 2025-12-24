import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers.dart';

final scheduleRepositoryProvider = Provider((ref) {
  return ScheduleRepository(ref.watch(databaseProvider));
});

class ScheduleRepository {
  final AppDatabase _db;
  ScheduleRepository(this._db);

  Stream<List<AppointmentWithPatient>> watchUpcomingAppointments() {
    final query =
        _db.select(_db.appointments).join([
            innerJoin(
              _db.patients,
              _db.patients.id.equalsExp(_db.appointments.patientId),
            ),
          ])
          ..where(
            _db.appointments.scheduledAt.isBiggerOrEqualValue(DateTime.now()),
          )
          ..orderBy([OrderingTerm(expression: _db.appointments.scheduledAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return AppointmentWithPatient(
          appointment: row.readTable(_db.appointments),
          patient: row.readTable(_db.patients),
        );
      }).toList();
    });
  }

  Future<void> createAppointment(
    int patientId,
    DateTime scheduledAt,
    String reason,
  ) async {
    await _db
        .into(_db.appointments)
        .insert(
          AppointmentsCompanion(
            patientId: Value(patientId),
            scheduledAt: Value(scheduledAt),
            reason: Value(reason),
          ),
        );
  }

  Future<void> updateAppointment(
    int id, {
    DateTime? scheduledAt,
    String? reason,
  }) async {
    await (_db.update(_db.appointments)..where((t) => t.id.equals(id))).write(
      AppointmentsCompanion(
        scheduledAt: scheduledAt != null
            ? Value(scheduledAt)
            : const Value.absent(),
        reason: reason != null ? Value(reason) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteAppointment(int id) async {
    await (_db.delete(_db.appointments)..where((t) => t.id.equals(id))).go();
  }
}

class AppointmentWithPatient {
  final Appointment appointment;
  final Patient patient;
  AppointmentWithPatient({required this.appointment, required this.patient});
}
