import 'package:flutter/material.dart';

import '../models/inquiry_model.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class BuyerInquiriesScreen extends StatefulWidget {
  final int buyerId;

  const BuyerInquiriesScreen({super.key, required this.buyerId});

  @override
  State<BuyerInquiriesScreen> createState() => _BuyerInquiriesScreenState();
}

class _BuyerInquiriesScreenState extends State<BuyerInquiriesScreen> {
  late Future<List<Inquiry>> _inquiriesFuture;

  @override
  void initState() {
    super.initState();
    _inquiriesFuture = ApiService().fetchBuyerInquiries(widget.buyerId);
  }

  void _openChat(Inquiry inquiry) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(inquiryId: inquiry.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Inquiry>>(
      future: _inquiriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00F5FF)),
          );
        }

        if (snapshot.hasError) {
          // ignore: avoid_print
          print('Buyer inquiries error: ${snapshot.error}');
          return Center(
            child: Text(
              'Failed to load inquiries',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final inquiries = snapshot.data ?? [];

        if (inquiries.isEmpty) {
          return Center(
            child: Text(
              'No inquiries yet. Start by exploring the showroom!',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: inquiries.length,
          itemBuilder: (context, index) {
            final inquiry = inquiries[index];
            return GestureDetector(
              onTap: () => _openChat(inquiry),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                inquiry.carName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                inquiry.message,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF00F5FF),
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      inquiry.date,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
