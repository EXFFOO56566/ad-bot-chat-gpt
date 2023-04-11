import 'dart:convert';

import 'package:http/http.dart' as http;

import '../helper/local_storage.dart';

class ApiServices {
  static var client = http.Client();

  static Future<String> generateResponse(String prompt) async {
    

    var url = Uri.https("api.openai.com", "/v1/completions");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        "Authorization": "Bearer ${LocalStorage.getChatGptApiKey()}"
      },
      body: json.encode({
        "model": "text-davinci-003",
        "prompt": prompt,
        'temperature': 0,
        'max_tokens': 2000,
        'top_p': 1,
        'frequency_penalty': 0.0,
        'presence_penalty': 0.0,
      }),
    );

    // Do something with the response
    Map<String, dynamic> newresponse = jsonDecode(utf8.decode(response.bodyBytes));

    return newresponse['choices'][0]['text'];
  }
}
