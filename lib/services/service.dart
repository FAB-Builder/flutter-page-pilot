import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pagepilot/constants/constants.dart';
import 'package:pagepilot/models/config_model.dart';
import 'package:pagepilot/models/step_model.dart';
import 'package:pagepilot/widgets/page_pilot_widgets.dart';

void doShow({
  required BuildContext context,
  required String screen,
  required Config config,
  String? type,
}) async {
  try {
    PagePilot.initStyles(config.styles);
    var jsonResponse;

    var response = await http.get(
      Uri.parse(
          "$baseUrl/tenant/${Config.tenantId}/client/unacknowledged?userId=${Config.userId}&device=${Platform.operatingSystem}&slug=${screen}"),
    );

    //mock data
    if (type != null) {
      jsonResponse = {
        "type": type,
        "content": {
          "shape": "react", //rect or circle
          // "element": "#dialog",
          // "element": "#tooltip",
          "element": "#beacon",
          "title": "This is title",
          "body": "this is the body of $type",
          // "tour": [
          //   {
          //     "title": "This is title",
          //     // "description": "this is the body of ${type}",
          //     "body": "this is the body of ${type}",
          //   },
          // ],//why extra tour array required ????
          "tourContent": [
            {
              "element": "#dialog",
              "shape": "rect",
              "title": "This is title",
              // "description": "this is the body of ${type}",
              "body": "this is the body of $type",
            },
            {
              "element": "#tooltip",
              "shape": "rect",
              "title": "This is title",
              // "description": "this is the body of ${type}",
              "body": "this is the body of $type",
            }
          ],
        }
      };
    } else {
      if (response.body != "null") {
        jsonResponse = jsonDecode(response.body);
      }
    }

    if (response.body != "null") {
      List<dynamic> tours = [];
      List<dynamic> tooltips = [];
      if (jsonResponse["tooltips"].length > 0) {
        tooltips = jsonResponse["tooltips"];
      }
      if (jsonResponse["tours"].length > 0) {
        tours = jsonResponse["tours"];
      }

      tooltips.forEach((tooltip) async {
        String slug = tooltip["slug"];
        if (slug == screen) {
          showWidget(
            "tooltip",
            tooltip["id"],
            [StepModel.fromJson(tooltip["step"])],
            config,
            context,
          );
        }
      });
      tours.forEach((tour) async {
        String slug = tour["slug"];
        List<StepModel> steps = [];
        for (int i = 0; i < tour["steps"].length; i++) {
          steps.add(StepModel.fromJson(tour["steps"][i]));
        }
        if (slug == screen) {
          showWidget(
            "tour",
            tour["id"],
            steps,
            config,
            context,
          );
        }
      });
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

acknowledge(id, userId, type) async {
  await http.get(
    Uri.parse(
        "$baseUrl/tenant/${Config.tenantId}/client/acknowledge?id=$id&userId=$userId&device=${Platform.operatingSystem}&type=$type"),
  );
}

void showWidget(String type, String id, List<StepModel> data, Config config,
    BuildContext context) async {
  String? shape,
      title,
      body,
      height,
      width,
      url,
      position,
      color,
      background,
      textColor,
      selector;
  int? scale;
  GlobalKey? key;
  bool showConfetti = false, isDraggable = false;
  if (type != "tour") {
    shape = data[0].shape ?? "rect";

    title = data[0].title;
    body = data[0].content;
    height = data[0].height;
    width = data[0].width;
    background = data[0].background ?? "#ffffff";
    textColor = data[0].textColor ?? "#000000";
    showConfetti = data[0].showConfetti ?? false;

    url = data[0].url;
    //TODO adjust scale from frontend(cs) first
    scale = null;
    // scale =
    //     int.tryParse(jsonResponse["content"]["bodyHtmlScale"].toString());
    isDraggable = data[0].draggable ?? false;
    position = data[0].position;
    color = data[0].color;
    selector = data[0].selector;
    key = config.keys[selector.toString()];
  }

  PagePilot.showConfetti = showConfetti;

  if (((body != null) || url != null) || type == "tour") {
    switch (type) {
      case "tooltip":
      case "i":
      case "?":
        if (key == null) {
          throw Exception(
            "PagePilotPluginError: Key not found for ${selector.toString()}",
          );
        }
        PagePilot.showTooltip(
          context,
          shape: shape ?? "rect",
          key: key,
          scale: scale,
          background: background,
          textColor: textColor,
          // title: jsonResponse["content"]["tour"][0]["title"],
          // description: jsonResponse["content"]["tour"][0]["description"],
          title: title,
          body: body ?? "",
          contentHeight: height,
          contentWidth: width,
          position: position,
        );
        await acknowledge(id, Config.userId, type);
        break;
      case "tour":
      case "walktrough":

        //KEYCHANGE: "description" => "body"
        PagePilot.showTour(context, config,
            tours: data, scrollController: config.scrollController);

        await acknowledge(id, Config.userId, type);
        break;

      /*case "dialog":
        PagePilot.showOkDialog(
          context,
          shape: shape ?? "rect",
          title: title,
          body: body,
          background: background,
          textColor: textColor,
          url: url,
          scale: scale,
          onOkPressed: () async {
            await http.get(
              Uri.parse(
                "$baseUrl/acknowledge?id=${jsonResponse["_id"]}",
              ),
            );
          },
        );
        break;
      case "snackbar":
      case "snack":
      case "toast":
        PagePilot.showSnackbar(
          context,
          title: title,
          body: body,
          background: background,
          textColor: textColor,
          url: url,
          scale: scale,
          duration: int.tryParse(jsonResponse["timeout"].toString()) ?? 3000,
        );
        //acknowledge
        await http.get(
          Uri.parse(
            "$baseUrl/acknowledge?id=${jsonResponse["_id"]}",
          ),
        );
        break;
      case "bottomsheet":
        PagePilot.showBottomSheet(
          context,
          title: title,
          body: body,
          background: background,
          textColor: textColor,
          url: url,
          scale: scale,
          onOkPressed: () async {
            await http.get(
              Uri.parse(
                "$baseUrl/acknowledge?id=${jsonResponse["_id"]}",
              ),
            );
          },
        );
        break;
      // case "spotlight":
      //   break;
      case "pip":
      case "floatingwidget":
        PagePilot.showFloatingWidget(
          context,
          title: title,
          body: body,
          background: background,
          textColor: textColor,
          url: url,
          position: position,
          scale: scale,
          isDraggable: isDraggable,
          isVisible: true,
        );
        await http.get(
          Uri.parse(
            "$baseUrl/acknowledge?id=${jsonResponse["_id"]}",
          ),
        );
        break;
      case "beacon":
        if (key == null) {
          throw Exception(
            "PagePilotPluginError: Key not found for ${jsonResponse["content"]["element"].toString()}",
          );
        }
        PagePilot.showBeacon(
          context,
          shape: shape ?? "rect",
          key: key,
          beaconPosition: position == null ? "center" : position.toLowerCase(),
          title: title,
          body: body ?? "",
          background: background,
          textColor: textColor,
          color: color == null
              ? Colors.blue.withOpacity(0.5)
              : PagePilot.hexToColor(color),
          onBeaconClicked: () async {
            //acknowledge
            await http.get(
              Uri.parse(
                "$baseUrl/acknowledge?id=${jsonResponse["_id"]}",
              ),
            );
          },
          // title: jsonResponse["content"]["tour"][0]["title"],
          // description: jsonResponse["content"]["tour"][0]["description"],
        );

        break;*/
    }
  } else {
    throw Exception(
      "PagePilotPluginError: Either provide title & body or html for $type  and key: ${data[0].selector.toString()}",
    );
  }
}
