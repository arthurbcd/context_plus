import 'package:context_watch/context_watch.dart';
import 'package:context_watch_signals/context_watch_signals.dart';
import 'package:flutter/material.dart';

import 'benchmark_screen.dart';
import 'home_screen.dart';
import 'hot_reload_test_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ContextWatchRoot(
      additionalWatchers: [
        SignalContextWatcher.instance,
      ],
      child: MaterialApp(
        routes: {
          '/': (_) => const HomeScreen(),
          '/benchmark': (_) => const BenchmarkScreen(),
          '/hot_reload_test': (_) => const HotReloadTestScreen(),
        },
      ),
    );
  }
}
