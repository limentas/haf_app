import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../logger.dart';
import '../storage.dart';
import '../user_info.dart';
import 'client_page.dart';
import 'form_instance_edit.dart';
import '../server_connection.dart';
import '../model/project_info.dart';
import '../model/instrument_instance.dart';
import '../model/forms_history_item.dart';

class NewClientPage extends StatelessWidget {
  NewClientPage(this._connection, this._projectInfo, {Key key})
      : _instrumentInstance = _projectInfo.initInstrument
            .instanceFromNonRepeatingForm(null, null),
        super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
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
                    title: Text("Новый участник"),
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
                              null,
                              _projectInfo.initInstrument,
                              _instrumentInstance,
                              sendData),
                          SliverOverlapInjector(
                            // This is the flip side of the SliverOverlapAbsorber
                            // above.
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                          ),
                        ],
                      ));
                },
              ),
            )));
  }

  Future<void> sendData(BuildContext context) async {
    try {
      var recordId = await _connection.createNewRecord(1, _instrumentInstance);
      if (recordId == null) {
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                'Ошибка добавления нового пользователя - свяжитесь с разработчиком')));
        return;
      }

      var secondaryId =
          _instrumentInstance.valuesMap[_projectInfo.secondaryIdFieldName];

      if (secondaryId.isEmpty) {
        logger.e("Couldn't get secondary id for the new created client");
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                'Ошибка добавления нового пользователя - свяжитесь с разработчиком')));
        return;
      }

      var historyItem = new FormsHistoryItem(
          tokenHash: UserInfo.tokenHash,
          createTime: DateTime.now(),
          lastEditTime: DateTime.now(),
          formName: _projectInfo.initInstrument.formNameId,
          secondaryId: secondaryId.first,
          instanceNumber: _instrumentInstance.number);
      Storage.addFormsHistoryItem(historyItem);

      await navigateToNewUser(recordId, context);
    } on TimeoutException catch (e) {
      logger.e("TimeoutException during creating new client", e);
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
              'Не удалось подключиться к серверу - повторите попытку позже')));
    }
  }

  Future<void> navigateToNewUser(int recordId, BuildContext context) async {
    try {
      var clientInfo = await _connection.retreiveClientInfoByRecordId(
          _projectInfo, recordId);
      if (clientInfo == null) {
        logger.e("Could not found recently added new record");
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                'Ошибка добавления нового пользователя - свяжитесь с разработчиком')));
        return;
      }

      var secondaryId = clientInfo.secondaryId;
      if (isEmpty(secondaryId)) {
        logger.e("Could not found secondary id for new record");
        Scaffold.of(context).showSnackBar(SnackBar(
            content: Text(
                'Ошибка добавления нового пользователя - свяжитесь с разработчиком')));
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ClientPage(_connection, _projectInfo, secondaryId, clientInfo),
        ),
      );
    } on SocketException catch (e) {
      logger.e("NewClientPage: caught SocketException", e);
    }
  }
}
