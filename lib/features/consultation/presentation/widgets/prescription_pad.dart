import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../consultation_controller.dart';
import '../../../../core/theme/app_colors.dart';

class PrescriptionPad extends ConsumerStatefulWidget {
  final int consultationId;
  final int? eventId;
  final int? prescriptionId;
  final Map<String, dynamic>? initialData;

  const PrescriptionPad({
    required this.consultationId,
    this.eventId,
    this.prescriptionId,
    this.initialData,
    super.key,
  });

  @override
  ConsumerState<PrescriptionPad> createState() => _PrescriptionPadState();
}

class _PrescriptionPadState extends ConsumerState<PrescriptionPad> {
  final _drugController = TextEditingController();
  final _dosageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _drugController.text = widget.initialData!['drugName'] ?? '';
      _dosageController.text = widget.initialData!['dosage'] ?? '';
    }
  }

  Color _getPillColor(String text) {
    final t = text.toLowerCase();
    if (t.contains('antibiotic') || t.contains('ill') || t.contains('ox')) {
      return Colors.red.shade100;
    }
    if (t.contains('pain') || t.contains('profen') || t.contains('mg')) {
      return Colors.blue.shade100;
    }
    return AppColors.sage100;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.eventId != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? "Update Prescription" : "Prescribe Medication",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Visual Med Preview
          Center(
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.sage200,
                  style: BorderStyle.none,
                ), // Dashed borders need custom painter in Flutter, skipping for simplicity
                color: AppColors.sand50,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getPillColor(_drugController.text),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.black12),
                ),
                child: Text(
                  _drugController.text.isEmpty
                      ? "Pill Preview"
                      : _drugController.text,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _drugController,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: "Drug Name",
              filled: true,
              fillColor: AppColors.sage50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dosageController,
            decoration: const InputDecoration(
              labelText: "Dosage & Sig",
              filled: true,
              fillColor: AppColors.sage50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                if (_drugController.text.isEmpty) return;

                if (isEditing) {
                  await ref
                      .read(consultationControllerProvider)
                      .updatePrescription(
                        widget.eventId!,
                        prescriptionId: widget.prescriptionId,
                        drugName: _drugController.text,
                        dosage: _dosageController.text,
                      );
                } else {
                  await ref
                      .read(consultationControllerProvider)
                      .addPrescription(
                        widget.consultationId,
                        drugName: _drugController.text,
                        dosage: _dosageController.text,
                      );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.midnight900,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isEditing ? "Update & Save" : "Sign & Prescribe"),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
