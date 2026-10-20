# Firma de contratos en modal e identidad web

## Comportamiento

El componente compartido SignaturePad muestra una vista previa y abre el editor al pulsar Firmar o Editar firma. Esto aplica a cliente y agente en entrega y recepción sin modificar las páginas consumidoras.

El editor se centra en escritorio, con un máximo de 900 × 640 y márgenes de 24. En anchos inferiores a 700, o dispositivos Android/iOS pequeños en horizontal, ocupa la pantalla completa y respeta las áreas seguras. Incluye Guardar firma, Limpiar y Cancelar. El tema del contenedor sigue el tema de la aplicación; el lienzo se mantiene blanco para los PDF.

Guardar firma exporta el lienzo como PNG y actualiza exclusivamente la vista previa del formulario. Limpiar borra el borrador del modal. Cancelar o volver no sustituye una firma previa. No se permite guardar un lienzo vacío. Los controles se bloquean durante la exportación. Las coordenadas de los trazos son proporcionales al lienzo para adaptarse al cambio de tamaño.

Se sustituyeron el favicon y los cuatro iconos de instalación web de Flutter por un símbolo de vehículo SGRV, con fuente SVG. El título, la descripción y el nombre de instalación se identifican como SGRV. Las referencias PNG incluyen una versión para renovar la caché del icono.

## Inspección y alcance

No se encontró AGENTS.md en ninguno de los dos repositorios ni en sus directorios superiores. Se siguieron las restricciones explícitas del usuario.

Patrones utilizados: SignaturePad y su exportación PNG existentes; showDialog y PopScope del diálogo de notificación de contratos. No se agregaron dependencias.

No se modificaron modelos, BaseEntity, DbContext, configuraciones EF, migraciones, SQL ni datos. Tampoco se editaron servicios, DTOs, controladores ni lógica de autenticación. Los cambios locales previos se conservaron.

## Limitaciones y compatibilidad

- Guardar firma no persiste el contrato en el servidor. Debe completarse Guardar formulario, como antes.
- Se mantiene la interfaz SignaturePadState.isEmpty, clear() y exportPng(), y el formato Uint8List PNG consumido por ambos generadores de PDF.
- No se agregaron campos ni almacenamiento de firmas separados. La edición se realiza sobre el PNG y los nuevos trazos del borrador.
- JWT, roles ADMIN/SUPADMIN, GetEmpresaId(), servicios asíncronos y respuestas ApiResponse<T> continúan en los recorridos existentes. La descarga de contenido conserva su respuesta PDF.
- Cambios de modelos o base de datos sugeridos y no realizados: ninguno; no son necesarios.

## Validación

- Análisis Flutter sin incidencias.
- Pruebas de firma: modal centrado en claro/oscuro, pantalla completa móvil vertical/horizontal, rechazo de firma vacía, PNG con trazos reales, guardado sin cambios, cancelar sin sustituir la firma y estados independientes del cliente/agente.
- Suite completa de Flutter: 44 pruebas.
- Compilación web de producción: flutter build web --release --no-pub.
- Backend: dotnet build SGRVBackEnd.sln --no-restore con salida SGRVBackEnd/bin/signature-validation: correcto, cero errores. Advertencia NU1900 por no poder consultar api.nuget.org. No se detuvo el backend que estaba en ejecución.
- Verificación de los cinco PNG: tamaños correctos, archivos sustituidos y referencias del manifiesto válidas.

## Swagger: pruebas recomendadas, no ejecutadas

Usar una empresa y rentas de prueba, sin sobrescribir documentos reales.

1. Con JWT autorizado, GET /api/rentas/{id}/entrega y los metadatos GET /api/rentas/{id}/documento-entrega y /documento-recepcion: conservar sus DTOs y ApiResponse<T>.
2. Guardar desde Flutter un documento de prueba con ambas firmas; comprobar POST /api/rentas/{id}/documento-entrega y /documento-recepcion con el multipart existente. Abrir los PDF mediante GET en /contenido y verificar que incluyen las firmas.
3. Repetir las consultas con JWT de otra empresa y el mismo ID: no debe accederse a información ajena. Los controladores inspeccionados pasan GetEmpresaId() a los servicios.
4. Sin JWT o con token vencido, comprobar rechazo de endpoints protegidos. Con un rol sin ADMIN/SUPADMIN, comprobar denegación del guardado.
5. Con datos de prueba, enviar un archivo vacío o inválido y verificar la validación de la API sin alterar el contrato de respuesta.

## Ajustes y comprobaciones Flutter

No se requieren dependencias, configuración ni cambios en las páginas consumidoras. Recompilar y desplegar build/web. Recargar la pestaña; si el navegador conserva una miniatura previa, realizar una recarga completa. Una aplicación web instalada puede requerir actualizar su instalación para renovar el icono.

Comprobar manualmente entrega y recepción: firmar cliente y agente, guardar, reabrir, limpiar, cancelar y guardar el formulario. Revisar ratón, entrada táctil, rotación del dispositivo y ambos temas. Comprobar favicon de pestaña e icono al instalar la web.

## Archivos creados

- test/signature_pad_test.dart
- web/icons/sgrv.svg
- docs/signature-modal.md

## Archivos modificados

- lib/features/rentas/widgets/signature_pad.dart
- web/index.html
- web/manifest.json
- web/favicon.png
- web/icons/Icon-192.png
- web/icons/Icon-512.png
- web/icons/Icon-maskable-192.png
- web/icons/Icon-maskable-512.png
