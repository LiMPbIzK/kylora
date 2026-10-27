/// Hora estimada a la que termina una reproducción.
///
/// [position] es el punto actual dentro del contenido y [duration] su duración
/// total. Si la posición ya supera la duración (p. ej. al llegar al final), la
/// hora de fin es [now].
DateTime playbackEndsAt({
  required DateTime now,
  required Duration position,
  required Duration duration,
}) {
  final Duration remaining = duration - position;
  return now.add(remaining.isNegative ? Duration.zero : remaining);
}
