import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../data/consultation_repository.dart';

// 1. Provider to get the active consultation ID for a patient
final activeConsultationProvider = FutureProvider.family<Consultation, int>((
  ref,
  patientId,
) async {
  final repo = ref.watch(consultationRepositoryProvider);
  return repo.getOrCreateActiveConsultation(patientId);
});

// 2. Provider to watch the stream events for a specific consultation ID
final consultationStreamProvider =
    StreamProvider.family<List<StreamEvent>, int>((ref, consultationId) {
      final repo = ref.watch(consultationRepositoryProvider);
      return repo.watchStreamEvents(consultationId);
    });

// 3. Controller for actions (Add Note, etc)
class ConsultationController {
  final ConsultationRepository _repo;

  ConsultationController(this._repo);

  Future<void> addNote(int consultationId, String text) async {
    if (text.trim().isEmpty) return;
    await _repo.addNote(consultationId, text);
  }

  Future<void> addVitals(int consultationId, Map<String, dynamic> data) async {
    await _repo.addVitals(consultationId, data);
  }

  Future<void> addImage(int consultationId, String path) async {
    await _repo.addImage(consultationId, path);
  }

  Future<void> addPrescription(
    int consultationId, {
    required String drugName,
    required String dosage,
    String? frequency,
    String? duration,
  }) async {
    await _repo.addPrescription(
      consultationId,
      drugName: drugName,
      dosage: dosage,
      frequency: frequency,
      duration: duration,
    );
  }

  Future<void> addLabRequest(
    int consultationId, {
    required List<String> tests,
    String? notes,
  }) async {
    await _repo.addLabRequest(consultationId, tests: tests, notes: notes);
  }

  Future<void> updateNote(int eventId, String text) async {
    if (text.trim().isEmpty) return;
    await _repo.updateNote(eventId, text);
  }

  Future<void> updateVitals(int eventId, Map<String, dynamic> data) async {
    await _repo.updateVitals(eventId, data);
  }

  Future<void> updateLabRequest(
    int eventId, {
    required List<String> tests,
    String? notes,
  }) async {
    await _repo.updateLabRequest(eventId, tests: tests, notes: notes);
  }

  Future<void> updatePrescription(
    int eventId, {
    int? prescriptionId,
    required String drugName,
    required String dosage,
    String? frequency,
    String? duration,
  }) async {
    await _repo.updatePrescription(
      eventId,
      prescriptionId: prescriptionId,
      drugName: drugName,
      dosage: dosage,
      frequency: frequency,
      duration: duration,
    );
  }

  Future<void> updateConsultationNotes(
    int id, {
    String? s,
    String? o,
    String? a,
    String? p,
  }) async {
    await _repo.updateConsultationNotes(id, s: s, o: o, a: a, p: p);
  }

  Future<void> deleteStreamEvent(int eventId) async {
    await _repo.deleteStreamEvent(eventId);
  }
}

final consultationControllerProvider = Provider((ref) {
  return ConsultationController(ref.watch(consultationRepositoryProvider));
});
