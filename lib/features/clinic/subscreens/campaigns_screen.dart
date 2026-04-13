import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../config/demo_data.dart';

class CampaignsScreen extends StatelessWidget {
  const CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Compute aggregate KPIs
    final campaigns = DemoData.campaigns;
    final totalSent = campaigns.fold<int>(0, (sum, c) => sum + (c['sent'] as int));
    final totalOpened = campaigns.fold<int>(0, (sum, c) => sum + (c['opened'] as int));
    final totalClicked = campaigns.fold<int>(0, (sum, c) => sum + (c['clicked'] as int));
    final openRate = totalSent > 0 ? (totalOpened / totalSent * 100).round() : 0;
    final clickRate = totalSent > 0 ? (totalClicked / totalSent * 100).round() : 0;
    final activeCampaigns = campaigns.where((c) => c['status'] == 'active').length;

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Campa\u00f1as'),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _showAddCampaignSheet(context),
            icon: const Icon(Icons.add, size: 24),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              children: [
                _kpiCard('Enviados', '$totalSent', KiltoColors.blue),
                _kpiCard('Tasa apertura', '$openRate%', KiltoColors.green),
                _kpiCard('Tasa clic', '$clickRate%', KiltoColors.teal),
                _kpiCard('Activas', '$activeCampaigns', KiltoColors.yellow),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Campa\u00f1as',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: KiltoColors.navy,
              ),
            ),
            const SizedBox(height: 12),
            ...campaigns.map((campaign) {
              final isActive = campaign['status'] == 'active';
              final sent = campaign['sent'] as int;
              final opened = campaign['opened'] as int;
              final clicked = campaign['clicked'] as int;
              final campaignOpenRate = sent > 0 ? (opened / sent * 100).round() : 0;
              final campaignClickRate = sent > 0 ? (clicked / sent * 100).round() : 0;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: KiltoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: KiltoColors.greyMid),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            campaign['name'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: KiltoColors.navy,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive ? KiltoColors.greenLight : KiltoColors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isActive ? 'Activa' : 'Borrador',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isActive ? KiltoColors.green : KiltoColors.greyText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _statChip('Enviados', '$sent'),
                        const SizedBox(width: 12),
                        _statChip('Apertura', '$campaignOpenRate%'),
                        const SizedBox(width: 12),
                        _statChip('Clic', '$campaignClickRate%'),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showAddCampaignSheet(BuildContext context) {
    String? selectedType;
    const campaignTypes = ['Promoción', 'Recordatorio', 'Cumpleaños'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              const Text('Nueva Campaña', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1B2A4A))),
              const SizedBox(height: 16),
              TextFormField(decoration: const InputDecoration(labelText: 'Nombre de campaña', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder()),
                items: campaignTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setSheetState(() => selectedType = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Mensaje', border: OutlineInputBorder(), alignLabelWithHint: true),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Campaña creada como borrador'), backgroundColor: Color(0xFF2EC4B6)),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: KiltoColors.teal, foregroundColor: KiltoColors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Crear borrador', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: KiltoColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11, color: KiltoColors.greyText),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: KiltoColors.navy,
          ),
        ),
      ],
    );
  }
}
