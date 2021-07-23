// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:cli/services/common/info_service.dart';
import 'package:equatable/equatable.dart';

/// A class that represents the information on a specific [InfoService].
class Dependency extends Equatable {
  /// A [String] representing the recommended version of this dependency.
  final String recommendedVersion;

  /// A [String] representing the installation URL of this dependency.
  final String installUrl;

  @override
  List<Object> get props => [recommendedVersion, installUrl];

  /// Creates a new instance of [Dependency] with the given [recommendedVersion]
  /// and [installUrl].
  const Dependency._({
    this.recommendedVersion,
    this.installUrl,
  });

  /// Creates a new instance of the [Dependency] from the given [map].
  ///
  /// Returns `null` if the given [map] is `null`.
  factory Dependency.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return Dependency._(
      recommendedVersion: map['recommended_version'] as String,
      installUrl: map['install_url'] as String,
    );
  }
}
