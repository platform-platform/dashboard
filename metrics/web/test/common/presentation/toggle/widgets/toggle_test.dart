import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/common/presentation/metrics_theme/model/metrics_theme_data.dart';
import 'package:metrics/common/presentation/toggle/theme/toggle_theme_data.dart';
import 'package:metrics/common/presentation/toggle/widgets/toggle.dart';

import '../../../../test_utils/metrics_themed_testbed.dart';

void main() {
  group("Toggle", () {
    const inactiveColor = Colors.red;
    const activeColor = Colors.blue;
    const activeHoverColor = Colors.green;
    const inactiveHoverColor = Colors.yellow;
    const metricsTheme = MetricsThemeData(
      toggleTheme: ToggleThemeData(
        inactiveColor: inactiveColor,
        activeColor: activeColor,
        activeHoverColor: activeHoverColor,
        inactiveHoverColor: inactiveHoverColor,
      ),
    );
    final flutterSwitchFinder = find.byType(FlutterSwitch);
    final mouseRegionFinder = find.ancestor(
      of: flutterSwitchFinder,
      matching: find.byType(MouseRegion),
    );

    testWidgets(
      "throws an AssertionError if a value is null",
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const _MetricsSwitchTestbed(
            value: null,
          ),
        );

        expect(tester.takeException(), isAssertionError);
      },
    );

    testWidgets(
      "applies the given value to the flutter switch widget",
      (WidgetTester tester) async {
        const value = true;

        await tester.pumpWidget(const _MetricsSwitchTestbed(
          value: value,
        ));

        final switchWidget = tester.widget<FlutterSwitch>(flutterSwitchFinder);

        expect(switchWidget.value, equals(value));
      },
    );

    testWidgets(
      "applies the given on toggle callback to the flutter switch widget",
      (WidgetTester tester) async {
        // ignore: avoid_positional_boolean_parameters
        void testCallback(bool value) {}

        await tester.pumpWidget(_MetricsSwitchTestbed(
          onToggle: testCallback,
        ));

        final switchWidget = tester.widget<FlutterSwitch>(flutterSwitchFinder);

        expect(switchWidget.onToggle, equals(testCallback));
      },
    );

    testWidgets(
      "applies the inactive color from the metrics theme",
      (WidgetTester tester) async {
        await tester.pumpWidget(const _MetricsSwitchTestbed(
          metricsThemeData: metricsTheme,
        ));

        final switchWidget = tester.widget<FlutterSwitch>(flutterSwitchFinder);

        expect(switchWidget.inactiveColor, equals(inactiveColor));
      },
    );

    testWidgets(
      "applies the active color from the metrics theme",
      (WidgetTester tester) async {
        await tester.pumpWidget(const _MetricsSwitchTestbed(
          metricsThemeData: metricsTheme,
        ));

        final switchWidget = tester.widget<FlutterSwitch>(flutterSwitchFinder);

        expect(switchWidget.activeColor, equals(activeColor));
      },
    );

    testWidgets(
      "applies the inactive hover color from the metrics theme when the toggle is hovered",
      (WidgetTester tester) async {
        await tester.pumpWidget(const _MetricsSwitchTestbed(
          metricsThemeData: metricsTheme,
        ));

        final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder);
        const pointerEnterEvent = PointerEnterEvent();
        mouseRegion.onEnter(pointerEnterEvent);

        await tester.pump();

        final switchWidget = tester.widget<FlutterSwitch>(flutterSwitchFinder);

        expect(switchWidget.inactiveColor, equals(inactiveHoverColor));
      },
    );

    testWidgets(
      "applies the active hover color from the metrics theme when the toggle is hovered",
      (WidgetTester tester) async {
        await tester.pumpWidget(const _MetricsSwitchTestbed(
          metricsThemeData: metricsTheme,
        ));

        final mouseRegion = tester.widget<MouseRegion>(mouseRegionFinder);
        const pointerEnterEvent = PointerEnterEvent();
        mouseRegion.onEnter(pointerEnterEvent);

        await tester.pump();

        final switchWidget = tester.widget<FlutterSwitch>(flutterSwitchFinder);

        expect(switchWidget.activeColor, equals(activeHoverColor));
      },
    );

    testWidgets(
      "calls the given on toggle callback with a new value when is tapped",
      (WidgetTester tester) async {
        const value = true;
        bool changedValue;

        await tester.pumpWidget(
          _MetricsSwitchTestbed(
            value: value,
            onToggle: (value) => changedValue = value,
          ),
        );

        await tester.tap(find.byType(Toggle));
        await tester.pumpAndSettle();

        expect(changedValue, equals(!value));
      },
    );
  });
}

/// A testbed class required to test the [Toggle] widget.
class _MetricsSwitchTestbed extends StatelessWidget {
  /// Indicates whether the [Toggle] is on or off.
  final bool value;

  /// A callback that is called when the user toggles the [Toggle].
  final ValueChanged<bool> onToggle;

  /// A [MetricsThemeData] to use in tests.
  final MetricsThemeData metricsThemeData;

  /// Creates a new instance of the [_MetricsSwitchTestbed].
  ///
  /// The [value] defaults to `false`.
  /// The [metricsThemeData] defaults to an empty [MetricsThemeData] instance.
  const _MetricsSwitchTestbed({
    Key key,
    this.value = false,
    this.onToggle,
    this.metricsThemeData = const MetricsThemeData(),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MetricsThemedTestbed(
      metricsThemeData: metricsThemeData,
      body: Toggle(
        value: value,
        onToggle: onToggle,
      ),
    );
  }
}
