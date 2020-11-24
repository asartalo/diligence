import 'package:flutter/material.dart';

import '../components/app_bar.dart';
import '../components/data/single_number.dart';

class ReviewPage extends StatefulWidget {
  ReviewPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: appBar(context, 'Review'),
      backgroundColor: theme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Today’s Summary',
                style: theme.textTheme.headline2,
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 640.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SingleNumberDataPoint(
                    title: 'Completed Tasks',
                    number: 23,
                  ),
                  SingleNumberDataPoint(
                    title: 'Overdues',
                    number: 2,
                  ),
                  SingleNumberDataPoint(
                    title: 'New Tasks',
                    number: 15,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.*/
    );
  }
}
