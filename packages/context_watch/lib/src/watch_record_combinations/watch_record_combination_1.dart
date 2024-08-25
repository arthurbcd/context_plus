// ignore_for_file: use_of_void_result

import 'package:flutter/widgets.dart';

import '../watchers/listenable_context_watcher.dart';

/// More convenient API for watching multiple values at once.
extension ContextWatchRecordExt1 on (Listenable, Listenable) {
  /// {@macro mass_watch_explanation}
  (void, void) watch(BuildContext context) =>
      ($1.watch(context) as Null, $2.watch(context) as Null,);
}
