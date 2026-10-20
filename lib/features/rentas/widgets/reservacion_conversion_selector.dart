import 'package:sgrv_frontend/core/utils/periodo_alquiler_fechas.dart';
import 'package:flutter/material.dart';
import 'package:sgrv_frontend/features/reservaciones/models/reservacion.dart';
import 'package:sgrv_frontend/features/reservaciones/services/reservacion_service.dart';

class ReservacionConversionSelector extends StatefulWidget {
  const ReservacionConversionSelector({
    required this.onChanged,
    this.service,
    this.onReservationChanged,
    super.key,
  });

  final ValueChanged<int?> onChanged;
  final ReservacionService? service;
  final ValueChanged<Reservacion?>? onReservationChanged;

  @override
  State<ReservacionConversionSelector> createState() =>
      _ReservacionConversionSelectorState();
}

class _ReservacionConversionSelectorState
    extends State<ReservacionConversionSelector> {
  late final ReservacionService _service;
  List<Reservacion> _items = [];
  bool _loading = true;
  String? _error;
  int? _selected;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ReservacionService();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _service.getConvertibles();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'No se pudieron recuperar las reservaciones.';
      });
    }
  }

  @override
  void dispose() {
    if (widget.service == null) _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _items
        .where((x) => x.idReservacion == _selected)
        .firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_loading) const LinearProgressIndicator(),
        if (_error != null) ...[
          Text(_error!),
          TextButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
        DropdownButtonFormField<int>(
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Reservación y vehículo',
            border: OutlineInputBorder(),
          ),
          hint: Text(
            _loading ? 'Cargando reservaciones…' : 'Selecciona una reservación',
          ),
          items: _items
              .map(
                (x) => DropdownMenuItem(
                  value: x.idReservacion,
                  child: Text(
                    '#${x.idReservacion} · ${x.vehiculoDescripcion} · ${x.clienteNombre}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: _loading || _error != null
              ? null
              : (value) {
                  setState(() => _selected = value);
                  widget.onChanged(value);
                  widget.onReservationChanged?.call(
                    _items.where((x) => x.idReservacion == value).firstOrNull,
                  );
                },
          validator: (value) =>
              value == null ? 'Selecciona una reservación confirmada' : null,
        ),
        if (!_loading && _error == null && _items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'No hay reservaciones confirmadas disponibles para convertir.',
            ),
          ),
        if (selected != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${selected.clienteNombre}\n${selected.vehiculoDescripcion}\n${PeriodoAlquilerFechas.formato(selected.fechaInicio, selected.periodoSinHora)} → ${PeriodoAlquilerFechas.formato(selected.fechaFin, selected.periodoSinHora)}',
            ),
          ),
      ],
    );
  }
}
