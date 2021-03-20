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
          shadowColor: Theme.of(context).cardTheme.shadowColor,
          shape: Theme.of(context).cardTheme.shape,
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
                color: Theme.of(context).textTheme.headline1.color,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).textTheme.subtitle1.color,
              ),
            ),
          ),
        ),
      );
}
