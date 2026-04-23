import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';
import '../../../../core/api/v1/models.dart';
import '../../../../core/api/v1/v1_providers.dart';
import '../../../../modules/dental/screens/odontogram_screen.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Todos';

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
          kDemoMode ? _buildDemoFilesTab() : _buildRealFilesTab(),
        ],
      ),
    );
  }

  // ── Demo path (unchanged hardcoded data) ──────────────────────────
  Widget _buildDemoFilesTab() {
    final documents = DemoData.documents.map((d) {
      return DocumentItem(
        id: 0,
        title: d['title'] as String,
        type: d['type'] as String?,
        category: d['category'] as String,
        date: d['date'] as String,
      );
    }).toList();
    final filters = [
      'Todos',
      ...{for (final d in documents) d.category},
    ];
    final filtered = _selectedFilter == 'Todos'
        ? documents
        : documents.where((d) => d.category == _selectedFilter).toList();
    return _filesLayout(filters, filtered);
  }

  // ── Real path ─────────────────────────────────────────────────────
  Widget _buildRealFilesTab() {
    final async = ref.watch(documentsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildErrorState(e.toString()),
      data: (docs) {
        final categories = {for (final d in docs) d.category};
        final filters = ['Todos', ...categories];
        final filtered = _selectedFilter == 'Todos'
            ? docs
            : docs.where((d) => d.category == _selectedFilter).toList();
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(documentsProvider),
          child: _filesLayout(filters, filtered),
        );
      },
    );
  }

  Widget _filesLayout(List<String> filters, List<DocumentItem> filtered) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filters.length,
            itemBuilder: (_, i) {
              final f = filters[i];
              final sel = _selectedFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f),
                  selected: sel,
                  onSelected: (_) => setState(() => _selectedFilter = f),
                  selectedColor: KiltoColors.teal.withOpacity(0.15),
                  checkmarkColor: KiltoColors.teal,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: sel ? KiltoColors.teal : KiltoColors.greyText,
                  ),
                  side: BorderSide(
                    color: sel ? KiltoColors.teal : KiltoColors.greyMid,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _buildDocumentCard(filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(DocumentItem doc) {
    final icon = _iconForType(doc.type);
    final color = _colorForType(doc.type);
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
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
                  '${doc.date} · ${doc.category}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: KiltoColors.greyText,
                  ),
                ),
              ],
            ),
          ),
          if (doc.downloadUrl != null)
            IconButton(
              onPressed: () => _openUrl(doc.downloadUrl!),
              icon: const Icon(Icons.visibility_outlined,
                  size: 20, color: KiltoColors.greyText),
              tooltip: 'Ver',
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
          if (doc.downloadUrl != null)
            IconButton(
              onPressed: () => _openUrl(doc.downloadUrl!),
              icon: const Icon(Icons.download_outlined,
                  size: 20, color: KiltoColors.greyText),
              tooltip: 'Descargar',
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el documento')),
      );
    }
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'xray':
        return Icons.image_outlined;
      case 'prescription':
        return Icons.description_outlined;
      case 'budget':
        return Icons.article_outlined;
      case 'consent':
        return Icons.verified_outlined;
      case 'invoice':
        return Icons.receipt_outlined;
      default:
        if (type == null) return Icons.insert_drive_file_outlined;
        if (type.contains('image')) return Icons.image_outlined;
        if (type.contains('pdf')) return Icons.picture_as_pdf_outlined;
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _colorForType(String? type) {
    switch (type) {
      case 'xray':
        return KiltoColors.blue;
      case 'prescription':
        return KiltoColors.green;
      case 'budget':
        return KiltoColors.teal;
      case 'consent':
        return KiltoColors.yellow;
      case 'invoice':
        return KiltoColors.navy;
      default:
        return KiltoColors.teal;
    }
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

  Widget _buildErrorState(String msg) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: KiltoColors.greyText),
            const SizedBox(height: 12),
            const Text('No se pudieron cargar los documentos',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: KiltoColors.greyText)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.invalidate(documentsProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
}
