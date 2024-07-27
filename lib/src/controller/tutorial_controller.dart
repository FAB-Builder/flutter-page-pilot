import '../model/tutorial_model.dart';
import '../service/pagepilot_service.dart';

class TutorialController {
  Future<List<Tutorial>> syncTutorial() async {
    TutorialModel data = await TutorialService().getTutorialContent();
    List<Tutorial> tutorials = [];
    if (data.tutorials != null && data.tutorials!.isNotEmpty) {
      for (var idx = 0; idx < data.tutorials!.length; idx++) {
        if (data.tutorials![idx].isActive == true) {
          tutorials.add(data.tutorials![idx]);
        }
      }
    }
    return tutorials;
  }
}
