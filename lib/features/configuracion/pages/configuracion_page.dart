import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_module_ui.dart';
import '../models/configuracion_catalogo.dart';
import '../providers/configuracion_provider.dart';
import '../widgets/configuracion_catalogo_form.dart';
import '../widgets/configuracion_catalogo_list.dart';

class ConfiguracionPage extends StatefulWidget {
  const ConfiguracionPage({super.key});

  @override
  State<ConfiguracionPage> createState() => _ConfiguracionPageState();
}

class _ConfiguracionPageState extends State<ConfiguracionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ConfiguracionProvider>().initialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConfiguracionProvider>();
    return AppModuleScaffold(
      title: 'Configuración',
      subtitle: 'Administra los catálogos operativos y accesorios del sistema.',
      floatingActionButton: provider.selected == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(provider),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo registro'),
            ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (provider.definitions.isEmpty && provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return constraints.maxWidth >= 820
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 260, child: _catalogs(provider)),
                    const SizedBox(width: 18),
                    Expanded(child: _content(provider)),
                  ],
                )
              : Column(
                  children: [
                    _catalogSelector(provider),
                    const SizedBox(height: 14),
                    Expanded(child: _content(provider)),
                  ],
                );
        },
      ),
    );
  }

  Widget _catalogs(ConfiguracionProvider provider) => Card(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Catálogos',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ),
          ...provider.definitions.map(
            (definition) => ListTile(
              selected: provider.selected?.key == definition.key,
              selectedTileColor: const Color(0xFF3867F4).withValues(alpha: .09),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: Icon(_icon(definition.key)),
              title: Text(definition.nombre),
              onTap: () => provider.select(definition),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _catalogSelector(ConfiguracionProvider provider) =>
      DropdownButtonFormField<ConfiguracionCatalogoDefinition>(
        initialValue: provider.selected,
        decoration: const InputDecoration(
          labelText: 'Catálogo',
          prefixIcon: Icon(Icons.tune_rounded),
        ),
        items: provider.definitions
            .map(
              (item) => DropdownMenuItem(value: item, child: Text(item.nombre)),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) provider.select(value);
        },
      );

  Widget _content(ConfiguracionProvider provider) {
    final definition = provider.selected;
    if (definition == null) {
      return const AppStateView(
        icon: Icons.tune_rounded,
        title: 'Selecciona un catálogo',
      );
    }
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(_icon(definition.key), color: const Color(0xFF3867F4)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        definition.nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        definition.esGlobal
                            ? 'Catálogo global · Solo SUPADMIN puede modificarlo.'
                            : 'Catálogo privado de la empresa y opciones globales.',
                      ),
                    ],
                  ),
                ),
                FilterChip(
                  selected: provider.incluirInactivos,
                  label: const Text('Inactivos'),
                  avatar: const Icon(Icons.visibility_outlined, size: 18),
                  onSelected: provider.setIncludeInactive,
                ),
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: provider.refresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: _state(provider)),
      ],
    );
  }

  Widget _state(ConfiguracionProvider provider) {
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return AppStateView(
        icon: Icons.cloud_off_rounded,
        title: 'No se pudo cargar la configuración',
        message: provider.error,
        onRetry: provider.refresh,
      );
    }
    if (provider.items.isEmpty) {
      return const AppStateView(
        icon: Icons.inventory_2_outlined,
        title: 'No hay registros',
        message: 'Crea el primer registro de este catálogo.',
      );
    }
    return RefreshIndicator(
      onRefresh: provider.refresh,
      child: ConfiguracionCatalogoList(
        items: provider.items,
        onEdit: (item) => _openForm(provider, item),
        onToggle: (item) => _toggle(provider, item),
      ),
    );
  }

  Future<void> _openForm(
    ConfiguracionProvider provider, [
    ConfiguracionCatalogoItem? item,
  ]) async {
    if (item?.esGlobal == true && provider.selected?.esAccesorio == true) {
      return;
    }
    final draft = await showDialog<ConfiguracionCatalogoDraft>(
      context: context,
      builder: (_) =>
          ConfiguracionCatalogoForm(definition: provider.selected!, item: item),
    );
    if (draft == null || !mounted) return;
    final success = await provider.save(draft, id: item?.id);
    if (!success && mounted) _showError(provider);
  }

  Future<void> _toggle(
    ConfiguracionProvider provider,
    ConfiguracionCatalogoItem item,
  ) async {
    final success = await provider.setActive(item, !item.activo);
    if (!success && mounted) _showError(provider);
  }

  void _showError(ConfiguracionProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.error ?? 'No fue posible guardar los cambios.'),
      ),
    );
  }

  IconData _icon(String key) => switch (key) {
    'estados' => Icons.flag_outlined,
    'tipos' => Icons.category_outlined,
    'metodos-pago' => Icons.credit_card_rounded,
    'combustibles' => Icons.local_gas_station_rounded,
    'transmisiones' => Icons.settings_suggest_outlined,
    'monedas' => Icons.currency_exchange_rounded,
    'accesorios' => Icons.extension_rounded,
    _ => Icons.tune_rounded,
  };
}
