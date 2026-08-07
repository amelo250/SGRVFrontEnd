import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/rentas/models/renta_entrega.dart';
import 'package:sgrv_frontend/features/rentas/providers/renta_provider.dart';

class RentaEntregaPage extends StatefulWidget {
  const RentaEntregaPage({required this.rentaId, super.key});
  final int rentaId;

  @override
  State<RentaEntregaPage> createState() => _RentaEntregaPageState();
}

class _RentaEntregaPageState extends State<RentaEntregaPage> {
  final Set<int> _confirmedAccessories = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<RentaProvider>().loadEntrega(widget.rentaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentaProvider>();
    final data = provider.entrega;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text('Formulario de entrega'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: provider.loadingEntrega
                ? null
                : () => provider.loadEntrega(widget.rentaId),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: provider.loadingEntrega
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? _error(provider)
          : SelectionArea(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1100),
                      child: Column(
                        children: [
                          _header(context, data),
                          const SizedBox(height: 16),
                          _notice(),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final client = _client(context, data);
                              final vehicle = _vehicle(context, data);
                              return constraints.maxWidth >= 760
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: client),
                                        const SizedBox(width: 16),
                                        Expanded(child: vehicle),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        client,
                                        const SizedBox(height: 16),
                                        vehicle,
                                      ],
                                    );
                            },
                          ),
                          const SizedBox(height: 16),
                          _financial(context, data),
                          const SizedBox(height: 16),
                          _accessories(context, data),
                          const SizedBox(height: 16),
                          _signatures(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _header(BuildContext context, RentaEntrega data) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(26),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF173C9B), Color(0xFF6655DF)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 14,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.empresa.nombreComercial,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'RNC ${data.empresa.rnc} · ${data.empresa.telefono}',
              style: const TextStyle(color: Color(0xFFDCE5FF)),
            ),
            Text(
              data.empresa.direccion,
              style: const TextStyle(color: Color(0xFFDCE5FF)),
            ),
          ],
        ),
        Chip(
          avatar: const Icon(Icons.description_outlined, size: 18),
          label: Text('Contrato ${data.numeroContrato}'),
        ),
      ],
    ),
  );

  Widget _notice() => const Card(
    child: ListTile(
      leading: Icon(Icons.info_outline_rounded, color: Color(0xFF3867F4)),
      title: Text('Constancia generada desde los datos actuales del sistema'),
      subtitle: Text(
        'La selección de accesorios y las firmas de esta pantalla todavía no se almacenan como inspección histórica.',
      ),
    ),
  );

  Widget _client(BuildContext context, RentaEntrega data) =>
      _section(context, 'Datos del cliente', Icons.person_outline_rounded, [
        _line('Nombre', data.cliente.nombreCompleto),
        _line('Dirección', data.cliente.direccion),
        _line('Teléfono', data.cliente.telefono),
        _line('Nacionalidad', data.cliente.nacionalidad),
        _line('Cédula/Pasaporte', data.cliente.cedulaPasaporte),
        _line('Licencia', data.cliente.licenciaConducir),
        _line(
          'Vence licencia',
          data.cliente.fechaVencimientoLicencia == null
              ? 'No registrado'
              : _date(data.cliente.fechaVencimientoLicencia!),
        ),
      ]);

  Widget _vehicle(
    BuildContext context,
    RentaEntrega data,
  ) => _section(context, 'Datos del vehículo', Icons.directions_car_outlined, [
    _line(
      'Vehículo',
      '${data.vehiculo.marca} ${data.vehiculo.modelo} ${data.vehiculo.anio}',
    ),
    _line('Tipo', data.vehiculo.tipo),
    _line('Placa', data.vehiculo.placa),
    _line('VIN', data.vehiculo.vin),
    _line('Color', data.vehiculo.color),
    _line(
      'Kilometraje',
      NumberFormat.decimalPattern('es_DO').format(data.vehiculo.kilometraje),
    ),
    _line('Salida', _dateTime(data.fechaInicio)),
    _line('Retorno previsto', _dateTime(data.fechaFin)),
  ]);

  Widget _financial(BuildContext context, RentaEntrega data) {
    final money = NumberFormat.currency(
      locale: 'es_DO',
      symbol: '${data.monedaSimbolo} ',
    );
    return _section(context, 'Condiciones pactadas', Icons.payments_outlined, [
      Wrap(
        spacing: 34,
        runSpacing: 12,
        children: [
          _metric('Precio por día', money.format(data.precioPorDiaPactado)),
          _metric('Días rentados', '${data.cantidadDias}'),
          _metric('Subtotal', money.format(data.subtotal)),
          _metric('Descuento', money.format(data.descuentos)),
          _metric('Depósito', money.format(data.deposito)),
          _metric('Total', money.format(data.total)),
          _metric(
            'Abonos registrados (DOP)',
            NumberFormat.currency(
              locale: 'es_DO',
              symbol: r'RD$ ',
            ).format(data.totalAbonadoLocal),
          ),
        ],
      ),
      if (data.observaciones?.trim().isNotEmpty == true)
        _line('Observaciones', data.observaciones!),
    ]);
  }

  Widget _accessories(BuildContext context, RentaEntrega data) => _section(
    context,
    'Accesorios entregados',
    Icons.checklist_rounded,
    data.accesorios.isEmpty
        ? [const Text('El vehículo no tiene accesorios activos registrados.')]
        : data.accesorios
              .map(
                (item) => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _confirmedAccessories.contains(item.idAccesorio),
                  title: Text(item.nombre),
                  subtitle: item.observaciones == null
                      ? null
                      : Text(item.observaciones!),
                  onChanged: (value) => setState(() {
                    if (value == true) {
                      _confirmedAccessories.add(item.idAccesorio);
                    } else {
                      _confirmedAccessories.remove(item.idAccesorio);
                    }
                  }),
                ),
              )
              .toList(),
  );

  Widget _signatures(BuildContext context) =>
      _section(context, 'Conformidad de entrega', Icons.draw_outlined, const [
        SizedBox(height: 30),
        Row(
          children: [
            Expanded(child: _SignatureLine('Cliente')),
            SizedBox(width: 24),
            Expanded(child: _SignatureLine('Agente de renta')),
          ],
        ),
        SizedBox(height: 20),
      ]);

  Widget _section(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF3867F4)),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    ),
  );

  Widget _line(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 145,
          child: Text(label, style: const TextStyle(color: Color(0xFF6F788C))),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? 'No registrado' : value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  Widget _metric(String label, String value) => SizedBox(
    width: 185,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6F788C))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    ),
  );

  Widget _error(RentaProvider provider) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off_outlined, size: 52),
        const SizedBox(height: 12),
        Text(provider.errorMessage ?? 'No fue posible generar el formulario.'),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: () => provider.loadEntrega(widget.rentaId),
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    ),
  );

  String _date(DateTime value) => DateFormat('dd/MM/yyyy').format(value);
  String _dateTime(DateTime value) =>
      DateFormat('dd/MM/yyyy · hh:mm a').format(value);
}

class _SignatureLine extends StatelessWidget {
  const _SignatureLine(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Divider(color: Color(0xFF172033)),
      const SizedBox(height: 6),
      Text(label),
    ],
  );
}
