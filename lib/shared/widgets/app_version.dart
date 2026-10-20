import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// El manifiesto empaquetado es la única fuente de versión comercial.
class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  static String? _cached;
  static Future<String> get value => _cached != null ? Future.value(_cached!) : rootBundle
      .loadString('pubspec.yaml')
      .then(
        (manifest) => _cached =
            RegExp(
              r'^version:\s*([^\s+]+)',
              multiLine: true,
            ).firstMatch(manifest)?.group(1) ??
            '',
      );

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
    future: value,
    builder: (context, snapshot) => Text(
      snapshot.hasData && snapshot.data!.isNotEmpty ? 'V${snapshot.data}' : '',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}
