import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/auth_repository.dart';
import '../../../core/theme/app_colors.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _nameController = TextEditingController();
  final _specController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;

  void _onComplete() async {
    if (_nameController.text.isEmpty || _pinController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill name and 4-digit PIN")),
      );
      return;
    }

    setState(() => _isLoading = true);
    await ref
        .read(authRepositoryProvider)
        .setupAccount(
          _nameController.text,
          _specController.text,
          _pinController.text,
        );

    // Refresh the authStateProvider
    ref.invalidate(authStateProvider);

    if (mounted) {
      context.go('/patients');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand50,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.medical_services_outlined,
                size: 64,
                color: AppColors.sage500,
              ),
              const SizedBox(height: 24),
              Text(
                "Welcome to iClinic",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.midnight900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Let's set up your professional profile",
                style: TextStyle(color: AppColors.sage600),
              ),
              const SizedBox(height: 48),
              _buildField("Full Name", _nameController, "Dr. Sarah Chen"),
              const SizedBox(height: 16),
              _buildField(
                "Specialization",
                _specController,
                "Internal Medicine",
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
                  onPressed: _isLoading ? null : _onComplete,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.sage500,
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
                          "Create My Account",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
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
