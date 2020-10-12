import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:metrics/common/presentation/graph_indicator/theme/attention_level/graph_indicator_attention_level.dart';
import 'package:metrics/common/presentation/graph_indicator/theme/style/graph_indicator_style.dart';
import 'package:metrics/common/presentation/graph_indicator/widgets/neutral_graph_indicator.dart';

// https://github.com/software-platform/monorepo/issues/140
// ignore_for_file: prefer_const_constructors

void main() {
  group("NeutralGraphIndicator", () {
    test(
      ".selectStyle() returns a neutral style of the given attention level",
      () {
        const graphIndicatorAttentionLevel = GraphIndicatorAttentionLevel(
          neutral: GraphIndicatorStyle(innerColor: Colors.green),
        );

        final indicator = NeutralGraphIndicator();
        final style = indicator.selectStyle(graphIndicatorAttentionLevel);

        expect(style, equals(graphIndicatorAttentionLevel.neutral));
      },
    );
  });
}
