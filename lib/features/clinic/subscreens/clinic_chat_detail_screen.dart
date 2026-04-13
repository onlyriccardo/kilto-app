import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class ClinicChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const ClinicChatDetailScreen({super.key, required this.patient});

  @override
  State<ClinicChatDetailScreen> createState() => _ClinicChatDetailScreenState();
}

class _ClinicChatDetailScreenState extends State<ClinicChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'from': 'patient', 'text': 'Buenos d\u00edas doctor, ten\u00eda una consulta', 'time': '09:00'},
    {'from': 'clinic', 'text': '\u00a1Hola! Claro, \u00bfen qu\u00e9 puedo ayudarte?', 'time': '09:02'},
    {'from': 'patient', 'text': '\u00bfPuedo reagendar mi cita de ma\u00f1ana?', 'time': '09:05'},
    {'from': 'clinic', 'text': 'Por supuesto. \u00bfQu\u00e9 d\u00eda te queda mejor?', 'time': '09:06'},
    {'from': 'patient', 'text': '\u00bfTienen disponibilidad el jueves por la tarde?', 'time': '09:08'},
    {'from': 'clinic', 'text': 'S\u00ed, tenemos horario a las 14:00 y 15:30 el jueves. \u00bfCu\u00e1l prefieres?', 'time': '09:10'},
    {'from': 'patient', 'text': 'El de las 14:00 estar\u00eda perfecto', 'time': '09:12'},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({
        'from': 'clinic',
        'text': text,
        'time': TimeOfDay.now().format(context),
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;

    return Scaffold(
      backgroundColor: KiltoColors.grey,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: KiltoColors.navy,
              child: Text(
                patient['initials'] as String,
                style: const TextStyle(
                  color: KiltoColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient['name'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: KiltoColors.navy,
                  ),
                ),
                Text(
                  patient['phone'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    color: KiltoColors.greyText,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Llamando a ${patient['name']}...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.phone_outlined, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Date pill
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: KiltoColors.greyMid,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Hoy',
                      style: TextStyle(
                        fontSize: 12,
                        color: KiltoColors.greyText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                ..._messages.map((msg) {
                  final isClinic = msg['from'] == 'clinic';
                  return _buildBubble(
                    text: msg['text'] as String,
                    time: msg['time'] as String,
                    isClinic: isClinic,
                  );
                }),
              ],
            ),
          ),
          // Quick replies
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _quickChip('\u{1F4C5} Agendar cita', '\u00a1Claro! \u00bfQu\u00e9 d\u00eda y horario te conviene? Tenemos disponibilidad esta semana.'),
                  const SizedBox(width: 8),
                  _quickChip('\u2705 Confirmar', '\u00a1Perfecto! Tu cita est\u00e1 confirmada. Te enviaremos un recordatorio.'),
                  const SizedBox(width: 8),
                  _quickChip('\u{1F4CB} Ver historial', 'Tu \u00faltimo tratamiento fue el 28 Mar 2026 \u2014 Ortodoncia Ajuste con Dra. Guti\u00e9rrez.'),
                ],
              ),
            ),
          ),
          // Input
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
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: const TextStyle(
                          color: KiltoColors.greyText,
                          fontSize: 14,
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
          ),
        ],
      ),
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
          color: isClinic ? KiltoColors.teal : KiltoColors.white,
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
                color: isClinic ? KiltoColors.white : KiltoColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isClinic
                    ? KiltoColors.white.withOpacity(0.7)
                    : KiltoColors.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(String label, String replyText) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _messages.add({
            'from': 'clinic',
            'text': replyText,
            'time': TimeOfDay.now().format(context),
          });
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: KiltoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: KiltoColors.greyMid),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: KiltoColors.navy,
          ),
        ),
      ),
    );
  }
}
