import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';
import '../../../../modules/dental/screens/odontogram_screen.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Todos';

  List<String> get _filters => kDemoMode
      ? ['Todos', ...{for (final d in DemoData.documents) d['category'] as String}]
      : ['Todos', 'Radiografías', 'Recetas', 'Informes', 'Consentimientos'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        title: const Text('Documentos'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: KiltoColors.teal,
          unselectedLabelColor: KiltoColors.greyText,
          indicatorColor: KiltoColors.teal,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'DMSans',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Odontograma'),
            Tab(text: 'Archivos'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const OdontogramScreen(),
          _buildFilesTab(),
        ],
      ),
    );
  }

  Widget _buildOdontogramTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: KiltoColors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                size: 40,
                color: KiltoColors.teal,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Odontograma',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: KiltoColors.navy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aquí podrás ver el estado de tu salud dental registrado por tu profesional.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: KiltoColors.greyText,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: KiltoColors.yellowLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Disponible próximamente',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: KiltoColors.yellow,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _docTypeIcons = {
    'xray': Icons.image_outlined,
    'prescription': Icons.description_outlined,
    'budget': Icons.article_outlined,
    'consent': Icons.verified_outlined,
    'invoice': Icons.receipt_outlined,
  };

  static const _docTypeColors = {
    'xray': KiltoColors.blue,
    'prescription': KiltoColors.green,
    'budget': KiltoColors.teal,
    'consent': KiltoColors.yellow,
    'invoice': KiltoColors.navy,
  };

  Widget _buildFilesTab() {
    final documents = kDemoMode
        ? DemoData.documents.map((d) => _DocumentData(
              title: d['title'] as String,
              category: d['category'] as String,
              date: d['date'] as String,
              doctor: d['doctor'] as String,
              icon: _docTypeIcons[d['type']] ?? Icons.description_outlined,
              iconColor: _docTypeColors[d['type']] ?? KiltoColors.greyText,
            )).toList()
        : [
            _DocumentData(
              title: 'Radiografía panorámica',
              category: 'Radiografías',
              date: '28 Mar, 2026',
              doctor: 'Dr. María López',
              icon: Icons.image_outlined,
              iconColor: KiltoColors.blue,
            ),
            _DocumentData(
              title: 'Receta enjuague bucal',
              category: 'Recetas',
              date: '28 Mar, 2026',
              doctor: 'Dr. María López',
              icon: Icons.description_outlined,
              iconColor: KiltoColors.green,
            ),
            _DocumentData(
              title: 'Informe de tratamiento',
              category: 'Informes',
              date: '15 Mar, 2026',
              doctor: 'Dr. Carlos Mendoza',
              icon: Icons.article_outlined,
              iconColor: KiltoColors.teal,
            ),
            _DocumentData(
              title: 'Consentimiento informado',
              category: 'Consentimientos',
              date: '10 Mar, 2026',
              doctor: 'Dr. Ana Rojas',
              icon: Icons.verified_outlined,
              iconColor: KiltoColors.yellow,
            ),
          ];

    final filteredDocs = _selectedFilter == 'Todos'
        ? documents
        : documents.where((d) => d.category == _selectedFilter).toList();

    return Column(
      children: [
        // Filter chips
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filters.length,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedFilter = filter);
                  },
                  selectedColor: KiltoColors.teal.withOpacity(0.15),
                  checkmarkColor: KiltoColors.teal,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? KiltoColors.teal : KiltoColors.greyText,
                  ),
                  side: BorderSide(
                    color: isSelected ? KiltoColors.teal : KiltoColors.greyMid,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
        // Document list
        Expanded(
          child: filteredDocs.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    return _buildDocumentCard(doc);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(_DocumentData doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KiltoColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KiltoColors.greyMid),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: doc.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(doc.icon, color: doc.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KiltoColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${doc.date} · ${doc.doctor}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: KiltoColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // View document
            },
            icon: const Icon(Icons.visibility_outlined,
                size: 20, color: KiltoColors.greyText),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            onPressed: () {
              // Download document
            },
            icon: const Icon(Icons.download_outlined,
                size: 20, color: KiltoColors.greyText),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 64,
              color: KiltoColors.greyText.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sin documentos',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: KiltoColors.navy,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'No se encontraron documentos en esta categoría',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: KiltoColors.greyText),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentData {
  final String title;
  final String category;
  final String date;
  final String doctor;
  final IconData icon;
  final Color iconColor;

  _DocumentData({
    required this.title,
    required this.category,
    required this.date,
    required this.doctor,
    required this.icon,
    required this.iconColor,
  });
}
