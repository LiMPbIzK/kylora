import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/series.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/series/series_bloc.dart';
import '../../blocs/series/series_event.dart';
import '../../blocs/series/series_state.dart';
import '../../shared_widgets/media_poster.dart';
import '../../shared_widgets/tv_focusable.dart';

/// Catálogo de series con rejilla de portadas y categorías.
class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final SeriesBloc bloc = context.read<SeriesBloc>();
      // Solo carga si el catálogo aún no está disponible, para no vaciar la
      // rejilla al volver de una ficha de detalle.
      if (bloc.state is! SeriesLoaded) {
        bloc.add(const SeriesStarted());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SeriesBloc, SeriesState>(
      builder: (context, state) {
        return switch (state) {
          SeriesLoading() => const Center(child: CircularProgressIndicator()),
          SeriesFailure() => _ErrorView(message: l10n.seriesLoadError),
          SeriesLoaded() =>
            _SeriesContent(state: state, controller: _searchController),
          SeriesDetailLoading() ||
          SeriesDetailLoaded() ||
          SeriesDetailFailure() =>
            const SizedBox.shrink(),
        };
      },
    );
  }
}

/// Contenido del catálogo: buscador, chips de categorías y rejilla de portadas.
class _SeriesContent extends StatelessWidget {
  const _SeriesContent({required this.state, required this.controller});

  final SeriesLoaded state;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: TextField(
            controller: controller,
            onChanged: (String value) =>
                context.read<SeriesBloc>().add(SeriesSearchChanged(value)),
            decoration: InputDecoration(
              hintText: l10n.searchPlaceholder,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.isSearching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        context
                            .read<SeriesBloc>()
                            .add(const SeriesSearchChanged(''));
                      },
                    )
                  : null,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.surfaceVariant),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: <Widget>[
              _CategoryChip(
                label: l10n.allCategories,
                selected: state.isAllSelected,
                onTap: () =>
                    context.read<SeriesBloc>().add(const SeriesCategorySelected(null)),
              ),
              for (final Category category in state.categories)
                _CategoryChip(
                  label: category.name,
                  selected: state.selectedCategoryId == category.id,
                  onTap: () => context
                      .read<SeriesBloc>()
                      .add(SeriesCategorySelected(category.id)),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: state.seriesList.isEmpty
              ? Center(
                  child: Text(
                    state.isSearching ? l10n.searchNoResults : l10n.noSeries,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                  itemCount: state.seriesList.length,
                  itemBuilder: (context, index) {
                    return _SeriesCard(
                      series: state.seriesList[index],
                      autofocus: index == 0,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Tarjeta de serie con portada y título.
class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.series, this.autofocus = false});

  final Series series;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      borderRadius: BorderRadius.circular(8),
      onPressed: () => context.push(Routes.seriesDetail, extra: series),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push(Routes.seriesDetail, extra: series),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: MediaPoster(url: series.cover, fallbackIcon: Icons.theaters),
            ),
            const SizedBox(height: 6),
            Text(
              series.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip de categoría seleccionable.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          color: selected ? AppColors.onPrimary : AppColors.onSurface,
        ),
        side: BorderSide(color: AppColors.surfaceVariant),
      ),
    );
  }
}

/// Vista de error de carga del catálogo.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.error_outline, size: 56, color: AppColors.error),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () => context.read<SeriesBloc>().add(const SeriesStarted()),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
