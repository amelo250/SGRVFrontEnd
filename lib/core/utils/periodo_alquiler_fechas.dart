import 'package:intl/intl.dart';

class PeriodoAlquilerFechas {
  static DateTime dia(DateTime value) {
    final local = value.toUtc().subtract(const Duration(hours: 4));
    return DateTime(local.year, local.month, local.day);
  }

  static DateTime desdeDia(DateTime date, {bool fin = false}) =>
      (fin
              ? DateTime.utc(
                  date.year,
                  date.month,
                  date.day + 1,
                  4,
                ).subtract(const Duration(milliseconds: 1))
              : DateTime.utc(date.year, date.month, date.day, 4))
          .toLocal();
  static String formato(DateTime value, bool sinHora) => sinHora
      ? '${DateFormat('dd/MM/yyyy').format(dia(value))} · Sin hora definida'
      : DateFormat('dd/MM/yyyy HH:mm').format(value.toLocal());
}
