/// Etiqueta de resolución para el chip del reproductor.
///
/// Se basa en la altura real del vídeo que reporta media_kit (no en metadatos
/// del canal). Agrupa los tamaños habituales para evitar etiquetas raras por
/// ligeros recortes o modos entrelazados.
String? videoResolutionLabel(int? height) {
  if (height == null || height <= 0) return null;
  if (height >= 4320) return '4320p';
  if (height >= 2160) return '2160p';
  if (height >= 1440) return '1440p';
  if (height >= 1080) return '1080p';
  if (height >= 720) return '720p';
  if (height >= 576) return '576p';
  if (height >= 540) return '540p';
  if (height >= 480) return '480p';
  if (height >= 360) return '360p';
  return '${height}p';
}
