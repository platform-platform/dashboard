import 'package:flutter/cupertino.dart';
import 'package:metrics/features/common/presentation/metrics_theme/store/theme_store.dart';
import 'package:metrics/features/dashboard/data/repositories/firestore_metrics_repository.dart';
import 'package:metrics/features/dashboard/domain/repositories/metrics_repository.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_project_metrics_updates.dart';
import 'package:metrics/features/dashboard/domain/usecases/receive_project_updates.dart';
import 'package:metrics/features/dashboard/presentation/state/project_metrics_store.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import '../../../../auth/data/repositories/user_repository.dart';
import '../../../../auth/service/user_service.dart';

/// Creates project stores and injects it using the [Injector] widget.
class InjectionContainer extends StatefulWidget {
  final Widget child;

  const InjectionContainer({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _InjectionContainerState createState() => _InjectionContainerState();
}

class _InjectionContainerState extends State<InjectionContainer> {
  final MetricsRepository _metricsRepository = FirestoreMetricsRepository();
  final UserRepository _userRepository = UserRepository();
  ReceiveProjectUpdates _receiveProjectUpdates;
  ReceiveProjectMetricsUpdates _receiveProjectMetricsUpdates;

  @override
  void initState() {
    _receiveProjectUpdates = ReceiveProjectUpdates(_metricsRepository);
    _receiveProjectMetricsUpdates =
        ReceiveProjectMetricsUpdates(_metricsRepository);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Injector(
      inject: [
        Inject<ProjectMetricsStore>(() => ProjectMetricsStore(
              _receiveProjectUpdates,
              _receiveProjectMetricsUpdates,
            )),
        Inject<UserService>(() => UserService(userRepository: _userRepository)),
        Inject<ThemeStore>(() => ThemeStore()),
      ],
      dispose: _dispose,
      initState: _initInjectorState,
      builder: (BuildContext context) => widget.child,
    );
  }

  /// Initiates the injector state.
  void _initInjectorState() {
    Injector.getAsReactive<ProjectMetricsStore>().setState(
      _initMetricsStore,
      catchError: true,
    );
    Injector.getAsReactive<ThemeStore>().setState(
      (store) => store.isDark = true,
      catchError: true,
    );
    Injector.getAsReactive<UserService>()
        .setState((store) => store.currentUser());
  }

  /// Initiates the [ProjectMetricsStore].
  Future _initMetricsStore(ProjectMetricsStore store) async {
    await store.subscribeToProjects();
  }

  /// Disposes the injected models.
  void _dispose() {
    Injector.get<ProjectMetricsStore>().dispose();
  }
}
