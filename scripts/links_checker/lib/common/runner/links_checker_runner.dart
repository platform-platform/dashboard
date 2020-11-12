import 'package:args/command_runner.dart';
import 'package:links_checker/common/command/links_checker_command.dart';

/// A [CommandRunner] for the links checker CLI.
class LinksCheckerRunner extends CommandRunner<void> {
  /// Creates a new instance of the [LinksCheckerRunner]
  /// and registers all available sub-commands.
  LinksCheckerRunner() : super('links_checker', 'A links checker tool.') {
    addCommand(LinksCheckerCommand());
  }
}
