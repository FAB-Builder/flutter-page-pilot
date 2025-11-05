import 'dart:ui';

import 'package:url_launcher/url_launcher.dart';

class Util {
  static bool isDarkMode = false;
  // static Color hexToColor(String hexString) {
  //   final buffer = StringBuffer();
  //   if (hexString.length == 6 || hexString.length == 7) {
  //     buffer.write('ff'); // Adds 'ff' for opacity if alpha is missing
  //   }
  //   buffer.write(hexString.replaceFirst('#', '')); // Removes the # if present
  //   return Color(int.parse(buffer.toString(), radix: 16));
  // }

  static Color hexToColor(String colorStr){
    final hexColorRegex = RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
    if (colorStr.startsWith("rgba")) {
      // Extract rgba values: rgba(r,g,b,a)
      final rgbaValues = colorStr.substring(5, colorStr.length - 1).split(",");
      return Color.fromRGBO(
        int.parse(rgbaValues[0].trim()),
        int.parse(rgbaValues[1].trim()),
        int.parse(rgbaValues[2].trim()),
        double.parse(rgbaValues[3].trim()),
      );
    } else if (colorStr.startsWith("rgb")) {
      // Extract rgb values: rgb(r,g,b), opacity = 1
      final rgbValues = colorStr.substring(4, colorStr.length - 1).split(",");
      return Color.fromRGBO(
        int.parse(rgbValues[0].trim()),
        int.parse(rgbValues[1].trim()),
        int.parse(rgbValues[2].trim()),
        1.0,
      );
    } else if (hexColorRegex.hasMatch(colorStr)) {
      // Handle hex colors with possible # and length 3, 6, 8
      String hex = colorStr.replaceFirst('#', '');
      if (hex.length == 3) {
        // Expand shorthand like 'abc' to 'aabbcc'
        hex = hex.split('').map((c) => c + c).join('');
      }
      if (hex.length == 6) {
        // Add 'ff' alpha if missing
        hex = 'ff' + hex;
      }
      int colorInt = int.parse(hex, radix: 16);
      return Color(colorInt);
    } else {
      throw UnsupportedError('Unsupported color format: $colorStr');
    }
  }

  static Future<void> launchInBrowser(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("ErrOr launching ${url}");
    }
  }
}
