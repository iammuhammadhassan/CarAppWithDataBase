import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/car_model.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _imageUrls {
    final urls = <String?>[
      widget.car.image,
      widget.car.imageUrl2,
      widget.car.imageUrl3,
    ];

    return urls
        .where((url) {
          final value = url?.trim() ?? '';
          if (value.isEmpty) return false;
          final uri = Uri.tryParse(value);
          return uri != null && (uri.isScheme('http') || uri.isScheme('https'));
        })
        .cast<String>()
        .toList();
  }

  String _formattedPrice() {
    return widget.car.price.toStringAsFixed(0);
  }

  Future<void> _handleInquiry(BuildContext context, String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final prefs = await SharedPreferences.getInstance();
    final buyerId = prefs.getInt('user_id') ?? prefs.getInt('seller_id') ?? 0;

    if (buyerId <= 0) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buyer ID not found. Please log in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await ApiService().sendInquiry(
      vehicleId: widget.car.vehicleId,
      sellerId: widget.car.sellerId,
      buyerId: buyerId,
      message: message,
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Inquiry Sent Successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Fetch the latest inquiry for this vehicle and navigate to ChatScreen
      await _navigateToChatForLatestInquiry(context, buyerId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to send inquiry. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToChatForLatestInquiry(
    BuildContext context,
    int buyerId,
  ) async {
    try {
      // Fetch all inquiries for this buyer
      final inquiries = await ApiService().fetchBuyerInquiries(buyerId);

      if (!context.mounted) return;

      // Find the most recent inquiry for this vehicle
      final relevantInquiries = inquiries.where((inq) {
        return inq.vehicleId == widget.car.vehicleId && inq.buyerId == buyerId;
      }).toList();

      if (relevantInquiries.isEmpty) {
        // If we can't find it immediately, wait a bit and try again
        await Future.delayed(const Duration(milliseconds: 500));
        final retryInquiries = await ApiService().fetchBuyerInquiries(buyerId);

        if (!context.mounted) return;

        final foundInquiries = retryInquiries.where((inq) {
          return inq.vehicleId == widget.car.vehicleId &&
              inq.buyerId == buyerId;
        }).toList();

        if (foundInquiries.isNotEmpty) {
          foundInquiries.sort((a, b) => b.date.compareTo(a.date));
          final latestInquiry = foundInquiries.first;

          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(inquiryId: latestInquiry.id),
            ),
          );
        }
        return;
      }

      // Sort by date (most recent first) and navigate to the latest
      relevantInquiries.sort((a, b) => b.date.compareTo(a.date));
      final latestInquiry = relevantInquiries.first;

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(inquiryId: latestInquiry.id),
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print('Error navigating to chat: $e');
    }
  }

  Future<void> _showInquiryDialog(BuildContext context) async {
    final messageController = TextEditingController(
      text: 'I am interested in this ${widget.car.make} ${widget.car.model}.',
    );

    try {
      final message = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return AlertDialog(
            backgroundColor: const Color(0xFF111417),
            title: const Text(
              'Send Inquiry',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: messageController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write your custom inquiry message',
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
                  Navigator.pop(dialogContext, messageController.text);
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

      if (!mounted || message == null) return;

      await _handleInquiry(context, message);
    } finally {
      messageController.dispose();
    }
  }

  Widget _buildImage(String url, int index) {
    return Hero(
      tag: 'car-image-${widget.car.vehicleId}-$index',
      child: url.isEmpty
          ? Container(
              color: const Color(0xFF111417),
              alignment: Alignment.center,
              child: const Icon(
                Icons.directions_car,
                size: 100,
                color: Colors.cyanAccent,
              ),
            )
          : Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF111417),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.directions_car,
                    size: 100,
                    color: Colors.cyanAccent,
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _imageUrls;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0D0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            backgroundColor: Colors.black,
            title: Text(
              '${widget.car.make} ${widget.car.model}',
              overflow: TextOverflow.ellipsis,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                controller: _pageController,
                itemCount: images.isEmpty ? 1 : images.length,
                itemBuilder: (context, index) {
                  if (images.isEmpty) {
                    return _buildImage('', index);
                  }
                  return _buildImage(images[index], index);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.car.make} ${widget.car.model}',
                    style: GoogleFonts.outfit(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'PKR ${_formattedPrice()}',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailCard(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _showInquiryDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Inquire Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
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

  Widget _buildDetailCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Make', widget.car.make),
          _buildDetailRow('Model', widget.car.model),
          _buildDetailRow('Year', widget.car.yearProduced.toString()),
          _buildDetailRow('Mileage', '${widget.car.mileage} km'),
          _buildDetailRow('Fuel Type', widget.car.fuelType),
          _buildDetailRow('Transmission', widget.car.transmission),
          _buildDetailRow('Location', widget.car.location),
          _buildDetailRow(
            'Inspected',
            widget.car.isInspected == 1 ? 'Yes' : 'No',
          ),
          _buildDetailRow('Views', widget.car.views.toString()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$label',
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
