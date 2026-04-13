import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../config/demo_data.dart';

class FinancesScreen extends StatelessWidget {
  const FinancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Finanzas'),
        centerTitle: false,
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
                _kpiCard('Ingresos Abr', '18,450 Bs', KiltoColors.green),
                _kpiCard('Pendiente', '2,300 Bs', KiltoColors.yellow),
                _kpiCard('Pagos hoy', '1,250 Bs', KiltoColors.teal),
                _kpiCard('Con deuda', '4 pacientes', KiltoColors.red),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              '\u00daltimas transacciones',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: KiltoColors.navy,
              ),
            ),
            const SizedBox(height: 12),
            ...DemoData.transactions.map((tx) {
              final status = tx['status'] as String;
              Color statusBg;
              Color statusFg;

              switch (status) {
                case 'Pagado':
                  statusBg = KiltoColors.greenLight;
                  statusFg = KiltoColors.green;
                  break;
                case 'Parcial':
                  statusBg = KiltoColors.yellowLight;
                  statusFg = KiltoColors.yellow;
                  break;
                case 'Pendiente':
                default:
                  statusBg = KiltoColors.redLight;
                  statusFg = KiltoColors.red;
                  break;
              }

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            tx['patient'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: KiltoColors.navy,
                            ),
                          ),
                        ),
                        Text(
                          tx['amount'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: KiltoColors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          tx['service'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: KiltoColors.greyText,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusFg,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 12, color: KiltoColors.greyText),
                        const SizedBox(width: 4),
                        Text(
                          tx['date'] as String,
                          style: const TextStyle(fontSize: 11, color: KiltoColors.greyText),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.payment, size: 12, color: KiltoColors.greyText),
                        const SizedBox(width: 4),
                        Text(
                          tx['method'] as String,
                          style: const TextStyle(fontSize: 11, color: KiltoColors.greyText),
                        ),
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
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
