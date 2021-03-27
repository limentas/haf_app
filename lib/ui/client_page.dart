import 'package:flutter/material.dart';

import 'form_instance_details.dart';
import 'non_repeat_form_edit.dart';
import 'client_repeat_form_tab.dart';
import 'client_overview_tab.dart';
import '../model/client_info.dart';
import '../model/project_info.dart';
import '../model/instrument_info.dart';
import '../model/instrument_instance.dart';
import '../server_connection.dart';
import 'new_form_instance_edit.dart';
import 'svg_icon_button.dart';

class ClientPage extends StatefulWidget {
  ClientPage(
      this._connection, this._projectInfo, this._clientId, this._clientInfo,
      {Key key})
      : super(key: key);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final String _clientId;
  final ClientInfo _clientInfo;

  @override
  _ClientPageState createState() {
    return _ClientPageState(_connection, _projectInfo, _clientId, _clientInfo);
  }
}

class _ClientPageState extends State<ClientPage>
    with SingleTickerProviderStateMixin {
  _ClientPageState(this._connection, this._projectInfo, this._clientSecondaryId,
      this._clientInfo);

  final ServerConnection _connection;
  final ProjectInfo _projectInfo;
  final String _clientSecondaryId;
  ClientInfo _clientInfo;

  TabController _tabController;
  final _tabs = new List<Tab>();
  final _pages = new List<Widget>();
  final _floatingButtons = new List<Widget>();
  //Key - instrument nameId, value - index of corresponding tab
  final _tabIndexer = new Map<String, int>();

  @override
  void initState() {
    super.initState();

    //The overview page
    _tabs.add(Tab(text: "Обзор"));
    _floatingButtons.add(null);

    for (var instrument in _projectInfo.instrumentsByName.values) {
      var tab = Tab(
          child: Text(
        instrument.formName,
        maxLines: 2,
        textAlign: TextAlign.center,
      ));
      _tabIndexer[instrument.formNameId] = _tabs.length;
      _tabs.add(tab);
      _floatingButtons.add(instrument.isRepeating
          ? new SvgIconButton(
              iconName: 'resources/icons/plus.svg',
              width: 54,
              height: 54,
              iconWidth: 40,
              onPressed: () =>
                  _createNewInstrumentInstance(context, instrument))
          : _projectInfo.initInstrument != instrument
              ? new SvgIconButton(
                  iconName: 'resources/icons/edit.svg',
                  width: 54,
                  height: 54,
                  iconWidth: 32,
                  onPressed: () =>
                      _editNonRepeatInstrument(context, instrument))
              : null);
    }

    _tabController = TabController(vsync: this, length: _tabs.length);
    _tabController.addListener(_handleTabIndexChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabIndexChanged() {
    setState(() {});
  }

  void _preBuild(BuildContext context) {
    _pages.clear();
    //The overview page
    _pages.add(ClientOverviewTab(_projectInfo, _clientInfo, (instrumentNameId) {
      var index = _tabIndexer[instrumentNameId];
      if (index == null) return;
      _tabController.animateTo(index);
    }, (instrument) {
      _createNewInstrumentInstance(context, instrument);
    }));

    for (var instrument in _projectInfo.instrumentsByName.values) {
      var page = instrument.isRepeating
          ? ClientRepeatFormTab(
              _projectInfo,
              _clientInfo,
              instrument,
              _clientInfo.repeatInstruments[instrument.formNameId].values
                  .toList())
          : FormInstanceDetails(_projectInfo, _clientInfo, instrument,
              new InstrumentInstance(-1, _clientInfo.valuesMap), false);

      _pages.add(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    _preBuild(context);
    return new Scaffold(
      //Took this from flutter docs examples: https://api.flutter.dev/flutter/widgets/NestedScrollView-class.html
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              // This widget takes the overlapping behavior of the SliverAppBar,
              // and redirects it to the SliverOverlapInjector below. If it is
              // missing, then it is possible for the nested "inner" scroll view
              // below to end up under the SliverAppBar even when the inner
              // scroll view thinks it has not been scrolled.
              // This is not necessary if the "headerSliverBuilder" only builds
              // widgets that do not overlap the next sliver.
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                title: Text("Участник $_clientSecondaryId"),
                centerTitle: true,
                floating: true,
                pinned: true,
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(
                    indicatorColor: Colors.black,
                    tabs: _tabs,
                    controller: _tabController),
              ),
            )
          ];
        },
        body: TabBarView(
          controller: _tabController,
          // These are the contents of the tab views, below the tabs.
          children: _pages.map((Widget page) {
            return SafeArea(
              top: false,
              bottom: false,
              child: Builder(
                // This Builder is needed to provide a BuildContext that is
                // "inside" the NestedScrollView, so that
                // sliverOverlapAbsorberHandleFor() can find the
                // NestedScrollView.
                builder: (BuildContext context) {
                  return new RefreshIndicator(
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
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
                          page,
                        ],
                      ),
                      onRefresh: _refreshClientInfo);
                },
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: _getFloatingButton(),
    );
  }

  Widget _getFloatingButton() {
    return _floatingButtons[_tabController.index];
  }

  Future<void> _refreshClientInfo() async {
    var clientInfo = await _connection.retreiveClientInfoByRecordId(
        _projectInfo, _clientInfo.recordId);
    setState(() {
      _clientInfo = clientInfo;
    });
  }

  Future<void> _createNewInstrumentInstance(
      BuildContext context, InstrumentInfo instrument) async {
    var needRefresh = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewRepeatingFormInstanceEdit(_connection,
              _projectInfo, _clientInfo, instrument, _clientInfo.recordId),
        ));
    if (needRefresh != null && needRefresh) _refreshClientInfo();
  }

  Future<void> _editNonRepeatInstrument(
      BuildContext context, InstrumentInfo instrument) async {
    var needRefresh = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NonRepeatFormEdit(_connection, _projectInfo,
              _clientInfo, instrument, _clientInfo.recordId),
        ));
    if (needRefresh != null && needRefresh) _refreshClientInfo();
  }
}
