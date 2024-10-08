import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:pagepilot/models/config_model.dart';
import 'package:pagepilot/widgets/page_pilot_widgets.dart';
import 'package:http/http.dart' as http;

void doShow(
  BuildContext context,
  Config config, {
  Widget? widget,
  String? type,
}) async {
  try {
    PagePilot.initStyles(config.styles);
    var jsonResponse;

    var response = await http.get(
      Uri.parse(
          "https://asia-south1.gcp.data.mongodb-api.com/app/mock-wallet-vrughwh/endpoint/ahd/get/unacknowledged"),
    );

    //mock data
    if (type != null) {
      jsonResponse = {
        "type": type,
        "shape": "react", //rect or circle
        "content": {
          // "element": "#dialog",
          // "element": "#tooltip",
          "element": "#beacon",
          "title": "This is title",
          "body": "this is the body of ${type}",
          "tour": [
            {
              "title": "This is title",
              "description": "this is the body of ${type}",
            },
          ],
          "tourContent": [
            {
              "element": "#dialog",
              "shape": "rect",
              "title": "This is title",
              "description": "this is the body of ${type}",
            },
            {
              "element": "#tooltip",
              "shape": "rect",
              "title": "This is title",
              "description": "this is the body of ${type}",
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
      String shape = jsonResponse["content"]["shape"] ?? "rect";

      switch (jsonResponse["type"].toString().toLowerCase()) {
        case "dialog":
          PagePilot.showOkDialog(
            context,
            shape: shape,
            key: config.keys[jsonResponse["content"]["element"].toString()],
            title: jsonResponse["content"]["title"],
            description: jsonResponse["content"]["body"],
            onOkPressed: () async {
              await http.get(
                Uri.parse(
                  "https://asia-south1.gcp.data.mongodb-api.com/app/mock-wallet-vrughwh/endpoint/ahd/acknowledge?id=${jsonResponse["_id"]}",
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
            title: jsonResponse["content"]["title"],
            body: jsonResponse["content"]["body"],
            duration: int.tryParse(jsonResponse["timeout"].toString()) ?? 3000,
          );
          //acknowledge
          await http.get(
            Uri.parse(
              "https://asia-south1.gcp.data.mongodb-api.com/app/mock-wallet-vrughwh/endpoint/ahd/acknowledge?id=${jsonResponse["_id"]}",
            ),
          );
          break;
        case "tooltip":
        case "i":
        case "?":
          // if (widget == null) {
          //   throw new Exception("Tooltip requires widget parameter");
          // }
          PagePilot.showTooltip(
            context,
            shape: shape,
            key: config.keys[jsonResponse["content"]["element"].toString()],
            title: jsonResponse["content"]["tour"][0]["title"],
            description: jsonResponse["content"]["tour"][0]["description"],
          );
          break;
        case "bottomsheet":
          PagePilot.showBottomSheet(
            context,
            title: jsonResponse["content"]["title"],
            body: jsonResponse["content"]["body"],
            onOkPressed: () async {
              await http.get(
                Uri.parse(
                  "https://asia-south1.gcp.data.mongodb-api.com/app/mock-wallet-vrughwh/endpoint/ahd/acknowledge?id=${jsonResponse["_id"]}",
                ),
              );
            },
          );
          break;
        // case "spotlight":
        //   break;
        case "pip":
          PagePilot.showPip(
            context,
            // shape: shape,
            key: config.keys[jsonResponse["content"]["element"].toString()],
          );
          break;
        case "beacon":
          PagePilot.showBeacon(
            context,
            shape: shape,
            key: config.keys[jsonResponse["content"]["element"].toString()],
          );
          //acknowledge
          await http.get(
            Uri.parse(
              "https://asia-south1.gcp.data.mongodb-api.com/app/mock-wallet-vrughwh/endpoint/ahd/acknowledge?id=${jsonResponse["_id"]}",
            ),
          );
          break;
        case "tour":
        case "walktrough":
          List<dynamic> tours = [];
          for (int i = 0;
              i < jsonResponse["content"]["tourContent"].length;
              i++) {
            tours.add(
              jsonResponse["content"]["tourContent"][i],
            );
          }

          PagePilot.showTour(context, config, tours: tours);
          break;
      }
    }
  } catch (e) {
    print(e);
  }
}
