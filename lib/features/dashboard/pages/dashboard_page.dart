import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sgrv_frontend/features/auth/pages/login_page.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/features/empresas/pages/empresa_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const Color _primaryColor = Color(0xFF3867F4);
  static const Color _secondaryColor = Color(0xFF7057F5);
  static const Color _darkColor = Color(0xFF081225);
  static const Color _darkSecondaryColor = Color(0xFF111D34);
  static const Color _backgroundColor = Color(0xFFF5F7FB);
  static const Color _surfaceColor = Colors.white;
  static const Color _textColor = Color(0xFF172033);
  static const Color _mutedColor = Color(0xFF7B8498);
  static const Color _borderColor = Color(0xFFE7EBF2);
  static const Color _successColor = Color(0xFF2EBE7E);
  static const Color _warningColor = Color(0xFFFFA52F);
  static const Color _dangerColor = Color(0xFFE94B4B);

  int _indiceSeleccionado = 0;

  final List<_MenuItem> _opcionesMenu = const [
    _MenuItem(titulo: 'Dashboard', icono: Icons.dashboard_rounded),
    _MenuItem(
      titulo: 'Reservas',
      icono: Icons.event_note_rounded,
      proximamente: true,
    ),
    _MenuItem(
      titulo: 'Vehículos',
      icono: Icons.directions_car_rounded,
      proximamente: true,
    ),
    _MenuItem(
      titulo: 'Clientes',
      icono: Icons.people_alt_rounded,
      proximamente: true,
    ),
    _MenuItem(
      titulo: 'Pagos',
      icono: Icons.payments_rounded,
      proximamente: true,
    ),
    _MenuItem(
      titulo: 'Calendario',
      icono: Icons.calendar_month_rounded,
      proximamente: true,
    ),
    _MenuItem(
      titulo: 'Reportes',
      icono: Icons.bar_chart_rounded,
      proximamente: true,
    ),
    _MenuItem(titulo: 'Empresas', icono: Icons.business_rounded),
    _MenuItem(
      titulo: 'Proveedores',
      icono: Icons.handshake_rounded,
      proximamente: true,
    ),
    _MenuItem(
      titulo: 'Configuración',
      icono: Icons.settings_rounded,
      proximamente: true,
    ),
  ];

  Future<void> _cerrarSesion(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    await authProvider.logout();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void _seleccionarOpcion(
    BuildContext context,
    int indice, {
    bool cerrarDrawer = false,
  }) {
    if (cerrarDrawer && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (indice == 7) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EmpresasPage()),
      );

      return;
    }

    setState(() {
      _indiceSeleccionado = indice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool esEscritorio = constraints.maxWidth >= 1050;
        final bool esTablet = constraints.maxWidth >= 700;

        return Scaffold(
          backgroundColor: _backgroundColor,
          drawer: esEscritorio
              ? null
              : Drawer(
                  backgroundColor: _darkColor,
                  child: SafeArea(
                    child: _Sidebar(
                      opciones: _opcionesMenu,
                      indiceSeleccionado: _indiceSeleccionado,
                      onSeleccionar: (indice) {
                        _seleccionarOpcion(context, indice, cerrarDrawer: true);
                      },
                      onCerrarSesion: () => _cerrarSesion(context),
                    ),
                  ),
                ),
          bottomNavigationBar: esTablet
              ? null
              : NavigationBar(
                  selectedIndex: _indiceSeleccionado.clamp(0, 3),
                  onDestinationSelected: (indice) {
                    _seleccionarOpcion(context, indice);
                  },
                  destinations: _opcionesMenu
                      .take(4)
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icono),
                          selectedIcon: Icon(item.icono, color: _primaryColor),
                          label: item.titulo,
                        ),
                      )
                      .toList(),
                ),
          body: Row(
            children: [
              if (esEscritorio)
                SizedBox(
                  width: 265,
                  child: _Sidebar(
                    opciones: _opcionesMenu,
                    indiceSeleccionado: _indiceSeleccionado,
                    onSeleccionar: (indice) {
                      _seleccionarOpcion(context, indice);
                    },
                    onCerrarSesion: () => _cerrarSesion(context),
                  ),
                ),
              Expanded(
                child: SafeArea(
                  child: Column(
                    children: [
                      _TopBar(
                        mostrarMenu: !esEscritorio,
                        titulo: _opcionesMenu[_indiceSeleccionado].titulo,
                        onCerrarSesion: () => _cerrarSesion(context),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(esEscritorio ? 28 : 18),
                          child: _construirContenido(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construirContenido() {
    if (_indiceSeleccionado == 0) {
      return const _ContenidoDashboard();
    }

    final opcion = _opcionesMenu[_indiceSeleccionado];

    return _PaginaProximamente(titulo: opcion.titulo, icono: opcion.icono);
  }
}

class _Sidebar extends StatelessWidget {
  final List<_MenuItem> opciones;
  final int indiceSeleccionado;
  final ValueChanged<int> onSeleccionar;
  final VoidCallback onCerrarSesion;

  const _Sidebar({
    required this.opciones,
    required this.indiceSeleccionado,
    required this.onSeleccionar,
    required this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _DashboardPageState._darkColor,
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 20),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: _LogoSGRV(),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              itemCount: opciones.length,
              separatorBuilder: (_, __) {
                return const SizedBox(height: 4);
              },
              itemBuilder: (context, indice) {
                final opcion = opciones[indice];
                final bool seleccionada = indice == indiceSeleccionado;

                return Material(
                  color: seleccionada
                      ? _DashboardPageState._primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(13),
                    onTap: () => onSeleccionar(indice),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            opcion.icono,
                            size: 21,
                            color: seleccionada
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.72),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              opcion.titulo,
                              style: TextStyle(
                                color: seleccionada
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.78),
                                fontWeight: seleccionada
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (opcion.proximamente)
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: _DashboardPageState._warningColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _DashboardPageState._darkSecondaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: _DashboardPageState._primaryColor,
                  child: Text(
                    'EM',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enmanuel Melo',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Administrador',
                        style: TextStyle(
                          color: _DashboardPageState._mutedColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onCerrarSesion,
                  tooltip: 'Cerrar sesión',
                  icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool mostrarMenu;
  final String titulo;
  final VoidCallback onCerrarSesion;

  const _TopBar({
    required this.mostrarMenu,
    required this.titulo,
    required this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: _DashboardPageState._borderColor),
        ),
      ),
      child: Row(
        children: [
          if (mostrarMenu)
            Builder(
              builder: (context) {
                return IconButton(
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                  icon: const Icon(Icons.menu_rounded),
                  tooltip: 'Abrir menú',
                );
              },
            ),
          if (mostrarMenu) const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: _DashboardPageState._textColor,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Resumen general de tu negocio',
                  style: TextStyle(
                    color: _DashboardPageState._mutedColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 290),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Buscar...',
                prefixIcon: Icon(Icons.search_rounded),
                isDense: true,
                filled: true,
                fillColor: Color(0xFFF8FAFD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: _DashboardPageState._borderColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                  borderSide: BorderSide(
                    color: _DashboardPageState._borderColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            onPressed: () {},
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_none_rounded),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            tooltip: 'Opciones de usuario',
            onSelected: (value) {
              if (value == 'logout') {
                onCerrarSesion();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'perfil',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline_rounded),
                      SizedBox(width: 10),
                      Text('Mi perfil'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: _DashboardPageState._dangerColor,
                      ),
                      SizedBox(width: 10),
                      Text('Cerrar sesión'),
                    ],
                  ),
                ),
              ];
            },
            child: const CircleAvatar(
              backgroundColor: Color(0xFFE9EEFF),
              child: Icon(
                Icons.person_rounded,
                color: _DashboardPageState._primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContenidoDashboard extends StatelessWidget {
  const _ContenidoDashboard();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double ancho = constraints.maxWidth;

        final int columnas = ancho >= 1300
            ? 4
            : ancho >= 700
            ? 2
            : 1;

        const double separacion = 16;

        final double anchoTarjeta =
            (ancho - separacion * (columnas - 1)) / columnas;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: separacion,
              runSpacing: separacion,
              children: [
                SizedBox(
                  width: anchoTarjeta,
                  child: const _TarjetaKpi(
                    titulo: 'Reservas hoy',
                    valor: '12',
                    porcentaje: '+20%',
                    icono: Icons.event_available_rounded,
                    color: _DashboardPageState._secondaryColor,
                  ),
                ),
                SizedBox(
                  width: anchoTarjeta,
                  child: const _TarjetaKpi(
                    titulo: 'Vehículos alquilados',
                    valor: '28',
                    porcentaje: '+15%',
                    icono: Icons.directions_car_rounded,
                    color: _DashboardPageState._successColor,
                  ),
                ),
                SizedBox(
                  width: anchoTarjeta,
                  child: const _TarjetaKpi(
                    titulo: 'Ingresos hoy',
                    valor: 'RD\$ 125,430',
                    porcentaje: '+18%',
                    icono: Icons.attach_money_rounded,
                    color: _DashboardPageState._warningColor,
                  ),
                ),
                SizedBox(
                  width: anchoTarjeta,
                  child: const _TarjetaKpi(
                    titulo: 'Clientes activos',
                    valor: '342',
                    porcentaje: '+12%',
                    icono: Icons.groups_rounded,
                    color: _DashboardPageState._primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (ancho >= 970)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _TarjetaIngresos()),
                  SizedBox(width: 18),
                  Expanded(flex: 5, child: _TarjetaReservas()),
                ],
              )
            else
              const Column(
                children: [
                  _TarjetaIngresos(),
                  SizedBox(height: 18),
                  _TarjetaReservas(),
                ],
              ),
            const SizedBox(height: 18),
            if (ancho >= 970)
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TarjetaCategorias()),
                  SizedBox(width: 18),
                  Expanded(child: _TarjetaProximasReservas()),
                  SizedBox(width: 18),
                  Expanded(child: _TarjetaActividad()),
                ],
              )
            else
              const Column(
                children: [
                  _TarjetaCategorias(),
                  SizedBox(height: 18),
                  _TarjetaProximasReservas(),
                  SizedBox(height: 18),
                  _TarjetaActividad(),
                ],
              ),
          ],
        );
      },
    );
  }
}

class _TarjetaKpi extends StatelessWidget {
  final String titulo;
  final String valor;
  final String porcentaje;
  final IconData icono;
  final Color color;

  const _TarjetaKpi({
    required this.titulo,
    required this.valor,
    required this.porcentaje,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icono, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: _DashboardPageState._mutedColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valor,
                    style: const TextStyle(
                      color: _DashboardPageState._textColor,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$porcentaje vs ayer',
                  style: const TextStyle(
                    color: _DashboardPageState._successColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaIngresos extends StatelessWidget {
  const _TarjetaIngresos();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Ingresos',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              Chip(label: Text('Este mes')),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'RD\$ 1,250,430',
            style: TextStyle(
              color: _DashboardPageState._textColor,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '+18.6% vs mes anterior',
            style: TextStyle(
              color: _DashboardPageState._successColor,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 245,
            width: double.infinity,
            child: CustomPaint(painter: _GraficoIngresosPainter()),
          ),
        ],
      ),
    );
  }
}

class _GraficoIngresosPainter extends CustomPainter {
  final List<double> valores = const [
    0.14,
    0.20,
    0.18,
    0.31,
    0.28,
    0.45,
    0.49,
    0.35,
    0.52,
    0.40,
    0.61,
    0.70,
    0.56,
    0.66,
    0.58,
    0.72,
    0.76,
    0.68,
    0.81,
    0.77,
    0.66,
    0.72,
    0.69,
    0.74,
    0.70,
    0.89,
    0.98,
    0.92,
    1.0,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint pinturaCuadricula = Paint()
      ..color = _DashboardPageState._borderColor
      ..strokeWidth = 1;

    final Paint pinturaLinea = Paint()
      ..color = _DashboardPageState._primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < 5; i++) {
      final double y = size.height * i / 4;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), pinturaCuadricula);
    }

    final Path path = Path();

    for (int i = 0; i < valores.length; i++) {
      final double x = size.width * i / (valores.length - 1);

      final double y = size.height - (valores[i] * (size.height - 16)) - 8;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, pinturaLinea);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _TarjetaReservas extends StatelessWidget {
  const _TarjetaReservas();

  static const List<_ReservaDashboard> reservas = [
    _ReservaDashboard(
      vehiculo: 'Toyota RAV4 2021',
      cliente: 'Juan Pérez',
      estado: 'Confirmada',
      color: _DashboardPageState._successColor,
    ),
    _ReservaDashboard(
      vehiculo: 'Hyundai Tucson 2020',
      cliente: 'María García',
      estado: 'En proceso',
      color: _DashboardPageState._primaryColor,
    ),
    _ReservaDashboard(
      vehiculo: 'Kia Sportage 2022',
      cliente: 'Carlos Rodríguez',
      estado: 'Pendiente',
      color: _DashboardPageState._warningColor,
    ),
    _ReservaDashboard(
      vehiculo: 'Nissan X-Trail 2021',
      cliente: 'Laura Martínez',
      estado: 'Confirmada',
      color: _DashboardPageState._successColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Reservas recientes',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                'Ver todas',
                style: TextStyle(
                  color: _DashboardPageState._primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          ...reservas.map((reserva) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F3F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: _DashboardPageState._primaryColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reserva.vehiculo,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reserva.cliente,
                          style: const TextStyle(
                            color: _DashboardPageState._mutedColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: reserva.color.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      reserva.estado,
                      style: TextStyle(
                        color: reserva.color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _TarjetaCategorias extends StatelessWidget {
  const _TarjetaCategorias();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehículos por categoría',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 22),
          Center(
            child: SizedBox(
              width: 125,
              height: 125,
              child: CircularProgressIndicator(
                value: 0.72,
                strokeWidth: 22,
                backgroundColor: Color(0xFFE8EDF8),
                color: _DashboardPageState._primaryColor,
              ),
            ),
          ),
          SizedBox(height: 24),
          _Leyenda(
            color: _DashboardPageState._primaryColor,
            texto: 'SUV',
            valor: '45%',
          ),
          _Leyenda(
            color: _DashboardPageState._successColor,
            texto: 'Sedán',
            valor: '30%',
          ),
          _Leyenda(
            color: _DashboardPageState._warningColor,
            texto: 'Camionetas',
            valor: '15%',
          ),
          _Leyenda(
            color: _DashboardPageState._secondaryColor,
            texto: 'Compactos',
            valor: '10%',
          ),
        ],
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String texto;
  final String valor;

  const _Leyenda({
    required this.color,
    required this.texto,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 9),
          Expanded(child: Text(texto)),
          Text(
            valor,
            style: const TextStyle(color: _DashboardPageState._mutedColor),
          ),
        ],
      ),
    );
  }
}

class _TarjetaProximasReservas extends StatelessWidget {
  const _TarjetaProximasReservas();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Próximas reservas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 16),
          _ElementoLista(
            icono: Icons.directions_car,
            titulo: 'Toyota Land Cruiser 2022',
            subtitulo: 'Mañana · 09:00 AM',
          ),
          _ElementoLista(
            icono: Icons.directions_car,
            titulo: 'Ford Explorer 2021',
            subtitulo: '24 Jul · 02:00 PM',
          ),
          _ElementoLista(
            icono: Icons.directions_car,
            titulo: 'Chevrolet Tahoe 2022',
            subtitulo: '25 Jul · 10:30 AM',
          ),
        ],
      ),
    );
  }
}

class _TarjetaActividad extends StatelessWidget {
  const _TarjetaActividad();

  @override
  Widget build(BuildContext context) {
    return const _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad reciente',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 16),
          _ElementoLista(
            icono: Icons.event_available,
            titulo: 'Nueva reserva creada',
            subtitulo: 'Hace 5 min',
          ),
          _ElementoLista(
            icono: Icons.payments,
            titulo: 'Pago recibido',
            subtitulo: 'Hace 15 min',
          ),
          _ElementoLista(
            icono: Icons.assignment_return,
            titulo: 'Vehículo devuelto',
            subtitulo: 'Hace 1 h',
          ),
        ],
      ),
    );
  }
}

class _ElementoLista extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;

  const _ElementoLista({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE9EEFF),
            child: Icon(
              icono,
              color: _DashboardPageState._primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    color: _DashboardPageState._mutedColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginaProximamente extends StatelessWidget {
  final String titulo;
  final IconData icono;

  const _PaginaProximamente({required this.titulo, required this.icono});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: SizedBox(
        height: 430,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 95,
                height: 95,
                decoration: BoxDecoration(
                  color: _DashboardPageState._primaryColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(
                  icono,
                  size: 50,
                  color: _DashboardPageState._primaryColor,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Este módulo está preparado para conectarse con tu API.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _DashboardPageState._mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _DashboardPageState._surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _DashboardPageState._borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A101828),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LogoSGRV extends StatelessWidget {
  const _LogoSGRV();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [_DashboardPageState._secondaryColor, Color(0xFF2F9DFF)],
            ),
          ),
          child: const Icon(
            Icons.directions_car_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SGRV',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              'RENT CAR',
              style: TextStyle(
                color: Color(0xFF58B8FF),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuItem {
  final String titulo;
  final IconData icono;
  final bool proximamente;

  const _MenuItem({
    required this.titulo,
    required this.icono,
    this.proximamente = false,
  });
}

class _ReservaDashboard {
  final String vehiculo;
  final String cliente;
  final String estado;
  final Color color;

  const _ReservaDashboard({
    required this.vehiculo,
    required this.cliente,
    required this.estado,
    required this.color,
  });
}
