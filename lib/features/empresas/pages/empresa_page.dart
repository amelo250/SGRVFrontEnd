import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/empresas/providers/empresa_provider.dart';

class EmpresasPage extends StatefulWidget {
  const EmpresasPage({super.key});

  @override
  State<EmpresasPage> createState() => _EmpresasPageState();
}

class _EmpresasPageState extends State<EmpresasPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmpresaProvider>().cargarEmpresas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmpresaProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Empresas')),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.cargarEmpresas,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.empresas.isEmpty) {
            return const Center(child: Text('No hay empresas registradas.'));
          }

          return RefreshIndicator(
            onRefresh: provider.cargarEmpresas,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.empresas.length,
              itemBuilder: (context, index) {
                final empresa = provider.empresas[index];

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        empresa.nombre.isNotEmpty
                            ? empresa.nombre[0].toUpperCase()
                            : '?',
                      ),
                    ),
                    title: Text(empresa.nombre),
                    subtitle: Text(empresa.RNC ?? 'Sin RNC'),
                    trailing: Icon(
                      empresa.activo ? Icons.check_circle : Icons.cancel,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
