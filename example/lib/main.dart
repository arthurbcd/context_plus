import 'package:context_plus/context_plus.dart';
import 'package:context_watch_bloc/context_watch_bloc.dart';
import 'package:context_watch_getx/context_watch_getx.dart';
import 'package:context_watch_mobx/context_watch_mobx.dart';
import 'package:context_watch_signals/context_watch_signals.dart';
import 'package:example/examples/context_plus_screen_state_example_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart' as signals;
import 'package:syntax_highlight/syntax_highlight.dart';
import 'package:url_router/url_router.dart';

import 'benchmarks/context_watch/benchmark_screen.dart';
import 'examples/context_plus_rainbow_example_screen.dart';
import 'examples/context_ref_bind_example_screen.dart';
import 'examples/context_ref_bind_value_example_screen.dart';
import 'examples/context_ref_nested_scopes_example_screen.dart';
import 'examples/context_watch_example_screen.dart';
import 'examples/context_watch_listenable_example_screen.dart';
import 'home_screen.dart';
import 'other/context_watch_hot_reload_test_screen.dart';

void main() {
  ErrorWidget.builder = ContextPlus.errorWidgetBuilder(ErrorWidget.builder);
  FlutterError.onError = ContextPlus.onError(FlutterError.onError);
  signals.disableSignalsDevTools();
  runApp(const _App());
}

class _App extends StatefulWidget {
  const _App();

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  late final UrlRouter router;

  @override
  void initState() {
    super.initState();
    Highlighter.initialize(['dart']);
    router = UrlRouter(
      onGeneratePages: _generatePages,
      onPopPage: (route, result) {
        final pages = _generatePages(router);
        if (pages.length > 1 && route.didPop(result)) {
          final uri = Uri.parse(router.url);
          final newPathSegments =
              uri.pathSegments.take(uri.pathSegments.length - 1);
          router.url = uri.replace(pathSegments: newPathSegments).toString();
          return true;
        }
        return false;
      },
    );
  }

  List<Page> _generatePages(UrlRouter router) => [
        const HomeScreen(),
        switch (router.urlPath) {
          BenchmarkScreen.urlPath => const BenchmarkScreen(),
          ContextWatchHotReloadTestScreen.urlPath =>
            const ContextWatchHotReloadTestScreen(),
          NestedScopesExampleScreen.urlPath =>
            const NestedScopesExampleScreen(),
          BindExampleScreen.urlPath => const BindExampleScreen(),
          BindValueExampleScreen.urlPath => const BindValueExampleScreen(),
          ContextWatchExampleScreen.urlPath =>
            const ContextWatchExampleScreen(),
          ContextPlusBindWatchExampleScreen.urlPath =>
            const ContextPlusBindWatchExampleScreen(),
          ContextWatchListenableExampleScreen.urlPath =>
            const ContextWatchListenableExampleScreen(),
          ContextPlusScreenStateExampleScreen.urlPath =>
            const ContextPlusScreenStateExampleScreen(),
          _ => null,
        },
      ].nonNulls.map((screen) => MaterialPage(child: screen)).toList();

  @override
  Widget build(BuildContext context) {
    return ContextPlus.root(
      additionalWatchers: [
        SignalContextWatcher.instance,
        MobxObservableWatcher.instance,
        BlocContextWatcher.instance,
        GetxContextWatcher.instance,
      ],
      child: MaterialApp.router(
        routeInformationParser: const _UrlRouteParser(),
        routerDelegate: router,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
      ),
    );
  }
}

class _UrlRouteParser extends RouteInformationParser<String> {
  const _UrlRouteParser();

  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) =>
      SynchronousFuture(routeInformation.uri.toString());

  @override
  RouteInformation? restoreRouteInformation(String configuration) =>
      RouteInformation(uri: Uri.parse(configuration));
}
