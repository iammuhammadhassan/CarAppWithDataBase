import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/car_model.dart';
import '../services/api_service.dart';
import '../widgets/car_card_widget.dart';
import 'login_screen.dart';

final Color primaryNeon = const Color(0xFF00F5FF);
final Color midnightBg = const Color(0xFF0B0D0F);

class ShowroomScreen extends StatefulWidget {
  final String userRole;
  final String fullName;

  const ShowroomScreen({
    super.key,
    this.userRole = 'buyer',
    this.fullName = '',
  });

  @override
  State<ShowroomScreen> createState() => _ShowroomScreenState();
}

class _ShowroomScreenState extends State<ShowroomScreen>
    with TickerProviderStateMixin {
  final ValueNotifier<bool> _isSearchFocused = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isFeaturedHovered = ValueNotifier<bool>(false);
  late final AnimationController _logoGlowController;
  late final AnimationController _featuredCardGlowController;

  @override
  void initState() {
    super.initState();
    _logoGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _featuredCardGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _isSearchFocused.dispose();
    _isFeaturedHovered.dispose();
    _logoGlowController.dispose();
    _featuredCardGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: _buildGlow(primaryNeon.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: 50,
            right: -100,
            child: _buildGlow(Colors.purple.withValues(alpha: 0.05)),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildSearchBar(),
                _buildSectionHeader(
                  'Featured Listings',
                  'Hand-picked premium vehicles',
                ),
                Expanded(
                  child: FutureBuilder<List<Car>>(
                    future: ApiService().getCars(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.cyanAccent,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Failed to load cars.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      final cars = snapshot.data;
                      if (cars == null || cars.isEmpty) {
                        return const Center(
                          child: Text(
                            'No cars found. Check XAMPP & Database.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _buildHeroFeaturedCard(cars.first),
                          const SizedBox(height: 25),
                          _buildBentoGrid(
                            cars.length > 1 ? cars.sublist(1) : const [],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final roleLabel = widget.userRole.toUpperCase();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;

          final title = Text(
            'VORTEX',
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
            ),
            child: Text(
              roleLabel,
              style: const TextStyle(
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
      ),
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

  Widget _buildSearchBar() {
    return Focus(
      onFocusChange: (hasFocus) {
        _isSearchFocused.value = hasFocus;
      },
      child: ValueListenableBuilder<bool>(
        valueListenable: _isSearchFocused,
        builder: (context, isFocused, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                if (isFocused)
                  BoxShadow(
                    color: primaryNeon.withValues(alpha: 0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for your dream car...',
                hintStyle: const TextStyle(color: Colors.white30),
                prefixIcon: Icon(
                  Icons.search,
                  color: isFocused ? primaryNeon : Colors.white30,
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: primaryNeon, width: 1.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
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
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: Text(
              subtitle,
              style: GoogleFonts.outfit(fontSize: 14, color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoGrid(List<Car> cars) {
    if (cars.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        return _buildVortexBentoCard(cars[index]);
      },
    );
  }

  Widget _buildHeroFeaturedCard(Car car) {
    return AnimatedBuilder(
      animation: _featuredCardGlowController,
      builder: (context, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isFeaturedHovered,
          builder: (context, isHovered, child) {
            return MouseRegion(
              onEnter: (_) => _isFeaturedHovered.value = true,
              onExit: (_) => _isFeaturedHovered.value = false,
              child: GestureDetector(
                onTapDown: (_) => _isFeaturedHovered.value = true,
                onTapCancel: () => _isFeaturedHovered.value = false,
                onTapUp: (_) => _isFeaturedHovered.value = false,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: isHovered
                          ? primaryNeon
                          : Colors.white.withValues(alpha: 0.1),
                      width: isHovered ? 2 : 1,
                    ),
                    boxShadow: [
                      if (isHovered)
                        BoxShadow(
                          color: primaryNeon.withValues(alpha: 0.32),
                          blurRadius: 22,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        height: 380,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          image: DecorationImage(
                            image: NetworkImage(car.image),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(35),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.9),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 20,
                              child: _buildPriceDropBadge(),
                            ),
                            Positioned(
                              bottom: 25,
                              left: 25,
                              right: 25,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    car.model,
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.white54,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          car.location,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white54,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          '640 HP • AWD',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white54,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        'PKR ${car.price}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w900,
                                          color: primaryNeon,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'PKR 92M',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: _MovingBorderGlowPainter(
                              progress: _featuredCardGlowController.value,
                              radius: 35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriceDropBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.cyan.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_down, size: 16, color: Colors.white),
          SizedBox(width: 5),
          Text(
            'Price Drop',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVortexBentoCard(Car car) {
    return CarCardWidget(car: car);
  }

  // Helper function for the glowing effect
  Widget _buildGlow(Color color) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
      ),
    );
  }
}

class _MovingBorderGlowPainter extends CustomPainter {
  final double progress;
  final double radius;

  _MovingBorderGlowPainter({required this.progress, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final rect = Offset.zero & size;
    final outerPath = Path()
      ..addRRect(RRect.fromRectXY(rect.deflate(1.5), radius, radius));

    final metric = outerPath.computeMetrics().isEmpty
        ? null
        : outerPath.computeMetrics().first;
    if (metric == null || metric.length == 0) {
      return;
    }

    final segmentLength = metric.length * 0.18;
    final start = metric.length * progress;
    final end = start + segmentLength;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = primaryNeon.withValues(alpha: 0.95)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = primaryNeon.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    if (end <= metric.length) {
      final segment = metric.extractPath(start, end);
      canvas.drawPath(segment, glowPaint);
      canvas.drawPath(segment, linePaint);
    } else {
      final firstSegment = metric.extractPath(start, metric.length);
      final secondSegment = metric.extractPath(0, end - metric.length);
      canvas.drawPath(firstSegment, glowPaint);
      canvas.drawPath(firstSegment, linePaint);
      canvas.drawPath(secondSegment, glowPaint);
      canvas.drawPath(secondSegment, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MovingBorderGlowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.radius != radius;
  }
}
