import 'package:flutter/material.dart';

abstract class AppModule {
  String get id;
  String get name;
  IconData get icon;

  // Client role
  List<ModuleTab> clientTabs();
  List<Widget> clientHomeWidgets(BuildContext context);
  Widget? clientDocumentSection(BuildContext context);

  // Staff role
  List<ModuleTab> staffTabs();
  Widget? staffContactSection(BuildContext context, int contactId);
}

class ModuleTab {
  final String id;
  final String label;
  final IconData icon;
  final Widget Function(BuildContext context) builder;
  final int? badgeCount;

  const ModuleTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.builder,
    this.badgeCount,
  });
}
