import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../consultation_controller.dart';

class VitalsInputSheet extends ConsumerStatefulWidget {
  final int consultationId;
  final int? eventId;
  final Map<String, dynamic>? initialData;

  const VitalsInputSheet({
    required this.consultationId,
    this.eventId,
    this.initialData,
    super.key,
  });

  @override
  ConsumerState<VitalsInputSheet> createState() => _VitalsInputSheetState();
}

class _VitalsInputSheetState extends ConsumerState<VitalsInputSheet> {
  final _bpController = TextEditingController();
  final _hrController = TextEditingController();
  final _tempController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      final sys = data['bp_sys'] ?? '';
      final dia = data['bp_dia'] ?? '';
      if (sys.isNotEmpty || dia.isNotEmpty) {
        _bpController.text = "$sys/$dia";
      }
      _hrController.text = data['heart_rate']?.toString() ?? '';
      _tempController.text = data['temp']?.toString() ?? '';
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
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for bottom sheet
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? "Update Vitals" : "Record Vitals",
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _bpController,
                  decoration: const InputDecoration(
                    labelText: "BP (e.g. 120/80)",
                    filled: true,
                    fillColor: AppColors.sage50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType
                      .datetime, // datetime sometimes allows / on keyboards
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _hrController,
                  decoration: const InputDecoration(
                    labelText: "HR (bpm)",
                    filled: true,
                    fillColor: AppColors.sage50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _tempController,
                  decoration: const InputDecoration(
                    labelText: "Temp (°C)",
                    filled: true,
                    fillColor: AppColors.sage50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                String sys = '';
                String dia = '';
                if (_bpController.text.contains('/')) {
                  final parts = _bpController.text.split('/');
                  sys = parts[0];
                  if (parts.length > 1) dia = parts[1];
                } else {
                  sys = _bpController.text;
                }

                final vitals = {
                  'bp_sys': sys,
                  'bp_dia': dia,
                  'heart_rate': _hrController.text,
                  'temp': _tempController.text,
                };

                if (isEditing) {
                  await ref
                      .read(consultationControllerProvider)
                      .updateVitals(widget.eventId!, vitals);
                } else {
                  await ref
                      .read(consultationControllerProvider)
                      .addVitals(widget.consultationId, vitals);
                }

                if (!context.mounted) return;
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.sage500,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isEditing ? "Update Vitals" : "Save Vitals"),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
