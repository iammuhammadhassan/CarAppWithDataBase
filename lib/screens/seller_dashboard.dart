// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login_screen.dart';
import '../services/api_service.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard>
    with TickerProviderStateMixin {
  late final AnimationController _logoGlowController;
  late final Future<Map<String, dynamic>> _sellerStatsFuture;
  late final Future<List<double>> _weeklyViewsFuture;

  @override
  void initState() {
    super.initState();
    _sellerStatsFuture = ApiService().fetchSellerStats();
    _weeklyViewsFuture = ApiService().fetchWeeklyViews();
    _logoGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoGlowController.dispose();
    super.dispose();
  }

  final Color primaryNeon = const Color(0xFF00F5FF);
  final Color obsidianBg = const Color(0xFF0B0D0F);

  String _formatCompactStat(dynamic value) {
    final raw = (value ?? '0').toString().trim().replaceAll(',', '');
    final number = double.tryParse(raw);
    if (number == null) return '0';

    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    }
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    }
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }

    return number.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
      body: Stack(
        children: [
          Positioned(
            top: -90,
            left: -100,
            child: _buildGlow(primaryNeon.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: 50,
            right: -110,
            child: _buildGlow(Colors.purple.withValues(alpha: 0.05)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildStatsGrid(),
                  const SizedBox(height: 30),
                  _buildChartSection(),
                  const SizedBox(height: 30),
                  _buildSectionHeader(
                    'Active Listings',
                    'Manage your live inventory',
                  ),
                  const SizedBox(height: 15),
                  _buildActiveListingsList(),
                  const SizedBox(height: 25),
                  _buildQuickListButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 420;

        final title = Text(
          'VORTEX MOTORS',
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        );

        final roleBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryNeon.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryNeon.withValues(alpha: 0.18)),
          ),
          child: const Text(
            'SELLER',
            style: TextStyle(
              color: Color(0xFF00F5FF),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

        final logoutButton = IconButton(
          icon: Icon(
            Icons.logout_rounded,
            color: Colors.white.withValues(alpha: 0.6),
          ),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          },
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildGlowingLogo(),
                  const SizedBox(width: 15),
                  Expanded(child: title),
                ],
              ),
              const SizedBox(height: 12),
              Row(children: [roleBadge, const Spacer(), logoutButton]),
            ],
          );
        }

        return Row(
          children: [
            _buildGlowingLogo(),
            const SizedBox(width: 15),
            Expanded(child: title),
            const SizedBox(width: 12),
            roleBadge,
            const SizedBox(width: 10),
            logoutButton,
          ],
        );
      },
    );
  }

  Widget _buildGlowingLogo() {
    return AnimatedBuilder(
      animation: _logoGlowController,
      builder: (context, child) {
        final glow = 0.25 + (_logoGlowController.value * 0.45);
        final spread = 2 + (_logoGlowController.value * 4);
        final blur = 14 + (_logoGlowController.value * 18);

        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryNeon.withValues(alpha: glow),
                blurRadius: blur,
                spreadRadius: spread,
              ),
            ],
            border: Border.all(
              color: primaryNeon.withValues(
                alpha: 0.55 + (_logoGlowController.value * 0.35),
              ),
              width: 1.2,
            ),
          ),
          child: Icon(Icons.directions_car, color: primaryNeon, size: 24),
        );
      },
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 28)],
      ),
    );
  }

  // 2. The Stats Grid (Using flex to ensure equal size)
  Widget _buildStatsGrid() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _sellerStatsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? <String, dynamic>{};
        final stats =
            (data['stats'] as Map<String, dynamic>?) ?? <String, dynamic>{};

        return Row(
          children: [
            _buildStatCard(
              _formatCompactStat(stats['active_listings']),
              "Active\nListings",
              Icons.directions_car,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              _formatCompactStat(stats['total_views']),
              "Total\nViews",
              Icons.remove_red_eye_outlined,
            ),
            const SizedBox(width: 10),
            _buildStatCard(
              _formatCompactStat(stats['total_inquiries']),
              "Inquiries",
              Icons.chat_bubble_outline,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      // Ensures equal distribution
      flex: 1,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: primaryNeon.withValues(alpha: 0.06),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryNeon, size: 18),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // 3. The Analytics Chart
  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Weekly Views', 'Performance at a glance'),
        const SizedBox(height: 15),
        Container(
          height: 180, // Adjusted height for proportion
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: primaryNeon.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: FutureBuilder<List<double>>(
            future: _weeklyViewsFuture,
            builder: (context, snapshot) {
              final values =
                  (snapshot.data != null && snapshot.data!.isNotEmpty)
                  ? snapshot.data!
                  : <double>[0, 0, 0, 0, 0, 0, 0];

              final spots = values
                  .asMap()
                  .entries
                  .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
                  .toList();

              return LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: primaryNeon,
                      barWidth: 4,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: primaryNeon.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 4. The Listings List (Using Network Images)
  Widget _buildActiveListingsList() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _sellerStatsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? <String, dynamic>{};
        final listings = (data['listings'] as List?) ?? <dynamic>[];

        if (listings.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Text(
            'No active listings found for this seller.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return Column(
          children: List.generate(listings.length, (index) {
            final item =
                listings[index] as Map<String, dynamic>? ?? <String, dynamic>{};

            final make = (item['make'] ?? '').toString().trim();
            final model = (item['model'] ?? '').toString().trim();
            final title = '$make $model'.trim().isEmpty
                ? 'Untitled Car'
                : '$make $model'.trim();
            final price = 'PKR ${(item['price'] ?? '0').toString()}';
            final imageUrl = (item['image_url'] ?? '').toString().trim();

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == listings.length - 1 ? 0 : 12,
              ),
              child: _buildListCard(imageUrl, title, price),
            );
          }),
        );
      },
    );
  }

  Widget _buildListCard(String imageUrl, String title, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: primaryNeon.withValues(alpha: 0.05),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            // Image Implementation
            borderRadius: BorderRadius.circular(15),
            child: imageUrl.isEmpty
                ? Container(
                    width: 60,
                    height: 60,
                    color: Colors.white12,
                    child: Icon(
                      Icons.directions_car,
                      color: primaryNeon,
                      size: 28,
                    ),
                  )
                : Image.network(
                    imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.white12,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: primaryNeon,
                          size: 28,
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  color: primaryNeon,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Row(
              children: List.generate(
                3,
                (index) => Container(
                  margin: const EdgeInsets.only(right: 3),
                  width: 3,
                  height: 24,
                  decoration: BoxDecoration(
                    color: primaryNeon,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryNeon.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuickListButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNeon,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {},
        child: const Text(
          "Quick List New Car",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
