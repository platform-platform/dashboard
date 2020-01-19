import 'package:flutter/material.dart';
import 'package:metrics/ui/widgets/circle_progress_widget.dart';
import 'package:metrics/utils/app_colors.dart';
import 'package:metrics/utils/app_strings.dart';
import 'package:metrics/utils/scaling_info.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget 
{
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
//math.Random().nextDouble()
  //dummy data
  final double mockDataStability =0.50;
  final double mockDataCoverage = math.Random().nextDouble();
  final int buildsNumber =7;
  final String performanceValue = "10M";

  @override
  Widget build(BuildContext context) {
    if (!ScalingInfo.initialized) {
      ScalingInfo.init(context);
    }

    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Center(
          child:

              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                child:
                 Row(

                    children: <Widget>[
              
            
         
          CircleProgressWidget(
                title: AppStrings.stability,
                percent: mockDataStability,
                color: AppColor.mediumBlueColor,
              ),
               SizedBox(
            width: 20,
          ),
          // CircleProgressWidget(
          //   title: AppStrings.coverage,
          //   percent: mockDataCoverage,
          //   color: AppColor.purpleColor,
          // ),
            ],
          ),
              ),
        ),
      ),
    );
  }
}

// SizedBox(
//   width: 20,
// ),
// BuildResultWidget(),
// SizedBox(
//   width: 20,
// ),
// SparklineGraphWidget(
//   title: AppStrings.performance,
//   value: performanceValue,
// ),
// SizedBox(
//   width: 20,
// ),
// SparklineGraphWidget(
//   title: AppStrings.builds,
//   value: buildsNumber.toString(),
// ),
// SizedBox(
//   width: 20,
// ),
