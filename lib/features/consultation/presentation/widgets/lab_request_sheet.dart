import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../consultation_controller.dart';

const commonLabs = [
  'CBC (Complete Blood Count)',
  'Urinalysis',
  'Lipid Profile',
  'FBS (Fasting Blood Sugar)',
  'Creatinine',
  'SGPT/SGOT',
  'Chest X-Ray',
  'ECG',
];

class LabRequestSheet extends ConsumerStatefulWidget {
  final int consultationId;
  final int? eventId;
  final Map<String, dynamic>? initialData;

  const LabRequestSheet({
    required this.consultationId,
    this.eventId,
    this.initialData,
    super.key,
  });

  @override
  ConsumerState<LabRequestSheet> createState() => _LabRequestSheetState();
}

class _LabRequestSheetState extends ConsumerState<LabRequestSheet> {
  final Set<String> _selectedLabs = {};
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final tests = widget.initialData!['tests'] as List?;
      if (tests != null) {
        _selectedLabs.addAll(tests.cast<String>());
      }
      _noteController.text = widget.initialData!['notes'] ?? '';
    }
  }

  Future<void> _handleSave() async {
    if (_selectedLabs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one test")),
      );
      return;
    }

    if (widget.eventId != null) {
      await ref
          .read(consultationControllerProvider)
          .updateLabRequest(
            widget.eventId!,
            tests: _selectedLabs.toList(),
            notes: _noteController.text,
          );
    } else {
      await ref
          .read(consultationControllerProvider)
          .addLabRequest(
            widget.consultationId,
            tests: _selectedLabs.toList(),
            notes: _noteController.text,
          );
    }

    if (mounted) {
      Navigator.pop(context);
    }
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
      height: MediaQuery.of(context).size.height * 0.8, // Taller sheet
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? "Update Lab Request" : "Lab Request",
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
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Common Tests",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.sage500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: commonLabs.map((lab) {
                      final isSelected = _selectedLabs.contains(lab);
                      return FilterChip(
                        label: Text(lab),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedLabs.add(lab);
                            } else {
                              _selectedLabs.remove(lab);
                            }
                          });
                        },
                        selectedColor: AppColors.sage500,
                        backgroundColor: AppColors.sand50,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.midnight900,
                        ),
                        checkmarkColor: Colors.white,
                        side: BorderSide(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.sage200,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Clinical Notes / Diagnosis",
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.sage500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: AppColors.sage50,
                      hintText: "Reason for request...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _handleSave,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.midnight900,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isEditing ? "Update Request" : "Generate Request"),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
