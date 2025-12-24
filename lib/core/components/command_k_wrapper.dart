import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'command_k_modal.dart';

class CommandKWrapper extends StatelessWidget {
  final Widget child;
  const CommandKWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          CommandKModal.show(context);
        },
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
          CommandKModal.show(context);
        },
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}
