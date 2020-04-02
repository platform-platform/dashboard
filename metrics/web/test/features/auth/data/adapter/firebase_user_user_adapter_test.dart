import 'package:firebase_auth/firebase_auth.dart';
import 'package:metrics/features/auth/data/adapter/firebase_user_user_adapter.dart';
import 'package:metrics/features/auth/domain/entities/user.dart';
import 'package:test/test.dart';

void main() {
  group("FirebaseUserUserAdapter", () {
    test("can't be created with null firebaseUser", () {
      expect(() => FirebaseUserUserAdapter(null), throwsArgumentError);
    });

    test("adapts firebaseUser to a User", () {
      const id = 'id';
      const email = 'email';

      final firebaseUser = FirebaseUserTestbed(
        uid: id,
        email: email,
      );
      final expectedUser = User(
        id: id,
        email: email,
      );

      final adaptedUser = FirebaseUserUserAdapter(firebaseUser);

      expect(adaptedUser, isA<User>());
      expect(adaptedUser.id, expectedUser.id);
      expect(adaptedUser.email, expectedUser.email);
    });
  });
}

class FirebaseUserTestbed implements FirebaseUser {
  @override
  final String uid;

  @override
  final String email;

  FirebaseUserTestbed({this.uid, this.email});

  @override
  Future<void> delete() async {}

  @override
  String get displayName => null;

  @override
  Future<IdTokenResult> getIdToken({bool refresh = false}) async {
    return null;
  }

  @override
  bool get isAnonymous => false;

  @override
  bool get isEmailVerified => true;

  @override
  Future<AuthResult> linkWithCredential(AuthCredential credential) async {
    return null;
  }

  @override
  FirebaseUserMetadata get metadata => null;

  @override
  String get phoneNumber => null;

  @override
  String get photoUrl => null;

  @override
  List<UserInfo> get providerData => null;

  @override
  String get providerId => null;

  @override
  Future<AuthResult> reauthenticateWithCredential(
      AuthCredential credential) async {
    return null;
  }

  @override
  Future<void> reload() async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> unlinkFromProvider(String provider) async {}

  @override
  Future<void> updateEmail(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<void> updatePhoneNumberCredential(AuthCredential credential) async {}

  @override
  Future<void> updateProfile(UserUpdateInfo userUpdateInfo) async {}
}
