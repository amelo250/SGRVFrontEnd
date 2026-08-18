import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/empresas/providers/empresa_provider.dart';

class EmpresaOnboardingPage extends StatefulWidget {
  const EmpresaOnboardingPage({super.key});
  @override
  State<EmpresaOnboardingPage> createState() => _EmpresaOnboardingPageState();
}

class _EmpresaOnboardingPageState extends State<EmpresaOnboardingPage> {
  final _key = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _comercial = TextEditingController();
  final _rnc = TextEditingController();
  final _plan = TextEditingController(text: '1');
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _direccion = TextEditingController();
  XFile? _logo;

  @override
  void dispose() {
    for (final controller in [
      _nombre,
      _comercial,
      _rnc,
      _plan,
      _telefono,
      _correo,
      _direccion,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmpresaProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding de empresa')),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Crea la organización',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Registra la identidad que aparecerá en el dashboard.',
                        ),
                        const SizedBox(height: 22),
                        OutlinedButton.icon(
                          onPressed: _pick,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: Text(
                            _logo?.name ?? 'Seleccionar logo (JPG, PNG o WebP)',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _field(_nombre, 'Nombre legal'),
                        _field(_comercial, 'Nombre comercial'),
                        _field(_rnc, 'RNC'),
                        _field(_plan, 'ID del plan', number: true),
                        _field(_telefono, 'Teléfono', required: false),
                        _field(_correo, 'Correo', required: false),
                        _field(
                          _direccion,
                          'Dirección',
                          required: false,
                          lines: 2,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: provider.isLoading ? null : _save,
                          icon: provider.isLoading
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.rocket_launch_outlined),
                          label: const Text('Crear empresa'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
    bool number = false,
    int lines = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      maxLines: lines,
      keyboardType: number ? TextInputType.number : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (required && (value?.trim().isEmpty ?? true)) {
          return 'Campo obligatorio';
        }
        if (number && (int.tryParse(value ?? '') ?? 0) <= 0) {
          return 'Introduce un ID válido';
        }
        return null;
      },
    ),
  );

  Future<void> _pick() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1600,
    );
    if (file != null && mounted) setState(() => _logo = file);
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    if (_logo == null) {
      _message('Selecciona el logo de la empresa.');
      return;
    }
    final name = _logo!.name.toLowerCase();
    final type = name.endsWith('.png')
        ? 'image/png'
        : name.endsWith('.webp')
        ? 'image/webp'
        : 'image/jpeg';
    final ok = await context.read<EmpresaProvider>().onboarding(
      logo: await _logo!.readAsBytes(),
      fileName: _logo!.name,
      contentType: type,
      nombre: _nombre.text.trim(),
      nombreComercial: _comercial.text.trim(),
      rnc: _rnc.text.trim(),
      idPlan: int.parse(_plan.text),
      telefono: _telefono.text,
      correo: _correo.text,
      direccion: _direccion.text,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, true);
    } else {
      _message(
        context.read<EmpresaProvider>().errorMessage ??
            'No fue posible crear la empresa.',
      );
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
}
