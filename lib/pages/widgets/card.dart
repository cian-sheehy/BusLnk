import 'package:flutter/material.dart';

class CardWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final Key key;
  final Widget leadingIcon;
  final Widget trailingIcon;
  final VoidCallback onTapCallback;
  final VoidCallback longPressCallback;

  const CardWidget({
    this.title,
    this.subtitle,
    this.key,
    this.leadingIcon,
    this.trailingIcon,
    this.onTapCallback,
    this.longPressCallback,
  });

  @override
  CardWidgetState createState() => CardWidgetState(
        title: title,
        subtitle: subtitle,
        key: key,
        leadingIcon: leadingIcon,
        trailingIcon: trailingIcon,
        onTapCallback: onTapCallback,
        longPressCallback: longPressCallback,
      );
}

class CardWidgetState extends State<CardWidget> with TickerProviderStateMixin {
  String title;
  String subtitle;
  Key key;
  Widget leadingIcon;
  Widget trailingIcon;
  VoidCallback onTapCallback;
  VoidCallback longPressCallback;
  CardWidgetState({
    this.title,
    this.subtitle,
    this.key,
    this.leadingIcon,
    this.trailingIcon,
    this.onTapCallback,
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
        color: Colors.transparent,
        child: Card(
          key: key,
          shape: Theme.of(context).cardTheme.shape,
          child: ListTile(
            onLongPress: longPressCallback,
            onTap: onTapCallback,
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
