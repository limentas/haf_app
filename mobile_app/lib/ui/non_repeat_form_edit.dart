import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../logger.dart';
import '../model/instrument_instance.dart';
import '../model/instrument_info.dart';
import '../model/client_info.dart';
import '../model/project_info.dart';
import '../model/send_form_mixin.dart';
import '../server_connection.dart';
import 'form_instance_edit.dart';

class NonRepeatFormEdit extends StatelessWidget with SendFormMixin {
  NonRepeatFormEdit(this._connection, this._projectInfo, this._clientInfo,
      this._instrumentInfo, this._recordId,
      {Key? key})
      : _instrumentInstance = _instrumentInfo.instanceFromNonRepeatingForm(
            _clientInfo, _clientInfo.valuesMap),
        super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final ClientInfo _clientInfo;
  final InstrumentInfo _instrumentInfo;
  final int _recordId;
  final InstrumentInstance _instrumentInstance;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomInset: false,
        //Took this from flutter docs examples: https://api.flutter.dev/flutter/widgets/NestedScrollView-class.html
        body: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  // This widget takes the overlapping behavior of the SliverAppBar,
                  // and redirects it to the SliverOverlapInjector below. If it is
                  // missing, then it is possible for the nested "inner" scroll view
                  // below to end up under the SliverAppBar even when the inner
                  // scroll view thinks it has not been scrolled.
                  // This is not necessary if the "headerSliverBuilder" only builds
                  // widgets that do not overlap the next sliver.
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    title: Text("Редактирование ${_instrumentInfo.formName}",
                        style: Theme.of(context).textTheme.titleLarge),
                    centerTitle: true,
                    floating: true,
                    pinned: false,
                    forceElevated: innerBoxIsScrolled,
                  ),
                )
              ];
            },
            body: SafeArea(
              top: true,
              bottom: true,
              child: Builder(
                // This Builder is needed to provide a BuildContext that is
                // "inside" the NestedScrollView, so that
                // sliverOverlapAbsorberHandleFor() can find the
                // NestedScrollView.
                builder: (BuildContext context) {
                  return Padding(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: CustomScrollView(
                        // The "controller" and "primary" members should be left
                        // unset, so that the NestedScrollView can control this
                        // inner scroll view.
                        // If the "controller" property is set, then this scroll
                        // view will not be associated with the NestedScrollView.
                        // The PageStorageKey should be unique to this ScrollView;
                        // it allows the list to remember its scroll position when
                        // the tab view is not on the screen.
                        slivers: <Widget>[
                          SliverOverlapInjector(
                            // This is the flip side of the SliverOverlapAbsorber
                            // above.
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                          ),
                          FormInstanceEdit(
                              _connection,
                              _projectInfo,
                              _clientInfo,
                              _instrumentInfo,
                              _instrumentInstance,
                              _sendData),
                        ],
                      ));
                },
              ),
            )));
  }

  Future<void> _sendData(BuildContext context) async {
    try {
      var result = await sendFormAndAddToHistory(_connection, _clientInfo,
          _instrumentInfo, _recordId, _instrumentInstance);

      if (!result) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Ошибка добавления данных - свяжитесь с разработчиком')));
        return;
      }

      //Return to the previous view.
      //Result is sign: do we need to refresh current client's info
      Navigator.pop(context, true);
    } on SocketException catch (e) {
      logger.e("SocketException during sending form", error: e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Не удалось подключиться к серверу - повторите попытку позже')));
    }
  }
}
