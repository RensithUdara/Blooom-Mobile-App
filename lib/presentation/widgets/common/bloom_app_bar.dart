import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';

class BloomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BloomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.showLogo = false,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showLogo;
  final Widget? leading;

  @override
  Size get preferredSize => Size.fromHeight(subtitle == null ? 70 : 82);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      toolbarHeight: preferredSize.height,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      leading: leading == null
          ? null
          : Padding(padding: const EdgeInsets.only(left: 10), child: leading),
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.82 : 0.90,
          ),
          border: Border(
            bottom: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.28),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.12 : 0.08,
              ),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
      ),
      title: Padding(
        padding: EdgeInsets.only(
          left: leading == null ? 18 : 0,
          right: actions.isEmpty ? 18 : 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (showLogo) ...[
              Container(
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Image.asset(AppConstants.logoAsset),
              ),
              const SizedBox(width: 12),
            ],
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        for (final action in actions)
          Padding(padding: const EdgeInsets.only(right: 8), child: action),
      ],
    );
  }
}
