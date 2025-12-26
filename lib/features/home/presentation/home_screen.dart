import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/home_repository.dart';
import '../../auth/data/auth_repository.dart';
import '../../schedule/presentation/schedule_screen.dart';
import 'package:intl/intl.dart';

final homeStatsProvider = FutureProvider<HomeStats>((ref) async {
  return ref.watch(homeRepositoryProvider).getStats();
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(homeStatsProvider);
    final upcomingAsync = ref.watch(scheduleStreamProvider);
    final doctorAsync = ref.watch(doctorProvider);

    return Scaffold(
      backgroundColor: AppColors.sand50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: doctorAsync.when(
                data: (doctor) => Text(
                  "Good Morning, Dr. ${doctor?.fullName.split(' ').last ?? 'Doctor'}",
                  style: const TextStyle(
                    color: AppColors.midnight900,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                loading: () => const Text("Good Morning..."),
                error: (_, _) => const Text("Good Morning"),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: AppColors.sage600,
                ),
                onPressed: () => context.go('/profile'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: statsAsync.when(
                data: (stats) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(context, stats),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Quick Actions"),
                    const SizedBox(height: 16),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Upcoming Appointments"),
                    const SizedBox(height: 16),
                    _buildUpcomingCard(context, upcomingAsync),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text("Error: $err")),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.midnight900,
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, HomeStats stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          "Today's Apps",
          stats.appointmentsToday.toString(),
          Icons.calendar_today,
          AppColors.sage500,
        ),
        _buildStatCard(
          "Total Patients",
          stats.totalPatients.toString(),
          Icons.people,
          Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.midnight900,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.sage400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildActionButton(
          context,
          "New Patient",
          Icons.person_add_outlined,
          () => context.go('/patients?action=new'),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          context,
          "New Appointment",
          Icons.event_outlined,
          () => context.go('/schedule?action=new'),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.sage500,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, AsyncValue upcomingAsync) {
    return upcomingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Error: $err")),
      data: (appointments) {
        if (appointments.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.sage100),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 40,
                  color: AppColors.sage200,
                ),
                SizedBox(height: 12),
                Text(
                  "No upcoming appointments",
                  style: TextStyle(color: AppColors.sage400),
                ),
              ],
            ),
          );
        }

        // Only show first 3
        final display = appointments.take(3).toList();

        return Column(
          children: [
            ...display.map((item) {
              final timeStr = DateFormat(
                'h:mm a',
              ).format(item.appointment.scheduledAt);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sage100),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sage50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        timeStr,
                        style: const TextStyle(
                          color: AppColors.sage600,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.patient.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.midnight900,
                            ),
                          ),
                          Text(
                            item.appointment.reason ?? "Consultation",
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.sage400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.sage200),
                  ],
                ),
              );
            }),
            if (appointments.length > 3)
              TextButton(
                onPressed: () => context.go('/schedule'),
                child: Text("View all ${appointments.length} appointments"),
              ),
          ],
        );
      },
    );
  }
}
