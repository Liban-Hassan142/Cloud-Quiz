import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/question.dart';
import '../services/firestore_service.dart';

class ReviewScreen extends StatefulWidget {
  final int score;
  final List<Question> questions;
  final List<String> selectedAnswers;
  final String roundId;

  const ReviewScreen({
    super.key,
    required this.score,
    required this.questions,
    required this.selectedAnswers,
    required this.roundId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool submitting = false;

  String statusMessage = '';

  Future<void> submitScore() async {
    setState(() {
      submitting = true;
      statusMessage = 'Submitting...';
    });

    try {
      final ref = await FirestoreService().submitAttempt(
        roundId: widget.roundId,
        score: widget.score,
      );

      final verified = await ref.get(const GetOptions(source: Source.server));

      if (!verified.exists) {
        throw Exception('Verification Failed');
      }

      final data = verified.data() as Map<String, dynamic>;

      if (data['variant'] != 'A') {
        throw Exception('Variant Mismatch');
      }

      if (data['questionCount'] != 10) {
        throw Exception('Question Count Mismatch');
      }

      if (data['correctCount'] != widget.score) {
        throw Exception('Score Mismatch');
      }

      setState(() {
        statusMessage = 'Cloud Verified ✅';
      });
    } catch (e) {
      setState(() {
        statusMessage = 'Error: $e';
      });
    }

    setState(() {
      submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Final Score: ${widget.score}/10',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Text(
              'Round ID:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            SelectableText(widget.roundId),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.questions[index].question),
                          const SizedBox(height: 5),
                          Text('Your Answer: ${widget.selectedAnswers[index]}'),
                          Text(
                            'Correct Answer: ${widget.questions[index].correctAnswer}',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            ElevatedButton(
              onPressed: submitting ? null : submitScore,
              child: const Text('Submit Score'),
            ),

            const SizedBox(height: 10),

            Text(
              statusMessage,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
