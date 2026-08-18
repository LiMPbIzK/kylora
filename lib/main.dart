import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/local/auth_store.dart';
import 'data/datasources/remote/xtream_api_client.dart';
import 'data/repositories/xtream_repository.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const _KyloraBlocObserver();

  final Dio dio = Dio(
    BaseOptions(
      connectTimeout: AppTimeouts.connect,
      receiveTimeout: AppTimeouts.receive,
      headers: <String, dynamic>{'User-Agent': AppConstants.userAgent},
    ),
  );

  final XtreamRepository repository = XtreamRepository(
    XtreamApiClient(dio),
    AuthStore(),
  );

  final AuthBloc authBloc = AuthBloc(repository)..add(const AuthStarted());

  runApp(KyloraApp(authBloc: authBloc));
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
