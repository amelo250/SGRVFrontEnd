import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:sgrv_frontend/shared/colors/app_theme.dart';

double contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return (a > b ? a + .05 : b + .05) / (a > b ? b + .05 : a + .05);
}

void main() {
  for (final entry in {
    'claro': AppTheme.light,
    'oscuro': AppTheme.dark,
  }.entries) {
    final theme = entry.value;
    testWidgets('chips renderizados con contraste en ${entry.key}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Wrap(
              children: [
                ChoiceChip(
                  label: const Text('Vacio'),
                  selected: false,
                  onSelected: (_) {},
                ),
                ChoiceChip(
                  label: const Text('Lleno'),
                  selected: true,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text('Accesorio'),
                  selected: false,
                  onSelected: (_) {},
                ),
                FilterChip(
                  label: const Text('Seleccionado'),
                  selected: true,
                  onSelected: (_) {},
                ),
              ],
            ),
          ),
        ),
      );
      for (final label in ['Vacio', 'Lleno', 'Accesorio', 'Seleccionado']) {
        final richText = find.descendant(
          of: find.byWidgetPredicate(
            (widget) =>
                widget is RawChip &&
                widget.label is Text &&
                (widget.label as Text).data == label,
          ),
          matching: find.byType(RichText),
        );
        final paragraph = tester.renderObject<RenderParagraph>(richText.first);
        final selected = label == 'Lleno' || label == 'Seleccionado';
        final background = theme.chipTheme.color!.resolve(
          selected ? {WidgetState.selected} : {},
        )!;
        expect(
          contrast(paragraph.text.style!.color!, background),
          greaterThanOrEqualTo(4.5),
          reason: label,
        );
      }
      expect(tester.takeException(), isNull);
    });
    test('labels legibles en tema ${entry.key}', () {
      final enabled = <WidgetState>{};
      for (final style in [
        theme.filledButtonTheme.style!,
        theme.elevatedButtonTheme.style!,
      ]) {
        expect(
          contrast(
            style.foregroundColor!.resolve(enabled)!,
            style.backgroundColor!.resolve(enabled)!,
          ),
          greaterThanOrEqualTo(4.5),
        );
        final disabled = {WidgetState.disabled};
        expect(
          contrast(
            style.foregroundColor!.resolve(disabled)!,
            style.backgroundColor!.resolve(disabled)!,
          ),
          greaterThanOrEqualTo(4.5),
        );
      }
      for (final style in [
        theme.textButtonTheme.style!,
        theme.outlinedButtonTheme.style!,
      ]) {
        expect(
          contrast(
            style.foregroundColor!.resolve(enabled)!,
            theme.colorScheme.surface,
          ),
          greaterThanOrEqualTo(4.5),
        );
      }
      for (final states in [
        enabled,
        {WidgetState.selected},
      ]) {
        final style = theme.segmentedButtonTheme.style!;
        expect(
          contrast(
            style.foregroundColor!.resolve(states)!,
            style.backgroundColor!.resolve(states)!,
          ),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(
        contrast(
          theme.inputDecorationTheme.labelStyle!.color!,
          theme.inputDecorationTheme.fillColor!,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(
          theme.chipTheme.labelStyle!.color!,
          theme.chipTheme.backgroundColor!,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(
          theme.chipTheme.secondaryLabelStyle!.color!,
          theme.chipTheme.selectedColor!,
        ),
        greaterThanOrEqualTo(4.5),
      );
    });
  }
}
