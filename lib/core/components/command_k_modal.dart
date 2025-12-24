import 'package:flutter/material.dart';
import 'package:drift/drift.dart'
    hide Column; // Hide Column to avoid conflict with Flutter's Column
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../providers.dart';
import '../database/database.dart';

class CommandKModal extends ConsumerStatefulWidget {
  const CommandKModal({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Command K",
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return const CommandKModal();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  @override
  ConsumerState<CommandKModal> createState() => _CommandKModalState();
}

class _CommandKModalState extends ConsumerState<CommandKModal> {
  final _controller = TextEditingController();
  List<Patient> _results = [];

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }
    final db = ref.read(databaseProvider);
    final results = await (db.select(
      db.patients,
    )..where((t) => t.fullName.contains(query))).get();
    setState(() => _results = results);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
          child: GestureDetector(
            onTap: () {}, // Prevent dismissal when clicking the box
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              elevation: 20,
              child: Container(
                width: 600,
                constraints: const BoxConstraints(maxHeight: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: AppColors.sage400),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              autofocus: true,
                              decoration: const InputDecoration(
                                hintText:
                                    "Search patients, schedule, actions...",
                                border: InputBorder.none,
                                hintStyle: TextStyle(color: AppColors.sage300),
                              ),
                              onChanged: _onSearch,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.sage50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.sage100),
                            ),
                            child: const Text(
                              "ESC",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.sage500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    if (_results.isNotEmpty)
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final patient = _results[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.sage100,
                                child: Text(
                                  patient.fullName[0],
                                  style: const TextStyle(
                                    color: AppColors.sage500,
                                  ),
                                ),
                              ),
                              title: Text(patient.fullName),
                              subtitle: Text(patient.phoneNumber ?? "No phone"),
                              onTap: () {
                                context.push('/patient/${patient.id}');
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      )
                    else if (_controller.text.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          "No results found.",
                          style: TextStyle(color: AppColors.sage400),
                        ),
                      )
                    else ...[
                      _buildQuickAction(
                        "Add New Patient",
                        Icons.person_add_outlined,
                        () {
                          Navigator.pop(context);
                          context.go('/patients');
                        },
                      ),
                      _buildQuickAction(
                        "Go to Schedule",
                        Icons.calendar_today_outlined,
                        () {
                          Navigator.pop(context);
                          context.go('/schedule');
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.sage500, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(
        Icons.keyboard_arrow_right,
        size: 16,
        color: AppColors.sage300,
      ),
      onTap: onTap,
    );
  }
}
