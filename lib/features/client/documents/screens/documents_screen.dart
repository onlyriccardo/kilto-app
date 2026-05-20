import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../config/clinic_theme.dart';
import '../../../../config/demo_data.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/theme.dart';
import '../../../../core/api/v1/models.dart';
import '../../../../core/api/v1/v1_providers.dart';
import '../../../../core/widgets/kilto_card.dart';
import '../../../../core/widgets/kilto_empty_state.dart';
import '../../../../core/widgets/kilto_text.dart';
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
    final accent =
        Theme.of(context).extension<ClinicAccentExtension>()?.accent ??
            KiltoColors.brandPrimary;

    return Scaffold(
      backgroundColor: KiltoColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KiltoText.label('Tu clínica'),
                  const SizedBox(height: 2),
                  KiltoText.h1('Documentos'),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              labelColor: accent,
              unselectedLabelColor: KiltoColors.zinc500,
              indicatorColor: accent,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: KiltoColors.border,
              labelStyle: const TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: -0.1,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: KiltoFonts.familyHeading,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Odontograma'),
                Tab(text: 'Archivos'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  const OdontogramScreen(),
                  kDemoMode ? _buildDemoFilesTab() : _buildRealFilesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
    final accent =
        Theme.of(context).extension<ClinicAccentExtension>()?.accent ??
            KiltoColors.brandPrimary;

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final f = filters[i];
              final sel = _selectedFilter == f;
              return _FilterPill(
                label: f,
                selected: sel,
                accent: accent,
                onTap: () => setState(() => _selectedFilter = f),
              );
            },
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? KiltoEmptyState(
                  icon: Icons.folder_open_outlined,
                  title: 'Sin documentos',
                  subtitle:
                      'No se encontraron documentos en esta categoría.',
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(20, 10, 20, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _DocumentCard(
                    doc: filtered[i],
                    onOpen: () => filtered[i].downloadUrl != null
                        ? _openUrl(filtered[i].downloadUrl!)
                        : null,
                  ),
                ),
        ),
      ],
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

  Widget _buildErrorState(String msg) => KiltoEmptyState(
        icon: Icons.error_outline_rounded,
        title: 'No se pudieron cargar los documentos',
        subtitle: msg,
        actionLabel: 'Reintentar',
        onAction: () => ref.invalidate(documentsProvider),
      );
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(KiltoRadii.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(KiltoRadii.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? accent : KiltoColors.surface,
            borderRadius: BorderRadius.circular(KiltoRadii.pill),
            border: Border.all(
              color: selected ? accent : KiltoColors.border,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: KiltoFonts.familyHeading,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
              color: selected
                  ? (accent.computeLuminance() > 0.55
                      ? Colors.black
                      : Colors.white)
                  : KiltoColors.zinc700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final DocumentItem doc;
  final VoidCallback? onOpen;
  const _DocumentCard({required this.doc, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final (icon, tint) = _visualForType(doc.type);

    return KiltoCard(
      onTap: onOpen,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(KiltoRadii.xsmall),
            ),
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                KiltoText.strong(doc.title, size: 13.5),
                const SizedBox(height: 2),
                KiltoText.label('${doc.date} · ${doc.category}'),
              ],
            ),
          ),
          if (doc.downloadUrl != null)
            const Icon(Icons.download_rounded,
                size: 18, color: KiltoColors.zinc500),
        ],
      ),
    );
  }

  static (IconData, Color) _visualForType(String? type) {
    switch (type) {
      case 'xray':
        return (Icons.image_outlined, KiltoColors.info);
      case 'prescription':
        return (Icons.description_outlined, KiltoColors.success);
      case 'budget':
        return (Icons.article_outlined, KiltoColors.violet);
      case 'consent':
        return (Icons.verified_outlined, KiltoColors.warning);
      case 'invoice':
        return (Icons.receipt_outlined, KiltoColors.zinc700);
      default:
        if (type == null) {
          return (Icons.insert_drive_file_outlined, KiltoColors.zinc500);
        }
        if (type.contains('image')) {
          return (Icons.image_outlined, KiltoColors.info);
        }
        if (type.contains('pdf')) {
          return (Icons.picture_as_pdf_outlined, KiltoColors.error);
        }
        return (Icons.insert_drive_file_outlined, KiltoColors.zinc500);
    }
  }
}
