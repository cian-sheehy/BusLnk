import 'package:flutter/material.dart';

class _JumpingDot extends AnimatedWidget {
  const _JumpingDot({Key key, Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Container(
      height: animation.value,
      child: Icon(
        Icons.directions_bus_rounded,
        size: 50,
        color: Theme.of(context).buttonColor,
      ),
    );
  }
}

class PageLoadingIndicator extends StatefulWidget {
  final int numberOfDots;
  final double dotSpacing;
  final int milliseconds;
  final double beginTweenValue = 0.0;
  final double endTweenValue = 15;

  const PageLoadingIndicator({
    this.numberOfDots = 5,
    this.dotSpacing = 5,
    this.milliseconds = 200,
  });

  @override
  _PageLoadingIndicatorState createState() => _PageLoadingIndicatorState(
        numberOfDots: numberOfDots,
        dotSpacing: dotSpacing,
        milliseconds: milliseconds,
      );
}

class _PageLoadingIndicatorState extends State<PageLoadingIndicator>
    with TickerProviderStateMixin {
  int numberOfDots;
  int milliseconds;
  double dotSpacing;
  List<AnimationController> controllers = <AnimationController>[];
  List<Animation<double>> animations = <Animation<double>>[];
  final List<Widget> _widgets = <Widget>[];

  _PageLoadingIndicatorState({
    this.numberOfDots,
    this.dotSpacing,
    this.milliseconds,
  });

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < numberOfDots; i++) {
      _addAnimationControllers();
      _buildAnimations(i);
      _addListOfDots(i);
    }

    controllers[0].forward();
  }

  void _addAnimationControllers() {
    controllers.add(
      AnimationController(
        duration: Duration(milliseconds: milliseconds),
        vsync: this,
      ),
    );
  }

  void _addListOfDots(int index) {
    _widgets.add(Padding(
      padding: EdgeInsets.only(right: dotSpacing),
      child: _JumpingDot(
        animation: animations[index],
      ),
    ));
  }

  void _buildAnimations(int index) {
    animations.add(
      Tween(begin: widget.beginTweenValue, end: widget.endTweenValue)
          .animate(controllers[index])
            ..addStatusListener(
              (AnimationStatus status) {
                if (status == AnimationStatus.completed) {
                  controllers[index].reverse();
                }
                if (index == numberOfDots - 1 &&
                    status == AnimationStatus.dismissed) {
                  controllers[0].forward();
                }
                if (animations[index].value > widget.endTweenValue / 2 &&
                    index < numberOfDots - 1) {
                  controllers[index + 1].forward();
                }
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _widgets,
        ),
      );

  @override
  void dispose() {
    for (var i = 0; i < numberOfDots; i++) {
      controllers[i].dispose();
    }
    super.dispose();
  }
}
