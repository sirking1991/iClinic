import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auto_lock_service.dart';

class AutoLockWrapper extends ConsumerWidget {
  final Widget child;

  const AutoLockWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => ref.read(autoLockProvider).userInteracted(),
      onPointerMove: (_) => ref.read(autoLockProvider).userInteracted(),
      onPointerUp: (_) => ref.read(autoLockProvider).userInteracted(),
      child: child,
    );
  }
}
