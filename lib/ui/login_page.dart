import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:haf_spb_app/model/empirical_evidence.dart';
import 'package:package_info/package_info.dart';

import '../storage.dart';
import '../location.dart';
import '../user_info.dart';
import '../logger.dart';
import '../model/project_info.dart';
import '../server_connection.dart';
import 'main_page.dart';
import 'svg_icon_button.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  _LoginPageState createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  final _tokenTextFieldController =
      TextEditingController(text: "--------------------------------");
  final _userTextFieldController = TextEditingController(text: "");
  final _tokenRegExp = RegExp(r'^(\d|[a-f]|[A-F]){32}$');
  final _tokenStorageKey = "API_TOKEN";
  final _fillCharacter = '-';
  final _userNameRegExp =
      RegExp(r'^[А-Я][а-я]*(-[А-Я][а-я]*)? [А-Я][а-я]*(-[А-Я][а-я]*)?$');
  final ServerConnection _connection = new ServerConnection();
  final _focusNode = new FocusNode();
  String _apiTokenFromStore;
  String _apiTokenFromStoreShadowed;
  String _tokenValidateError;
  bool _usingTokenFromStore = false;
  int _tokenToShowLinesCount = 0; //We can split
  bool _showBusyIndicator = false;
  String _busyMessage = '';
  String _lastOnChangedText = '';
  String _appVersion = "";
  String _deviceName = "";
  String _userNameError;

  int get tokenToShowLinesCount => _tokenToShowLinesCount;
  set tokenToShowLinesCount(value) {
    if (_tokenToShowLinesCount == value) return;
    if (!_usingTokenFromStore) {
      if (_tokenToShowLinesCount == 1) {
        _tokenTextFieldController.text =
            _tokenTextFieldController.text.replaceAll('\n', '');
      } else {
        var leftPart = _tokenTextFieldController.text.substring(0, 15);
        var rightPart = _tokenTextFieldController.text.substring(16, 31);
        _tokenTextFieldController.text = leftPart + '\n' + rightPart;
      }
    }
    _tokenToShowLinesCount = value;
  }

  ProjectInfo _projectInfo;

  void _focusListener() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Read api token
    final storage = new FlutterSecureStorage();
    storage.read(key: _tokenStorageKey).then((token) {
      if (token != null) {
        _apiTokenFromStore = token;
        _apiTokenFromStoreShadowed =
            _apiTokenFromStore.replaceRange(4, null, "*****");
        logger.i("Token was successfully loaded: $_apiTokenFromStoreShadowed");
        _tokenTextFieldController.text = _apiTokenFromStoreShadowed;
        setState(() {
          _usingTokenFromStore = true;
        });
      } else {
        logger.i("There is no stored token");
      }
    });

    PackageInfo.fromPlatform().then((value) => setState(() {
          _appVersion = "v${value.version}(${value.buildNumber})";
        }));

    UserInfo.init().then((value) => setState(() {
          _deviceName = UserInfo.deviceName;
        }));

    _focusNode.addListener(_focusListener);

    Storage.init().then((val) {
      final userName = Storage.getDefaultValue(
          EmpiricalEvidence.fellowWorkerUnifiedVariable);
      if (userName.isNotEmpty) {
        UserInfo.userName = userName.first;

        if (UserInfo.userName != null)
          _userTextFieldController.text = UserInfo.userName;
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_focusListener);
    _tokenTextFieldController.dispose();
    _userTextFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    logger.i(
        "Screen size = $screenSize, devicePixelRatio = ${MediaQuery.of(context).devicePixelRatio}");
    tokenToShowLinesCount = MediaQuery.of(context).size.width > 700 ? 1 : 2;
    return Scaffold(
        drawer: null,
        body: Stack(children: [
          SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: screenSize.height / 4),
                        TextField(
                            style: TextStyle(fontSize: 22),
                            textAlign: TextAlign.left,
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Фамилия и имя сотрудника",
                                helperText: "Пример: Иванов Иван",
                                errorText: _userNameError),
                            controller: _userTextFieldController,
                            onChanged: (newValue) {},
                            onEditingComplete: () {}),
                        SizedBox(height: 40),
                        InputDecorator(
                            isFocused: _focusNode.hasFocus,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Введите токен",
                              labelStyle: TextStyle(
                                  letterSpacing: 0,
                                  fontFamily: "",
                                  fontFeatures: []),
                              errorText: _tokenValidateError,
                            ),
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              Expanded(
                                  child: TextField(
                                      style: TextStyle(
                                          fontSize: 22,
                                          letterSpacing: 2,
                                          fontFamily: "monospace",
                                          fontFeatures: [
                                            FontFeature.tabularFigures()
                                          ]),
                                      decoration: null, //InputDecoration(),
                                      focusNode: _focusNode,
                                      textAlign: TextAlign.center,
                                      maxLines: _usingTokenFromStore
                                          ? 1
                                          : tokenToShowLinesCount,
                                      keyboardType: TextInputType.text,
                                      inputFormatters: _usingTokenFromStore
                                          ? null
                                          : [
                                              TextInputFormatter.withFunction(
                                                  idTextFormat)
                                            ],
                                      controller: _tokenTextFieldController,
                                      onChanged: (newValue) {
                                        if (newValue != _lastOnChangedText) {
                                          _lastOnChangedText = newValue;
                                          setState(() {
                                            if (_usingTokenFromStore) {
                                              _usingTokenFromStore = false;
                                              _tokenTextFieldController
                                                  .text = tokenToShowLinesCount ==
                                                      1
                                                  ? "--------------------------------"
                                                  : "----------------\n----------------";
                                            }
                                            _tokenValidateError = null;
                                          });
                                        }
                                      },
                                      onEditingComplete: () {
                                        submitToken();
                                      })),
                              SvgIconButton(
                                iconName: 'resources/icons/restore.svg',
                                width: 48,
                                height: 48,
                                onPressed: _usingTokenFromStore ||
                                        _apiTokenFromStore == null ||
                                        _apiTokenFromStore.isEmpty
                                    ? null
                                    : () {
                                        setState(() {
                                          _usingTokenFromStore = true;
                                          _tokenTextFieldController.text =
                                              _apiTokenFromStoreShadowed;
                                        });
                                      },
                              )
                            ])),
                        const SizedBox(height: 50),
                        ElevatedButton(
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15))),
                          child: Text('ВОЙТИ',
                              style: Theme.of(context).textTheme.button),
                          onPressed: () {
                            submitToken();
                          },
                        ),
                        SizedBox(height: 40),
                        Visibility(
                            visible: _showBusyIndicator,
                            child: SpinKitCircle(
                                size: 100,
                                color: Theme.of(context).primaryColor)),
                        SizedBox(height: 20),
                        Visibility(
                            visible:
                                _showBusyIndicator && _busyMessage.isNotEmpty,
                            child: Text(
                              _busyMessage,
                              style: Theme.of(context).textTheme.subtitle1,
                            ))
                      ]))),
          Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(10),
              child: Text(_appVersion,
                  style: Theme.of(context).textTheme.caption)),
          Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(10),
              child: Text("Устройство: $_deviceName",
                  style: Theme.of(context).textTheme.caption))
        ]));
  }

  void submitToken() async {
    if (!_userNameRegExp.hasMatch(_userTextFieldController.text)) {
      setState(() {
        _userNameError = "Введите фамилию и имя в формате 'Фамилия Имя'";
      });
      return;
    }

    setState(() {
      _userNameError = null;
    });

    UserInfo.userName = _userTextFieldController.text;
    Storage.setDefaultValue(
        EmpiricalEvidence.fellowWorkerUnifiedVariable, [UserInfo.userName]);

    var token = _usingTokenFromStore
        ? _apiTokenFromStore
        : _tokenTextFieldController.text.replaceAll(RegExp(r'-|\n'), '');

    if (!_usingTokenFromStore) {
      logger.d("Checking token from user = '$token'");
      if (!_tokenRegExp.hasMatch(token)) {
        setState(() {
          _tokenValidateError =
              "Токен - это строка из 32-х шестнадцатиричных цифр";
        });
        return;
      }
    }

    FocusScope.of(context).unfocus();

    try {
      setState(() {
        _showBusyIndicator = true;
        _busyMessage = "Проверяем...";
      });
      _connection.setToken(token);
      var checkResult = await _connection.checkAccess();
      if (!checkResult) {
        setState(() {
          _tokenValidateError = "Не удалось авторизоваться. Проверьте токен.";
        });
        return;
      }

      if (!_usingTokenFromStore) {
        var saveResult = await saveToken(token);
        if (!saveResult) {
          logger.e("Error saving token to storage");
          return;
        }

        setState(() {
          _usingTokenFromStore = true;
          _apiTokenFromStore = token;
          _apiTokenFromStoreShadowed =
              _apiTokenFromStore.replaceRange(4, null, "*****");
          _tokenTextFieldController.text = _apiTokenFromStoreShadowed;
        });
      }

      var locationFuture = Location.init();

      UserInfo.tokenHash = _apiTokenFromStore;

      setState(() {
        _showBusyIndicator = true;
        _busyMessage = "Получаем данные...";
      });

      var projectXml = await _connection.retreiveProjectXml();
      _projectInfo = ProjectInfo.fromXml(projectXml);
      if (_projectInfo == null) {
        setState(() {
          _tokenValidateError =
              "Ошибка разбора структуры проекта. Свяжитесь с разработчиком.";
        });
        return;
      }

      await locationFuture;

      if (Location.inited)
        logger.i("Location: ${Location.latitude}:${Location.longitude}" +
            ":${Location.altitude}");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MainPage(_connection, _projectInfo, _appVersion, _deviceName),
        ),
      );
    } on SocketException catch (e) {
      logger.e("LoginPage: caught SocketException", e);
      setState(() {
        _tokenValidateError =
            "Не удалось подключиться к серверу. Проверьте подключение к Интернет.";
      });
    } on TimeoutException catch (e) {
      logger.e("LoginPage: caught TimeoutException", e);
      setState(() {
        _tokenValidateError =
            "Не удалось подключиться к серверу. Проверьте подключение к Интернет.";
      });
    } finally {
      setState(() {
        _showBusyIndicator = false;
        _busyMessage = "";
      });
    }
  }

  Future<bool> saveToken(String token) async {
    // Write api token
    logger.d("Saving token to secure storage");
    final storage = new FlutterSecureStorage();
    try {
      await storage.write(key: _tokenStorageKey, value: token);
      return true;
    } on PlatformException catch (e) {
      logger.e("PlatformException caught", e);
      return false;
    }
  }

  TextEditingValue idTextFormat(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text == newValue.text) return newValue;
    logger.v("oldValue=${oldValue.text}, newValue=$newValue");
    var newValueText = _usingTokenFromStore
        ? ''
        : newValue.text.replaceAll(RegExp(r'-|\n'), '');
    if (tokenToShowLinesCount == 1) {
      return newValue.copyWith(text: newValueText.padRight(32, _fillCharacter));
    }
    String resultText;
    int cursorOffset;
    var cursorAtTheEnd =
        newValue.selection.baseOffset >= newValue.text.length ||
            newValue.text[newValue.selection.baseOffset] == _fillCharacter;
    if (newValueText.length < 16) {
      resultText = newValueText.padRight(16, _fillCharacter) +
          '\n'.padRight(17, _fillCharacter);
      cursorOffset =
          cursorAtTheEnd ? newValueText.length : newValue.selection.baseOffset;
    } else {
      resultText = newValueText.substring(0, 16) +
          '\n' +
          newValueText
              .substring(
                16,
                min(newValueText.length, 32),
              )
              .padRight(16, _fillCharacter);
      cursorOffset = cursorAtTheEnd
          ? min(newValueText.length + 1, 33)
          : newValue.selection.baseOffset;
    }
    var result = newValue.copyWith(
        text: resultText,
        selection:
            TextSelection.fromPosition(TextPosition(offset: cursorOffset)),
        composing: TextRange.empty);
    logger.v("result = $result");
    return result;
  }
}
