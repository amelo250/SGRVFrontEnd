import 'package:sgrv_frontend/features/configuracion/widgets/condiciones_contrato_panel.dart';
import 'package:flutter/material.dart';
import 'package:sgrv_frontend/features/configuracion/widgets/personalizacion_contrato_panel.dart';
import 'package:sgrv_frontend/features/configuracion/widgets/configuracion_alquiler_panel.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/features/clientes/providers/cliente_provider.dart';
import 'package:sgrv_frontend/features/reservaciones/services/reservacion_service.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';

import 'package:image_picker/image_picker.dart';
import 'package:sgrv_frontend/features/empresas/services/empresa_service.dart';
import 'package:sgrv_frontend/features/dashboard/providers/dashboard_task_provider.dart';

class EmpresaConfiguracionPage extends StatefulWidget {
  const EmpresaConfiguracionPage({super.key});
  @override
  State<EmpresaConfiguracionPage> createState() =>
      _EmpresaConfiguracionPageState();
}

class _EmpresaConfiguracionPageState extends State<EmpresaConfiguracionPage> {
  bool _generatingLink = false;
  @override
  Widget build(BuildContext context) {
    final allowed = const [
      'ADMIN',
      'SUPADMIN',
    ].contains(context.watch<AuthProvider>().role);
    return AppModuleScaffold(
      title: 'Configuración de empresa',
      body: ListView(
        children: [
          if (allowed) ...[
            const ConfiguracionAlquilerPanel(),
            const CondicionesContratoPanel(),
            const PersonalizacionContratoPanel(),
            ListTile(
              title: const Text('Logo de la empresa'),
              subtitle: const Text('Selecciona una imagen JPG, PNG o WebP.'),
              trailing: const Icon(Icons.image_outlined),
              onTap: _generatingLink ? null : _logo,
            ),
            ListTile(
              title: const Text('Formulario público'),
              trailing: const Icon(Icons.link),
              onTap: _generatingLink ? null : _publicLink,
            ),
            ListTile(
              title: const Text('Copiar enlace fijo del catálogo'),
              trailing: const Icon(Icons.public),
              onTap: _generatingLink ? null : _fixedCatalog,
            ),
            if (_generatingLink) const LinearProgressIndicator(),
          ] else
            const Text('No tienes permisos para administrar la empresa.'),
        ],
      ),
    );
  }

  Future<void> _logo() async {
    setState(() => _generatingLink = true);
    final service = EmpresaService();
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 90,
      );
      if (file == null) return;
      final name = file.name.toLowerCase();
      if (!['.jpg', '.jpeg', '.png', '.webp'].any(name.endsWith))
        throw Exception('Selecciona JPG, PNG o WebP.');
      final bytes = await file.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024)
        throw Exception('El logo debe ser menor de 5 MB.');
      await service.updateLogo(
        logo: bytes,
        fileName: file.name,
        contentType: name.endsWith('.png')
            ? 'image/png'
            : name.endsWith('.webp')
            ? 'image/webp'
            : 'image/jpeg',
      );
      if (!mounted) return;
      await context.read<DashboardTaskProvider>().load(refresh: true);
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Logo actualizado.')));
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      service.dispose();
      if (mounted) setState(() => _generatingLink = false);
    }
  }

  Future<void> _fixedCatalog() async {
    setState(() => _generatingLink = true);
    final service = ReservacionService();
    try {
      final url = await service.obtenerCatalogoFijo();
      await Clipboard.setData(ClipboardData(text: url));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Enlace fijo copiado.')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      service.dispose();
      if (mounted) setState(() => _generatingLink = false);
    }
  }

  Future<void> _publicLink() async {
    setState(() => _generatingLink = true);
    final service = ReservacionService();
    try {
      final clients = context.read<ClienteProvider>();
      await clients.cargarParaSelector();
      if (!mounted) return;
      int? clientId;
      int days = 30;
      bool phone = false;
      bool address = false;
      String currency = 'DOP';
      double? exchangeRate;
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, update) => AlertDialog(
            title: const Text('Formulario público por empresa'),
            content: SizedBox(
              width: 440,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'El enlace permite solicitar reservas pendientes. Comparte los enlaces personales solo con el cliente indicado.',
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: currency,
                      decoration: const InputDecoration(
                        labelText: 'Moneda del catálogo',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'DOP',
                          child: Text('Pesos dominicanos (DOP)'),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Text('Dólares estadounidenses (USD)'),
                        ),
                      ],
                      onChanged: (value) =>
                          update(() => currency = value ?? 'DOP'),
                    ),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Pesos por dólar (1 USD = ... DOP)',
                        helperText:
                            'Tasa obligatoria. Precios informativos al consultar el enlace.',
                        helperMaxLines: 2,
                      ),
                      onChanged: (value) => update(
                        () => exchangeRate = double.tryParse(
                          value.trim().replaceAll(',', '.'),
                        ),
                      ),
                    ),
                    DropdownButtonFormField<int>(
                      isExpanded: true,
                      initialValue: 0,
                      decoration: const InputDecoration(
                        labelText: 'Destinatario',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 0,
                          child: Text('Público: clientes nuevos'),
                        ),
                        ...clients.clientes
                            .where((x) => x.activo)
                            .map(
                              (x) => DropdownMenuItem(
                                value: x.idCliente,
                                child: Text(
                                  x.nombreCompleto,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                      ],
                      onChanged: (value) =>
                          update(() => clientId = value == 0 ? null : value),
                    ),
                    DropdownButtonFormField<int>(
                      initialValue: days,
                      decoration: const InputDecoration(labelText: 'Vigencia'),
                      items: [1, 7, 30, 90]
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text('$value días'),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => update(() => days = value ?? 30),
                    ),
                    if (clientId == null) ...[
                      CheckboxListTile(
                        title: const Text('Teléfono obligatorio'),
                        value: phone,
                        onChanged: (value) =>
                            update(() => phone = value ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Dirección obligatoria'),
                        value: address,
                        onChanged: (value) =>
                            update(() => address = value ?? false),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Volver'),
              ),
              FilledButton(
                onPressed:
                    exchangeRate != null &&
                        exchangeRate!.isFinite &&
                        exchangeRate! >= 0.000001 &&
                        exchangeRate! <= 1000000
                    ? () => Navigator.pop(dialogContext, true)
                    : null,
                child: const Text('Generar enlace'),
              ),
            ],
          ),
        ),
      );
      if (accepted != true) return;
      final url = await service.crearEnlacePublico(
        diasVigencia: days,
        idCliente: clientId,
        solicitarTelefono: phone,
        solicitarDireccion: address,
        monedaCodigo: currency,
        pesosPorDolar: exchangeRate,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Enlace de reservación'),
          content: SingleChildScrollView(child: SelectableText(url)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copiar enlace'),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: url));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      service.dispose();
      if (mounted) setState(() => _generatingLink = false);
    }
  }
}
