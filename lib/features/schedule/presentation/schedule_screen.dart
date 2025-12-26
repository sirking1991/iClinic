import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../data/schedule_repository.dart';
import 'widgets/appointment_form_sheet.dart';

final scheduleStreamProvider = StreamProvider((ref) {
  return ref.watch(scheduleRepositoryProvider).watchUpcomingAppointments();
});

class ScheduleScreen extends ConsumerStatefulWidget {
  final bool showAddDialog;
  const ScheduleScreen({super.key, this.showAddDialog = false});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.showAddDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNewAppointmentSheet();
        // Clear the query param so it doesn't pop up again on refresh/back
        if (mounted) context.go('/schedule');
      });
    }
  }

  void _showNewAppointmentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppointmentFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleAsync = ref.watch(scheduleStreamProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Schedule"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: AppColors.midnight900,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text("Error: $err")),
        data: (appointments) {
          if (appointments.isEmpty) {
            return const Center(
              child: Text(
                "No upcoming appointments",
                style: TextStyle(color: AppColors.sage400),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final item = appointments[index];
              final dateStr = DateFormat(
                'EEE, MMM d',
              ).format(item.appointment.scheduledAt);
              final timeStr = DateFormat(
                'h:mm a',
              ).format(item.appointment.scheduledAt);

              // Simple header logic: check if prev item was same day
              bool showHeader = true;
              if (index > 0) {
                final prev = appointments[index - 1];
                final prevDay = DateFormat(
                  'yyyyMMdd',
                ).format(prev.appointment.scheduledAt);
                final currDay = DateFormat(
                  'yyyyMMdd',
                ).format(item.appointment.scheduledAt);
                if (prevDay == currDay) showHeader = false;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader) ...[
                    if (index > 0) const SizedBox(height: 24),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.sage600,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  InkWell(
                    onTap: () {
                      context.push('/patient/${item.patient.id}');
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>
                            AppointmentFormSheet(appointmentWithPatient: item),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.sage100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                timeStr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "30 min",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.sage400,
                                ),
                              ), // Hardcode duration for now
                            ],
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 1,
                            height: 40,
                            color: AppColors.sage100,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.patient.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.appointment.reason ?? "Consultation",
                                  style: const TextStyle(
                                    color: AppColors.sage500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right,
                            color: AppColors.sage300,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewAppointmentSheet,
        label: const Text("New Appointment"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.sage500,
      ),
    );
  }
}
