import 'package:pagepilot/models/step_model.dart';

class DataModel {
  String id;
  String? type;
  String? slug;
  List<StepModel> steps;

  DataModel(
      {required this.id, required this.type, required this.steps, this.slug});

  // Convert DataModel instance to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'slug': slug,
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }

  // Create DataModel instance from JSON map
  factory DataModel.fromJson(Map<String, dynamic> json, List<StepModel> steps) {
    return DataModel(
      id: json['id'],
      type: json['type'],
      slug: json['slug'],
      steps: steps,
    );
  }
}
