import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/clock_view.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    Stream<DateTime> getTimeStream() {
      return Stream.periodic(Duration(seconds: 1), (_) => DateTime.now());
    }

    var timezoneString = now.timeZoneOffset.toString().split('.').first;
    var offsetSign = '';
    if (!timezoneString.startsWith('-')) offsetSign = '+';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 64.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Text(
              'Clock',
              style: TextStyle(
                fontFamily: 'avenir',
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 24.0,
              ),
            ),
          ),
          SizedBox(
            height: 32.0,
          ),
          Flexible(
            flex: 2,
            child: StreamBuilder<DateTime>(
              stream: getTimeStream(),
              builder: (context, snapshot) {
                if(snapshot.hasData){
                  var now = snapshot.data!;
                  var formattedTime = DateFormat('HH:mm:ss').format(now);
                  var formattedDate = DateFormat('EEE, d MMM').format(now);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontFamily: 'avenir',
                          color: Colors.white,
                          fontSize: 64.0,
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontFamily: 'avenir',
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  );
                }else {
                  return Text(
                    'Loading...',
                    style: TextStyle(
                      fontFamily: 'avenir',
                      color: Colors.white,
                      fontSize: 64.0,
                    ),
                  );
                }
              }
            ),
          ),
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: ClockView(
              size: MediaQuery.of(context).size.height / 4,
            ),
          ),
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Timezone',
                  style: TextStyle(
                    fontFamily: 'avenir',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    Text(
                      'UTC ' + offsetSign + timezoneString,
                      style: TextStyle(
                          fontFamily: 'avenir',
                          color: Colors.white,
                          fontSize: 14.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
