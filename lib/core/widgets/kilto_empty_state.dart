import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'kilto_text.dart';

/// Shared empty-state block: icon-in-rounded-square + title + sub + optional
/// CTA. Drop into a `Center` (or use it directly inside an `Expanded`) — it
/// sizes itself and clamps width on wide screens.
class KiltoEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Optional tint override for the icon container.
  final Color? iconTint;

  const KiltoEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconTint,
  });

  @override
  Widget build(BuildContext context) {
    final tint = iconTint ?? KiltoColors.zinc500;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: KiltoColors.zinc100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 32, color: tint),
              ),
              const SizedBox(height: 16),
              KiltoText.h3(title, align: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                KiltoText.body(
                  subtitle!,
                  align: TextAlign.center,
                  color: KiltoColors.zinc500,
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
