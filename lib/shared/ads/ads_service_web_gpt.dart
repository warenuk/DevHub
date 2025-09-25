// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'dart:ui_web' as ui_web;

import 'package:devhub_gpt/shared/ads/ads_service.dart';
import 'package:flutter/widgets.dart';

const _viewType = 'devhub-gpt-banner-slot';

AdsService createAdsService(AdsConfig config) => AdsServiceWebGpt(config);

class AdsServiceWebGpt implements AdsService {
  AdsServiceWebGpt(this.config) {
    _registerViewFactory();
  }

  static bool _viewFactoryRegistered = false;
  static AdsConfig? _registeredConfig;
  static bool _slotDisplayed = false;

  @override
  final AdsConfig config;

  @override
  bool get isEnabled => true;

  void _registerViewFactory() {
    if (_viewFactoryRegistered) {
      _registeredConfig = config;
      return;
    }

    _registeredConfig = config;
    final slotId = config.slotId;
    final size = config.slotSize;

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final container = html.DivElement()
        ..id = '$slotId-container'
        ..style.width = '${size.width}px'
        ..style.height = '${size.height}px'
        ..style.display = 'flex'
        ..style.justifyContent = 'center'
        ..style.alignItems = 'center';

      final existingSlot = html.document.getElementById(slotId);
      final slotElement =
          existingSlot is html.Element ? existingSlot : html.DivElement()
            ..id = slotId;

      slotElement.style
        ..width = '${size.width}px'
        ..height = '${size.height}px'
        ..margin = '0 auto'
        ..display = 'block';

      if (slotElement.parent != null) {
        slotElement.remove();
      }

      container.append(slotElement);

      return container;
    });

    _viewFactoryRegistered = true;
  }

  static void _displaySlot() {
    final config = _registeredConfig;
    if (config == null || _slotDisplayed) {
      return;
    }
    if (!js_util.hasProperty(html.window, 'devhubDisplayGptSlot')) {
      return;
    }
    final payload = <String, Object?>{
      'slotId': config.slotId,
      'slotPath': config.slotPath,
      'slotSize': <int>[config.slotSize.width, config.slotSize.height],
    };
    js_util.callMethod<void>(
      html.window,
      'devhubDisplayGptSlot',
      <Object?>[js_util.jsify(payload)],
    );
    _slotDisplayed = true;
  }

  @override
  Widget buildBanner({Key? key}) {
    return _WebGptBanner(key: key, config: config);
  }

  @override
  void dispose() {
    _slotDisplayed = false;
  }
}

class _WebGptBanner extends StatefulWidget {
  const _WebGptBanner({super.key, required this.config});

  final AdsConfig config;

  @override
  State<_WebGptBanner> createState() => _WebGptBannerState();
}

class _WebGptBannerState extends State<_WebGptBanner> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdsServiceWebGpt._displaySlot();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.config.slotSize;
    return SizedBox(
      width: size.widthPx,
      height: size.heightPx,
      child: const HtmlElementView(viewType: _viewType),
    );
  }
}
