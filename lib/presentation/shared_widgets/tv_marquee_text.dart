import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tv_focusable.dart';

/// Texto de tarjeta que se desplaza horizontalmente cuando la tarjeta que lo
/// contiene tiene el foco.
///
/// Sólo se anima si el texto no cabe en el ancho disponible. El resto del
/// tiempo se comporta como un [Text] normal con `maxLines` y elipsis. La
/// altura reservada es la del texto estático, así que al enfocar la tarjeta no
/// cambia el tamaño de la rejilla.
///
/// Normalmente no hace falta pasar [active]: se toma del [TvFocusScope] que
/// crea [TvFocusable] alrededor de su contenido.
class TvMarqueeText extends StatefulWidget {
  const TvMarqueeText({
    super.key,
    required this.text,
    this.style,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.active,
    this.gap = 32,
    this.pixelsPerSecond = 45,
  });

  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextAlign textAlign;

  /// Fuerza el estado activo/inactivo. Si es null se usa el foco del
  /// [TvFocusable] ancestro.
  final bool? active;

  /// Separación al final del texto antes de volver a empezar.
  final double gap;

  /// Velocidad de desplazamiento.
  final double pixelsPerSecond;

  @override
  State<TvMarqueeText> createState() => _TvMarqueeTextState();
}

class _TvMarqueeTextState extends State<TvMarqueeText>
    with SingleTickerProviderStateMixin {
  /// Porcentaje del recorrido que se mantiene quieto en cada extremo.
  static const double _holdFraction = 0.12;

  late final AnimationController _controller;
  bool _needsScroll = false;
  bool _wasActive = false;
  double _distance = 0;
  double _reservedHeight = 0;
  bool _syncScheduled = false;

  bool get _active =>
      widget.active ?? (TvFocusScope.maybeOf(context)?.focused ?? false);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void didUpdateWidget(covariant TvMarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.active != widget.active ||
        oldWidget.maxLines != widget.maxLines ||
        oldWidget.style != widget.style) {
      _scheduleSync();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (mounted) _syncAnimation();
    });
  }

  void _syncAnimation() {
    if (!_needsScroll || !_wasActive) {
      if (_controller.isAnimating) _controller.stop();
      if (_controller.value != 0) _controller.value = 0;
      return;
    }

    final double travelSeconds = _distance / widget.pixelsPerSecond;
    final int totalMs = (travelSeconds * 1000 / (1 - 2 * _holdFraction))
        .round()
        .clamp(1600, 20000)
        .toInt();
    _controller.duration = Duration(milliseconds: totalMs);
    if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  double _offsetAt(double value) {
    if (value < _holdFraction) return 0;
    if (value < 0.5) {
      return _distance * ((value - _holdFraction) / (0.5 - _holdFraction));
    }
    if (value < 0.5 + _holdFraction) return _distance;
    return _distance *
        (1 - (value - 0.5 - _holdFraction) / (0.5 - _holdFraction));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.isEmpty) return const SizedBox.shrink();

    final TextStyle effectiveStyle = DefaultTextStyle.of(context).style
        .merge(widget.style);
    final TextScaler textScaler = MediaQuery.textScalerOf(context);
    final TextDirection textDirection = Directionality.of(context);
    final String singleLine = widget.text.replaceAll('\n', ' ');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool hasFiniteWidth = constraints.maxWidth.isFinite;
        final double maxWidth = hasFiniteWidth
            ? math.max(0.0, constraints.maxWidth)
            : 0.0;

        final TextPainter staticPainter = TextPainter(
          text: TextSpan(text: widget.text, style: effectiveStyle),
          maxLines: widget.maxLines,
          textDirection: textDirection,
          textScaler: textScaler,
          ellipsis: '…',
        )..layout(maxWidth: hasFiniteWidth ? maxWidth : double.infinity);

        final bool overflows =
            hasFiniteWidth && staticPainter.didExceedMaxLines;
        final TextPainter fullPainter = TextPainter(
          text: TextSpan(text: singleLine, style: effectiveStyle),
          maxLines: 1,
          textDirection: textDirection,
          textScaler: textScaler,
        )..layout();

        final double distance = math.max(
          0.0,
          fullPainter.width - maxWidth + (overflows ? widget.gap : 0.0),
        );
        final bool needsScroll = overflows && distance > 0;
        final double reservedHeight = math.max(
          staticPainter.height,
          fullPainter.height,
        );

        if (needsScroll != _needsScroll ||
            distance != _distance ||
            reservedHeight != _reservedHeight ||
            _active != _wasActive) {
          _needsScroll = needsScroll;
          _distance = distance;
          _reservedHeight = reservedHeight;
          _wasActive = _active;
          _scheduleSync();
        }

        final bool showMarquee = needsScroll && _active;
        if (!showMarquee) {
          return Text(
            widget.text,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: widget.textAlign,
            style: widget.style,
          );
        }

        return SizedBox(
          height: reservedHeight,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (BuildContext context, Widget? child) {
                return Transform.translate(
                  offset: Offset(-_offsetAt(_controller.value), 0),
                  child: child,
                );
              },
              child: OverflowBox(
                alignment: Alignment.topLeft,
                maxWidth: double.infinity,
                child: Text(
                  singleLine,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  textAlign: widget.textAlign,
                  style: widget.style,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
