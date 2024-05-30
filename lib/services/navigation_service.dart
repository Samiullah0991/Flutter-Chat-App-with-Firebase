import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService instance = NavigationService._();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  NavigationService._();

  Future<dynamic> _navigateTo(String routeName, {bool replace = false}) {
    if (_navigatorKey.currentState != null) {
      if (replace) {
        return _navigatorKey.currentState!.pushReplacementNamed(routeName);
      } else {
        return _navigatorKey.currentState!.pushNamed(routeName);
      }
    }
    return Future.value();
  }

  Future<dynamic> navigateToReplacement(String routeName) =>
      _navigateTo(routeName, replace: true);

  Future<dynamic> navigateTo(String routeName) => _navigateTo(routeName);

  Future<dynamic> navigateToRoute(MaterialPageRoute route) {
    if (_navigatorKey.currentState != null) {
      return _navigatorKey.currentState!.push(route);
    }
    return Future.value();
  }

  void goBack() {
    if (_navigatorKey.currentState != null) {
      _navigatorKey.currentState!.pop();
    }
  }

  // Getter method to access the navigator key
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
}
