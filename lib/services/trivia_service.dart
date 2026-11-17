import 'dart:async';
import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;

import '../models/question.dart';

class TriviaService {
  Future<List<Question>> fetchQuestions() async {
    const url =
        'https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple';

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('HTTP Error');
    }

    final data = jsonDecode(response.body);

    if (data['response_code'] != 0) {
      throw Exception('API Error');
    }

    if ((data['results'] as List).length != 10) {
      throw Exception('Expected 10 Questions');
    }

    final unescape = HtmlUnescape();

    return (data['results'] as List).map((item) {
      final correct = unescape.convert(item['correct_answer']);

      final options = [
        correct,
        ...(item['incorrect_answers'] as List).map(
          (e) => unescape.convert(e.toString()),
        ),
      ];

      options.shuffle();

      return Question(
        question: unescape.convert(item['question']),
        correctAnswer: correct,
        options: options,
      );
    }).toList();
  }
}
