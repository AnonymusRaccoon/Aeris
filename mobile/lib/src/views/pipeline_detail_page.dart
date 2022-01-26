import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/src/models/pipeline.dart';
import 'package:mobile/src/widgets/aeris_card_page.dart';

/// Class to get the pipeline's name in route's arguments
class PipelineDetailPageArguments {
  final Pipeline
      pipeline; // TODO Should be later defined as an int, to fetch from db, or as the object

  PipelineDetailPageArguments(this.pipeline);
}

// Page for a Pipeline's details
class PipelineDetailPage extends StatelessWidget {
  //final String pipelineName; // TODO Define as int later on
  const PipelineDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PipelineDetailPageArguments arguments = ModalRoute.of(context)!
        .settings
        .arguments as PipelineDetailPageArguments;
    Pipeline pipeline = arguments.pipeline;
    return AerisCardPage(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              flex: 7,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(pipeline.name,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                        )),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(pipeline.trigger.lastToString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 17,
                        )),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    ));
  }
}
