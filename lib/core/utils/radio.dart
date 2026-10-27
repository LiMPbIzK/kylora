/// Detección heurística de categorías de radio en listas IPTV.
///
/// Muchos proveedores agrupan las emisoras en una categoría cuyo nombre
/// contiene "radio" (p. ej. `EU- NL RADIO ZENDERS` o `VIP US- USA RADIO`).
/// Los canales de esas categorías son streams de audio y se muestran en la
/// sección Radio, separados de los canales de televisión.
bool isRadioCategory(String name) => name.toLowerCase().contains('radio');
