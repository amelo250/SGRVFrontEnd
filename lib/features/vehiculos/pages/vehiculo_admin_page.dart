import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';
import 'package:sgrv_frontend/core/utils/money_formatter.dart';
import '../models/vehiculo.dart';
import '../providers/vehiculo_provider.dart';
import '../providers/vehiculo_media_provider.dart';
import '../widgets/vehiculo_accesorios_section.dart';
import '../widgets/vehiculo_galeria_section.dart';
import '../widgets/vehiculo_financial_summary.dart';
import 'vehiculo_form_page.dart';

class VehiculoAdminPage extends StatefulWidget {
  const VehiculoAdminPage({required this.vehiculo, super.key});
  final Vehiculo vehiculo;

  @override
  State<VehiculoAdminPage> createState() => _VehiculoAdminPageState();
}

class _VehiculoAdminPageState extends State<VehiculoAdminPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiculoProvider>().cargarResumenFinanciero(
        widget.vehiculo.idVehiculo,
      );
      context.read<VehiculoMediaProvider>().cargar(widget.vehiculo.idVehiculo);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = widget.vehiculo;
    return DefaultTabController(
      length: 4,
      child: AppModuleScaffold(
        title: '${vehicle.marca} ${vehicle.modelo}',
        subtitle:
            '${vehicle.placa} · ${vehicle.anio} · Administración del vehículo',
        actions: [
          IconButton(
            tooltip: 'Editar información general',
            onPressed: _edit,
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
        body: Column(
          children: [
            Card(
              child: TabBar(
                isScrollable: MediaQuery.sizeOf(context).width < 760,
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline_rounded), text: 'General'),
                  Tab(icon: Icon(Icons.extension_rounded), text: 'Accesorios'),
                  Tab(icon: Icon(Icons.insights_rounded), text: 'Finanzas'),
                  Tab(
                    icon: Icon(Icons.photo_library_outlined),
                    text: 'Galería',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: TabBarView(
                children: [
                  _GeneralSection(vehicle: vehicle),
                  VehiculoAccesoriosSection(idVehiculo: vehicle.idVehiculo),
                  _FinancialSection(idVehiculo: vehicle.idVehiculo),
                  VehiculoGaleriaSection(idVehiculo: vehicle.idVehiculo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => VehiculoFormPage(vehiculo: widget.vehiculo),
      ),
    );
    if (mounted) Navigator.pop(context);
  }
}

class _GeneralSection extends StatelessWidget {
  const _GeneralSection({required this.vehicle});
  final Vehiculo vehicle;

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      AppSectionCard(
        title: 'Información general',
        subtitle: 'Identificación y características principales.',
        child: Wrap(
          spacing: 34,
          runSpacing: 22,
          children: [
            _Detail(label: 'Marca', value: vehicle.marca),
            _Detail(label: 'Modelo', value: vehicle.modelo),
            _Detail(label: 'Año', value: '${vehicle.anio}'),
            _Detail(label: 'Placa', value: vehicle.placa),
            _Detail(label: 'VIN', value: vehicle.vin ?? 'No indicado'),
            _Detail(label: 'Color', value: vehicle.color ?? 'No indicado'),
            _Detail(label: 'Kilometraje', value: '${vehicle.kilometraje} km'),
            _Detail(label: 'Propiedad', value: vehicle.tipoPropiedad.label),
          ],
        ),
      ),
      const SizedBox(height: 16),
      AppSectionCard(
        title: 'Tarifa y operación',
        child: Wrap(
          spacing: 34,
          runSpacing: 22,
          children: [
            _Detail(
              label: 'Precio por día',
              value: MoneyFormatter.format(
                vehicle.precioPorDia,
                currencyCode: vehicle.monedaCodigo,
                currencySymbol: vehicle.monedaSimbolo,
              ),
            ),
            _Detail(
              label: 'Depósito de combustible',
              value:
                  '${vehicle.depositoCombustible.toStringAsFixed(2)} galones',
            ),
            _Detail(
              label: 'Estado',
              value: vehicle.activo ? 'Activo' : 'Inactivo',
            ),
            _Detail(
              label: 'Descripción',
              value: vehicle.descripcion?.trim().isNotEmpty == true
                  ? vehicle.descripcion!
                  : 'Sin descripción',
            ),
          ],
        ),
      ),
    ],
  );
}

class _FinancialSection extends StatelessWidget {
  const _FinancialSection({required this.idVehiculo});
  final int idVehiculo;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehiculoProvider>();
    if (provider.isLoadingSummary) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.summaryError != null) {
      return AppStateView(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudo cargar el resumen',
        message: provider.summaryError,
        onRetry: () => provider.cargarResumenFinanciero(idVehiculo),
      );
    }
    final summary = provider.resumenFinanciero;
    if (summary == null) {
      return const AppStateView(
        icon: Icons.insights_rounded,
        title: 'Sin información financiera',
      );
    }
    return SingleChildScrollView(
      child: VehiculoFinancialSummary(summary: summary),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 225,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF7B8498))),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    ),
  );
}
