// ignore_for_file: use_of_void_result

import 'package:context_ref/context_ref.dart' as context_ref;
import 'package:context_watch/context_watch.dart' as context_watch;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// More convenient API for watching multiple values at once.
extension ContextWatchRecordRefExt66<T0, T2> on (context_ref.ReadOnlyRef<Stream<T0>>, context_ref.ReadOnlyRef<Listenable>, context_ref.ReadOnlyRef<ValueListenable<T2>>) {
  /// {@macro mass_watch_explanation}
  (AsyncSnapshot<T0>, void, T2) watch(BuildContext context) =>
      ($1.of(context).watch(context), $2.of(context).watch(context) as Null, $3.of(context).watch(context),);
}
