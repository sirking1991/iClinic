import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'consultation_controller.dart';

class ConsultationForm extends ConsumerStatefulWidget {
  final int patientId;
  const ConsultationForm({required this.patientId, super.key});

  @override
  ConsumerState<ConsultationForm> createState() => _ConsultationFormState();
}

class _ConsultationFormState extends ConsumerState<ConsultationForm> {
  final _sController = TextEditingController();
  final _oController = TextEditingController();
  final _aController = TextEditingController();
  final _pController = TextEditingController();

  Future<void> _save(int consultationId) async {
    await ref
        .read(consultationControllerProvider)
        .updateConsultationNotes(
          consultationId,
          s: _sController.text,
          o: _oController.text,
          a: _aController.text,
          p: _pController.text,
        );

    _sController.clear();
    _oController.clear();
    _aController.clear();
    _pController.clear();

    // Invalidate the provider to fetch the updated (cleared) data from the database
    ref.invalidate(activeConsultationProvider(widget.patientId));

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("SOAP Notes Saved")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(activeConsultationProvider(widget.patientId));

    return activeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
      data: (consultation) {
        // Init controllers only once if database has data
        if (_sController.text.isEmpty) {
          _sController.text = consultation.subjectiveNotes ?? '';
          _oController.text = consultation.objectiveNotes ?? '';
          _aController.text = consultation.assessment ?? '';
          _pController.text = consultation.plan ?? '';
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildField("Subjective", _sController),
            const SizedBox(height: 16),
            _buildField("Objective", _oController),
            const SizedBox(height: 16),
            _buildField("Assessment", _aController),
            const SizedBox(height: 16),
            _buildField("Plan", _pController),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _save(consultation.id),
              icon: const Icon(Icons.save),
              label: const Text("Save SOAP Notes"),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sage500,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 50),
          ],
        );
      },
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.sage600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.sage100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.sage100),
            ),
          ),
        ),
      ],
    );
  }
}
