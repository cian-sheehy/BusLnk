import 'package:flutter/material.dart';

class CardWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget leadingIcon;
  final Widget trailingIcon;
  final VoidCallback callback;
  final VoidCallback longPressCallback;

  const CardWidget({
    this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.callback,
    this.longPressCallback,
  });

  @override
  CardWidgetState createState() => CardWidgetState(
        title: title,
        subtitle: subtitle,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        callback: callback,
        longPressCallback: longPressCallback,
      );
}

class CardWidgetState extends State<CardWidget> with TickerProviderStateMixin {
  String title;
  String subtitle;
  Widget leadingIcon;
  Widget trailingIcon;
  VoidCallback callback;
  VoidCallback longPressCallback;
  CardWidgetState({
    this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.callback,
    this.longPressCallback,
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
  Widget build(BuildContext context) => Container(
        width: MediaQuery.of(context).size.width - 10,
        child: Card(
          shape: RoundedRectangleBorder(
            // borderRadius: BorderRadius.circular(15),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
            side: BorderSide(
              color: Colors.blueGrey[300],
            ),
          ),
          // color: Colors.white,
          child: ListTile(
            onLongPress: longPressCallback,
            onTap: callback,
            contentPadding: const EdgeInsets.only(
              left: 15,
            ),
            leading: leadingIcon,
            trailing: trailingIcon,
            title: Text(
              title,
              style: TextStyle(
                color: Color(0xff699b2c),
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: Colors.blueGrey[800],
              ),
            ),
          ),
        ),
      );
}
