import 'package:metrics/common/domain/entities/firestore_error_code.dart';
import 'package:metrics/project_groups/presentation/strings/project_groups_strings.dart';

/// A class that provides the firestore error description based on [FirestoreErrorCode].
class ProjectGroupFirestoreErrorMessage {
  final FirestoreErrorCode _code;

  /// Creates the [ProjectGroupFirestoreErrorMessage] from the given [FirestoreErrorCode].
  const ProjectGroupFirestoreErrorMessage(this._code);

  /// Provides an firestore error message based on the [FirestoreErrorCode].
  String get message {
    switch (_code) {
      case FirestoreErrorCode.unknown:
        return ProjectGroupsStrings.unknownErrorMessage;
      default:
        return null;
    }
  }
}
