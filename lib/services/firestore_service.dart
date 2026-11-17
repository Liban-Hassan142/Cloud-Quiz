import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final firestore = FirebaseFirestore.instance;

  Future<String> createRoundId() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return firestore
        .collection('users')
        .doc(uid)
        .collection('attempts')
        .doc()
        .id;
  }

  Future<DocumentReference> submitAttempt({
    required String roundId,
    required int score,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final ref = firestore
        .collection('users')
        .doc(uid)
        .collection('attempts')
        .doc(roundId);

    final payload = {
      "schemaVersion": 1,
      "variant": "A",
      "categoryId": 9,
      "questionCount": 10,
      "correctCount": score,
      "submittedAt": FieldValue.serverTimestamp(),
    };

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        transaction.set(ref, payload);
      }
    });

    return ref;
  }
}
