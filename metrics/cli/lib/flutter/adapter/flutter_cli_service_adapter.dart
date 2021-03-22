import 'package:cli/flutter/cli/flutter_cli.dart';
import 'package:cli/flutter/service/flutter_service.dart';

/// An adapter for the [FlutterCli] to implement the [FlutterService]
/// interface.
class FlutterCliServiceAdapter implements FlutterService {
  /// A [FlutterCli] class that provides an ability to interact
  /// with the Flutter CLI.
  final FlutterCli _flutterCli;

  /// Creates a new instance of the [UserMenuThemeData]
  /// with the given [FlutterCli].
  ///
  /// Throws an [AssertionError] if the given [FlutterCli] is `null`.
  FlutterCliServiceAdapter(this._flutterCli) : assert(_flutterCli != null);

  @override
  Future<void> build(String appPath) async {
    await _flutterCli.enableWeb();
    await _flutterCli.buildWeb(appPath);
  }

  @override
  Future<void> version() {
    return _flutterCli.version();
  }
}
