import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  final _specController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _isInitialized = false;

  void _onSave() async {
    if (_nameController.text.isEmpty || _pinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill name and 4-digit PIN")),
      );
      return;
    }

    setState(() => _isLoading = true);
    await ref
        .read(authRepositoryProvider)
        .updateAccount(
          name: _nameController.text,
          specialization: _specController.text,
          pin: _pinController.text,
        );

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(doctorProvider);

    return Scaffold(
      backgroundColor: AppColors.sand50,
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: AppColors.midnight900,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: doctorAsync.when(
        data: (doctor) {
          if (doctor == null)
            return const Center(child: Text("No account found"));

          if (!_isInitialized) {
            _nameController.text = doctor.fullName;
            _specController.text = doctor.specialization ?? '';
            _pinController.text = doctor.pin;
            _isInitialized = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.sage100,
                        child: Text(
                          doctor.fullName.isNotEmpty
                              ? doctor.fullName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.sage600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        doctor.fullName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.midnight900,
                        ),
                      ),
                      Text(
                        doctor.specialization ?? "General Practitioner",
                        style: const TextStyle(color: AppColors.sage500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildSectionHeader("Account Details"),
                const SizedBox(height: 16),
                _buildField("Full Name", _nameController, "Your Name"),
                const SizedBox(height: 16),
                _buildField(
                  "Specialization",
                  _specController,
                  "e.g. Cardiology",
                ),
                const SizedBox(height: 16),
                _buildField(
                  "Security PIN (4 digits)",
                  _pinController,
                  "••••",
                  obscure: true,
                  kb: TextInputType.number,
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.midnight900,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Save Changes",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
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

  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    TextInputType? kb,
  }) {
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
          obscureText: obscure,
          keyboardType: kb,
          decoration: InputDecoration(
            hintText: hint,
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
