import 'package:flutter/material.dart';
import 'package:mobile/src/models/action.dart' as aeris;
import 'package:mobile/src/models/service.dart';
import 'package:mobile/src/models/trigger.dart';
import 'package:mobile/src/widgets/action_form.dart';
import 'package:mobile/src/widgets/aeris_card_page.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Class to get the action in route's arguments
class SetupActionPageArguments {
  aeris.Action action;

  SetupActionPageArguments(this.action);
}

///Page to setup an action
class SetupActionPage extends StatefulWidget {
  const SetupActionPage({Key? key}) : super(key: key);

  @override
  State<SetupActionPage> createState() => _SetupActionPageState();
}

class _SetupActionPageState extends State<SetupActionPage> {
  Service? serviceState;

  @override
  Widget build(BuildContext context) {
    final SetupActionPageArguments arguments =
        ModalRoute.of(context)!.settings.arguments as SetupActionPageArguments;

    serviceState ??= arguments.action.service;

    // TODO Call provider
    List<aeris.Action> availableActions = [
      for (int i = 0; i <= 10; i++)
        Trigger(
            last: DateTime.now(),
            service: arguments.action.service,
            name: "action",
            parameters: {'key1': 'value1', 'key2': 'value2'})
    ];

    final Widget serviceDropdown = DropdownButton<Service>(
      value: serviceState,
      elevation: 8,
      underline: Container(),
      onChanged: (service) {
        setState(() {
          serviceState = service;
          // TODO call api to get available actions
        });
      },
      items: Service.all().map<DropdownMenuItem<Service>>((Service service) {
        return DropdownMenuItem<Service>(
          value: service,
          child: Row(children: [
            service.getLogo(logoSize: 30),
            const SizedBox(
              width: 10,
              height: 100,
            ),
            Text(service.name, style: const TextStyle(fontSize: 20))
          ]),
        );
      }).toList(),
    );

    return AerisCardPage(
        body: Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
      child: ListView(
        children: [
          const Text("Setup Action",
              style: TextStyle(
                fontSize: 25,
              )),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${availableActions.length} ${AppLocalizations.of(context).avalableActionsFor} ",
                  )),
              Align(alignment: Alignment.centerRight, child: serviceDropdown),
            ],
          ),
          const SizedBox(height: 30),
          for (aeris.Action availableAction in availableActions) ...[
            Card(
              elevation: 5,
              child: ExpandablePanel(
                  header: Padding(
                      padding:
                          const EdgeInsets.only(left: 30, top: 20, bottom: 20),
                      child: Text(availableAction.name,
                          style: const TextStyle(fontSize: 15))),
                  collapsed: Container(),
                  expanded: Padding(
                    padding: const EdgeInsets.all(20),
                    child: ActionForm(
                        name: availableAction.name,
                        parametersNames:
                            availableAction.parameters.keys.toList(),
                        initValues: arguments.action.parameters,
                        onValidate: (parameters) {
                          arguments.action.service = serviceState!;
                          arguments.action.parameters = parameters;
                          arguments.action.name = availableAction.name;
                          Navigator.of(context).pop();
                        }),
                  )),
            ),
            const SizedBox(height: 10)
          ]
        ],
      ),
    ));
  }
}
