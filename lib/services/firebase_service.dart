import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth State Changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<String?> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optional: Create a user document in Firestore
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.code} - ${e.message}');
      return _getErrorMessage(e.code);
    } catch (e) {
      print('Unexpected error during sign up: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.code} - ${e.message}');
      return _getErrorMessage(e.code);
    } catch (e) {
      print('Unexpected error during sign in: $e');
      return 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }

  // Get todos stream
  Stream<QuerySnapshot> getTodos() {
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('todos')
        .where('userId', isEqualTo: currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add new todo
  Future<void> addTodo(String title) async {
    if (currentUser == null) return;

    try {
      await _firestore.collection('todos').add({
        'userId': currentUser!.uid,
        'title': title,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding todo: $e');
      rethrow;
    }
  }

  // Update todo completion status
  Future<void> toggleTodoCompletion(String docId, bool isCompleted) async {
    try {
      await _firestore.collection('todos').doc(docId).update({
        'isCompleted': !isCompleted,
      });
    } catch (e) {
      print('Error updating todo: $e');
      rethrow;
    }
  }

  // Delete todo
  Future<void> deleteTodo(String docId) async {
    try {
      await _firestore.collection('todos').doc(docId).delete();
    } catch (e) {
      print('Error deleting todo: $e');
      rethrow;
    }
  }

  // Helper method to convert Firebase error codes to user-friendly messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
