import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pagepilot/constants/constants.dart';
import 'package:pagepilot/models/config_model.dart';
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
          "$baseUrl/tenant/${Config.tenantId}/client/unacknowledged?userId=${Config.userId}"),
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
            tooltip["step"],
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

void showWidget(type, id, data, config, context) async {
  String? shape,
      title,
      body,
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
    shape = data["shape"] ?? "rect";

    // title = data["step"]["title"];
    // body = data["step"]["body"];
    background = data["background"];
    textColor = data["textColor"];
    showConfetti = data["showConfetti"] || false;

    url = data["url"];
    //TODO adjust scale from frontend(cs) first
    scale = null;
    // scale =
    //     int.tryParse(jsonResponse["content"]["bodyHtmlScale"].toString());
    isDraggable = data["draggable"] ?? false;
    position = data["position"];
    color = data["color"];
    selector = data["selector"];
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
        );
        await http.get(
          Uri.parse(
            "$baseUrl/acknowledge?id=${id}",
          ),
        );
        break;
      // case "tour":
      // case "walktrough":
      //   List<dynamic> tours = [];
      //   for (int i = 0; i < jsonResponse["tourContent"].length; i++) {
      //     tours.add(
      //       jsonResponse["tourContent"][i],
      //     );
      //   }

      //   //KEYCHANGE: "description" => "body"
      //   PagePilot.showTour(context, config,
      //       tours: tours, scrollController: config.scrollController!);

      //   await http.get(
      //     Uri.parse(
      //       "$baseUrl/acknowledge?id=${jsonResponse["_id"]}",
      //     ),
      //   );
      //   break;

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
      "PagePilotPluginError: Either provide title & body or html for ${type}  and key: ${data["selector"].toString()}",
    );
  }
}
