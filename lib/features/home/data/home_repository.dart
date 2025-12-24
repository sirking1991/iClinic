import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../../../core/database/database.dart';
import '../../../core/providers.dart';

final homeRepositoryProvider = Provider(
  (ref) => HomeRepository(ref.watch(databaseProvider)),
);

class HomeStats {
  final int appointmentsToday;
  final int totalPatients;
  HomeStats(this.appointmentsToday, this.totalPatients);
}

class HomeRepository {
  final AppDatabase _db;
  HomeRepository(this._db);

  Future<HomeStats> getStats() async {
    final patients = await _db.select(_db.patients).get();

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final appointments = await (_db.select(
      _db.appointments,
    )..where((t) => t.scheduledAt.isBetweenValues(start, end))).get();

    return HomeStats(appointments.length, patients.length);
  }
}
