import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../core/auth/account.dart';

/// A single clinic tile in the MyClinics list.
class ClinicCard extends StatelessWidget {
  final ClinicMembership membership;
  final VoidCallback? onTap;

  const ClinicCard({super.key, required this.membership, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KiltoRadii.large),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _Avatar(membership: membership),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membership.tenantName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: KiltoColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _RolePill(role: membership.role),
                        if (membership.status != 'active') ...[
                          const SizedBox(width: 6),
                          _StatusPill(status: membership.status),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: KiltoColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final ClinicMembership membership;
  const _Avatar({required this.membership});

  @override
  Widget build(BuildContext context) {
    final initial = membership.tenantName.isNotEmpty
        ? membership.tenantName[0].toUpperCase()
        : '?';

    // Each clinic gets its own accent: we paint a filled rounded-square in
    // its brand color with a contrasting initial. Falls back to the default
    // Kilto light fill when the clinic hasn't customized its branding.
    final brand = membership.brandColor;
    final bg = brand ?? KiltoColors.brandLight;
    final fg = brand == null
        ? KiltoColors.textPrimary
        : (brand.computeLuminance() > 0.55 ? Colors.black : Colors.white);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KiltoRadii.small),
        border: Border.all(
          color: brand ?? KiltoColors.border,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final String role;
  const _RolePill({required this.role});

  @override
  Widget build(BuildContext context) {
    final isStaff = role == 'staff';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isStaff ? KiltoColors.infoLight : KiltoColors.borderLight,
        borderRadius: BorderRadius.circular(KiltoRadii.pill),
        border: Border.all(
          color: isStaff ? KiltoColors.info : KiltoColors.border,
        ),
      ),
      child: Text(
        isStaff ? 'Staff' : 'Cliente',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isStaff ? KiltoColors.info : KiltoColors.textSecondary,
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'pending_approval' => KiltoColors.warning,
      'disabled' => KiltoColors.error,
      _ => KiltoColors.textSecondary,
    };
    final bg = switch (status) {
      'pending_approval' => KiltoColors.warningLight,
      'disabled' => KiltoColors.errorLight,
      _ => KiltoColors.borderLight,
    };
    final label = switch (status) {
      'pending_approval' => 'Pendiente',
      'disabled' => 'Deshabilitado',
      _ => status,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KiltoRadii.pill),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
