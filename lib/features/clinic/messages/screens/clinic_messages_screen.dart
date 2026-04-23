import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/theme.dart';
import '../../../../core/api/v1/clinic_providers.dart';
import '../../subscreens/clinic_chat_detail_screen.dart';

/// Conversations list for clinic staff. Fetched from /v1/clinic/conversations.
/// Backend returns { id, contact_id, name, initials, last_message,
/// time_label, unread_count }.
class ClinicMessagesScreen extends ConsumerStatefulWidget {
  const ClinicMessagesScreen({super.key});

  @override
  ConsumerState<ClinicMessagesScreen> createState() =>
      _ClinicMessagesScreenState();
}

class _ClinicMessagesScreenState extends ConsumerState<ClinicMessagesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(clinicConversationsProvider);

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Mensajes',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: KiltoColors.navy),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Buscar conversación...',
                  prefixIcon:
                      const Icon(Icons.search, color: KiltoColors.greyText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: KiltoColors.greyMid),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: KiltoColors.greyMid),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2),
                  ),
                  filled: true,
                  fillColor: KiltoColors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: async.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: KiltoColors.red, size: 36),
                        const SizedBox(height: 8),
                        Text('No se pudo cargar mensajes\n$err',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: KiltoColors.greyText)),
                      ],
                    ),
                  ),
                ),
                data: (all) {
                  final list = _searchQuery.isEmpty
                      ? all
                      : all
                          .where((c) => (c['name'] as String? ?? '')
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();
                  return RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(clinicConversationsProvider),
                    child: list.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'No hay conversaciones.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: KiltoColors.greyText),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: list.length,
                            itemBuilder: (context, i) =>
                                _buildConversationCard(list[i]),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conv) {
    final unread = (conv['unread_count'] as int?) ?? 0;
    final hasUnread = unread > 0;
    final accent = Theme.of(context).colorScheme.primary;
    final onAccent = Theme.of(context).colorScheme.onPrimary;
    final accentLight = Color.alphaBlend(accent.withOpacity(0.12), Colors.white);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ClinicChatDetailScreen(
              conversationId: conv['id'] as int,
              patient: {
                'name': conv['name'] ?? '',
                'initials': conv['initials'] ?? '??',
                'phone': '',
                'avatar': conv['avatar'],
              },
            ),
          ),
        ).then((_) => ref.invalidate(clinicConversationsProvider));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasUnread ? accentLight : KiltoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KiltoColors.greyMid),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: accent,
                  child: Text(
                    conv['initials'] as String? ?? '??',
                    style: TextStyle(
                        color: onAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration:
                          BoxDecoration(color: accent, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '$unread',
                          style: TextStyle(
                              color: onAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conv['name'] as String? ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                      color: KiltoColors.navy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    conv['last_message'] as String? ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          hasUnread ? KiltoColors.navy : KiltoColors.greyText,
                      fontWeight:
                          hasUnread ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              conv['time_label'] as String? ?? '',
              style: TextStyle(
                fontSize: 11,
                color: hasUnread ? accent : KiltoColors.greyText,
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
