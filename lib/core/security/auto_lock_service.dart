import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../features/auth/data/auth_repository.dart';

final autoLockProvider = ChangeNotifierProvider<AutoLockService>(
  (ref) => AutoLockService(ref.watch(authRepositoryProvider)),
);

class AutoLockService extends ChangeNotifier {
  final AuthRepository _authRepo;
  Timer? _timer;
  static const int kTimeoutSeconds =
      300; // 5 minutes standard for HIPAA (often less, but 5 is user-friendly)

  AutoLockService(this._authRepo);

  bool _isLocked = false;
  bool get isLocked => _isLocked;

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: kTimeoutSeconds), _lockApp);
  }

  void userInteracted() {
    if (!_isLocked) {
      startTimer();
    }
  }

  void _lockApp() {
    _isLocked = true;
    notifyListeners(); // UI should listen to this and redirect
  }

  Future<bool> unlock(String pin) async {
    final doctor = await _authRepo.getDoctor();
    if (doctor != null && doctor.pin == pin) {
      _isLocked = false;
      startTimer();
      notifyListeners();
      return true;
    }
    return false;
  }
}
