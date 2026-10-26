import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiException implements Exception {
  const GeminiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Minimal client for the Gemini "generateContent" REST endpoint.
/// Docs: https://ai.google.dev/api/generate-content
class GeminiClient {
  GeminiClient({required this.apiKey, http.Client? client}) : _client = client ?? http.Client();

  static const defaultModel = 'gemini-3.6-flash';

  final String apiKey;
  final http.Client _client;

  /// Sends [prompt] and asks Gemini for JSON matching [schema] (an OpenAPI-subset schema map).
  /// Returns the raw JSON text of the response.
  Future<String> generateJson({required String prompt, required Map<String, Object> schema}) async {
    if (apiKey.isEmpty) throw const GeminiException('Add a Gemini API key in Settings first.');

    final response = await _client.post(
      Uri.https('generativelanguage.googleapis.com', '/v1beta/models/$defaultModel:generateContent'),
      headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {'responseMimeType': 'application/json', 'responseSchema': schema},
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GeminiException('Gemini request failed (${response.statusCode}): ${response.body}');
    }

    final top = jsonDecode(response.body);
    final text = top is Map ? _firstText(top) : null;
    if (text == null) {
      final preview = response.body.length > 300 ? response.body.substring(0, 300) : response.body;
      throw GeminiException("Couldn't understand Gemini's response: $preview");
    }
    return text;
  }

  String? _firstText(Map<dynamic, dynamic> top) {
    final candidates = top['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final parts = (candidates.first as Map)['content']?['parts'];
    if (parts is! List || parts.isEmpty) return null;
    return (parts.first as Map)['text'] as String?;
  }
}
