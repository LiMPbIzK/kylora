import 'package:flutter_bloc/flutter_bloc.dart';

/// Estado global de visibilidad del buscador de los catálogos.
///
/// La lupa del `HomeShellScreen` alterna esta bandera; cada catálogo
/// (Directo/Películas/Series) muestra u oculta su `CatalogSearchField` según
/// este estado. Así el buscador queda oculto por defecto y solo se muestra al
/// pulsar la lupa.
class SearchVisibilityCubit extends Cubit<bool> {
  SearchVisibilityCubit() : super(false);

  void toggle() => emit(!state);

  void show() => emit(true);

  void hide() => emit(false);
}