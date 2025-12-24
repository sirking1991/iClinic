import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iclinic/core/theme/app_colors.dart';
import 'package:iclinic/features/consultation/presentation/consultation_stream.dart';
import 'package:iclinic/features/consultation/presentation/consultation_form.dart';
import '../data/patient_repository.dart';
import '../../../core/database/database.dart';

final patientProvider = FutureProvider.family<Patient, int>((ref, id) async {
  return ref.watch(patientRepositoryProvider).getPatientById(id);
});

class PatientDetailScreen extends ConsumerStatefulWidget {
  final String patientId;
  const PatientDetailScreen({required this.patientId, super.key});

  @override
  ConsumerState<PatientDetailScreen> createState() =>
      _PatientDetailScreenState();
}

class _PatientDetailScreenState extends ConsumerState<PatientDetailScreen> {
  int _selectedView = 0; // 0 = Stream, 1 = Form

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(widget.patientId) ?? 0;
    final patientAsync = ref.watch(patientProvider(id));

    return Scaffold(
      body: patientAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (patient) => NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.sand50,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: AppColors.sage100.withValues(alpha: 0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SafeArea(child: SizedBox(height: 20)),
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.sage300,
                          child: Text(
                            patient.fullName[0],
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          patient.fullName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          "${patient.gender} • ${patient.phoneNumber ?? 'No phone'}",
                          style: const TextStyle(color: AppColors.sage600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(
                        value: 0,
                        label: Text("Stream"),
                        icon: Icon(Icons.chat_bubble_outline),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text("Form"),
                        icon: Icon(Icons.description_outlined),
                      ),
                    ],
                    selected: {_selectedView},
                    onSelectionChanged: (Set<int> newSelection) {
                      setState(() {
                        _selectedView = newSelection.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith<Color>((
                        states,
                      ) {
                        return states.contains(WidgetState.selected)
                            ? AppColors.sage200
                            : Colors.transparent;
                      }),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: _selectedView == 0
              ? ConsultationStream(patientId: id)
              : ConsultationForm(patientId: id),
        ),
      ),
    );
  }
}
