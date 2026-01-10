import 'dart:convert';
import 'package:http/http.dart' as http;

class MistralClient {
  final String apiKey;
  final String baseUrl;
  final http.Client _httpClient;

  MistralClient({
    required this.apiKey,
    this.baseUrl = 'https://api.mistral.ai/v1',
    http.Client? client,
  }) : _httpClient = client ?? http.Client();

  Future<String> chat({
    required String model,
    required List<Map<String, String>> messages,
    double? temperature,
    int? maxTokens,
    bool? safePrompt,
    int? randomSeed,
  }) async {
    final url = Uri.parse('$baseUrl/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
    };

    final body = {
      'model': model,
      'messages': messages,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (safePrompt != null) 'safe_prompt': safePrompt,
      if (randomSeed != null) 'random_seed': randomSeed,
    };

    final response = await _httpClient.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      if (jsonResponse['choices'] != null &&
          (jsonResponse['choices'] as List).isNotEmpty) {
        return jsonResponse['choices'][0]['message']['content'] as String;
      } else {
        throw Exception('Empty response from Mistral API: ${response.body}');
      }
    } else {
      throw Exception(
          'Failed to chat with Mistral API: ${response.statusCode} ${response.body}');
    }
  }

  Stream<String> streamChat({
    required String model,
    required List<Map<String, String>> messages,
    double? temperature,
    int? maxTokens,
    bool? safePrompt,
    int? randomSeed,
  }) async* {
    final url = Uri.parse('$baseUrl/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
      'Accept': 'text/event-stream',
    };

    final body = {
      'model': model,
      'messages': messages,
      'stream': true,
      if (temperature != null) 'temperature': temperature,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (safePrompt != null) 'safe_prompt': safePrompt,
      if (randomSeed != null) 'random_seed': randomSeed,
    };

    final request = http.Request('POST', url);
    request.headers.addAll(headers);
    request.body = jsonEncode(body);

    final response = await _httpClient.send(request);

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw Exception(
          'Failed to chat with Mistral API: ${response.statusCode} $body');
    }

    await for (final line in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6).trim();
        if (data == '[DONE]') break;
        
        try {
          final json = jsonDecode(data);
          if (json['choices'] != null && (json['choices'] as List).isNotEmpty) {
            final delta = json['choices'][0]['delta'];
            if (delta['content'] != null) {
              yield delta['content'] as String;
            }
          }
        } catch (e) {
          // Ignore parse errors for partial lines or keepalives
        }
      }
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
