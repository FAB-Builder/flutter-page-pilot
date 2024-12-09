import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pagepilot/constants/constants.dart';
import 'package:pagepilot/models/config_model.dart';
import 'package:pagepilot/widgets/page_pilot_widgets.dart';
import 'package:http/http.dart' as http;

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
      Uri.parse("$baseUrl/get/unacknowledged?userId=${config.userId}"),
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
          "body": "this is the body of ${type}",
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
              "body": "this is the body of ${type}",
              "type": "dialog",
            },
            {
              "element": "#tooltip",
              "shape": "rect",
              "title": "This is title",
              "body": "this is the body of ${type}",
              "type": "tooltip",
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
      String? title = jsonResponse["content"]["title"];
      String? body = jsonResponse["content"]["body"];
      String? url = jsonResponse["content"]["url"];

      if (jsonResponse["screen"].toString().toLowerCase() ==
          screen.toLowerCase()) {
        if ((title != null && body != null) || url != null) {
          showWidget(context, jsonResponse, config);
        } else {
          throw Exception(
            "PagePilotPluginError: Either provide title & body or html for ${jsonResponse["content"]["element"].toString()}",
          );
        }
      }
    }
  } catch (e) {
    print(e);
  }
}

showWidget(BuildContext context, dynamic jsonResponse, Config config) async {
  String shape = jsonResponse["content"]["shape"] ?? "rect";

  String? title = jsonResponse["content"]["title"];
  String? body = jsonResponse["content"]["body"];
  String? url = jsonResponse["content"]["url"];
  String? position = jsonResponse["content"]["position"];
  String? color = jsonResponse["content"]["color"];
  GlobalKey? key = config.keys[jsonResponse["content"]["element"].toString()];
  switch (jsonResponse["type"].toString().toLowerCase()) {
    case "dialog":
      PagePilot.showOkDialog(
        context,
        shape: shape,
        title: title,
        body: body,
        url: url,
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
        url: url,
        duration: int.tryParse(jsonResponse["timeout"].toString()) ?? 3000,
      );
      //acknowledge
      await http.get(
        Uri.parse(
          "$baseUrl/acknowledge?id=${jsonResponse["_id"]}",
        ),
      );
      break;
    case "tooltip":
    case "i":
    case "?":
      if (key == null) {
        throw Exception(
          "PagePilotPluginError: Key not found for ${jsonResponse["content"]["element"].toString()}",
        );
      }
      PagePilot.showTooltip(
        context,
        shape: shape,
        key: key,
        // title: jsonResponse["content"]["tour"][0]["title"],
        // description: jsonResponse["content"]["tour"][0]["description"],
        title: title ?? "",
        body: body ?? "",
      );
      await http.get(
        Uri.parse(
          "$baseUrl/acknowledge?id=${jsonResponse["_id"]}",
        ),
      );
      break;
    case "bottomsheet":
      PagePilot.showBottomSheet(
        context,
        title: title ?? "",
        body: body ?? "",
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
      if (key == null) {
        throw Exception(
          "PagePilotPluginError: Key not found for ${jsonResponse["content"]["element"].toString()}",
        );
      }
      // PagePilot.showPip(
      //   context,
      //   // shape: shape,
      //   key: key,
      // );
      break;
    case "beacon":
      if (key == null) {
        throw Exception(
          "PagePilotPluginError: Key not found for ${jsonResponse["content"]["element"].toString()}",
        );
      }
      PagePilot.showBeacon(
        context,
        shape: shape,
        key: key,
        beaconPosition: position == null ? "center" : position!.toLowerCase(),
        title: title ?? "",
        body: body ?? "",
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

      break;
    case "tour":
    case "walktrough":
      // List<dynamic> tours = [];
      for (int i = 0; i < jsonResponse["content"]["tourContent"].length; i++) {
        // tours.add(
        //   jsonResponse["content"]["tourContent"][i],
        // );
        showWidget(
          context,
          {
            "content": jsonResponse["content"]["tourContent"][i],
            "type": jsonResponse["content"]["tourContent"][i]["type"],
            "timeout":
                jsonResponse["content"]["tourContent"][i]["timeout"] ?? null,
          },
          jsonResponse["content"]["tourContent"]["element"],
        );
      }

      //KEYCHANGE: "description" => "body"
      // PagePilot.showTour(context, config, tours: tours);

      await http.get(
        Uri.parse(
          "$baseUrl/acknowledge?id=${jsonResponse["_id"]}",
        ),
      );
      break;
  }
}
