import 'package:flutter/material.dart';

import '../model/instrument_instance.dart';
import '../model/instrument_info.dart';
import '../model/client_info.dart';
import '../model/project_info.dart';
import '../model/send_form_mixin.dart';
import '../server_connection.dart';
import 'form_instance_edit.dart';

class FormInstanceEditScaffold extends StatelessWidget with SendFormMixin {
  FormInstanceEditScaffold(
      this._connection,
      this._projectInfo,
      this._clientInfo,
      this._instrumentInfo,
      this._instrumentInstance,
      this._titleText,
      this._sendFunction,
      {Key? key})
      : super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final ClientInfo _clientInfo;
  final InstrumentInfo _instrumentInfo;
  final InstrumentInstance _instrumentInstance;
  final String _titleText;
  final Future<void> Function(BuildContext) _sendFunction;

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
                    title: Text(_titleText),
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
                              _sendFunction),
                        ],
                      ));
                },
              ),
            )));
  }
}
