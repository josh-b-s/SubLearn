import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

/// One row of a [GroupedSection]: a title with optional detail text, control or chevron on the right.
class GroupedRow extends StatelessWidget {
  const GroupedRow({
    super.key,
    required this.title,
    this.subtitle,
    this.info,
    this.leading,
    this.trailing,
    this.onTap,
    this.chevron = false,
  });

  final String title;
  final String? subtitle;

  /// Grey value text next to the chevron or control.
  final String? info;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      backgroundColor: context.cardBackground,
      backgroundColorActivated: context.resolve(CupertinoColors.systemGrey4),
      padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 20, 12),
      leading: leading,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      additionalInfo: info == null ? null : Text(info!),
      trailing: trailing ?? (chevron ? const CupertinoListTileChevron() : null),
      onTap: onTap,
    );
  }
}
