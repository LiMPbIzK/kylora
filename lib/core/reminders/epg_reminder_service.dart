import 'dart:async';

import 'package:flutter/foundation.dart';

/// Recordatorio de un programa EPG.
class EpgReminder {
  const EpgReminder({
    required this.streamId,
    required this.channelName,
    required this.title,
    required this.start,
    this.end,
    this.logo,
  });

  final int streamId;
  final String channelName;
  final String title;
  final DateTime start;
  final DateTime? end;
  final String? logo;

  String get key => '$streamId|${start.toIso8601String()}';
}

/// Recordatorios EPG en memoria, activos mientras la app está abierta.
///
/// No pretende sustituir a una notificación del sistema: sirve para avisar
/// dentro de Kylora cuando empieza un programa. Al cerrar la app se pierden.
class EpgReminderService extends ChangeNotifier {
  EpgReminderService._();

  static final EpgReminderService instance = EpgReminderService._();

  final Map<String, EpgReminder> _reminders = <String, EpgReminder>{};
  final Map<String, Timer> _timers = <String, Timer>{};
  final List<EpgReminder> _due = <EpgReminder>[];

  bool isSet(EpgReminder reminder) => _reminders.containsKey(reminder.key);

  bool get hasReminders => _reminders.isNotEmpty;

  List<EpgReminder> get reminders =>
      List<EpgReminder>.unmodifiable(_reminders.values);

  void toggle(EpgReminder reminder) {
    if (isSet(reminder)) {
      remove(reminder);
    } else {
      add(reminder);
    }
  }

  void add(EpgReminder reminder) {
    if (reminder.start.isBefore(DateTime.now())) return;
    if (_reminders.containsKey(reminder.key)) return;
    _reminders[reminder.key] = reminder;
    _timers[reminder.key] = Timer(
      reminder.start.difference(DateTime.now()),
      () => _fire(reminder),
    );
    notifyListeners();
  }

  void remove(EpgReminder reminder) {
    _timers.remove(reminder.key)?.cancel();
    if (_reminders.remove(reminder.key) != null) {
      notifyListeners();
    }
  }

  /// Limpia los recordatorios (p. ej. al cambiar de cuenta).
  void clear() {
    for (final Timer timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _reminders.clear();
    _due.clear();
    notifyListeners();
  }

  EpgReminder? takeDue() {
    if (_due.isEmpty) return null;
    return _due.removeAt(0);
  }

  void _fire(EpgReminder reminder) {
    _timers.remove(reminder.key);
    _reminders.remove(reminder.key);
    _due.add(reminder);
    notifyListeners();
  }
}
