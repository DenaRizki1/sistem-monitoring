import 'package:flutter/material.dart';

class AppNavigator {
  static final AppNavigator _instance = AppNavigator._();

  AppNavigator._();

  static AppNavigator get instance => _instance;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  bool isMounted() {
    return navigatorKey.currentState?.mounted ?? false;
  }

  BuildContext? context() {
    return navigatorKey.currentState?.context;
  }

  Future<T?> push<T extends Object?>(Route<T> route) async {
    return await navigatorKey.currentState?.push(route);
  }

  /* Navigate to another screen using route name */
  Future<T?> pushNamed<T extends Object?>(String routeName, {Object? arguments}) async {
    return await navigatorKey.currentState?.pushNamed<T>(routeName, arguments: arguments);
  }

  /* Navigate to one step back */
  void pop<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }

  /* Remove all screen from stack until we reach to mentioned route in stack */
  void popUntil(String routeName) {
    navigatorKey.currentState?.popUntil(ModalRoute.withName(routeName));
  }

  /*Go back one step and push mentioned route in stack */
  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    return await navigatorKey.currentState?.popAndPushNamed<T, TO>(routeName, result: result, arguments: arguments);
  }

  /* Replace mentioned route with current route being displayed */
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    return await navigatorKey.currentState?.pushReplacementNamed<T, TO>(routeName, result: result, arguments: arguments);
  }

  /* Push mentioned route in stack and remove all routes from stack*/
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) async {
    return await navigatorKey.currentState?.pushNamedAndRemoveUntil(newRouteName, predicate, arguments: arguments);
  }

  /* Push mentioned route in stack and remove all routes from stack*/
  Future<T?> pushAndRemoveUntil<T extends Object?>(
    Route<T> route,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) async {
    return await navigatorKey.currentState?.pushAndRemoveUntil(route, predicate);
  }

  Object? get arguments => ModalRoute.of(navigatorKey.currentContext!)?.settings.arguments;
}
