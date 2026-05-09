import 'package:flutter/material.dart';

import '../models/car_model.dart';

const Color carCardPrimaryNeon = Color(0xFF00F5FF);

class CarCardWidget extends StatefulWidget {
  final Car car;

  const CarCardWidget({super.key, required this.car});

  @override
  State<CarCardWidget> createState() => _CarCardWidgetState();
}

class _CarCardWidgetState extends State<CarCardWidget> {
  bool _isHovered = false;

  String get _safeImageUrl {
    final url = widget.car.image.trim();
    if (url.isEmpty) return '';
    final uri = Uri.tryParse(url);
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      return '';
    }
    return url;
  }

  void _setHover(bool value) {
    if (_isHovered != value) {
      setState(() => _isHovered = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: GestureDetector(
        onTapDown: (_) => _setHover(true),
        onTapCancel: () => _setHover(false),
        onTapUp: (_) => _setHover(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _isHovered
                  ? carCardPrimaryNeon
                  : Colors.white.withValues(alpha: 0.1),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: carCardPrimaryNeon.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                _safeImageUrl.isNotEmpty
                    ? Image.network(
                        _safeImageUrl,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.cyanAccent,
                              size: 36,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.cyanAccent,
                          size: 36,
                        ),
                      ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 15,
                  left: 15,
                  right: 15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.car.model,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${widget.car.price} PKR',
                        style: TextStyle(
                          color: carCardPrimaryNeon,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
