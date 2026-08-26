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
    this.icon = Icons.live_tv,
    this.width = 200,
    this.resumeLabel,
    this.isResumeSelected = false,
    this.onResumeSelected,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;
  final IconData icon;
  final double width;

  /// Etiqueta de la opción "Continuar visualización" (null la oculta).
  final String? resumeLabel;

  /// Si está activa la vista de reanudación.
  final bool isResumeSelected;

  /// Añade la opción de reanudación (al pulsar).
  final VoidCallback? onResumeSelected;

  @override
  Widget build(BuildContext context) {
    final bool hasResume =
        resumeLabel != null && onResumeSelected != null;
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
              onTap: onResumeSelected!,
            ),
          for (final Category category in categories)
            _SidebarButton(
              label: category.name,
              icon: icon,
              selected: selectedCategoryId == category.id,
              onTap: () => onCategorySelected(category.id),
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
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return TvFocusable(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: selected ? colors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}