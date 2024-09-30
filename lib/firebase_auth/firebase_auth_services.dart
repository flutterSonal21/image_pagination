import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../global/common/toast.dart';

class FirebaseAuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential =await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {

      if (e.code == 'email-already-in-use') {
        showToast(message: 'The email address is already in use.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }
    }
    return null;

  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {

    try {
      UserCredential credential =await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        showToast(message: 'Invalid email or password.');
      } else {
        showToast(message: 'An error occurred: ${e.code}');
      }

    }
    return null;

  }

//Add   =>    String lastName,
  Future<void> saveUserProfile(String uid, String firstName,  String email) async {
    try {
      var _firestore;
      await _firestore.collection('users').doc(uid).set({
        'firstName': firstName,
        // 'lastName': lastName,
        'email': email,
      });
    } catch (e) {
      // Handle errors here
      print(e);
    }
  }
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      var _firestore;
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Get user profile error: $e');
      return null;
    }
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../../../global/common/toast.dart';

// class FirebaseAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<User?> signUpWithEmailAndPassword(String email, String password) async {
//     try {
//       UserCredential credential = await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return credential.user;
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'email-already-in-use') {
//         showToast(message: 'The email address is already in use.');
//       } else {
//         showToast(message: 'An error occurred: ${e.code}');
//       }
//     }
//     return null;
//   }

//   Future<User?> signInWithEmailAndPassword(String email, String password) async {
//     try {
//       UserCredential credential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return credential.user;
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found' || e.code == 'wrong-password') {
//         showToast(message: 'Invalid email or password.');
//       } else {
//         showToast(message: 'An error occurred: ${e.code}');
//       }
//     }
//     return null;
//   }

//   Future<void> saveUserProfile(String uid, String firstName, String email) async {
//     try {
//       await _firestore.collection('users').doc(uid).set({
//         'firstName': firstName,
//         'email': email,
//       });
//     } catch (e) {
//       print(e);
//     }
//   }

//   Future<Map<String, dynamic>?> getFirstUserProfile() async {
//     try {
//       QuerySnapshot querySnapshot = await _firestore.collection('users').limit(1).get();
//       if (querySnapshot.docs.isNotEmpty) {
//         return querySnapshot.docs.first.data() as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       print('Get first user profile error: $e');
//       return null;
//     }
//   }
// }
