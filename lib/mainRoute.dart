import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'globalVars.dart' as globals;
import 'dart:async';
import 'package:jiffy/jiffy.dart';

class MainRoute extends StatefulWidget {
  @override
  _MainRouteState createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute> {
  static final baseURL = 'https://covid-19-data.p.rapidapi.com';
  static final formatter = new NumberFormat();
  static Map<String, String> get headers => {
        "x-rapidapi-host": "covid-19-data.p.rapidapi.com",
        "x-rapidapi-key": "102816ce5cmsh4c94ef763829602p170083jsnf5119ba0397f"
      };
  var textField = (type, value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Total $type ${type != 'deaths' ? 'cases' : ''}: ',
              style: new TextStyle(fontSize: 50)),
          Text('${formatter.format(value)}',
              style: new TextStyle(fontSize: 50)),
        ],
      );
  static var confirmed = 0;
  static var recovered = 0;
  static var critical = 0;
  static var deaths = 0;
  static final time = const Duration(seconds: 900);
  static var lastUpdate;
  static var lastUpdateRelative;

  @override
  void initState() {
    super.initState();
    getTotal();
    new Timer.periodic(time, (Timer t) => getTotal());
    new Timer.periodic(
        const Duration(seconds: 1), (Timer t) => updateRelativeTime());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Route"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Hello ' + globals.currentUser + '!',
                      style: new TextStyle(fontSize: 30)),
                  Text(
                    'Live Covid-19 statistics',
                    style: new TextStyle(fontSize: 30),
                  ),
                  Padding(padding: const EdgeInsets.all(40.0)),
                  Text(
                    'Updated $lastUpdateRelative (automatically update every 15 minutes)',
                    style: new TextStyle(fontSize: 30),
                  ),
                ]),
            SizedBox(
              width: 800, // hard coding child width
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.all(30.0)),
                  textField('confirmed', confirmed),
                  textField('recovered', recovered),
                  textField('critical', critical),
                  textField('deaths', deaths),
                ],
              ),
            ),
            Padding(padding: const EdgeInsets.all(30.0)),
            ButtonTheme(
              minWidth: 120.0,
              height: 60.0,
              child: RaisedButton(
                onPressed: () => getTotal(),
                child: Text('UPDATE'),
              ),
            ),
            Padding(padding: const EdgeInsets.all(30.0)),
            RaisedButton(
              onPressed: () {
                globals.currentUser = '';
                confirmed = 0;
                recovered = 0;
                critical = 0;
                deaths = 0;
                // Navigate back to first route when tapped.
                Navigator.pop(context);
              },
              child: Text('Go back!'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getTotal() async {
    var response = await http.get(baseURL + '/totals', headers: headers);
    var totals = jsonDecode(response.body)[0];
    setState(() {
      confirmed = int.parse(totals['confirmed']);
      recovered = int.parse(totals['recovered']);
      critical = int.parse(totals['critical']);
      deaths = int.parse(totals['deaths']);
    });
    lastUpdate = Jiffy(DateTime.now());
    print('Data updated!');
  }

  updateRelativeTime() {
    setState(() {
      lastUpdateRelative = lastUpdate.fromNow();
    });
  }
}
