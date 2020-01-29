import 'package:guardian/utils/yaml/formatter/type_formatter.dart';

class ListTypeFormatter extends IterableTypeFormatter<List> {
  ListTypeFormatter(int spacesPerIndentationLevel,
      void Function(dynamic, StringBuffer, int) delegateCallback)
      : super(
          spacesPerIndentationLevel,
          delegateCallback,
        );

  @override
  void format(List<dynamic> value, StringBuffer buffer, int indentationLevel) {
    buffer.write('\n');

    for (var i = 0; i < value.length; i++) {
      buffer.write(' ' * spacesPerIndentationLevel * indentationLevel);
      buffer.write('- ');
      delegateCallback(value[i], buffer, indentationLevel + 1);

      if (i != value.length - 1) {
        buffer.write('\n');
      }
    }
  }
}
