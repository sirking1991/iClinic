import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

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

class LabRequestSheet extends StatefulWidget {
  const LabRequestSheet({super.key});

  @override
  State<LabRequestSheet> createState() => _LabRequestSheetState();
}

class _LabRequestSheetState extends State<LabRequestSheet> {
  final Set<String> _selectedLabs = {};
  final _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                "Lab Request",
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
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.midnight900,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Generate Request"),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
