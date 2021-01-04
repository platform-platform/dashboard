import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:metrics/common/presentation/navigation/route_configuration/route_configuration.dart';
import 'package:metrics/common/presentation/navigation/state/navigation_notifier.dart';

/// A class that builds the [Navigator] widget with a
/// list of configured pages.
///
/// It defines how the [Router] reacts to changes
/// in both the application state and operating system.
class MetricsRouterDelegate extends RouterDelegate<RouteConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  /// A [ChangeNotifier] that manages a list of pages
  /// and provides methods to perform navigation.
  final NavigationNotifier _navigationNotifier;

  /// A list of observers for the [Navigator] widget.
  final List<NavigatorObserver> navigatorObservers;

  @override
  RouteConfiguration get currentConfiguration =>
      _navigationNotifier.currentConfiguration;

  @override
  GlobalKey<NavigatorState> get navigatorKey => GlobalObjectKey<NavigatorState>(
        _navigationNotifier,
      );

  /// Creates a new instance of the [MetricsRouterDelegate].
  ///
  /// The [navigatorObservers] defaults to an empty list.
  ///
  /// The navigation notifier and [navigatorObservers] must not be `null`.
  MetricsRouterDelegate(
    this._navigationNotifier, {
    this.navigatorObservers = const <NavigatorObserver>[],
  })  : assert(_navigationNotifier != null),
        assert(navigatorObservers != null) {
    _navigationNotifier.addListener(notifyListeners);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _navigationNotifier.pages,
      observers: navigatorObservers,
      onPopPage: _onPopPage,
    );
  }

  @override
  Future<void> setInitialRoutePath(RouteConfiguration configuration) async {
    _navigationNotifier.handleInitialRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(RouteConfiguration configuration) async {
    _navigationNotifier.handleNewRoutePath(configuration);
  }

  /// A callback that invokes when the [Navigator] pops.
  ///
  /// If the [route.didPop] method returns `true`, the [_navigationNotifier.pop]
  /// is called.
  bool _onPopPage(Route<dynamic> route, dynamic result) {
    final didPop = route.didPop(result);

    if (didPop) {
      _navigationNotifier.pop();
    }

    return didPop;
  }

  @override
  void dispose() {
    _navigationNotifier.removeListener(notifyListeners);

    super.dispose();
  }
}
