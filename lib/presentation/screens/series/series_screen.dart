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

/// Catálogo de series con rejilla de portadas y categorías.
class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SeriesBloc>().add(const SeriesStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.series)),
      body: BlocBuilder<SeriesBloc, SeriesState>(
        builder: (context, state) {
          return switch (state) {
            SeriesLoading() => const Center(child: CircularProgressIndicator()),
            SeriesFailure() => _ErrorView(message: l10n.seriesLoadError),
            SeriesLoaded() => _SeriesContent(state: state),
            SeriesDetailLoading() ||
            SeriesDetailLoaded() ||
            SeriesDetailFailure() =>
              const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

/// Contenido del catálogo: chips de categorías y rejilla de portadas.
class _SeriesContent extends StatelessWidget {
  const _SeriesContent({required this.state});

  final SeriesLoaded state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      children: <Widget>[
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
              ? Center(child: Text(l10n.noSeries))
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
                    return _SeriesCard(series: state.seriesList[index]);
                  },
                ),
        ),
      ],
    );
  }
}

/// Tarjeta de serie con portada y título.
class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.series});

  final Series series;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
