import 'package:flutter/material.dart';

/// Stores the theme data for the project group dropdown item.
class ProjectGroupDropdownItemThemeData {
  /// A background [Color] of the project group dropdown item.
  final Color backgroundColor;

  /// A hover [Color] of the project group dropdown item.
  final Color hoverColor;

  /// A [TextStyle] of the project group dropdown item text.
  final TextStyle textStyle;

  /// Creates the [ProjectgroupDropdownItemThemeData].
  const ProjectGroupDropdownItemThemeData({
    this.backgroundColor,
    this.hoverColor,
    this.textStyle,
  });
}
