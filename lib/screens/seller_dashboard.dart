// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  final Color primaryNeon = const Color(0xFF00F5FF);
  final Color obsidianBg = const Color(0xFF0B0D0F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: obsidianBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(), // Fix 1: Header added
              const SizedBox(height: 20),
              _buildStatsGrid(), // Fix 2: Equalized card sizes
              const SizedBox(height: 30),
              _buildChartSection(),
              const SizedBox(height: 30),
              Text("Active Listings", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 15),
              _buildActiveListingsList(), // Fix 3: Image implementation
              const SizedBox(height: 25),
              _buildQuickListButton(),
            ],
          ),
        ),
      ),
    );
  }

  // 1. The Fixed Header
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.directions_car, color: primaryNeon, size: 28),
        const SizedBox(width: 10),
        Text("VORTEX MOTORS", style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const Spacer(),
        Icon(Icons.login_rounded, color: primaryNeon),
      ],
    );
  }

  // 2. The Stats Grid (Using flex to ensure equal size)
  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard("2", "Active", Icons.directions_car),
        const SizedBox(width: 10),
        _buildStatCard("4.3K", "Views", Icons.remove_red_eye_outlined),
        const SizedBox(width: 10),
        _buildStatCard("75", "Inquiries", Icons.chat_bubble_outline),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded( // Ensures equal distribution
      flex: 1, 
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryNeon, size: 18),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey), textAlign: TextAlign.center),
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
        Text("Weekly Views", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 15),
        Container(
          height: 180, // Adjusted height for proportion
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [FlSpot(0, 200), FlSpot(1, 300), FlSpot(2, 280), FlSpot(3, 450), FlSpot(4, 520), FlSpot(5, 680), FlSpot(6, 540)],
                  isCurved: true,
                  color: primaryNeon,
                  barWidth: 4,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, color: primaryNeon.withOpacity(0.1)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 4. The Listings List (Using Network Images)
  Widget _buildActiveListingsList() {
    return Column(
      children: [
        _buildListCard("https://images.unsplash.com/photo-1503376780353-7e11c2706b74", "Porsche 911", "PKR 85.5M"),
        const SizedBox(height: 12),
        _buildListCard("https://images.unsplash.com/photo-1555215695-3004980ad54e", "BMW M4", "PKR 28.5M"),
      ],
    );
  }

  Widget _buildListCard(String imageUrl, String title, String price) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipRRect( // Image Implementation
            borderRadius: BorderRadius.circular(15),
            child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover),
          ),
          const SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(price, style: TextStyle(color: primaryNeon, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () {},
        child: const Text("Quick List New Car", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}