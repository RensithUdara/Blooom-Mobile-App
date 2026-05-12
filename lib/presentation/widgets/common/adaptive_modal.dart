import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<T?> showAdaptiveModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  double webMaxWidth = 640,
}) {
  if (!kIsWeb) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      builder: builder,
    );
  }

  return showDialog<T>(
    context: context,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final size = MediaQuery.sizeOf(dialogContext);
      return Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: webMaxWidth,
            maxHeight: size.height - 48,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Material(
              color: theme.colorScheme.surface,
              child: builder(dialogContext),
            ),
          ),
        ),
      );
    },
  );
}
