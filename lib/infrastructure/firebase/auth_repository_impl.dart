import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:groceryhelper/domain/repositories/auth_repository.dart';
import 'package:groceryhelper/infrastructure/services/talker_service.dart';

class AuthRepositoryImpl extends AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({required FirebaseAuth firebaseAuth, GoogleSignIn? googleSignIn, String? googleClientId})
    : _firebaseAuth = firebaseAuth,
      _googleSignIn =
          googleSignIn ?? (kIsWeb && googleClientId != null ? GoogleSignIn(clientId: googleClientId) : GoogleSignIn());

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Stream<User?> get user => _firebaseAuth.userChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<Either<Exception, UserCredential>> signInWithGoogle() async {
    try {
      TalkerService.log('Starting Google sign in process');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        TalkerService.warning('Google sign in was cancelled by user');
        return left(Exception('Sign in aborted by user'));
      }

      TalkerService.log('Google user selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      TalkerService.log('Successfully signed in with Google: ${result.user?.email}');
      return right(result);
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Firebase Auth Exception during Google sign in', e);
      return left(e);
    } on FirebaseException catch (e) {
      TalkerService.error('Firebase Exception during Google sign in', e);
      return left(e);
    } catch (e) {
      TalkerService.error('Unexpected error during Google sign in', e);
      return left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, UserCredential>> signInWithApple() async {
    try {
      return left(Exception('Not implemented'));
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Firebase Auth Exception during Apple sign in', e);
      return left(e);
    } on FirebaseException catch (e) {
      TalkerService.error('Firebase Exception during Apple sign in', e);
      return left(e);
    } catch (e) {
      TalkerService.error('Unexpected error during Apple sign in', e);
      return left(Exception(e.toString()));
    }
  }

  Future<Either<Exception, UserCredential>> signInWithEmailAndPassword(String email, String password) async {
    try {
      final result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      TalkerService.log('Successfully signed in with email: ${result.user?.email}');
      return right(result);
    } on FirebaseAuthException catch (e) {
      TalkerService.error('Firebase Auth Exception during email sign in', e);
      return left(e);
    }
  }

  Future<Either<Exception, void>> signOut() async {
    try {
      TalkerService.log('Starting sign out process');

      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();

      TalkerService.log('Successfully signed out');
      return right(null);
    } catch (e) {
      TalkerService.error('Error during sign out', e);
      return left(Exception(e.toString()));
    }
  }
}
