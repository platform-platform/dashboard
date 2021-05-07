// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:metrics/dashboard/domain/entities/metrics/build_day_project_metrics.dart';
import 'package:metrics/dashboard/domain/usecases/parameters/project_id_param.dart';
import 'package:metrics/dashboard/domain/usecases/receive_build_day_project_metrics_updates.dart';

/// A stub implementation of the [ReceiveBuildDayProjectMetricsUpdates].
class ReceiveBuildDayProjectMetricsUpdatesStub
    implements ReceiveBuildDayProjectMetricsUpdates {
  @override
  Stream<BuildDayProjectMetrics> call(ProjectIdParam params) {
    return const Stream.empty();
  }
}
