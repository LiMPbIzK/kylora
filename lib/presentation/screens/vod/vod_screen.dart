import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/movie.dart';
import '../../../l10n/app_localizations.dart';
import '../../blocs/vod/vod_bloc.dart';
import '../../blocs/vod/vod_event.dart';
import '../../blocs/vod/vod_state.dart';
import '../../shared_widgets/media_poster.dart';
import '../../shared_widgets/tv_focusable.dart';

/// Catálogo de películas (VOD) con rejilla de pósters y categorías.
class VodScreen extends StatefulWidget {
  const VodScreen({super.key});

  @override
  State<VodScreen> createState() => _VodScreenState();
}

class _VodScreenState extends State<VodScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final VodBloc bloc = context.read<VodBloc>();
      // Solo carga si el catálogo aún no está disponible, para no vaciar la
      // rejilla al volver de una ficha de detalle.
      if (bloc.state is! VodLoaded) {
        bloc.add(const VodStarted());
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

    return BlocBuilder<VodBloc, VodState>(
      builder: (context, state) {
        return switch (state) {
          VodLoading() => const Center(child: CircularProgressIndicator()),
          VodFailure() => _ErrorView(message: l10n.vodLoadError),
          VodLoaded() => _VodContent(state: state, controller: _searchController),
        };
      },
    );
  }
}

/// Contenido del catálogo: buscador, chips de categorías y rejilla de pósters.
class _VodContent extends StatelessWidget {
  const _VodContent({required this.state, required this.controller});

  final VodLoaded state;
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
                context.read<VodBloc>().add(VodSearchChanged(value)),
            decoration: InputDecoration(
              hintText: l10n.searchPlaceholder,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: state.isSearching
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        context
                            .read<VodBloc>()
                            .add(const VodSearchChanged(''));
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
                onTap: () => context
                    .read<VodBloc>()
                    .add(const VodCategorySelected(null)),
              ),
              for (final Category category in state.categories)
                _CategoryChip(
                  label: category.name,
                  selected: state.selectedCategoryId == category.id,
                  onTap: () => context
                      .read<VodBloc>()
                      .add(VodCategorySelected(category.id)),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: state.movies.isEmpty
              ? Center(
                  child: Text(state.isSearching ? l10n.searchNoResults : l10n.noMovies),
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
                  itemCount: state.movies.length,
                  itemBuilder: (context, index) {
                    return _MovieCard(
                      movie: state.movies[index],
                      autofocus: index == 0,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Tarjeta de película con póster y título.
class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie, this.autofocus = false});

  final Movie movie;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TvFocusable(
      autofocus: autofocus,
      borderRadius: BorderRadius.circular(8),
      onPressed: () => context.push(Routes.movieDetail, extra: movie),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => context.push(Routes.movieDetail, extra: movie),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: MediaPoster(url: movie.streamIcon, fallbackIcon: Icons.movie),
            ),
            const SizedBox(height: 6),
            Text(
              movie.name,
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
            onPressed: () => context.read<VodBloc>().add(const VodStarted()),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
