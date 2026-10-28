import 'package:flutter/material.dart';

/// Formatea una hora según el ajuste 12/24 h de la app.
///
/// No usa `MaterialLocalizations.formatTimeOfDay(alwaysUse24HourFormat: false)`
/// porque ese flag significa "usa el formato preferido del idioma": en español
/// el formato regional ya es 24 h, así que cambiar a 12 h no surtía efecto.
String formatClockTime(
  TimeOfDay time, {
  required bool clock24h,
  required MaterialLocalizations localizations,
}) {
  final String minute = time.minute.toString().padLeft(2, '0');
  if (clock24h) {
    final String hour = time.hour.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  final int hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final String period = time.period == DayPeriod.am
      ? localizations.anteMeridiemAbbreviation
      : localizations.postMeridiemAbbreviation;
  return '$hour12:$minute $period';
}
