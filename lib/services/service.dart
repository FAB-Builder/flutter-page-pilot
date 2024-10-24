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
              // "description": "this is the body of ${type}",
              "body": "this is the body of ${type}",
            },
            {
              "element": "#tooltip",
              "shape": "rect",
              "title": "This is title",
              // "description": "this is the body of ${type}",
              "body": "this is the body of ${type}",
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
      String? shape, title, body, url, position, color;
      GlobalKey? key;
      if (jsonResponse["type"].toString() != "tour") {
        shape = jsonResponse["content"]["shape"] ?? "rect";

        title = jsonResponse["content"]["title"];
        body = jsonResponse["content"]["body"];
        url = jsonResponse["content"]["url"];
        position = jsonResponse["content"]["position"];
        color = jsonResponse["content"]["color"];
        key = config.keys[jsonResponse["content"]["element"].toString()];
      }

      if (jsonResponse["screen"].toString().toLowerCase() ==
          screen.toLowerCase()) {
        if (((title != null && body != null) || url != null) ||
            jsonResponse["type"].toString() == "tour") {
          switch (jsonResponse["type"].toString().toLowerCase()) {
            case "dialog":
              PagePilot.showOkDialog(
                context,
                shape: shape ?? "rect",
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
                duration:
                    int.tryParse(jsonResponse["timeout"].toString()) ?? 3000,
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
                shape: shape ?? "rect",
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
              PagePilot.showPip(
                context,
                // shape: shape,
                key: key,
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
                beaconPosition:
                    position == null ? "center" : position!.toLowerCase(),
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
              List<dynamic> tours = [];
              for (int i = 0; i < jsonResponse["tourContent"].length; i++) {
                tours.add(
                  jsonResponse["tourContent"][i],
                );
              }

              //KEYCHANGE: "description" => "body"
              PagePilot.showTour(context, config, tours: tours);

              await http.get(
                Uri.parse(
                  "$baseUrl/acknowledge?id=${jsonResponse["_id"]}",
                ),
              );
              break;
          }
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
