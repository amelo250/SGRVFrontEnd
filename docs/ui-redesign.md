# Rediseño de pantallas y filtros

## Alcance

Login, formularios, listados, tarjetas, detalles, diálogos y paneles adoptan los temas claro y oscuro existentes: superficies neutras, bordes sutiles, geometría compacta y tipografía coherente. Los componentes compartidos propagan el estilo a las páginas que ya los utilizan.

Los filtros comienzan cerrados y se muestran mediante **Filtros** en clientes, proveedores, pagos, gastos, mantenimientos, reservaciones, vehículos, rentas, calendario y configuración; contabilidad agrupa tipo, categoría y fechas. Las acciones de alta, conversión y exportación permanecen fuera del panel. Las pestañas de rentas y la navegación entre meses conservan su función de navegación.

El calendario conserva el panel abierto al recargar resultados y adapta las celdas de los días a pantallas pequeñas. El panel mantiene los controles montados para preservar texto y selección, restringe el foco cuando está cerrado y permite desplazar formularios de filtros largos. Los filtros siguen aplicándose con sus callbacks actuales; cerrar el panel no equivale a limpiar.

## Restricciones y patrones

No se encontró AGENTS.md en los dos repositorios ni en sus directorios superiores al inspeccionarlos. Se siguieron las restricciones expresas del usuario.

Se reutilizan AppModuleScaffold, AppSearchPanel, AppPageHeader, AppSectionCard, ThemeProvider y VehiculoFilterPanel. Sin dependencias nuevas.

No se modificaron modelos, DTOs, servicios, controladores, BaseEntity, DbContext, mapeos EF, migraciones, SQL ni datos en esta tarea. Los cambios locales anteriores permanecen y no deben atribuirse a este rediseño.

Autorización, JWT, roles, identificación de empresa, protección por ID y ApiResponse<T> conservan sus contratos y recorridos actuales. Las pruebas existentes de sesión y de respuestas API se ejecutan junto con las pruebas visuales. Esto no constituye una auditoría exhaustiva del backend.

## Limitaciones actuales

- Solo se reorganizan las opciones de filtrado que cada módulo ya soporta; no se agregan filtros nuevos al servidor.
- El antiguo checkbox Recordarme del login no se enviaba al servicio ni alteraba la sesión. Se retiró del formulario para no ofrecer una opción sin efecto. La política de sesión existente continúa igual.
- No se realizaron peticiones autenticadas contra datos reales en Swagger. Las comprobaciones siguientes quedan recomendadas.
- Cambios de modelos o base de datos sugeridos: ninguno. No se requieren para esta tarea.

## Validación

- Flutter analyze: sin incidencias en la comprobación final.
- Flutter test: 39 pruebas, incluyendo contraste, preferencia de tema, login móvil/escritorio, filtros, persistencia del panel del calendario durante recargas, sesiones, ApiResponse y pruebas funcionales existentes.
- Flutter build web --release --no-pub: compilación web de producción.
- dotnet build SGRVBackEnd.sln --no-restore con OutputPath separado: compilación correcta, cero errores. Advertencia NU1900 por falta de acceso a api.nuget.org. La salida habitual estaba bloqueada por el backend ejecutándose; no se detuvo el proceso. Los binarios de validación se movieron a SGRVBackEnd/bin/ui-validation.
- Inspección visual del login claro y oscuro a 360×800 y 1440×900 usando fuentes reales.

## Swagger: comprobaciones recomendadas (no ejecutadas)

1. POST /api/Auth/login con credenciales de prueba válidas y erróneas: conservar ApiResponse y emisión/rechazo de JWT.
2. Autorizar con JWT de una empresa A. GET /api/vehiculos y GET /api/clientes: solo resultados de A.
3. GET /api/vehiculos/{id} y GET /api/clientes/{id} usando IDs de una empresa B: no devolver registros ajenos (404 según los controladores inspeccionados).
4. GET /api/clientes?Search=texto&IncluirInactivos=false&PageNumber=1&PageSize=20 y las opciones de VehiculoSearchDto expuestas por Swagger: validar el mismo resultado y contrato con filtros.
5. Llamar a endpoints protegidos sin JWT o con token vencido y comprobar rechazo. Con usuarios de roles sin permisos administrativos, comprobar que las operaciones restringidas siguen denegadas, usando datos de prueba.
6. Validar búsqueda, fechas y paginación de los demás listados desde las opciones existentes en Swagger; no se modificaron sus rutas ni parámetros.

## Flutter: ajustes y verificación manual

Los cambios ya están integrados en el frontend; basta recompilar y recargar. No se requieren cambios de configuración, paquetes ni API.

Recorrer cada listado en claro y oscuro; abrir Filtros, buscar/seleccionar, cerrarlo y reabrirlo. Verificar persistencia de valores, resultados, limpieza, paginación y navegación a formularios. En móvil revisar desplazamiento de filtros largos y teclado; comprobar botones de crear/guardar/exportar. Probar acceso y recuperación de contraseña, estados de carga/error y cambio de tema persistente.

Para exportar vistas del login de forma opcional, ejecutar login_appearance_test.dart con SAVE_UI_PREVIEWS=true y configurar UI_PREVIEW_DIR, UI_FONT_PATH y UI_ICON_FONT_PATH según el equipo. Las pruebas normales no requieren esas opciones.

## Archivos creados

- `lib/shared/widgets/app_filter_panel.dart`
- `test/app_filter_panel_test.dart`
- `test/login_appearance_test.dart`
- `docs/ui-redesign.md`

## Archivos modificados en esta tarea

- `lib/features/administracion/pages/administracion_dashboard_page.dart`
- `lib/features/administracion/pages/usuario_admin_form_page.dart`
- `lib/features/administracion/pages/usuarios_admin_page.dart`
- `lib/features/auth/pages/login_page.dart`
- `lib/features/calendario/pages/calendario_page.dart`
- `lib/features/calendario/widgets/calendario_evento_card.dart`
- `lib/features/calendario/widgets/calendario_month_grid.dart`
- `lib/features/clientes/widgets/cliente_card.dart`
- `lib/features/clientes/widgets/documento_cliente_card.dart`
- `lib/features/configuracion/pages/configuracion_page.dart`
- `lib/features/configuracion/widgets/configuracion_catalogo_list.dart`
- `lib/features/contabilidad/pages/contabilidad_page.dart`
- `lib/features/dashboard/widgets/dashboard_quick_actions.dart`
- `lib/features/dashboard/widgets/dashboard_quick_actions_fab.dart`
- `lib/features/dashboard/widgets/dashboard_tasks_section.dart`
- `lib/features/empresas/pages/empresa_onboarding_page.dart`
- `lib/features/empresas/pages/empresa_page.dart`
- `lib/features/gastos/pages/gasto_detail_page.dart`
- `lib/features/gastos/widgets/gasto_card.dart`
- `lib/features/gastos/widgets/gasto_summary_cards.dart`
- `lib/features/mantenimientos/pages/mantenimientos_page.dart`
- `lib/features/pagos/pages/pago_detail_page.dart`
- `lib/features/pagos/pages/pago_form_page.dart`
- `lib/features/pagos/widgets/pago_card.dart`
- `lib/features/pagos/widgets/pago_status_chip.dart`
- `lib/features/pagos/widgets/pago_summary_card.dart`
- `lib/features/proveedores/pages/proveedor_vehiculo_form_page.dart`
- `lib/features/rentas/pages/renta_detail_page.dart`
- `lib/features/rentas/pages/renta_entrega_page.dart`
- `lib/features/rentas/pages/renta_form_page.dart`
- `lib/features/rentas/pages/renta_recepcion_page.dart`
- `lib/features/rentas/pages/rentas_page.dart`
- `lib/features/rentas/widgets/fuel_level_selector.dart`
- `lib/features/rentas/widgets/renta_card.dart`
- `lib/features/rentas/widgets/renta_financial_summary.dart`
- `lib/features/rentas/widgets/renta_history_card.dart`
- `lib/features/rentas/widgets/renta_status_chip.dart`
- `lib/features/vehiculos/pages/vehiculo_admin_page.dart`
- `lib/features/vehiculos/pages/vehiculo_form_page.dart`
- `lib/features/vehiculos/pages/vehiculos_page.dart`
- `lib/features/vehiculos/widgets/vehiculo_accesorios_section.dart`
- `lib/features/vehiculos/widgets/vehiculo_card.dart`
- `lib/features/vehiculos/widgets/vehiculo_feature_blocked.dart`
- `lib/features/vehiculos/widgets/vehiculo_filter_panel.dart`
- `lib/features/vehiculos/widgets/vehiculo_financial_summary.dart`
- `lib/features/vehiculos/widgets/vehiculo_galeria_section.dart`
- `lib/features/vehiculos/widgets/vehiculo_mantenimientos_section.dart`
- `lib/shared/colors/app_theme.dart`
- `lib/shared/widgets/app_module_ui.dart`
