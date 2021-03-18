import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../helpers/utils.dart';
import 'card.dart';

class NoStopInformationWidget extends StatefulWidget {
  final String stopNumber;
  final String stopName;
  final String lastUpdated;

  const NoStopInformationWidget({
    this.stopNumber,
    this.stopName,
    this.lastUpdated,
  });

  @override
  NoStopInformationWidgetState createState() => NoStopInformationWidgetState(
        stopNumber: stopNumber,
        stopName: stopName,
        lastUpdated: lastUpdated,
      );
}

class NoStopInformationWidgetState extends State<NoStopInformationWidget>
    with TickerProviderStateMixin {
  String stopNumber;
  String stopName;
  String lastUpdated;
  NoStopInformationWidgetState({
    this.stopNumber,
    this.stopName,
    this.lastUpdated,
  });

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          CardWidget(
            title: stopName,
            subtitle: 'Stop $stopNumber, last updated at $lastUpdated',
          ),
          Container(
            margin: const EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
              color: ColorConstants.mainBackground,
            ),
            child: Center(
              child: ListTile(
                title: Text(
                  'No service information for stop $stopNumber',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color(0xff699b2c),
                  ),
                ),
                subtitle: Text(
                  'Try again later or press the button for more information',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.blueGrey[800],
                  ),
                ),
                trailing: IconButton(
                  color: Color(0xff699b2c),
                  icon: Icon(
                    Icons.open_in_browser_rounded,
                    size: 40,
                  ),
                  onPressed: () {
                    Utils.launchURL(stopNumber);
                  },
                ),
              ),
            ),
          ),
        ],
      );
}
