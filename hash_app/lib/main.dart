import 'package:flutter/material.dart';
import 'package:hash_lib/hash_lib.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hashing application',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lightBlue,
        typography: Typography.material2018(),
      ),
      home: MyHomePage(title: 'Hashing application'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _inputTextController = TextEditingController();
  final _outputTextController = TextEditingController();
  final _inputRegexp = RegExp(r'^[0-9a-fA-F]+$');
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 100,
                ),
                TextFormField(
                  controller: _inputTextController,
                  style: TextStyle(fontSize: 22),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  autocorrect: false,
                  enableSuggestions: false,
                  //autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (text) {
                    if (_formKey.currentState?.validate() == true) {
                      var input = text.toUpperCase();
                      if (_inputTextController.text != input)
                        _inputTextController.text = input;
                      _outputTextController.text =
                          Hash.calc(_inputTextController.text);
                    } else
                      _outputTextController.text = "";
                  },
                  validator: (text) {
                    if (text == null || text.length != 32) {
                      return "Токен должен иметь длину 32 символа";
                    }
                    if (_inputRegexp.allMatches(text).isEmpty) {
                      return "Токен состоит из шестнадцатиричных цифр";
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Токен для хэширования",
                      helperText: "Пример: 00112233445566778899AABBCCDDEEFF"),
                ),
                SizedBox(
                  height: 50,
                ),
                TextField(
                  controller: _outputTextController,
                  style: TextStyle(fontSize: 22),
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  readOnly: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Результат",
                      suffix: IconButton(
                        icon: Icon(Icons.copy),
                        splashRadius: 24,
                        iconSize: 24,
                        onPressed: () {
                          if (_outputTextController.text.isNotEmpty)
                            Clipboard.setData(ClipboardData(
                                text: _outputTextController.text));
                        },
                      )),
                ),
              ],
            )),
      ),
    );
  }
}
