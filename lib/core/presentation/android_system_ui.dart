import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../platform/window_service.dart';

class AndroidSystemUi extends StatelessWidget {
  const AndroidSystemUi({
    super.key,
    required this.child,
    this.backgroundColor,
    this.brightness,
  });

  final Widget child;
  final Color? backgroundColor;
  final Brightness? brightness;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (theme.platform != TargetPlatform.android) return child;
    final backgroundBrightness = brightness ?? theme.brightness;
    final dark = backgroundBrightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // MaterialApp's default styles both request a black navigation bar.
      // Let edge-to-edge content paint behind the gesture area on older Android
      // versions too, including route barriers and image-preview backgrounds.
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: backgroundBrightness,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: backgroundColor ?? Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: child,
    );
  }
}

/// Inline playback hides only the navigation bar. Keep a single owner above
/// the retained workspace pages so offstage players cannot change window UI.
class AndroidPlaybackNavigationBar extends StatefulWidget {
  const AndroidPlaybackNavigationBar({
    super.key,
    required this.playbackVisible,
    required this.child,
  });

  final bool playbackVisible;
  final Widget child;

  @override
  State<AndroidPlaybackNavigationBar> createState() =>
      _AndroidPlaybackNavigationBarState();
}

class _AndroidPlaybackNavigationBarState
    extends State<AndroidPlaybackNavigationBar> {
  bool _hidden = false;

  void _updateVisibility() {
    _setHidden(
      widget.playbackVisible && MediaQuery.viewInsetsOf(context).bottom == 0,
    );
  }

  void _setHidden(bool hidden) {
    if (_hidden == hidden) return;
    _hidden = hidden;
    unawaited(WindowService.setAndroidPlaybackNavigationHidden(hidden));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateVisibility();
  }

  @override
  void didUpdateWidget(covariant AndroidPlaybackNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateVisibility();
  }

  @override
  void dispose() {
    _setHidden(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
