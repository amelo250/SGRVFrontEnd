import 'package:flutter/foundation.dart';
import '../models/configuracion_catalogo.dart';
import '../services/configuracion_service.dart';

class ConfiguracionProvider extends ChangeNotifier {
  ConfiguracionProvider({ConfiguracionService? service})
    : _service = service ?? ConfiguracionService();

  final ConfiguracionService _service;
  List<ConfiguracionCatalogoDefinition> definitions = const [];
  List<ConfiguracionCatalogoItem> items = const [];
  ConfiguracionCatalogoDefinition? selected;
  bool incluirInactivos = false;
  bool loading = false;
  bool saving = false;
  String? error;

  Future<void> initialize() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      definitions = await _service.getDefinitions();
      selected ??= definitions.isEmpty ? null : definitions.first;
      if (selected != null) {
        items = await _service.getItems(
          selected!,
          incluirInactivos: incluirInactivos,
        );
      }
    } catch (exception) {
      error = _message(exception);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> select(ConfiguracionCatalogoDefinition definition) async {
    selected = definition;
    await refresh();
  }

  Future<void> setIncludeInactive(bool value) async {
    incluirInactivos = value;
    await refresh();
  }

  Future<void> refresh() async {
    final definition = selected;
    if (definition == null) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _service.getItems(
        definition,
        incluirInactivos: incluirInactivos,
      );
    } catch (exception) {
      error = _message(exception);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> save(ConfiguracionCatalogoDraft draft, {int? id}) async {
    final definition = selected;
    if (definition == null) return false;
    saving = true;
    error = null;
    notifyListeners();
    try {
      if (id == null) {
        await _service.create(definition, draft);
      } else {
        await _service.update(definition, id, draft);
      }
      await refresh();
      return true;
    } catch (exception) {
      error = _message(exception);
      return false;
    } finally {
      saving = false;
      notifyListeners();
    }
  }

  Future<bool> setActive(ConfiguracionCatalogoItem item, bool active) async {
    final definition = selected;
    if (definition == null || (definition.esAccesorio && item.esGlobal)) {
      return false;
    }
    try {
      await _service.setActive(definition, item.id, active);
      await refresh();
      return true;
    } catch (exception) {
      error = _message(exception);
      notifyListeners();
      return false;
    }
  }

  String _message(Object exception) =>
      exception.toString().replaceFirst('Exception: ', '');
}
