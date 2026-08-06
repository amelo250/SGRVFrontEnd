import 'package:flutter/material.dart';
import '../models/vehicle_catalog_option.dart';
import '../models/vehiculo_filter.dart';

class VehiculoFilterPanel extends StatelessWidget {
  const VehiculoFilterPanel({
    required this.filter,
    required this.types,
    required this.fuels,
    required this.brands,
    required this.onTypeChanged,
    required this.onFuelChanged,
    required this.onBrandChanged,
    required this.onClear,
    super.key,
  });

  final VehiculoFilter filter;
  final List<VehicleCatalogOption> types;
  final List<VehicleCatalogOption> fuels;
  final List<String> brands;
  final ValueChanged<int?> onTypeChanged;
  final ValueChanged<int?> onFuelChanged;
  final ValueChanged<String?> onBrandChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_alt_outlined),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Filtrar flota',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              if (!filter.isEmpty)
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.filter_alt_off_rounded),
                  label: const Text('Limpiar'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 780
                  ? (constraints.maxWidth - 28) / 3
                  : constraints.maxWidth;
              return Wrap(
                spacing: 14,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: width,
                    child: DropdownButtonFormField<int?>(
                      initialValue: filter.idTipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de vehículo',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Todos los tipos'),
                        ),
                        ...types.map(
                          (item) => DropdownMenuItem<int?>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        ),
                      ],
                      onChanged: onTypeChanged,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: DropdownButtonFormField<String?>(
                      initialValue: filter.marca,
                      decoration: const InputDecoration(
                        labelText: 'Marca',
                        prefixIcon: Icon(Icons.directions_car_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Todas las marcas'),
                        ),
                        ...brands.map(
                          (brand) => DropdownMenuItem<String?>(
                            value: brand,
                            child: Text(brand),
                          ),
                        ),
                      ],
                      onChanged: onBrandChanged,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: DropdownButtonFormField<int?>(
                      initialValue: filter.idCombustible,
                      decoration: const InputDecoration(
                        labelText: 'Combustible',
                        prefixIcon: Icon(Icons.local_gas_station_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Todos los combustibles'),
                        ),
                        ...fuels.map(
                          (item) => DropdownMenuItem<int?>(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        ),
                      ],
                      onChanged: onFuelChanged,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}
