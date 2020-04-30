import 'package:ci_integration/ci_integration/config/model/raw_integration_config.dart';
import 'package:yaml_map/yaml_map.dart';

/// A class providing methods for parsing [RawIntegrationConfig]
/// from YAML string.
class RawIntegrationConfigParser {
  /// The YAML parser used to convert YAML string to the [Map] instance.
  static const YamlMapParser _parser = YamlMapParser();

  const RawIntegrationConfigParser();

  /// Parses the given [configYaml] into the [RawIntegrationConfig] instance.
  ///
  /// The [configYaml] is required.
  /// Throws an [ArgumentError] if [configYaml] is `null`.
  RawIntegrationConfig parse(String configYaml) {
    ArgumentError.checkNotNull(configYaml, 'configYaml');

    final configMap = _parser.parse(configYaml);
    final sourceMap = configMap['source'] as Map<String, dynamic>;
    final destinationMap = configMap['destination'] as Map<String, dynamic>;

    if (sourceMap == null) {
      throw const FormatException('The source configuration is missing!');
    }

    if (destinationMap == null) {
      throw const FormatException('The destination configuration is missing!');
    }

    return RawIntegrationConfig(
      sourceConfigMap: sourceMap,
      destinationConfigMap: destinationMap,
    );
  }
}
