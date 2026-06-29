import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

typedef ScreenWakeLockAction = Future<void> Function();

class KeepScreenOn extends StatefulWidget {
  const KeepScreenOn({
    required this.child,
    this.enable = WakelockPlus.enable,
    this.disable = WakelockPlus.disable,
    super.key,
  });

  final Widget child;
  final ScreenWakeLockAction enable;
  final ScreenWakeLockAction disable;

  @override
  State<KeepScreenOn> createState() => _KeepScreenOnState();
}

class _KeepScreenOnState extends State<KeepScreenOn>
    with WidgetsBindingObserver {
  void _runWakeLockAction(Future<void> Function() action) {
    unawaited(
      action().catchError((Object error) {
        debugPrint('Screen wake lock action failed: $error');
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _runWakeLockAction(widget.enable);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _runWakeLockAction(widget.enable);
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _runWakeLockAction(widget.disable);
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _runWakeLockAction(widget.disable);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
