// Use of this source code is governed by the Apache License, Version 2.0
// that can be found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:metrics_core/src/features/validation/validation_conclusion.dart';
import 'package:metrics_core/src/features/validation/validation_target.dart';

/// A class that represents a validation result for a single [ValidationTarget].
class TargetValidationResult<T> {
  /// A validated data of this target validation result.
  final T data;

  /// A [ValidationTarget] of this target validation result.
  final ValidationTarget<T> target;

  /// A [ValidationConclusion] of this target validation result.
  final ValidationConclusion<T> conclusion;

  /// A [String] containing short description of this target validation
  /// result.
  final String description;

  /// A [Map] containing additional details of this target validation result.
  final Map<String, dynamic> details;

  /// A [Map] containing context of the validation process.
  final Map<String, dynamic> context;

  /// Creates a new instance of the [TargetValidationResult] with the given
  /// parameters.
  ///
  /// The [details] defaults to an empty map.
  /// The [context] defaults to an empty map.
  ///
  /// Throws an [AssertionError] if the given [target], [conclusion], or
  /// [description] is null.
  const TargetValidationResult({
    @required this.target,
    @required this.conclusion,
    @required this.description,
    this.details = const {},
    this.context = const {},
    this.data,
  })  : assert(target != null),
        assert(conclusion != null),
        assert(description != null);

  /// Creates a new instance of the [TargetValidationResult] based on current
  /// instance.
  ///
  /// If any of the given parameters is null, or parameter isn't specified,
  /// the value will be copied from the current instance.
  TargetValidationResult<T> copyWith({
    ValidationTarget<T> target,
    ValidationConclusion<T> conclusion,
    String description,
    Map<String, dynamic> details,
    Map<String, dynamic> context,
    T data,
  }) {
    return TargetValidationResult(
      target: target ?? this.target,
      conclusion: conclusion ?? this.conclusion,
      description: description ?? this.description,
      details: details ?? this.details,
      context: context ?? this.context,
      data: data ?? this.data,
    );
  }
}