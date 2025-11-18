class StepModel {
  TriggerIcon? triggerIcon;
  TriggerLabel? triggerLabel;
  String? trigger;
  String? dismissalSetting;
  String? title;
  String? selector;
  Null? language;
  String? content;
  String? animationType;
  int? delay;
  bool? isBackdrop;
  bool? isCaret;
  String? position;
  String? triggerMode;
  String? id;
  String? shape;
  String? background;
  String? textColor;
  bool? showConfetti;
  bool? draggable;
  String? url;
  String? color;
  String? width;
  String? height;
  String? backgroundColor;
  int? borderRadius;

  StepModel({
    this.triggerIcon,
    this.triggerLabel,
    this.trigger,
    this.dismissalSetting,
    this.title,
    this.selector,
    this.language,
    this.content,
    this.animationType,
    this.delay,
    this.isBackdrop,
    this.isCaret,
    this.position,
    this.triggerMode,
    this.id,
    this.shape,
    this.background,
    this.textColor,
    this.showConfetti,
    this.draggable,
    this.url,
    this.color,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderRadius,
  });

  StepModel.fromJson(Map<String, dynamic> json) {
    triggerIcon = json['triggerIcon'] != null
        ? new TriggerIcon.fromJson(json['triggerIcon'])
        : null;
    triggerLabel = json['triggerLabel'] != null
        ? new TriggerLabel.fromJson(json['triggerLabel'])
        : null;
    trigger = json['trigger'];
    dismissalSetting = json['dismissalSetting'];
    title = json['title'];
    selector = json['selector'];
    language = json['language'];
    content = json['content'];
    animationType = json['animationType'];
    delay = json['delay'];
    isBackdrop = json['isBackdrop'];
    isCaret = json['isCaret'];
    position = json['position'];
    triggerMode = json['triggerMode'];
    id = json['id'];
    shape = json['shape'];
    background = json['background'];
    textColor = json['textColor'];
    showConfetti = json['showConfetti'];
    draggable = json['draggable'];
    url = json['url'];
    color = json['color'];
    height = json['height'];
    width = json['width'];
    backgroundColor = json['backgroundColor'];
    borderRadius = int.tryParse(json['borderRadius'] ?? "0");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.triggerIcon != null) {
      data['triggerIcon'] = this.triggerIcon!.toJson();
    }
    if (this.triggerLabel != null) {
      data['triggerLabel'] = this.triggerLabel!.toJson();
    }
    data['trigger'] = this.trigger;
    data['dismissalSetting'] = this.dismissalSetting;
    data['title'] = this.title;
    data['selector'] = this.selector;
    data['language'] = this.language;
    data['content'] = this.content;
    data['animationType'] = this.animationType;
    data['delay'] = this.delay;
    data['isBackdrop'] = this.isBackdrop;
    data['isCaret'] = this.isCaret;
    data['position'] = this.position;
    data['triggerMode'] = this.triggerMode;
    data['id'] = this.id;
    data['shape'] = this.shape;
    data['background'] = this.background;
    data['textColor'] = this.textColor;
    data['showConfetti'] = this.showConfetti;
    data['draggable'] = this.draggable;
    data['url'] = this.url;
    data['color'] = this.color;
    data['height'] = this.height;
    data['width'] = this.width;
    data['backgroundColor'] = this.backgroundColor;
    data['borderRadius'] = this.borderRadius;
    return data;
  }
}

class TriggerIcon {
  String? color;
  int? opacity;
  bool? isAnimated;
  String? type;

  TriggerIcon({this.color, this.opacity, this.isAnimated, this.type});

  TriggerIcon.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    opacity = json['opacity'];
    isAnimated = json['isAnimated'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['color'] = this.color;
    data['opacity'] = this.opacity;
    data['isAnimated'] = this.isAnimated;
    data['type'] = this.type;
    return data;
  }
}

class TriggerLabel {
  String? color;
  String? background;
  String? text;

  TriggerLabel({this.color, this.background, this.text});

  TriggerLabel.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    background = json['background'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['color'] = this.color;
    data['background'] = this.background;
    data['text'] = this.text;
    return data;
  }
}
