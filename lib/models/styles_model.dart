import 'dart:ui';

class Styles {
  Color? shadowColor;
  double? shadowOpacity;
  String? textSkip;
  ImageFilter? imageFilter;

  Styles(
      {this.shadowColor, this.shadowOpacity, this.textSkip, this.imageFilter});

  Styles.fromJson(Map<dynamic, dynamic> json) {
    shadowColor = json['shadowColor'];
    shadowOpacity = json['shadowOpacity'];
    textSkip = json['textSkip'];
    imageFilter = json['imageFilter'];
  }

  // Map<dynamic, dynamic> toJson() {
  //   final Map<dynamic, dynamic> data = new Map<dynamic, dynamic>();
  //   data['shadowColor'] = this.shadowColor;
  //   data['shadowOpacity'] = this.shadowOpacity;
  //   data['textSkip'] = this.textSkip;
  //   data['imageFilter'] = this.imageFilter;
  //   return data;
  // }
}
