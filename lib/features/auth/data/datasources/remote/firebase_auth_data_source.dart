import 'package:devhub_gpt/features/auth/data/datasources/remote/auth_remote_data_source.dart';
import 'package:devhub_gpt/features/auth/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  FirebaseAuthRemoteDataSource(this._auth);
  final fb.FirebaseAuth _auth;

  UserModel _map(fb.User u) => UserModel(
        id: u.uid,
        email: u.email ?? '',
        name: u.displayName ?? (u.email ?? 'User'),
        avatarUrl: u.photoURL,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          u.metadata.creationTime?.millisecondsSinceEpoch ??
              DateTime.now().millisecondsSinceEpoch,
        ),
        isEmailVerified: u.emailVerified,
      );

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _map(cred.user!);
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);
    await cred.user!.reload();
    return _map(_auth.currentUser!);
  }

  @override
  Future<void> signOut() async => _auth.signOut();

  @override
  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not authenticated');
    if (data['name'] != null) {
      await u.updateDisplayName(data['name'] as String);
    }
    if (data['photoURL'] != null) {
      await u.updatePhotoURL(data['photoURL'] as String);
    }
    await u.reload();
    return _map(_auth.currentUser!);
  }

  @override
  Stream<UserModel?> watchAuthState() =>
      _auth.authStateChanges().map((u) => u == null ? null : _map(u));
}
