import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../patient/data/patient_repository.dart';
import '../../data/schedule_repository.dart';
import '../../../../core/database/database.dart';

class AppointmentFormSheet extends ConsumerStatefulWidget {
  final AppointmentWithPatient? appointmentWithPatient;
  const AppointmentFormSheet({this.appointmentWithPatient, super.key});

  @override
  ConsumerState<AppointmentFormSheet> createState() =>
      _AppointmentFormSheetState();
}

class _AppointmentFormSheetState extends ConsumerState<AppointmentFormSheet> {
  Patient? _selectedPatient;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.appointmentWithPatient != null) {
      final appt = widget.appointmentWithPatient!.appointment;
      _selectedPatient = widget.appointmentWithPatient!.patient;
      _selectedDate = appt.scheduledAt;
      _selectedTime = TimeOfDay.fromDateTime(appt.scheduledAt);
      _reasonController.text = appt.reason ?? '';
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _onDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Appointment"),
        content: const Text(
          "Are you sure you want to delete this appointment?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(scheduleRepositoryProvider)
          .deleteAppointment(widget.appointmentWithPatient!.appointment.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointmentWithPatient != null;
    final patientsAsync = ref.watch(patientsStreamProvider);

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing ? "Edit Appointment" : "New Appointment",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  if (isEditing)
                    IconButton(
                      onPressed: _onDelete,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: "Delete Appointment",
                    ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Patient Selection (Disabled in editing for simplicity, change if needed)
          const Text(
            "Patient",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.sage600,
            ),
          ),
          const SizedBox(height: 8),
          if (isEditing)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.sage50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_selectedPatient?.fullName ?? "Unknown Patient"),
            )
          else
            patientsAsync.when(
              data: (patients) => DropdownButtonFormField<Patient>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.sage50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                hint: const Text("Select a patient"),
                value: _selectedPatient,
                items: patients
                    .map(
                      (p) =>
                          DropdownMenuItem(value: p, child: Text(p.fullName)),
                    )
                    .toList(),
                onChanged: (p) => setState(() => _selectedPatient = p),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text("Error loading patients: $err"),
            ),

          const SizedBox(height: 16),

          // Date & Time
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Date",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.sage600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sage50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(_selectedDate),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppColors.sage400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Time",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.sage600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sage50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedTime.format(context)),
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.sage400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Reason
          const Text(
            "Reason for visit",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.sage600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.sage50,
              hintText: "e.g. Annual Checkup",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedPatient == null
                  ? null
                  : () async {
                      final scheduledAt = DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                        _selectedTime.hour,
                        _selectedTime.minute,
                      );

                      if (isEditing) {
                        await ref
                            .read(scheduleRepositoryProvider)
                            .updateAppointment(
                              widget.appointmentWithPatient!.appointment.id,
                              scheduledAt: scheduledAt,
                              reason: _reasonController.text,
                            );
                      } else {
                        await ref
                            .read(scheduleRepositoryProvider)
                            .createAppointment(
                              _selectedPatient!.id,
                              scheduledAt,
                              _reasonController.text,
                            );
                      }

                      if (mounted) Navigator.pop(context);
                    },
              style: FilledButton.styleFrom(
                backgroundColor: isEditing
                    ? AppColors.midnight900
                    : AppColors.sage500,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? "Update Appointment" : "Create Appointment",
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
