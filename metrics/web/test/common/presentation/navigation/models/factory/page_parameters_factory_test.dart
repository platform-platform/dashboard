// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:metrics/common/presentation/navigation/models/factory/page_parameters_factory.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_configuration.dart';
import 'package:metrics/dashboard/presentation/models/dashboard_page_parameters_model.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import '../../../../../test_utils/route_configuration_mock.dart';
import '../../../../../test_utils/route_name_mock.dart';

void main() {
  group("PageParametersFactory", () {
    const projectFilter = 'projectFilter';
    const projectGroupId = 'projectGroupId';
    const pageParametersMap = {
      'projectFilter': projectFilter,
      'projectGroupId': projectGroupId,
    };

    final pageParametersFactory = PageParametersFactory();
    final routeConfiguration = RouteConfigurationMock();
    final routeName = RouteNameMock();

    test(
      ".create() returns null if the given route configuration is null",
      () {
        final pageParameters = pageParametersFactory.create(null);

        expect(pageParameters, isNull);
      },
    );

    test(
      ".create() returns the dashboard page parameters model if the given route configuration name is a dashboard",
      () {
        final routeConfiguration = RouteConfiguration.dashboard(
          parameters: pageParametersMap,
        );

        final pageParameters = pageParametersFactory.create(routeConfiguration);

        expect(pageParameters, isA<DashboardPageParametersModel>());
      },
    );

    test(
      ".create() returns the dashboard page parameters model with parameters from the route configuration",
      () {
        final routeConfiguration = RouteConfiguration.dashboard(
          parameters: pageParametersMap,
        );

        final pageParameters = pageParametersFactory.create(routeConfiguration)
            as DashboardPageParametersModel;

        expect(pageParameters.projectFilter, equals(projectFilter));
        expect(pageParameters.projectGroupId, equals(projectGroupId));
      },
    );

    test(
      ".create() returns null if the given route configuration name is unknown",
      () {
        when(routeName.value).thenReturn('unknown');
        when(routeConfiguration.name).thenReturn(routeName);

        final pageParameters = pageParametersFactory.create(routeConfiguration);

        expect(pageParameters, isNull);
      },
    );
  });
}