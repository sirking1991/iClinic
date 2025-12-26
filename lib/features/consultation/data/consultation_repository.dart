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
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc),
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
    final prescriptionId = await _db
        .into(_db.prescriptions)
        .insert(
          PrescriptionsCompanion.insert(
            consultationId: consultationId,
            drugName: drugName,
            dosage: dosage,
            frequency: frequency ?? '',
            duration: duration ?? '',
          ),
        );

    // 2. Add as an event to the stream for the timeline
    final timelineContent = jsonEncode({
      'prescriptionId': prescriptionId,
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

  Future<void> addLabRequest(
    int consultationId, {
    required List<String> tests,
    String? notes,
  }) async {
    final content = jsonEncode({'tests': tests, 'notes': notes});
    await _db
        .into(_db.streamEvents)
        .insert(
          StreamEventsCompanion.insert(
            consultationId: consultationId,
            type: 'lab',
            contentJson: content,
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
    // 1. Update the consultations table
    await (_db.update(_db.consultations)..where((t) => t.id.equals(id))).write(
      ConsultationsCompanion(
        subjectiveNotes: s != null ? Value(s) : const Value.absent(),
        objectiveNotes: o != null ? Value(o) : const Value.absent(),
        assessment: a != null ? Value(a) : const Value.absent(),
        plan: p != null ? Value(p) : const Value.absent(),
      ),
    );

    // 2. Sync with stream_events
    // Fetch the latest consultation state to ensure we have all fields for the JSON snapshot
    final consultation = await (_db.select(
      _db.consultations,
    )..where((t) => t.id.equals(id))).getSingle();

    final content = jsonEncode({
      's': consultation.subjectiveNotes,
      'o': consultation.objectiveNotes,
      'a': consultation.assessment,
      'p': consultation.plan,
    });

    final existing =
        await (_db.select(_db.streamEvents)
              ..where(
                (t) => t.consultationId.equals(id) & t.type.equals('soap'),
              )
              ..limit(1))
            .getSingleOrNull();

    if (existing != null) {
      await (_db.update(
        _db.streamEvents,
      )..where((t) => t.id.equals(existing.id))).write(
        StreamEventsCompanion(
          contentJson: Value(content),
          timestamp: Value(DateTime.now()), // Push to top of stream
        ),
      );
    } else {
      await _db
          .into(_db.streamEvents)
          .insert(
            StreamEventsCompanion.insert(
              consultationId: id,
              type: 'soap',
              contentJson: content,
              authorName: 'Dr. Sherwin',
              timestamp: Value(DateTime.now()),
            ),
          );
    }

    // 3. Clear the draft in the consultations table so the form is empty next time
    await (_db.update(_db.consultations)..where((t) => t.id.equals(id))).write(
      const ConsultationsCompanion(
        subjectiveNotes: Value(null),
        objectiveNotes: Value(null),
        assessment: Value(null),
        plan: Value(null),
      ),
    );
  }

  Future<void> updateNote(int eventId, String text) async {
    final content = jsonEncode({'text': text});
    await (_db.update(_db.streamEvents)..where((t) => t.id.equals(eventId)))
        .write(StreamEventsCompanion(contentJson: Value(content)));
  }

  Future<void> updateVitals(
    int eventId,
    Map<String, dynamic> vitalsData,
  ) async {
    await (_db.update(
      _db.streamEvents,
    )..where((t) => t.id.equals(eventId))).write(
      StreamEventsCompanion(contentJson: Value(jsonEncode(vitalsData))),
    );
  }

  Future<void> updateLabRequest(
    int eventId, {
    required List<String> tests,
    String? notes,
  }) async {
    final content = jsonEncode({'tests': tests, 'notes': notes});
    await (_db.update(_db.streamEvents)..where((t) => t.id.equals(eventId)))
        .write(StreamEventsCompanion(contentJson: Value(content)));
  }

  Future<void> updatePrescription(
    int eventId, {
    int? prescriptionId,
    required String drugName,
    required String dosage,
    String? frequency,
    String? duration,
  }) async {
    // 1. Update the Prescriptions table if we have an ID
    if (prescriptionId != null) {
      await (_db.update(
        _db.prescriptions,
      )..where((t) => t.id.equals(prescriptionId))).write(
        PrescriptionsCompanion(
          drugName: Value(drugName),
          dosage: Value(dosage),
          frequency: Value(frequency ?? ''),
          duration: Value(duration ?? ''),
        ),
      );
    }

    // 2. Update the StreamEvent
    final content = jsonEncode({
      if (prescriptionId != null) 'prescriptionId': prescriptionId,
      'drugName': drugName,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    });

    await (_db.update(_db.streamEvents)..where((t) => t.id.equals(eventId)))
        .write(StreamEventsCompanion(contentJson: Value(content)));
  }

  Future<void> deleteStreamEvent(int eventId) async {
    final event = await (_db.select(
      _db.streamEvents,
    )..where((t) => t.id.equals(eventId))).getSingleOrNull();

    if (event == null) return;

    // 1. Handle linked data
    if (event.type == 'prescription') {
      try {
        final content = jsonDecode(event.contentJson) as Map<String, dynamic>;
        final prescriptionId = content['prescriptionId'] as int?;
        if (prescriptionId != null) {
          await (_db.delete(
            _db.prescriptions,
          )..where((t) => t.id.equals(prescriptionId))).go();
        }
      } catch (e) {
        // Handle potential json decode errors
      }
    } else if (event.type == 'soap') {
      // Clear SOAP data in consultation if deleted
      await (_db.update(
        _db.consultations,
      )..where((t) => t.id.equals(event.consultationId))).write(
        const ConsultationsCompanion(
          subjectiveNotes: Value(null),
          objectiveNotes: Value(null),
          assessment: Value(null),
          plan: Value(null),
        ),
      );
    }

    // 2. Delete the event itself
    await (_db.delete(
      _db.streamEvents,
    )..where((t) => t.id.equals(eventId))).go();
  }
}
