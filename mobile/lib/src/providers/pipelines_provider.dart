import 'package:aeris/src/models/aeris_api.dart';
import 'package:aeris/src/models/pipeline.dart';
import 'package:flutter/cupertino.dart';
import 'package:aeris/src/models/pipeline_collection.dart';
import 'package:aeris/src/models/reaction.dart';
import 'package:aeris/src/models/service.dart';
import 'package:aeris/src/models/trigger.dart';
import 'package:get_it/get_it.dart';

/// Provider class for Pipelines
class PipelineProvider extends ChangeNotifier {
  /// List of Pipelines stored in Provider
  late PipelineCollection pipelineCollection;

  PipelineProvider() {
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
    pipelineCollection = PipelineCollection(pipelines: [
      pipeline3,
      pipeline2,
      pipeline1,
      pipeline3,
      pipeline2,
      pipeline1,
      pipeline3,
      pipeline2,
      pipeline1
    ], sortingMethod: PipelineCollectionSort.last, sortingSplitDisabled: true);
  }

  /// Adds a pipeline in the Provider
  addPipeline(Pipeline newPipeline) {
    pipelineCollection.pipelines.add(newPipeline);
    GetIt.I<AerisAPI>().createPipeline(newPipeline);
    sortPipelines();
    notifyListeners();
  }

  /// Sets a new list of pipelines into the Provider
  setPipelineProvider(List<Pipeline> newPipelines) {
    pipelineCollection.pipelines = [];
    pipelineCollection.pipelines = newPipelines;
    sortPipelines();
  }

  /// Sort pipelines inside the Provider
  sortPipelines() {
    pipelineCollection.sort();
    notifyListeners();
  }

  /// Removes a specific pipeline from the Provider
  removePipeline(Pipeline pipeline) {
    pipelineCollection.pipelines.remove(pipeline);
    notifyListeners();
  }

  /// Removes every pipeline from the Provider
  clearProvider() {
    pipelineCollection.pipelines.clear();
    notifyListeners();
  }
}
