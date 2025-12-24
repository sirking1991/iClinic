import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iclinic/core/security/auto_lock_service.dart';
import 'package:iclinic/core/theme/app_colors.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sage800,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: AppColors.sage100),
            const SizedBox(height: 24),
            Text(
              "iClinic Locked",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter PIN to resume session",
              style: TextStyle(color: AppColors.sage200),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  hintText: "••••",
                  hintStyle: const TextStyle(color: AppColors.sage400),
                  filled: true,
                  fillColor: AppColors.sage900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) async {
                  final success = await ref
                      .read(autoLockProvider)
                      .unlock(value);
                  if (!success) {
                    _pinController.clear();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Incorrect PIN")),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () async {
                final success = await ref
                    .read(autoLockProvider)
                    .unlock(_pinController.text);
                if (!success) {
                  _pinController.clear();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Incorrect PIN")),
                    );
                  }
                }
              },
              child: const Text(
                "Unlock",
                style: TextStyle(color: AppColors.clay300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
