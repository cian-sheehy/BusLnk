import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils {
  static void onButtonTap(AnimationController controller) {
    controller.reset();
    if (controller.status == AnimationStatus.completed) {
      controller.forward();
    } else if (controller.status == AnimationStatus.dismissed) {
      controller.forward();
    }
  }

  static void addStatusListener(AnimationController controller) {
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });
  }

  static String getCurrentTime() =>
      "${DateTime.now().toLocal().hour.toString().padLeft(2, '0')}:${DateTime.now().toLocal().minute.toString().padLeft(2, '0')}";

  static void launchStopURL(String stopNumber) async {
    launchURL('https://www.metlink.org.nz/stop/$stopNumber');
  }

  static void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw ArgumentError('Could not launch $url');
    }
  }

  static double animationRotateValue(AnimationController controller) =>
      controller.value * 360 / 360 * 2 * pi;

  static DateTime getScheduledTime(int depatureSeconds) {
    var realTimeSeconds = (depatureSeconds * 1000) +
        (DateTime.now().toLocal().millisecondsSinceEpoch.toInt());
    return DateTime.fromMillisecondsSinceEpoch(
      realTimeSeconds,
      isUtc: true,
    ).toLocal();
  }

  static dynamic findRoute(routes, String routeNum) => routes
      .where((stop) => stop['route_short_name'].toLowerCase() == routeNum)
      .toList();

  static void scrollToEnd(ScrollController _scrollController) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 10),
        curve: Curves.linear,
      );
    }
  }

  static void scrollToTop(ScrollController _scrollController) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 10),
        curve: Curves.linear,
      );
    }
  }

  static Duration departureDuration(var _stopInfo) {
    var currentTime = DateTime.now().toLocal();
    final expectedDate =
        DateTime.parse(_stopInfo['departure']['expected'].toString());
    return expectedDate.difference(currentTime);
  }

  static Duration delayedDuration(var _stopInfo) {
    final aimedDate =
        DateTime.parse(_stopInfo['departure']['aimed'].toString());
    final expectedDate =
        DateTime.parse(_stopInfo['departure']['expected'].toString());
    return aimedDate.difference(expectedDate);
  }

  static Color hexToColor(String hexColor) {
    var newHexColor = hexColor.replaceAll('#', '');
    if (newHexColor.length == 6) {
      newHexColor = 'FF$newHexColor';
    }
    if (newHexColor.length == 8) {
      return Color(int.parse('0x$newHexColor'));
    }
    return Colors.blueGrey[800];
  }

  static String setTime(var _time) =>
      "${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}";

  static Color calculateStatusColour(String status) {
    switch (status) {
      case 'ontime':
        return Colors.yellow[100];
      case 'delayed':
        return Colors.red[100];
      case 'early':
        return Colors.green[100];
      default:
        return Colors.white;
    }
  }

  static Color calculateStatusTextColour(String status) {
    switch (status) {
      case 'delayed':
        return Colors.blueGrey[800];
      default:
        return Colors.white;
    }
  }

  static Color calculateBannerAlertColour(String warning) {
    switch (warning) {
      case 'INFO':
        return Colors.blueGrey[300];
      case 'WARNING':
        return Colors.orange[300];
      case 'SEVERE':
        return Colors.red[300];
      default:
        return Colors.blueGrey[400];
    }
  }
}
