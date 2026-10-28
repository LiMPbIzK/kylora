import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show KeyDownEvent, KeyEvent, KeyUpEvent, LogicalKeyboardKey;

import '../../core/theme/app_theme.dart';

/// Expone a los descendientes si el [TvFocusable] que los envuelve tiene el
/// foco (o el hover) activo.
///
/// Lo usa [TvMarqueeText] para animar únicamente el título de la tarjeta
/// enfocada, sin que las demás tarjetas se muevan.
class TvFocusScope extends InheritedWidget {
  const TvFocusScope({super.key, required this.focused, required super.child});

  final bool focused;

  static TvFocusScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TvFocusScope>();

  @override
  bool updateShouldNotify(TvFocusScope oldWidget) =>
      focused != oldWidget.focused;
}

/// Envoltorio para TV/mando: añade un anillo de foco y escala al widget hijo
/// cuando recibe el foco (D-Pad) o el hover (ratón), además de activar la
/// navegación con Enter/OK del mando.
///
/// Si se indica [onLongPress], mantener pulsado OK durante ~500 ms abre la
/// acción larga (menú contextual) y una pulsación corta sigue ejecutando
/// [onPressed]. En Android TV el `InkWell.onLongPress` no se dispara al mantener
/// OK, por eso la detección se hace sobre los eventos de teclado del foco.
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
    this.onLongPress,
    this.autofocus = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.focusScale = 1.05,
    this.focusNode,
    this.onFocusChanged,
  });

  final Widget child;
  final VoidCallback? onPressed;

  /// Acción al mantener pulsado OK/Enter (menú contextual). Si es null, el
  /// comportamiento es el de siempre (activación inmediata en OK).
  final VoidCallback? onLongPress;

  final bool autofocus;
  final BorderRadius borderRadius;
  final double focusScale;

  /// FocusNode externo opcional (p. ej. para mover el foco al primer resultado
  /// de una búsqueda al confirmarla).
  final FocusNode? focusNode;

  /// Notifica los cambios de foco (útil para hacer scroll hasta la tarjeta
  /// enfocada en listas largas).
  final ValueChanged<bool>? onFocusChanged;

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable> {
  bool _focused = false;
  bool _hovered = false;
  FocusNode? _internalFocusNode;

  /// Nodo al que está enganchado el detector de pulsación larga.
  FocusNode? _attachedNode;
  KeyEventResult Function(FocusNode, KeyEvent)? _previousOnKeyEvent;
  Timer? _holdTimer;
  bool _selectHeld = false;
  bool _longPressFired = false;

  static const Duration _longPressDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _attachFocusNode();
  }

  @override
  void didUpdateWidget(covariant TvFocusable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusNode();
      _attachFocusNode();
    }
  }

  @override
  void dispose() {
    _detachFocusNode();
    _holdTimer?.cancel();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  FocusNode get _focusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  void _attachFocusNode() {
    final FocusNode node = _focusNode;
    _attachedNode = node;
    _focused = node.hasFocus;
    _previousOnKeyEvent = node.onKeyEvent;
    node.onKeyEvent = _handleKeyEvent;
    node.addListener(_onFocusChanged);
  }

  void _detachFocusNode() {
    final FocusNode? node = _attachedNode;
    if (node == null) return;
    node.removeListener(_onFocusChanged);
    node.onKeyEvent = _previousOnKeyEvent;
    _attachedNode = null;
  }

  void _onFocusChanged() {
    final bool hasFocus = _focusNode.hasFocus;
    if (mounted && _focused != hasFocus) {
      setState(() => _focused = hasFocus);
      widget.onFocusChanged?.call(hasFocus);
    }
    if (hasFocus) return;
    _holdTimer?.cancel();
    _selectHeld = false;
    _longPressFired = false;
  }

  /// Detecta la pulsación larga del OK del mando.
  ///
  /// Un OK corto se consume aquí y se traduce en [TvFocusable.onPressed] al
  /// soltar (evita que el `ActivateIntent` abra el contenido al instante). Un
  /// OK mantenido lanza [TvFocusable.onLongPress] a los 500 ms.
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.onLongPress == null) return KeyEventResult.ignored;

    final LogicalKeyboardKey key = event.logicalKey;
    final bool isSelect =
        key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.gameButtonA;
    if (!isSelect) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      // Repeticiones mientras se mantiene pulsado: no reiniciar el temporizador.
      if (_selectHeld) return KeyEventResult.handled;
      _selectHeld = true;
      _longPressFired = false;
      _holdTimer?.cancel();
      _holdTimer = Timer(_longPressDuration, () {
        if (!mounted || !_selectHeld) return;
        // No abrir el menú mientras el OK sigue pulsado: en Android TV los
        // eventos repetidos podrían activar la primera opción del diálogo.
        // La acción larga se ejecuta al soltar.
        _longPressFired = true;
      });
      return KeyEventResult.handled;
    }

    if (event is KeyUpEvent) {
      if (!_selectHeld) return KeyEventResult.ignored;
      _selectHeld = false;
      _holdTimer?.cancel();
      final bool longPressFired = _longPressFired;
      _longPressFired = false;
      if (longPressFired) {
        widget.onLongPress?.call();
      } else {
        widget.onPressed?.call();
      }
      return KeyEventResult.handled;
    }

    // KeyRepeatEvent: consumir mientras el botón sigue pulsado.
    return _selectHeld ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _focused || _hovered;
    return FocusableActionDetector(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
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
      child: TvFocusScope(
        focused: active,
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
                boxShadow: active
                    ? <BoxShadow>[
                        BoxShadow(
                          color: context.colors.focusGlow.withValues(
                            alpha: 0.55,
                          ),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
