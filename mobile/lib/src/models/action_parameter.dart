import 'package:flutter/material.dart';

/// Object representation of an action's parameter
class ActionParameter {
  /// Name of the action parameter
  final String name;

  /// Description of theparameter
  final String description;

  /// Value of the pamrameter
  Object? value;

  ActionParameter(
      {Key? key, required this.name, this.description = "", this.value});

  MapEntry<String, dynamic> toJson() => MapEntry(name, value);

  static List<ActionParameter> fromJSON(Map<String, dynamic> params) {
    List<ActionParameter> actionParameters = [];
    params.forEach((key, value) =>
        actionParameters.add(ActionParameter(name: key, value: value)));
    return actionParameters;
  }
}
