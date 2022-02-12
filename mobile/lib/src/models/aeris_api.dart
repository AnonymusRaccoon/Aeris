import 'dart:async';

import 'package:aeris/src/main.dart';
import 'package:aeris/src/models/action.dart';
import 'package:aeris/src/models/action_template.dart';
import 'package:aeris/src/models/pipeline.dart';
import 'package:aeris/src/models/reaction.dart';
import 'package:aeris/src/models/service.dart';
import 'package:aeris/src/models/trigger.dart';

/// Call to interact with Aeris' Back end
class AerisAPI {
  late List<Pipeline> fakeAPI;

  AerisAPI() {
    var trigger1 = Trigger(
        service: const Service.spotify(),
        name: "Play song",
        last: DateTime.now());
    var trigger3 = Trigger(
        service: const Service.discord(),
        name: "Send a message",
        last: DateTime.now());
    var trigger2 = Trigger(
        service: const Service.spotify(),
        name: "Play song",
        last: DateTime.parse("2022-01-01"));
    var reaction = Reaction(
        service: const Service.twitter(), parameters: {}, name: "Post a tweet");
    var pipeline1 = Pipeline(
        id: 10,
        name: "My Action",
        triggerCount: 1,
        enabled: true,
        trigger: trigger1,
        reactions: [reaction]);
    var pipeline2 = Pipeline(
        id: 10,
        name: "My very long action Action",
        triggerCount: 10,
        enabled: true,
        trigger: trigger2,
        reactions: [reaction, reaction]);
    var pipeline3 = Pipeline(
        id: 10,
        name: "Disabled",
        triggerCount: 3,
        enabled: false,
        trigger: trigger3,
        reactions: [reaction]);
    fakeAPI = [
      pipeline3,
      pipeline2,
      pipeline1,
      pipeline3,
      pipeline2,
      pipeline1,
      pipeline3,
      pipeline2,
      pipeline1
    ];
  }

  /// Adds new pipeline to API
  Future<void> createPipeline(Pipeline newPipeline) {
    ///TODO Send Pipeline to API
    fakeAPI.add(newPipeline);
    return Future.delayed(Duration.zero);
  }

  /// Removes pipeline to API
  Future<void> removePipeline(Pipeline pipeline) {
    ///TODO Send delete request to API
    fakeAPI.remove(pipeline);
    return Future.delayed(Duration.zero);
  }

  Future<void> updatePipeline(Pipeline updatedPipeline) {
    ///TODO Send update request to API
    for (var pipeline in fakeAPI) {
      if (pipeline.id == updatedPipeline.id) {
        pipeline = updatedPipeline;
        break;
      }
    }

    return Future.delayed(Duration.zero);
  }

  /// Fetches the Pipelines from the API
  Future<List<Pipeline>> getPipelines() async {
    /// TODO Fetch the API
    await Future.delayed(const Duration(seconds: 1));
    return fakeAPI;
  }

  /// Disconnects the user form the service
  Future<void> disconnectService(Service service) {
    ///TODO disconnect service from user
    return Future.delayed(Duration.zero);
  }

  Future<List<ActionTemplate>> getActionsFor(
      Service service, Action action) async {
    await Future.delayed(Duration.zero);
    if (action is Trigger) {
      ///TODO get triggers
    } else if (action is Reaction) {
      ///TODO get reactions
    }
    return [
      for (int i = 0; i <= 10; i++)
        ActionTemplate(
            service: service,
            name: "action$i",
            parameters: {'key1': 'value1', 'key2': 'value2'})
    ];
  }
}
