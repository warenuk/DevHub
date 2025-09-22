import 'package:devhub_gpt/core/router/route_telemetry_observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PageRoute<void> _routeWithName(String name) {
  return PageRouteBuilder<void>(
    settings: RouteSettings(name: name),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const SizedBox.shrink(),
  );
}

PageRoute<void> _routeWithArgs(String args) {
  return PageRouteBuilder<void>(
    settings: RouteSettings(arguments: args),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const SizedBox.shrink(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('captures push, replace and pop transitions', () {
    final events = <RouteTelemetryEvent>[];
    final observer = RouteTelemetryObserver(onEvent: events.add);

    final routeA = _routeWithName('/a');
    final routeB = _routeWithName('/b');

    observer.didPush(routeA, null);
    observer.didReplace(newRoute: routeB, oldRoute: routeA);
    observer.didPop(routeB, routeA);

    expect(events.map((e) => e.event), ['push', 'replace', 'pop']);
    expect(events[0].routeName, '/a');
    expect(events[1].routeName, '/b');
    expect(events[2].previousRouteName, '/a');
  });

  test('falls back to arguments or runtime type when name is absent', () {
    final events = <RouteTelemetryEvent>[];
    final observer = RouteTelemetryObserver(onEvent: events.add);

    final unnamed = PageRouteBuilder<void>(
      settings: const RouteSettings(),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const SizedBox.shrink(),
    );
    final withArgs = _routeWithArgs('details/42');

    observer.didPush(unnamed, null);
    observer.didReplace(newRoute: withArgs, oldRoute: unnamed);

    expect(events.first.routeName, contains('PageRouteBuilder'));
    expect(events.last.routeName, 'details/42');
  });
}
