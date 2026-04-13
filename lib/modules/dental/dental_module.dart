import 'package:flutter/material.dart';
import '../module_interface.dart';
import 'screens/odontogram_screen.dart';

class DentalModule extends AppModule {
  @override String get id => 'dental';
  @override String get name => 'Odontología';
  @override IconData get icon => Icons.medical_services_rounded;

  @override
  List<ModuleTab> clientTabs() => [
    ModuleTab(
      id: 'odontogram',
      label: 'Odontograma',
      icon: Icons.medical_services_rounded,
      builder: (context) => const OdontogramScreen(),
    ),
  ];

  @override
  List<Widget> clientHomeWidgets(BuildContext context) => [];

  @override
  Widget? clientDocumentSection(BuildContext context) => null;

  @override
  List<ModuleTab> staffTabs() => [];

  @override
  Widget? staffContactSection(BuildContext context, int contactId) => null;
}
