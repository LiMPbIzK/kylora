import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const _KyloraBlocObserver();
  runApp(const KyloraApp());
}

/// Observador global de Bloc para trazabilidad de eventos en desarrollo.
class _KyloraBlocObserver extends BlocObserver {
  const _KyloraBlocObserver();

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    if (kDebugMode) {
      debugPrint('${bloc.runtimeType}: ${transition.event.runtimeType}');
    }
  }
}
