import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'app_theme.dart';

const Set<String> appIconNames = <String>{
  'globe',
  'live',
  'chat',
  'user',
  'cam',
  'camOutline',
  'plus',
  'calendar',
  'history',
  'sliders',
  'back',
  'chev',
  'dots',
  'ghost',
  'eye',
  'bell',
  'bellOff',
  'block',
  'copy',
  'headset',
  'send',
  'heart',
  'shield',
  'search',
  'edit',
  'clipboard',
  'bag',
  'diamond',
  'dollar',
  'gear',
  'doc',
  'flame',
};

String appColorHex(Color color) {
  final int value = color.toARGB32() & 0x00FFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0')}';
}

String _iconBody(String name) => switch (name) {
  'globe' => '<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c3 3 3 15 0 18M12 3c-3 3-3 15 0 18"/>',
  'live' => '<rect x="3" y="4" width="18" height="16" rx="4"/><path d="M10 9l5 3-5 3z"/>',
  'chat' => '<path d="M5 5h14a2 2 0 012 2v8a2 2 0 01-2 2h-7l-5 4v-4H5a2 2 0 01-2-2V7a2 2 0 012-2z"/>',
  'user' =>
    '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 3.5-6 8-6s8 2 8 6"/>',
  'cam' => '<path d="M3 8a2 2 0 012-2h8a2 2 0 012 2v2l5-3v10l-5-3v2a2 2 0 01-2 2H5a2 2 0 01-2-2z" fill="currentColor"/>',
  'camOutline' => '<path d="M3 8a2 2 0 012-2h8a2 2 0 012 2v2l5-3v10l-5-3v2a2 2 0 01-2 2H5a2 2 0 01-2-2z"/>',
  'plus' => '<path d="M12 5v14M5 12h14"/>',
  'calendar' => '<rect x="3" y="5" width="18" height="16" rx="3"/><path d="M8 3v4M16 3v4M3 10h18M9 15l2 2 4-4"/>',
  'history' =>
    '<path d="M4 12a8 8 0 108-8 8 8 0 00-6 2.7M4 4v4h4M12 8v4l3 2"/>',
  'sliders' => '<path d="M4 8h9M17 8h3M4 16h3M11 16h9"/>',
  'back' => '<path d="M15 5l-7 7 7 7"/>',
  'chev' => '<path d="M9 5l7 7-7 7"/>',
  'dots' => '<path d="M5 12h.01M12 12h.01M19 12h.01" stroke-width="3"/>',
  'ghost' => '<path d="M5 21V11a7 7 0 0114 0v10l-3-2-2 2-2-2-2 2-2-2z" fill="currentColor"/>',
  'eye' => '<path d="M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12z"/><circle cx="12" cy="12" r="3"/>',
  'bell' => '<path d="M6 16V11a6 6 0 0112 0v5l2 2H4zM10 21h4"/>',
  'bellOff' =>
    '<path d="M6 16V11a6 6 0 0110-4.5M18 11v5l2 2H4M10 21h4M3 3l18 18"/>',
  'block' => '<circle cx="12" cy="12" r="9"/><path d="M5.6 5.6l12.8 12.8"/>',
  'copy' => '<rect x="8.5" y="8.5" width="11" height="12" rx="2.5"/><path d="M15.5 5.5v-.5A2 2 0 0013.5 3h-7A2 2 0 004.5 5v10a2 2 0 002 2H7"/>',
  'headset' => '<path d="M4 14v-2a8 8 0 0116 0v2"/><rect x="3" y="14" width="4" height="6" rx="2"/><rect x="17" y="14" width="4" height="6" rx="2"/><path d="M19 20c0 1.5-2 2-5 2"/>',
  'send' => '<path d="M21 3L3 10l7 3 3 7zM10 13l11-10"/>',
  'heart' => '<path d="M12 20s-8-5-8-11a4.5 4.5 0 018-2.5A4.5 4.5 0 0120 9c0 6-8 11-8 11z" fill="currentColor"/>',
  'shield' => '<path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6zM8.5 12l2.5 2.5 4.5-5"/>',
  'search' => '<circle cx="11" cy="11" r="6"/><path d="M16 16l4 4"/>',
  'edit' => '<path d="M5 4h8M4 6v13a1 1 0 001 1h13a1 1 0 001-1v-7M18 3l3 3-9 9-4 1 1-4z"/>',
  'clipboard' => '<rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 3h6v3H9zM8.5 13l2 2 4-4"/>',
  'bag' => '<path d="M7 8V6a5 5 0 0110 0v2M5 8h14l1 12H4zM9 13h6"/>',
  'diamond' =>
    '<path d="M12 21l-8-9 3-6h10l3 6zM4 12h16M9 6l3 15M15 6l-3 15"/>',
  'dollar' => '<circle cx="12" cy="12" r="9"/><path d="M14.5 9c-.5-1-1.5-1.5-2.7-1.5-1.5 0-2.600.8-2.600 2s1 1.700 2.800 2 2.800.8 2.800 2-1.200 2-2.800 2c-1.300 0-2.400-.6-2.900-1.700M12 6v1.500M12 16.500V18"/>',
  'gear' => '<circle cx="12" cy="12" r="3"/><path d="M12 3v3M12 18v3M3 12h3M18 12h3M5.600 5.600l2.100 2.100M16.300 16.300l2.100 2.100M5.600 18.400l2.100-2.100M16.300 7.700l2.100-2.100"/>',
  'doc' => '<path d="M6 3h9l4 4v14H6zM9 12h7M9 16h7M9 8h3"/>',
  'flame' => '<path d="M12 3c1 4 5 5.500 5 10a5 5 0 01-10 0c0-2 1-3 2-4 0 2 1 3 2 3 1-3 0-6 1-9z" fill="currentColor" stroke="none"/>',
  _ => throw ArgumentError.value(name, 'name', 'Unknown AppIcon'),
};

String _appIconSvg({
  required String body,
  required Color color,
  required double stroke,
}) {
  return '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" opacity="${color.a}" fill="none" color="${appColorHex(color)}" stroke="${appColorHex(color)}" stroke-width="$stroke" stroke-linecap="round" stroke-linejoin="round">$body</svg>';
}

class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    required this.name,
    this.size = 24,
    this.color,
    this.stroke = 1.75,
  });

  final String name;
  final double size;
  final Color? color;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    assert(appIconNames.contains(name), 'Unknown AppIcon name: $name');
    final Color resolved =
        color ?? DefaultTextStyle.of(context).style.color ?? AppColors.ink;
    return SvgPicture.string(
      _appIconSvg(body: _iconBody(name), color: resolved, stroke: stroke),
      theme: SvgTheme(currentColor: resolved.withValues(alpha: 1)),
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
    );
  }
}

const String _navCircle =
    'M12 2.900a9.100 9.100 0 100 18.200 9.100 9.100 0 000-18.200z';

String _navSvg({
  required String body,
  required Color color,
  required bool solid,
}) {
  final String fill = solid ? appColorHex(color) : 'none';
  final String stroke = appColorHex(color);
  return '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" opacity="${color.a}" color="$stroke" fill="$fill" stroke="$stroke" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">$body</svg>';
}

class NavIcon extends StatelessWidget {
  const NavIcon({
    super.key,
    required this.kind,
    required this.color,
    this.solid = false,
    this.size = 24,
  });

  final String kind;
  final Color color;
  final bool solid;
  final double size;

  String get _body => switch (kind) {
    'compass' =>
      '<path fill-rule="evenodd" d="$_navCircle M15.800 8.200l-2.100 5.500-5.500 2.100 2.100-5.500z" stroke="${solid ? 'none' : 'currentColor'}" fill="${solid ? 'currentColor' : 'none'}"/>${solid ? '<circle cx="12" cy="12" r="9.100" fill="none"/>' : ''}',
    'live' =>
      '<path fill-rule="evenodd" d="$_navCircle M10 8.300l5.600 3.700-5.600 3.700z" stroke="${solid ? 'none' : 'currentColor'}" fill="${solid ? 'currentColor' : 'none'}"/>',
    'chat' => '<path d="M6.500 3.900h11A2.600 2.600 0 0120.100 6.500v7.200a2.600 2.600 0 01-2.600 2.600h-5.300L7.600 20.100v-3.800H6.500a2.600 2.600 0 01-2.600-2.600V6.500A2.600 2.600 0 016.500 3.900z"/>',
    'user' => '<circle cx="12" cy="7.600" r="3.700"/><path d="M4.500 20.100c0-3.700 3.200-6.100 7.500-6.100s7.500 2.400 7.500 6.100z"/>',
    _ => throw ArgumentError.value(kind, 'kind', 'Unknown navigation icon'),
  };

  @override
  Widget build(BuildContext context) => SvgPicture.string(
    _navSvg(body: _body, color: color, solid: solid),
    theme: SvgTheme(currentColor: color.withValues(alpha: 1)),
    width: size,
    height: size,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
  );
}

class CompassIcon extends NavIcon {
  const CompassIcon({
    super.key,
    super.color = AppColors.ink,
    super.solid,
    super.size,
  }) : super(kind: 'compass');
}

class PlayCircleIcon extends NavIcon {
  const PlayCircleIcon({
    super.key,
    super.color = AppColors.ink,
    super.solid,
    super.size,
  }) : super(kind: 'live');
}

class ChatBubbleIcon extends NavIcon {
  const ChatBubbleIcon({
    super.key,
    super.color = AppColors.ink,
    super.solid,
    super.size,
  }) : super(kind: 'chat');
}

class UserIcon extends NavIcon {
  const UserIcon({
    super.key,
    super.color = AppColors.ink,
    super.solid,
    super.size,
  }) : super(kind: 'user');
}

String appGiftSvg(Color color) =>
    '<svg xmlns="http://www.w3.org/2000/svg" width="34" height="34" viewBox="0 0 24 24" fill="none" color="${appColorHex(color)}" stroke="${appColorHex(color)}" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="8" width="18" height="4" rx="1"/><path d="M5 12v8h14v-8M12 8v12M12 8c-2 0-4-1-4-2.500S10 3 12 8c2-5 4-4.500 4-3S14 8 12 8z"/></svg>';
