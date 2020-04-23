import 'package:firedart/firedart.dart' as fd;

/// A Firestore wrapper class providing an access to the project id
/// and the Firebase Authentication client.
class Firestore extends fd.Firestore {
  /// The Firestore project id.
  final String projectId;

  /// The Firebase Authentication client.
  final fd.FirebaseAuth firebaseAuth;

  /// Creates an instance of this Firestore wrapper with the given [projectId].
  ///
  /// The [firebaseAuth] is optional. If it is not provided then no
  /// authorization for Firestore related requests is applied.
  /// 
  /// Throws an [ArgumentError] if the given [projectId] is `null` or empty.
  Firestore(
    this.projectId, {
    this.firebaseAuth,
  }) : super(
          projectId,
          auth: firebaseAuth,
        ) {
    if (projectId == null || projectId.isEmpty) {
      throw ArgumentError.value(
        projectId,
        'projectId',
        'must not be null or empty',
      );
    }
  }
}
