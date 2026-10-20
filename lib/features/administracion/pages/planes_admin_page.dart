import 'package:flutter/material.dart';
import 'package:sgrv_frontend/core/config/api_config.dart';
import 'package:sgrv_frontend/core/network/api_client.dart';
import 'package:sgrv_frontend/core/network/api_exception.dart';

class PlanesAdminPage extends StatefulWidget {
  const PlanesAdminPage({super.key});
  @override
  State<PlanesAdminPage> createState() => _PlanesAdminPageState();
}

class _PlanesAdminPageState extends State<PlanesAdminPage> {
  final _api = ApiClient();
  String get _url => '${ApiConfig.baseUrl}/api/administracion/planes';
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.getJson(_url);
      if (response['success'] != true) {
        throw const ApiException(
          message: 'No fue posible consultar los planes.',
        );
      }
      if (mounted) {
        setState(
          () =>
              _items = (response['data'] as List).cast<Map<String, dynamic>>(),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = e is ApiException
              ? e.message
              : 'No fue posible consultar los planes.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Planes comerciales'),
      actions: [
        IconButton(
          onPressed: _loading ? null : _load,
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _loading ? null : () => _edit(),
      child: const Icon(Icons.add),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: TextButton(
              onPressed: _load,
              child: Text('$_error · Reintentar'),
            ),
          )
        : ListView(
            children: _items
                .map(
                  (p) => ListTile(
                    title: Text('${p['nombre']} (${p['codigo']})'),
                    subtitle: Text(
                      '${p['precioMensual']} / mes · ${p['maxVehiculos']} vehículos · ${p['activo'] == true ? 'Activo' : 'Inactivo'}',
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _edit(p),
                  ),
                )
                .toList(),
          ),
  );

  Future<void> _edit([Map<String, dynamic>? item]) async {
    final form = GlobalKey<FormState>();
    final code = TextEditingController(text: item?['codigo']?.toString());
    final name = TextEditingController(text: item?['nombre']?.toString());
    final price = TextEditingController(
      text: item?['precioMensual']?.toString() ?? '0',
    );
    final max = TextEditingController(
      text: item?['maxVehiculos']?.toString() ?? '1',
    );
    final flags = <String, bool>{
      for (final key in [
        'permiteMantenimiento',
        'permiteReservas',
        'permiteReportes',
        'permiteCuentasPorCobrar',
        'activo',
      ])
        key: item?[key] as bool? ?? key == 'activo',
    };
    const labels = {
      'permiteMantenimiento': 'Mantenimiento',
      'permiteReservas': 'Reservas',
      'permiteReportes': 'Reportes',
      'permiteCuentasPorCobrar': 'Cuentas por cobrar',
      'activo': 'Plan activo',
    };
    bool busy = false;
    String? error;
    try {
      final saved = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialog) => StatefulBuilder(
          builder: (dialog, update) => PopScope(
            canPop: !busy,
            child: AlertDialog(
              title: Text(item == null ? 'Crear plan' : 'Editar plan'),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: form,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: code,
                          enabled: !busy,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            labelText: 'Código',
                          ),
                          validator: (v) => v?.trim().isNotEmpty == true
                              ? null
                              : 'Obligatorio',
                        ),
                        TextFormField(
                          controller: name,
                          enabled: !busy,
                          maxLength: 150,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                          validator: (v) => v?.trim().isNotEmpty == true
                              ? null
                              : 'Obligatorio',
                        ),
                        TextFormField(
                          controller: price,
                          enabled: !busy,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Precio mensual',
                          ),
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            return n != null && n.isFinite && n >= 0
                                ? null
                                : 'Precio inválido';
                          },
                        ),
                        TextFormField(
                          controller: max,
                          enabled: !busy,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Máximo de vehículos',
                          ),
                          validator: (v) => (int.tryParse(v ?? '') ?? 0) > 0
                              ? null
                              : 'Debe ser mayor que cero',
                        ),
                        const Text(
                          'Cambiar capacidades afecta a todas las empresas asignadas a este plan.',
                        ),
                        for (final entry in flags.entries)
                          SwitchListTile(
                            title: Text(labels[entry.key]!),
                            value: entry.value,
                            onChanged: busy
                                ? null
                                : (v) => update(() => flags[entry.key] = v),
                          ),
                        if (error != null)
                          Text(
                            error!,
                            style: TextStyle(
                              color: Theme.of(dialog).colorScheme.error,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: busy ? null : () => Navigator.pop(dialog, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: busy
                      ? null
                      : () async {
                          if (!form.currentState!.validate()) return;
                          update(() {
                            busy = true;
                            error = null;
                          });
                          try {
                            final body = {
                              'codigo': code.text.trim(),
                              'nombre': name.text.trim(),
                              'precioMensual': double.parse(price.text),
                              'maxVehiculos': int.parse(max.text),
                              ...flags,
                            };
                            final response = item == null
                                ? await _api.postJson(_url, body)
                                : await _api.putJson(
                                    '$_url/${item['idPlan']}',
                                    body,
                                  );
                            if (response['success'] != true) {
                              throw const ApiException(
                                message: 'No se guardó el plan.',
                              );
                            }
                            if (dialog.mounted) Navigator.pop(dialog, true);
                          } catch (e) {
                            if (dialog.mounted) {
                              update(
                                () => error = e is ApiException
                                    ? e.message
                                    : 'No fue posible guardar el plan.',
                              );
                            }
                          } finally {
                            if (dialog.mounted) update(() => busy = false);
                          }
                        },
                  child: const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      );
      if (saved == true && mounted) await _load();
    } finally {
      for (final c in [code, name, price, max]) {
        c.dispose();
      }
    }
  }
}
