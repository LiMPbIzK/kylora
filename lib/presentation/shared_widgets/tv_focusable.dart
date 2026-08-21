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
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool autofocus;
  final BorderRadius borderRadius;
  final double focusScale;

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable> {
  bool _focused = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool active = _focused || _hovered;
    return FocusableActionDetector(
      autofocus: widget.autofocus,
      onShowFocusHighlight: (bool value) {
        if (mounted) setState(() => _focused = value);
      },
      onShowHoverHighlight: (bool value) {
        if (mounted) setState(() => _hovered = value);
      },
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (Intent intent) {
            widget.onPressed?.call();
            return null;
          },
        ),
      },
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
              color: active ? AppColors.focusGlow : Colors.transparent,
              width: 3,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}