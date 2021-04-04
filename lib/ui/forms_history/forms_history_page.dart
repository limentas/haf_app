import 'package:flutter/material.dart';
import 'package:haf_spb_app/model/saved_form.dart';
import 'package:haf_spb_app/ui/forms_history/last_sent_forms_tab.dart';

import '../../model/instrument_instance.dart';
import '../../model/project_info.dart';
import '../../server_connection.dart';
import 'saved_forms_tab.dart';

class FormsHistoryPage extends StatelessWidget {
  FormsHistoryPage(this._connection, this._projectInfo, {Key key})
      : _instrumentInstance = _projectInfo.initInstrument
            .instanceFromNonRepeatingForm(null, null),
        super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final InstrumentInstance _instrumentInstance;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: new Scaffold(
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
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                      sliver: SliverAppBar(
                          title: Text("Журнал"),
                          centerTitle: true,
                          floating: true,
                          pinned: true,
                          forceElevated: innerBoxIsScrolled,
                          bottom: TabBar(indicatorColor: Colors.black, tabs: [
                            Tab(
                                child: Text(
                              "Сохраненные формы (не отправленные)",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            )),
                            Tab(
                                child: Text(
                              "Последние отредактированные формы",
                              maxLines: 2,
                              textAlign: TextAlign.center,
                            ))
                          ])),
                    )
                  ];
                },
                body: SafeArea(
                    top: false,
                    bottom: false,
                    child: TabBarView(
                        // These are the contents of the tab views, below the tabs.
                        children: [
                          buildTabPage(
                              SavedFormsTab(_connection, _projectInfo)),
                          buildTabPage(
                              LastSentFormsTab(_connection, _projectInfo))
                        ])))));
  }

  Widget buildTabPage(Widget child) {
    return Builder(builder: (BuildContext context) {
      return CustomScrollView(physics: const AlwaysScrollableScrollPhysics(),
          // The "controller" and "primary" members should be left
          // unset, so that the NestedScrollView can control this
          // inner scroll view.
          // If the "controller" property is set, then this scroll
          // view will not be associated with the NestedScrollView.
          // The PageStorageKey should be unique to this ScrollView;
          // it allows the list to remember its scroll position when
          // the tab view is not on the screen.
          slivers: [
            SliverOverlapInjector(
              // This is the flip side of the SliverOverlapAbsorber
              // above.
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
            child
          ]);
    });
  }
}
