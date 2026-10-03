# Prueba de SGRV en Android por USB

La APK utiliza `http://127.0.0.1:5083` y requiere un túnel USB hacia la API del PC. No utiliza la dirección de emulador `10.0.2.2`. La URL queda incorporada al compilar; cambiarla requiere generar e instalar otra APK.

## 1. Preparar el teléfono

1. En Ajustes > Acerca del teléfono, pulsa siete veces Número de compilación (la ubicación varía según fabricante).
2. En Opciones de desarrollador, activa Depuración USB.
3. Conecta el teléfono al PC con un cable de datos, desbloquéalo y acepta la autorización RSA de depuración.
4. En PowerShell ejecuta:

```powershell
$adbSgrv = 'C:\Users\amelo\AppData\Local\Android\sdk\platform-tools\adb.exe'
& $adbSgrv devices -l
```

Debe aparecer con estado `device`. Si aparece `unauthorized`, acepta el mensaje del teléfono. Si no aparece, prueba un cable de datos, otro puerto o el controlador USB oficial del fabricante. Los siguientes comandos asumen un solo dispositivo USB; con varios, usa `-s SERIAL` en lugar de `-d`.

## 2. Iniciar la API

En otra ventana de PowerShell, mantén este proceso ejecutándose:

```powershell
Set-Location 'C:\Users\amelo\source\repos\SGRVBackEnd'
dotnet run --project .\SGRVBackEnd\SGRVBackEnd.csproj --launch-profile http
```

Si la API ya está iniciada en el puerto 5083, utiliza esa instancia. Comprueba `http://localhost:5083/swagger` en el PC. Se requieren la configuración local existente de JWT y acceso a SQL Server; no se crean ni alteran datos para configurar la APK.

## 3. Crear el túnel e instalar

En la ventana donde definiste `$adbSgrv`:

```powershell
& $adbSgrv -d reverse tcp:5083 tcp:5083
& $adbSgrv -d reverse --list
& $adbSgrv -d install -r 'C:\Users\amelo\source\repos\sgrv_frontend\build\app\outputs\flutter-apk\app-release.apk'
```

Espera `Success` y abre `sgrv_frontend` en el teléfono. El túnel puede perderse al desconectar o reiniciar: vuelve a ejecutar `reverse` al reconectar. No necesitas abrir puertos del firewall ni compartir Wi-Fi. Puedes abrir `http://127.0.0.1:5083/swagger` en el navegador del teléfono para comprobar el túnel.

Si aparece `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, hay una instalación firmada con otra clave. No la desinstales sin decidir antes si puedes perder sus datos locales; utiliza la firma original o un teléfono de prueba limpio.

## 4. Recompilar

```powershell
Set-Location 'C:\Users\amelo\source\repos\sgrv_frontend'
flutter build apk --release --dart-define=API_BASE_URL=http://127.0.0.1:5083
```

El proyecto ya incluye permiso INTERNET y HTTP local. La compilación release utiliza la clave debug configurada en Gradle: esta entrega es para pruebas locales, no para publicación. No se incorporan credenciales al comando ni se agregan dependencias.

## 5. Comprobaciones

- En Android: iniciar sesión con un usuario de prueba existente, consultar clientes/vehículos, navegar, cerrar sesión y volver a entrar. Probar fotos y PDF si forman parte del uso previsto.
- En Swagger: `POST /api/Auth/login` con credenciales de prueba y verificar `success`, `message`, `data` y token. Introducir solo el token en Authorize.
- Consultar endpoints protegidos sin token o con token vencido: esperar 401 y el formato `ApiResponse<T>`; verificar 403 para roles sin autorización donde corresponda.
- Con usuarios existentes de dos empresas, comprobar que los listados solo muestran la empresa autenticada. Solicitar por ID un recurso de la otra empresa: no debe revelar sus datos (403/404 según contrato).
- No ejecutar escrituras sobre datos reales. Probar altas, cambios y eliminación lógica únicamente en un entorno de pruebas autorizado.

No se modifican modelos, DbContext, migraciones, SQL, roles, filtros por empresa ni contratos de API. No se requieren cambios de modelo o base de datos. Estas comprobaciones funcionales requieren el teléfono y credenciales; compilar no las reemplaza.

## Referencias

- [Android: configurar un dispositivo físico](https://developer.android.com/studio/run/device)
- [Flutter: generar APK](https://docs.flutter.dev/deployment/android)
