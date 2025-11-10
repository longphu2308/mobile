import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/User/domain/models/user.dart';
import 'package:mobile/core/errors/app_exception.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel user = UserModel(
        userId: cred.user!.uid,
        email: email,
        fullName: fullName,
      );

      await _firestore
          .collection('users')
          .doc(cred.user!.uid)
          .set(user.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _handleFirebaseError(e),
        code: e.code,
      );
    }
  }

  // Sign in
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return await _getUserData(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _handleFirebaseError(e),
        code: e.code,
      );
    }
  }

  // Get user from Firestore
  Future<UserModel> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) throw AuthException(message: 'User not found');
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw AuthException(message: 'Failed to load user');
    }
  }

  Future<void> signOut() => _auth.signOut();

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  String _handleFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'email-already-in-use':
        return 'Email đã được sử dụng';
      case 'user-not-found':
      case 'wrong-password':
        return 'Email hoặc mật khẩu không đúng';
      case 'invalid-email':
        return 'Email không hợp lệ';
      default:
        return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
    }
  }

  Future<UserModel> _getUserData(String uid) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}