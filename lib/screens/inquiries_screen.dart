import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_screen.dart';
import '../services/api_service.dart';

class InquiriesScreen extends StatefulWidget {
  final bool isSellerView;
  final int? userId;

  const InquiriesScreen({super.key, required this.isSellerView, this.userId});

  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  late Future<List<Map<String, dynamic>>> _inquiriesFuture;

  @override
  void initState() {
    super.initState();
    _inquiriesFuture = _loadInquiries();
  }

  Future<List<Map<String, dynamic>>> _loadInquiries() async {
    final id = widget.userId ?? await _readUserId();
    if (id <= 0) return [];

    final api = ApiService();
    final primary = widget.isSellerView
        ? api.fetchInquiriesForSeller(id)
        : api.fetchInquiriesForBuyer(id);
    final fallback = widget.isSellerView
        ? api.fetchInquiriesForBuyer(id)
        : api.fetchInquiriesForSeller(id);

    final results = await primary;
    if (results.isNotEmpty) return results;

    return fallback;
  }

  Future<int> _readUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? prefs.getInt('seller_id') ?? 0;
  }

  Future<void> _replyToInquiry(Map<String, dynamic> inquiry) async {
    final replyController = TextEditingController();
    final reply = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111417),
          title: const Text(
            'Reply to Inquiry',
            style: TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: replyController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Type your reply',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, replyController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    replyController.dispose();

    if (reply == null || reply.trim().isEmpty) return;

    final inquiryId =
        int.tryParse(
          inquiry['inquiry_id']?.toString() ?? inquiry['id']?.toString() ?? '0',
        ) ??
        0;
    if (inquiryId <= 0) return;

    final success = await ApiService().replyToInquiry(
      inquiryId: inquiryId,
      reply: reply,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Reply sent successfully.' : 'Failed to send reply.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) {
      setState(() {
        _inquiriesFuture = _loadInquiries();
      });
    }
  }

  int _readInquiryId(Map<String, dynamic> inquiry) {
    return int.tryParse(
          inquiry['inquiry_id']?.toString() ?? inquiry['id']?.toString() ?? '0',
        ) ??
        0;
  }

  void _openChat(Map<String, dynamic> inquiry) {
    final inquiryId = _readInquiryId(inquiry);
    if (inquiryId <= 0) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(inquiryId: inquiryId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _inquiriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00F5FF)),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Failed to load inquiries.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final inquiries = snapshot.data ?? const <Map<String, dynamic>>[];
        if (inquiries.isEmpty) {
          return Center(
            child: Text(
              widget.isSellerView
                  ? 'No inquiries received yet.'
                  : 'No inquiries sent yet.',
              style: const TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: inquiries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final inquiry = inquiries[index];
            final message = (inquiry['message'] ?? '').toString();
            final reply = (inquiry['reply'] ?? inquiry['seller_reply'] ?? '')
                .toString();
            final vehicleId = (inquiry['vehicle_id'] ?? '').toString();
            final createdAt = (inquiry['created_at'] ?? '').toString();

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle #$vehicleId',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.isEmpty ? 'No message provided.' : message,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    createdAt.isEmpty ? '' : createdAt,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  if (reply.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.cyanAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Reply: $reply',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _openChat(inquiry),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Open Chat'),
                      ),
                      if (widget.isSellerView)
                        ElevatedButton(
                          onPressed: () => _replyToInquiry(inquiry),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Reply'),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
