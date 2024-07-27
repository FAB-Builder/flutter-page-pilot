import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/tutorial_model.dart';

class TutorialService {
  Future getTutorialContent() async {
    try {
      var response = await http.get(
          Uri.parse(
              'https://pagepilot.fabbuilder.com/api/tenant/651456610067eba9d6188aac/client/context-tours?filter[isActive]=true'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          });

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        TutorialModel tutorialModel = TutorialModel.fromJson(jsonResponse);
        return tutorialModel;
      } else {
        throw Exception(response.reasonPhrase);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
