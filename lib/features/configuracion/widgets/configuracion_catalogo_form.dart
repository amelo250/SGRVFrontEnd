import 'package:flutter/material.dart';
import '../models/configuracion_catalogo.dart';

class ConfiguracionCatalogoForm extends StatefulWidget {
  const ConfiguracionCatalogoForm({
    required this.definition,
    this.item,
    super.key,
  });

  final ConfiguracionCatalogoDefinition definition;
  final ConfiguracionCatalogoItem? item;

  @override
  State<ConfiguracionCatalogoForm> createState() =>
      _ConfiguracionCatalogoFormState();
}

class _ConfiguracionCatalogoFormState extends State<ConfiguracionCatalogoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codigo;
  late final TextEditingController _nombre;
  late final TextEditingController _categoria;
  late final TextEditingController _simbolo;
  late final TextEditingController _descripcion;
  late final TextEditingController _icono;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _codigo = TextEditingController(text: item?.codigo);
    _nombre = TextEditingController(text: item?.nombre);
    _categoria = TextEditingController(text: item?.categoria);
    _simbolo = TextEditingController(text: item?.simbolo);
    _descripcion = TextEditingController(text: item?.descripcion);
    _icono = TextEditingController(text: item?.icono);
  }

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    _categoria.dispose();
    _simbolo.dispose();
    _descripcion.dispose();
    _icono.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(widget.item == null ? Icons.add_rounded : Icons.edit_rounded),
      title: Text(widget.item == null ? 'Nuevo registro' : 'Editar registro'),
      content: SizedBox(
        width: 540,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _codigo,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Código',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Indica el código.'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.label_outline_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Indica el nombre.'
                      : null,
                ),
                if (widget.definition.usaCategoria) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _categoria,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Indica la categoría.'
                        : null,
                  ),
                ],
                if (widget.definition.usaSimbolo) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _simbolo,
                    decoration: const InputDecoration(
                      labelText: 'Símbolo',
                      prefixIcon: Icon(Icons.attach_money_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Indica el símbolo.'
                        : null,
                  ),
                ],
                if (widget.definition.esAccesorio) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descripcion,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _icono,
                    decoration: const InputDecoration(
                      labelText: 'Icono o referencia visual',
                      prefixIcon: Icon(Icons.extension_rounded),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.save_rounded),
          label: const Text('Guardar'),
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      ConfiguracionCatalogoDraft(
        codigo: _codigo.text.trim(),
        nombre: _nombre.text.trim(),
        categoria: _value(_categoria),
        simbolo: _value(_simbolo),
        descripcion: _value(_descripcion),
        icono: _value(_icono),
        rowVersion: widget.item?.rowVersion,
      ),
    );
  }

  String? _value(TextEditingController controller) =>
      controller.text.trim().isEmpty ? null : controller.text.trim();
}
