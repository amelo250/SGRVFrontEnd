import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sgrv_frontend/features/auth/pages/login_page.dart';
import 'package:sgrv_frontend/features/auth/providers/auth_provider.dart';
import 'package:sgrv_frontend/shared/colors/app_theme.dart';
import 'package:sgrv_frontend/shared/theme/theme_provider.dart';
import 'package:sgrv_frontend/shared/widgets/app_version.dart';

void main() {
  setUpAll(() async {
    if (!const bool.fromEnvironment('SAVE_UI_PREVIEWS')) return;
    const fonts = {
      'Arial': String.fromEnvironment('UI_FONT_PATH'),
      'MaterialIcons': String.fromEnvironment('UI_ICON_FONT_PATH'),
    };
    for (final font in fonts.entries) {
      if (font.value.isEmpty) continue;
      final loader = FontLoader(font.key);
      loader.addFont(
        File(
          font.value,
        ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
      );
      await loader.load();
    }
  });
  for (final dark in [false, true]) {
    for (final size in [const Size(360, 800), const Size(1440, 900)]) {
      testWidgets('Login legible y validado: oscuro=$dark, tamaño=$size', (
        tester,
      ) async {
        SharedPreferences.setMockInitialValues({});
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final appearance = ThemeProvider();
        await appearance.setDarkMode(dark);
        await tester.runAsync(() => AppVersion.value);
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AuthProvider()),
              ChangeNotifierProvider.value(value: appearance),
            ],
            child: Consumer<ThemeProvider>(
              builder: (_, value, _) => MaterialApp(
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: value.themeMode,
                home: const RepaintBoundary(
                  key: ValueKey('login-preview'),
                  child: LoginPage(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        if (const bool.fromEnvironment('SAVE_UI_PREVIEWS')) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const ValueKey('login-preview')),
          );
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final data = await image.toByteData(format: ui.ImageByteFormat.png);
            const directory = String.fromEnvironment(
              'UI_PREVIEW_DIR',
              defaultValue: 'build/ui-previews',
            );
            final file = File(
              '$directory/login-${dark ? 'dark' : 'light'}-${size.width.toInt()}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(data!.buffer.asUint8List());
            image.dispose();
          });
        }
        expect(find.text('Bienvenido de vuelta'), findsOneWidget);
        expect(find.textContaining('By Nicoretech'), findsOneWidget);
        expect(find.text('V1.2.0'), findsOneWidget);
        expect(
          Theme.of(tester.element(find.byType(Form))).brightness,
          dark ? Brightness.dark : Brightness.light,
        );
        await tester.ensureVisible(find.text('Iniciar sesión'));
        await tester.tap(find.text('Iniciar sesión'));
        await tester.pumpAndSettle();
        expect(find.text('Introduce el correo.'), findsOneWidget);
        expect(find.text('Introduce la contraseña.'), findsOneWidget);
        final toggle = find.byTooltip(
          dark ? 'Activar tema claro' : 'Activar tema oscuro',
        );
        await tester.ensureVisible(toggle);
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect(appearance.isDarkMode, !dark);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
