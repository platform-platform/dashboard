import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/base/presentation/widgets/clearable_text_form_field.dart';

void main() {
  group("ClearableTextFormField", () {
    final clearIconButtonFinder = find.descendant(
      of: find.byType(IconButton),
      matching: find.byIcon(Icons.close),
    );

    testWidgets(
      "throws an AssertionError if the given controller is null",
      (tester) async {
        await tester.pumpWidget(
          const _ClearableTextFormFieldTestbed(controller: null),
        );

        expect(tester.takeException(), isAssertionError);
      },
    );

    testWidgets(
      "applies the given text editing controller",
      (WidgetTester tester) async {
        final testController = TextEditingController();

        await tester.pumpWidget(
          _ClearableTextFormFieldTestbed(
            controller: testController,
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));

        expect(textField.controller, equals(testController));
      },
    );

    testWidgets(
      "applies the given validator",
      (WidgetTester tester) async {
        final controller = TextEditingController();
        String validator(String value) {
          return null;
        }

        await tester.pumpWidget(
          _ClearableTextFormFieldTestbed(
            controller: controller,
            validator: validator,
          ),
        );

        final textFormField = tester.widget<TextFormField>(
          find.byType(TextFormField),
        );

        expect(textFormField.validator, equals(validator));
      },
    );

    testWidgets(
      "displays the default clear icon if it's null an input is not empty",
      (WidgetTester tester) async {
        final controller = TextEditingController(text: 'text');

        await tester.pumpWidget(
          _ClearableTextFormFieldTestbed(controller: controller),
        );

        expect(clearIconButtonFinder, findsOneWidget);
      },
    );

    testWidgets(
      "does not display the default clear icon if it's null an input is empty",
      (WidgetTester tester) async {
        final controller = TextEditingController(text: 'text');

        await tester.pumpWidget(
          _ClearableTextFormFieldTestbed(controller: controller),
        );

        expect(
          clearIconButtonFinder,
          findsOneWidget,
        );
      },
    );

    testWidgets(
      "applies the default input decoration if it's null",
      (WidgetTester tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          _ClearableTextFormFieldTestbed(controller: controller),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));

        expect(textField.decoration, isNotNull);
      },
    );

    testWidgets(
      "applies the given input decoration",
      (WidgetTester tester) async {
        const inputDecoration = InputDecoration();
        final globalKey = GlobalKey();
        final controller = TextEditingController();

        await tester.pumpWidget(
          _ClearableTextFormFieldTestbed(
            key: globalKey,
            controller: controller,
            inputDecoration: inputDecoration,
          ),
        );

        final theme = Theme.of(globalKey.currentContext);
        final defaultInputDecoration = inputDecoration.applyDefaults(
          theme.inputDecorationTheme,
        );
        final textField = tester.widget<TextField>(find.byType(TextField));

        expect(textField.decoration, equals(defaultInputDecoration));
      },
    );

    testWidgets("applies the given textStyle", (WidgetTester tester) async {
      const testTextStyle = TextStyle();
      final controller = TextEditingController();

      await tester.pumpWidget(
        _ClearableTextFormFieldTestbed(
          controller: controller,
          textStyle: testTextStyle,
        ),
      );

      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(textField.style, equals(testTextStyle));
    });

    testWidgets(
      "does not display the given clear icon if an input is empty",
      (WidgetTester tester) async {
        const clearIcon = Icon(Icons.close);
        final controller = TextEditingController();

        await tester.pumpWidget(
          _ClearableTextFormFieldTestbed(
            controller: controller,
            clearIcon: clearIcon,
          ),
        );

        expect(
          find.byWidget(clearIcon),
          findsNothing,
        );
      },
    );

    testWidgets(
      "displays the given clear icon if an input is not empty",
      (WidgetTester tester) async {
        const clearIcon = Icon(Icons.close);
        final controller = TextEditingController(text: 'text');

        await tester.pumpWidget(
          _ClearableTextFormFieldTestbed(
            controller: controller,
            clearIcon: clearIcon,
          ),
        );

        expect(
          find.byWidget(clearIcon),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      "applies a hand cursor to the clear icon",
          (WidgetTester tester) async {
        final controller = TextEditingController(text: 'text');

        await tester.pumpWidget(
          _ClearableTextFormFieldTestbed(label: label, controller: controller),
        );

        expect(clearIconButtonFinder, findsOneWidget);
      },
    );

    testWidgets(
      "calls the validation callback on form validation",
      (WidgetTester tester) async {
        final controller = TextEditingController(text: 'text');

        bool _callbackIsCalled = false;
        final _formKey = GlobalKey<FormState>();

        await tester.pumpWidget(
          _ClearableTextFormFieldTestbed(
            formKey: _formKey,
            controller: controller,
            validator: (String value) {
              _callbackIsCalled = true;
              return null;
            },
          ),
        );

        _formKey.currentState.validate();

        expect(_callbackIsCalled, isTrue);
      },
    );

    testWidgets(
      "clears an input on tap on a clear icon",
      (WidgetTester tester) async {
        final controller = TextEditingController(text: 'text');

        await tester.pumpWidget(
          _ClearableTextFormFieldTestbed(controller: controller),
        );

        await tester.tap(clearIconButtonFinder);
        await tester.pump();

        expect(controller.text, isEmpty);
      },
    );
  });
}

/// A testbed class required to test the [ClearableTextFormField] widget.
class _ClearableTextFormFieldTestbed extends StatelessWidget {
  /// The style to use for the text being edited.
  final TextStyle textStyle;

  /// The icon to use for the clear content button within this text field.
  final Widget clearIcon;

  /// A text field controller.
  final TextEditingController controller;

  /// A text field form validator.
  final FormFieldValidator<String> validator;

  /// The decoration to show around this text field.
  ///
  /// The [InputDecoration.suffixIcon] is ignored and replaced with
  /// the clear [IconButton]. To change the clear button use the [clearIcon].
  final InputDecoration inputDecoration;

  /// The unique key for accessing the [Form].
  final GlobalKey formKey;

  /// Creates an instance of this testbed with the given parameters.
  const _ClearableTextFormFieldTestbed({
    Key key,
    this.formKey,
    this.controller,
    this.validator,
    this.clearIcon,
    this.inputDecoration,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Form(
          key: formKey,
          child: ClearableTextFormField(
            controller: controller,
            validator: validator,
            inputDecoration: inputDecoration,
            textStyle: textStyle,
            clearIcon: clearIcon,
          ),
        ),
      ),
    );
  }
}
