import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';
import 'tv_focusable.dart';

/// Barra lateral vertical con las secciones (categorías) de un catálogo.
///
/// Diseñada para Android TV/mando: una columna a la izquierda con todos los
/// filtros, reemplazando a los chips horizontales. El icono de cada entrada
/// se parametriza ([icon]) y la anchura de la columna es [width].
///
/// Si se proporcionan [resumeLabel] y [onResumeSelected], se muestra la opción
/// "Continuar visualización" en la **primera posición** (donde antes estaba
/// "Todas").
class CategorySidebar extends StatelessWidget {
  const CategorySidebar({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.onCategoryLongPress,
    this.favoriteGroupIds = const <int>{},
    this.icon = Icons.live_tv,
    this.width = 200,
    this.resumeLabel,
    this.isResumeSelected = false,
    this.onResumeSelected,
    this.firstCategoryFocus,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;
  final ValueChanged<Category>? onCategoryLongPress;
  final Set<int> favoriteGroupIds;
  final IconData icon;
  final double width;

  /// Etiqueta de la opción "Continuar visualización" (null la oculta).
  final String? resumeLabel;

  /// Si está activa la vista de reanudación.
  final bool isResumeSelected;

  /// Añade la opción de reanudación (al pulsar).
  final VoidCallback? onResumeSelected;

  /// FocusNode opcional que se asigna a la primera sección (para volver desde
  /// el buscador con `ArrowUp` en TV).
  final FocusNode? firstCategoryFocus;

  @override
  Widget build(BuildContext context) {
    final bool hasResume = resumeLabel != null && onResumeSelected != null;
    final int selectedIndex = categories.indexWhere(
      (Category category) => category.id == selectedCategoryId,
    );
    return SizedBox(
      width: width,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: <Widget>[
          if (hasResume)
            _SidebarButton(
              label: resumeLabel!,
              icon: Icons.play_circle_outline,
              selected: isResumeSelected,
              autofocus: isResumeSelected,
              focusNode: isResumeSelected ? firstCategoryFocus : null,
              onTap: onResumeSelected!,
            ),
          for (int i = 0; i < categories.length; i++)
            _SidebarButton(
              label: categories[i].name,
              icon: icon,
              selected: selectedCategoryId == categories[i].id,
              autofocus:
                  !isResumeSelected && selectedCategoryId == categories[i].id,
              focusNode:
                  !isResumeSelected &&
                      i == (selectedIndex >= 0 ? selectedIndex : 0)
                  ? firstCategoryFocus
                  : null,
              isGroupFavorite: favoriteGroupIds.contains(categories[i].id),
              onTap: () => onCategorySelected(categories[i].id),
              onLongPress: onCategoryLongPress == null
                  ? null
                  : () => onCategoryLongPress!(categories[i]),
            ),
        ],
      ),
    );
  }
}

/// Botón de sección vertical de la barra lateral.
class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.isGroupFavorite = false,
    this.autofocus = false,
    this.focusNode,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isGroupFavorite;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return TvFocusable(
      autofocus: autofocus,
      focusNode: focusNode,
      borderRadius: BorderRadius.circular(8),
      onPressed: onTap,
      onLongPress: onLongPress,
      child: Material(
        color: selected ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          canRequestFocus: false,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 18,
                  color: selected ? colors.onPrimary : colors.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? colors.onPrimary : colors.onSurface,
                      fontWeight: selected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isGroupFavorite)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(
                      Icons.star,
                      size: 15,
                      color: selected ? colors.onPrimary : colors.secondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
