import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/trivia_service.dart';
import '../services/firestore_service.dart';
import 'review_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];

  bool loading = true;

  int currentIndex = 0;
  int score = 0;

  String? selectedAnswer;

  List<String> selectedAnswers = [];

  String roundId = '';

  @override
  void initState() {
    super.initState();
    initializeQuiz();
  }

  Future<void> initializeQuiz() async {
    roundId = await FirestoreService().createRoundId();

    questions = await TriviaService().fetchQuestions();

    setState(() {
      loading = false;
    });
  }

  void selectAnswer(String answer) {
    if (selectedAnswer != null) return;

    setState(() {
      selectedAnswer = answer;

      selectedAnswers.add(answer);

      if (answer == questions[currentIndex].correctAnswer) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (selectedAnswer == null) return;

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewScreen(
            score: score,
            questions: questions,
            selectedAnswers: selectedAnswers,
            roundId: roundId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Question ${currentIndex + 1}/10')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LinearProgressIndicator(value: (currentIndex + 1) / 10),

            const SizedBox(height: 15),

            Text(
              question.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ...question.options.map((option) {
              Color? color;

              if (selectedAnswer != null) {
                if (option == question.correctAnswer) {
                  color = Colors.green;
                } else if (option == selectedAnswer) {
                  color = Colors.red;
                }
              }

              return Card(
                color: color,
                child: ListTile(
                  title: Text(option),
                  onTap: () => selectAnswer(option),
                ),
              );
            }),

            const Spacer(),

            Text('Current Score: $score'),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: selectedAnswer == null ? null : nextQuestion,
              child: Text(currentIndex == 9 ? 'Finish Quiz' : 'Next Question'),
            ),
          ],
        ),
      ),
    );
  }
}
