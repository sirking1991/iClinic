import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers.dart';

final consultationRepositoryProvider = Provider<ConsultationRepository>((ref) {
  return ConsultationRepository(ref.watch(databaseProvider));
});

class ConsultationRepository {
  final AppDatabase _db;

  ConsultationRepository(this._db);

  /// Gets the active consultation for a patient (created within last 24h) or creates a new one.
  Future<Consultation> getOrCreateActiveConsultation(int patientId) async {
    final now = DateTime.now();

    final query = _db.select(_db.consultations)
      ..where((tbl) => tbl.patientId.equals(patientId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
      ])
      ..limit(1);

    final latest = await query.getSingleOrNull();

    if (latest != null) {
      final diff = now.difference(latest.date);
      if (diff.inHours < 24) {
        return latest;
      }
    }

    final id = await _db
        .into(_db.consultations)
        .insert(
          ConsultationsCompanion(patientId: Value(patientId), date: Value(now)),
        );

    return (await (_db.select(
      _db.consultations,
    )..where((t) => t.id.equals(id))).getSingle());
  }

  Stream<List<StreamEvent>> watchStreamEvents(int consultationId) {
    return (_db.select(_db.streamEvents)
          ..where((t) => t.consultationId.equals(consultationId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  Future<void> addNote(int consultationId, String text) async {
    final content = jsonEncode({'text': text});
    await _db
        .into(_db.streamEvents)
        .insert(
          StreamEventsCompanion(
            consultationId: Value(consultationId),
            type: const Value('note'),
            contentJson: Value(content),
            authorName: const Value('Dr. Sherwin'),
            timestamp: Value(DateTime.now()),
          ),
        );
  }

  Future<void> addVitals(
    int consultationId,
    Map<String, dynamic> vitalsData,
  ) async {
    await _db
        .into(_db.streamEvents)
        .insert(
          StreamEventsCompanion(
            consultationId: Value(consultationId),
            type: const Value('vitals'),
            contentJson: Value(jsonEncode(vitalsData)),
            authorName: const Value('Dr. Sherwin'),
            timestamp: Value(DateTime.now()),
          ),
        );
  }

  Future<void> addImage(int consultationId, String imagePath) async {
    final content = jsonEncode({'path': imagePath});
    await _db
        .into(_db.streamEvents)
        .insert(
          StreamEventsCompanion(
            consultationId: Value(consultationId),
            type: const Value('image'),
            contentJson: Value(content),
            authorName: const Value('Dr. Sherwin'),
            timestamp: Value(DateTime.now()),
          ),
        );
  }

  Future<void> addPrescription(
    int consultationId, {
    required String drugName,
    required String dosage,
    String? frequency,
    String? duration,
  }) async {
    // 1. Add to the Prescriptions table
    await _db
        .into(_db.prescriptions)
        .insert(
          PrescriptionsCompanion.insert(
            consultationId: consultationId,
            drugName: drugName,
            dosage: dosage,
            frequency: frequency != null
                ? Value<String>(frequency)
                : const Value.absent(),
            duration: duration != null
                ? Value<String>(duration)
                : const Value.absent(),
          ),
        );

    // 2. Add as an event to the stream for the timeline
    final timelineContent = jsonEncode({
      'drugName': drugName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    });

    await _db
        .into(_db.streamEvents)
        .insert(
          StreamEventsCompanion.insert(
            consultationId: consultationId,
            type: 'prescription',
            contentJson: timelineContent,
            authorName: 'Dr. Sherwin',
          ),
        );
  }

  Future<void> updateConsultationNotes(
    int id, {
    String? s,
    String? o,
    String? a,
    String? p,
  }) async {
    await (_db.update(_db.consultations)..where((t) => t.id.equals(id))).write(
      ConsultationsCompanion(
        subjectiveNotes: s != null ? Value(s) : const Value.absent(),
        objectiveNotes: o != null ? Value(o) : const Value.absent(),
        assessment: a != null ? Value(a) : const Value.absent(),
        plan: p != null ? Value(p) : const Value.absent(),
      ),
    );
  }
}
