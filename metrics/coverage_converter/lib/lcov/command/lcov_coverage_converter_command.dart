import 'package:coverage_converter/common/arguments/model/coverage_converter_arguments.dart';
import 'package:coverage_converter/common/arguments/parser/arguments_parser.dart';
import 'package:coverage_converter/common/arguments/parser/coverage_converter_arguments_parser.dart';
import 'package:coverage_converter/common/command/coverage_converter_command.dart';
import 'package:coverage_converter/common/converter/coverage_converter.dart';
import 'package:coverage_converter/lcov/converter/lcov_coverage_converter.dart';

/// A [CoverageConverterCommand] used to convert the LCOV coverage report.
class LcovCoverageConverterCommand extends CoverageConverterCommand {
  @override
  String get name => 'lcov';

  @override
  String get description => 'Convert an LCOV coverage format.';

  @override
  CoverageConverter<CoverageConverterArguments> get converter =>
      LcovCoverageConverter();

  /// Creates a new instance of the [LcovCoverageConverterCommand]
  /// with the given [argumentsParser].
  ///
  /// If the [argumentsParser] is null,
  /// the [CoverageConverterArgumentsParser] used.
  LcovCoverageConverterCommand({
    ArgumentsParser<CoverageConverterArguments> argumentsParser,
  }) : super(argumentsParser ?? CoverageConverterArgumentsParser());
}
