import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_mode.dart';
import '../../../../config/demo_data.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final List<_ChatMessage> _messages = kDemoMode
      ? DemoData.chatMessages.map((m) => _ChatMessage(
            text: m['text'] as String,
            isFromClinic: m['from'] == 'clinic',
            time: m['time'] as String,
          )).toList()
      : [
          _ChatMessage(
            text: 'Hola, bienvenido/a a nuestra clínica. ¿En qué podemos ayudarte?',
            isFromClinic: true,
            time: '9:00 AM',
          ),
          _ChatMessage(
            text: 'Hola, me gustaría agendar una limpieza dental.',
            isFromClinic: false,
            time: '9:02 AM',
          ),
          _ChatMessage(
            text: 'Con gusto. Tenemos disponibilidad el lunes 15 a las 10:00 AM o el miércoles 17 a las 3:30 PM. ¿Cuál prefieres?',
            isFromClinic: true,
            time: '9:05 AM',
          ),
        ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isFromClinic: false,
        time: TimeOfDay.now().format(context),
      ));
      _messageController.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kDemoMode ? DemoData.tenant['name'] as String : 'Clínica Dental',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: KiltoColors.navy,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: KiltoColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'En línea',
                  style: TextStyle(
                    fontSize: 11,
                    color: KiltoColors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Hours banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: KiltoColors.tealLight,
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 15, color: KiltoColors.tealDark),
                const SizedBox(width: 8),
                Text(
                  'Horario de atención: Lun-Vie 8:00 AM - 6:00 PM',
                  style: TextStyle(
                    fontSize: 12,
                    color: KiltoColors.navy.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          // Quick action chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildQuickChip('Solicitar cita', Icons.calendar_today),
                const SizedBox(width: 8),
                _buildQuickChip('Enviar foto', Icons.camera_alt_outlined),
                const SizedBox(width: 8),
                _buildQuickChip('Urgencia', Icons.warning_amber_rounded),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Input bar
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            decoration: const BoxDecoration(
              color: KiltoColors.white,
              border: Border(top: BorderSide(color: KiltoColors.greyMid)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: KiltoColors.greyText,
                      ),
                      filled: true,
                      fillColor: KiltoColors.grey,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: KiltoColors.teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: KiltoColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage message) {
    final isClinic = message.isFromClinic;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isClinic ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isClinic) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: KiltoColors.navy.withOpacity(0.1),
              child: const Icon(Icons.business, size: 14, color: KiltoColors.navy),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isClinic ? KiltoColors.white : KiltoColors.teal,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isClinic ? 4 : 16),
                  bottomRight: Radius.circular(isClinic ? 16 : 4),
                ),
                border: isClinic
                    ? Border.all(color: KiltoColors.greyMid)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: isClinic ? KiltoColors.navy : KiltoColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.time,
                    style: TextStyle(
                      fontSize: 10,
                      color: isClinic
                          ? KiltoColors.greyText
                          : KiltoColors.white.withOpacity(0.7),
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

  Widget _buildQuickChip(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        _messageController.text = label;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: KiltoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KiltoColors.greyMid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: KiltoColors.teal),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: KiltoColors.navy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isFromClinic;
  final String time;

  _ChatMessage({
    required this.text,
    required this.isFromClinic,
    required this.time,
  });
}
