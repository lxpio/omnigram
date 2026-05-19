import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omnigram/theme/typography.dart';

abstract class AbstractSettingsTile extends StatelessWidget {
  const AbstractSettingsTile({super.key});
}

enum SettingsTileType { simpleTile, switchTile, navigationTile }

class SettingsTile extends AbstractSettingsTile {
  SettingsTile({
    this.leading,
    this.trailing,
    this.value,
    required this.title,
    this.description,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
    super.key,
  }) {
    onToggle = null;
    initialValue = null;
    activeSwitchColor = null;
    tileType = SettingsTileType.simpleTile;
  }

  SettingsTile.navigation({
    this.leading,
    this.trailing,
    this.value,
    required this.title,
    this.description,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
    super.key,
  }) {
    onToggle = null;
    initialValue = null;
    activeSwitchColor = null;
    tileType = SettingsTileType.navigationTile;
  }

  SettingsTile.switchTile({
    required this.initialValue,
    required this.onToggle,
    this.activeSwitchColor,
    this.leading,
    this.trailing,
    required this.title,
    this.description,
    this.onPressed,
    this.onLongPress,
    this.enabled = true,
    super.key,
  }) {
    value = null;
    tileType = SettingsTileType.switchTile;
  }

  /// The widget at the beginning of the tile
  final Widget? leading;

  /// The Widget at the end of the tile
  final Widget? trailing;

  /// The widget at the center of the tile
  final Widget title;

  /// The widget at the bottom of the [title]
  final Widget? description;

  /// A function that is called by tap on a tile
  final Function(BuildContext context)? onPressed;

  /// Long-press handler. Used by the stealth-mode entry on "About".
  final VoidCallback? onLongPress;

  late final Color? activeSwitchColor;
  late final Widget? value;
  late final Function(bool value)? onToggle;
  late final SettingsTileType tileType;
  late final bool? initialValue;
  late final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AndroidSettingsTile(
      description: description,
      onPressed: onPressed,
      onLongPress: onLongPress,
      onToggle: onToggle,
      tileType: tileType,
      value: value,
      leading: leading,
      title: title,
      enabled: enabled,
      activeSwitchColor: activeSwitchColor,
      initialValue: initialValue ?? false,
      trailing: trailing,
    );
  }
}

class AndroidSettingsTile extends StatelessWidget {
  const AndroidSettingsTile({
    required this.tileType,
    required this.leading,
    required this.title,
    required this.description,
    required this.onPressed,
    required this.onLongPress,
    required this.onToggle,
    required this.value,
    required this.initialValue,
    required this.activeSwitchColor,
    required this.enabled,
    required this.trailing,
    super.key,
  });

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget? title;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final VoidCallback? onLongPress;
  final Function(bool value)? onToggle;
  final Widget? value;
  final bool initialValue;
  final bool enabled;
  final Color? activeSwitchColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: _GlassSettingsRow(
        tileType: tileType,
        leading: leading,
        title: title,
        description: description,
        value: value,
        trailing: trailing,
        initialValue: initialValue,
        onPressed: onPressed,
        onLongPress: onLongPress,
        onToggle: onToggle,
        enabled: enabled,
        activeSwitchColor: activeSwitchColor,
      ),
    );
  }
}

class _GlassSettingsRow extends StatefulWidget {
  const _GlassSettingsRow({
    required this.tileType,
    required this.leading,
    required this.title,
    required this.description,
    required this.value,
    required this.trailing,
    required this.initialValue,
    required this.onPressed,
    required this.onLongPress,
    required this.onToggle,
    required this.enabled,
    required this.activeSwitchColor,
  });

  final SettingsTileType tileType;
  final Widget? leading;
  final Widget? title;
  final Widget? description;
  final Widget? value;
  final Widget? trailing;
  final bool initialValue;
  final Function(BuildContext)? onPressed;
  final VoidCallback? onLongPress;
  final Function(bool)? onToggle;
  final bool enabled;
  final Color? activeSwitchColor;

  @override
  State<_GlassSettingsRow> createState() => _GlassSettingsRowState();
}

class _GlassSettingsRowState extends State<_GlassSettingsRow> {
  bool _pressed = false;

  bool get _interactive => widget.tileType == SettingsTileType.switchTile
      ? widget.onToggle != null || widget.onPressed != null
      : widget.onPressed != null;

  void _handleTap() {
    if (!_interactive) return;
    HapticFeedback.selectionClick();
    if (widget.tileType == SettingsTileType.switchTile) {
      widget.onToggle?.call(!widget.initialValue);
    } else {
      widget.onPressed?.call(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = widget.enabled ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.4);
    final subFg = widget.enabled
        ? scheme.onSurfaceVariant
        : scheme.onSurfaceVariant.withValues(alpha: 0.4);

    final titleText = DefaultTextStyle.merge(
      style: OmnigramTypography.titleMedium(context).copyWith(
        color: fg,
        fontWeight: FontWeight.w500,
      ),
      child: widget.title ?? const SizedBox.shrink(),
    );

    final subline = widget.value ?? widget.description;
    final subtitleText = subline == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(top: 2),
            child: DefaultTextStyle.merge(
              style: OmnigramTypography.caption(context).copyWith(color: subFg),
              child: subline,
            ),
          );

    final leading = widget.leading == null
        ? null
        : Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconTheme.merge(
              data: IconThemeData(
                color: widget.enabled ? scheme.primary : subFg,
                size: 20,
              ),
              child: widget.leading!,
            ),
          );

    final trailing = _buildTrailing(scheme, fg);

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (leading != null) ...[
            leading,
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleText,
                if (subtitleText != null) subtitleText,
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing,
          ],
        ],
      ),
    );

    final hasGesture = _interactive || widget.onLongPress != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: hasGesture ? (_) => setState(() => _pressed = true) : null,
      onTapUp: hasGesture ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: hasGesture ? () => setState(() => _pressed = false) : null,
      onTap: _interactive ? _handleTap : null,
      onLongPress: widget.onLongPress == null
          ? null
          : () {
              HapticFeedback.mediumImpact();
              widget.onLongPress!();
            },
      child: AnimatedScale(
        scale: _pressed ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: row,
      ),
    );
  }

  Widget? _buildTrailing(ColorScheme scheme, Color fg) {
    switch (widget.tileType) {
      case SettingsTileType.switchTile:
        final sw = CupertinoSwitch(
          value: widget.initialValue,
          onChanged: widget.enabled ? widget.onToggle : null,
          activeTrackColor: widget.activeSwitchColor ?? scheme.primary,
        );
        final extra = widget.trailing;
        if (extra == null) return sw;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [extra, const SizedBox(width: 8), sw],
        );
      case SettingsTileType.navigationTile:
        return widget.trailing ??
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant, size: 22);
      case SettingsTileType.simpleTile:
        return widget.trailing;
    }
  }
}

class CustomSettingsTile extends AbstractSettingsTile {
  const CustomSettingsTile({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
