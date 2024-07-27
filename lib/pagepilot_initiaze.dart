import 'dart:ui';

import 'package:flutter/material.dart';

import 'pagepilot.dart';
import 'src/controller/tutorial_controller.dart';
import 'src/model/tutorial_model.dart';

class TutorialInitiaze {
  TutorialInitiaze();

  Future<PagePilot> initialize(Map mapKeys) async {
    final TutorialController controller = TutorialController();
    List<TargetFocus> temp = [];
    await controller.syncTutorial().then((tutorials) {
      temp = _createTargets(tutorials, mapKeys);
    });
    return createTutorial(temp);
  }

  PagePilot createTutorial(List<TargetFocus> targets) {
    return PagePilot(
      targets: targets,
      colorShadow: Colors.red,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {},
      onClickTarget: (target) {},
      onClickTargetWithTapPosition: (target, tapDetails) {},
      onClickOverlay: (target) {},
      onSkip: () {},
    );
  }

  List<TargetFocus> _createTargets(List<Tutorial> tutorials, Map mapKeys) {
    List<TargetFocus> targets = [];
    for (var idx = 0; idx < tutorials.length; idx++) {
      if (tutorials[idx].isActive == true) {
        targets.add(
          TargetFocus(
            identify: tutorials[idx].selector!,
            keyTarget: mapKeys[tutorials[idx].selector!],
            contents: [
              TargetContent(
                align: ContentAlign.top,
                builder: (context, controller) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        tutorials[idx].content!.title!,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          tutorials[idx].content!.content!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      }
    }

    return targets;
  }
}
