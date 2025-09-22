import 'package:devhub_gpt/core/utils/app_logger.dart';
import 'package:flutter/widgets.dart';

class RouteTelemetryEvent {
  const RouteTelemetryEvent({
    required this.event,
    required this.routeName,
    required this.previousRouteName,
  });

  final String event;
  final String? routeName;
  final String? previousRouteName;
}

typedef RouteTelemetrySink = void Function(RouteTelemetryEvent event);

class RouteTelemetryObserver extends NavigatorObserver {
  RouteTelemetryObserver({RouteTelemetrySink? onEvent})
      : _onEvent = onEvent ?? _defaultSink;

  final RouteTelemetrySink _onEvent;

  static void _defaultSink(RouteTelemetryEvent event) {
    final route = event.routeName ?? 'unknown';
    final previous = event.previousRouteName ?? 'none';
    AppLogger.info(
      '[router] ${event.event}: $route <- $previous',
      area: 'router',
    );
  }

  void _emit(String event, Route<dynamic>? route, Route<dynamic>? previous) {
    _onEvent(
      RouteTelemetryEvent(
        event: event,
        routeName: _describe(route),
        previousRouteName: _describe(previous),
      ),
    );
  }

  String? _describe(Route<dynamic>? route) {
    if (route == null) return null;
    final settings = route.settings;
    if (settings.name != null && settings.name!.isNotEmpty) {
      return settings.name;
    }
    if (settings.arguments != null) {
      return settings.arguments.toString();
    }
    return route.runtimeType.toString();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _emit('push', route, previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _emit('replace', newRoute, oldRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _emit('pop', route, previousRoute);
    super.didPop(route, previousRoute);
  }
}
