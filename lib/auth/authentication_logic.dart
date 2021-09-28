import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {
  final FirebaseAuth _fbAuthInstance;

  AuthenticationService(this._fbAuthInstance);

  Stream<User?> get authStateChanges => _fbAuthInstance.authStateChanges();
  User? get currentUser => _fbAuthInstance.currentUser;
  Future<void> signOut() async {await _fbAuthInstance.signOut();}

  Future<void> signIn({required String email,required String password}) async {
    try {
      UserCredential userCredential = await _fbAuthInstance.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      print('Signed in');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser != null) {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      await _fbAuthInstance.signInWithCredential(credential);
      print('Signed In');
    } else {
      print('Failed');
    }
  }

  Future<void> signUp({required String email,required String password}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
      print('Signed up');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}