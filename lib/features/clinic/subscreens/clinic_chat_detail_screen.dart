import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/clinic_theme.dart';
import '../../../config/theme.dart';
import '../../../core/api/v1/clinic_providers.dart';

/// Chat detail for a single conversation. When [conversationId] is passed,
/// messages are fetched from /v1/clinic/conversations/{id}/messages and sent
/// through POST on the same endpoint. The [patient] map is used only for
/// the AppBar header so callers don't need to fetch it separately.
class ClinicChatDetailScreen extends ConsumerStatefulWidget {
  final int? conversationId;
  final Map<String, dynamic> patient;

  const ClinicChatDetailScreen({
    super.key,
    this.conversationId,
    required this.patient,
  });

  @override
  ConsumerState<ClinicChatDetailScreen> createState() =>
      _ClinicChatDetailScreenState();
}

class _ClinicChatDetailScreenState
    extends ConsumerState<ClinicChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;
    final convId = widget.conversationId;
    if (convId == null) return;

    setState(() => _sending = true);
    try {
      await ref.read(clinicMessagingServiceProvider).send(convId, text);
      _messageController.clear();
      ref.invalidate(clinicConversationMessagesProvider(convId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo enviar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      ClinicAccentTheme(child: _buildContent(context));

  Widget _buildContent(BuildContext context) {
    final patient = widget.patient;
    final convId = widget.conversationId;

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                patient['initials'] as String? ?? '??',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient['name'] as String? ?? '',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: KiltoColors.navy),
                ),
                Text(
                  patient['phone'] as String? ?? '',
                  style: const TextStyle(
                      fontSize: 11, color: KiltoColors.greyText),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: convId == null
                ? const Center(
                    child: Text(
                      'Selecciona una conversación.',
                      style: TextStyle(color: KiltoColors.greyText),
                    ),
                  )
                : _buildMessages(convId),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: KiltoColors.white,
              border: Border(top: BorderSide(color: KiltoColors.greyMid)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      enabled: convId != null && !_sending,
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: const TextStyle(
                            color: KiltoColors.greyText, fontSize: 14),
                        filled: true,
                        fillColor: KiltoColors.grey,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: _sending
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white),
                              ),
                            )
                          : Icon(
                              Icons.send,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(int convId) {
    final async = ref.watch(clinicConversationMessagesProvider(convId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('No se pudieron cargar los mensajes\n$err',
              textAlign: TextAlign.center,
              style: const TextStyle(color: KiltoColors.greyText)),
        ),
      ),
      data: (d) {
        final messages = ((d['messages'] as List?) ?? [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: KiltoColors.greyMid,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Hoy',
                  style: TextStyle(
                      fontSize: 12,
                      color: KiltoColors.greyText,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            if (messages.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Aún no hay mensajes en esta conversación.',
                    style: TextStyle(color: KiltoColors.greyText),
                  ),
                ),
              )
            else
              ...messages.map((msg) {
                return _buildBubble(
                  text: msg['content'] as String? ?? '',
                  time: msg['time_label'] as String? ?? '',
                  isClinic: msg['from_clinic'] == true,
                );
              }),
          ],
        );
      },
    );
  }

  Widget _buildBubble({
    required String text,
    required String time,
    required bool isClinic,
  }) {
    return Align(
      alignment: isClinic ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isClinic
              ? Theme.of(context).colorScheme.primary
              : KiltoColors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isClinic ? 16 : 4),
            bottomRight: Radius.circular(isClinic ? 4 : 16),
          ),
          border: isClinic ? null : Border.all(color: KiltoColors.greyMid),
        ),
        child: Column(
          crossAxisAlignment:
              isClinic ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isClinic
                    ? Theme.of(context).colorScheme.onPrimary
                    : KiltoColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isClinic
                    ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)
                    : KiltoColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
