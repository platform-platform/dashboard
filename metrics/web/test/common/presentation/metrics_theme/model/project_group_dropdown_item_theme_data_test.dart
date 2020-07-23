import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/metrics_theme/model/project_groups_dropdown_item_theme_data.dart';
import 'package:test/test.dart';

// https://github.com/software-platform/monorepo/issues/140
// ignore_for_file: prefer_const_constructors

void main() {
  group("ProjectGroupDropdownItemThemeData", () {
    test("creates an instance with the given values", () {
      const backgroundColor = Colors.red;
      const textStyle = TextStyle(fontSize: 13.0);
      const hoverColor = Colors.orange;

      final themeData = ProjectGroupsDropdownItemThemeData(
        backgroundColor: backgroundColor,
        textStyle: textStyle,
        hoverColor: hoverColor,
      );

      expect(themeData.backgroundColor, equals(backgroundColor));
      expect(themeData.textStyle, equals(textStyle));
      expect(themeData.hoverColor, equals(hoverColor));
    });
  });
}
