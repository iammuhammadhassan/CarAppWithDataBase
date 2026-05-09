import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/car_model.dart';
import '../services/api_service.dart';

class CarDetailsScreen extends StatefulWidget {
  final Car car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final PageController _pageController = PageController();
  bool _isSendingInquiry = false;

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

  Future<void> _sendInquiry() async {
    if (_isSendingInquiry) return;

    setState(() => _isSendingInquiry = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final buyerId = prefs.getInt('user_id') ?? 0;

      if (buyerId <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Buyer ID not found. Please log in again.'),
          ),
        );
        return;
      }

      final success = await ApiService().sendInquiry(
        widget.car.vehicleId,
        widget.car.sellerId,
        buyerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Inquiry sent successfully.' : 'Failed to send inquiry.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSendingInquiry = false);
      }
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
                      onPressed: _isSendingInquiry ? null : _sendInquiry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSendingInquiry
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
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
