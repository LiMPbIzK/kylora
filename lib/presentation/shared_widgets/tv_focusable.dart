import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Envoltorio para TV/mando: añade un anillo de foco y escala al widget hijo
/// cuando recibe el foco (D-Pad) o el hover (ratón), además de activar la
/// navegación con Enter/OK del mando.
///
/// Los widgets Material ya son enfocables con las flechas del mando; este
/// wrapper solo aporta el feedback visual (borde + escala) que se espera en
/// pantallas de TV (10-foot UI). Enfócate en el primer elemento de cada lista
/// con [autofocus].
class TvFocusable extends StatefulWidget {
  const TvFocusable({
    super.key,
    required this.child,
    this.onPressed,
    this.autofocus = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.focusScale = 1.05,
    this.focusNode,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool autofocus;
  final BorderRadius borderRadius;
  final double focusScale;

  /// FocusNode externo opcional (p. ej. para mover el foco al primer resultado
  /// de una búsqueda al confirmarla).
  final FocusNode? focusNode;

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable> {
  bool _focused = false;
  bool _hovered = false;
  FocusNode? _internalFocusNode;

  FocusNode get _focusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _focused || _hovered;
    return FocusableActionDetector(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onShowFocusHighlight: (bool value) {
        if (mounted) setState(() => _focused = value);
      },
      onShowHoverHighlight: (bool value) {
        if (mounted) setState(() => _hovered = value);
      },
      actions: widget.onPressed == null
          ? null
          : <Type, Action<Intent>>{
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (Intent intent) {
                  widget.onPressed?.call();
                  return null;
                },
              ),
            },
      child: ClipRect(
        // Recorta la escala para que el elemento enfocado no se salga del
        // ancho de la pantalla (el efecto crece desde el centro).
        child: AnimatedScale(
          scale: active ? widget.focusScale : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              border: Border.all(
                color: active ? context.colors.focusGlow : Colors.transparent,
                width: 3,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}