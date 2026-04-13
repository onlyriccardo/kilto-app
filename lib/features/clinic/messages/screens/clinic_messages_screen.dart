import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../config/demo_data.dart';
import '../../subscreens/clinic_chat_detail_screen.dart';

class ClinicMessagesScreen extends StatefulWidget {
  const ClinicMessagesScreen({super.key});

  @override
  State<ClinicMessagesScreen> createState() => _ClinicMessagesScreenState();
}

class _ClinicMessagesScreenState extends State<ClinicMessagesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get _filteredConversations {
    if (_searchQuery.isEmpty) return DemoData.conversations;

    return DemoData.conversations.where((conv) {
      final patientIdx = conv['patientIdx'] as int;
      final patient = DemoData.patients[patientIdx];
      final name = (patient['name'] as String).toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conversations = _filteredConversations;

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
                  color: KiltoColors.navy,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Buscar conversaci\u00f3n...',
                  hintStyle: const TextStyle(color: KiltoColors.greyText, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: KiltoColors.greyText),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: KiltoColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: KiltoColors.greyMid),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: KiltoColors.greyMid),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: KiltoColors.teal, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Conversation list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  final patientIdx = conv['patientIdx'] as int;
                  final patient = DemoData.patients[patientIdx];
                  final unread = conv['unread'] as int;
                  final hasUnread = unread > 0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClinicChatDetailScreen(patient: patient),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: hasUnread ? KiltoColors.tealLight.withOpacity(0.3) : KiltoColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: KiltoColors.greyMid),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: KiltoColors.navy,
                                child: Text(
                                  patient['initials'] as String,
                                  style: const TextStyle(
                                    color: KiltoColors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (hasUnread)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      color: KiltoColors.teal,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$unread',
                                        style: const TextStyle(
                                          color: KiltoColors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
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
                                  patient['name'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                                    color: KiltoColors.navy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  conv['lastMsg'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: hasUnread ? KiltoColors.navy : KiltoColors.greyText,
                                    fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            conv['time'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: hasUnread ? KiltoColors.teal : KiltoColors.greyText,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
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
}
