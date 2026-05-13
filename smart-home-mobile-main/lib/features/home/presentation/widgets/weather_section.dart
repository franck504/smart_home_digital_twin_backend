import 'package:flutter/material.dart';
import '../../data/models/house_state_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math' as math;

class WeatherSection extends StatefulWidget {
  final Weather weather;

  const WeatherSection({super.key, required this.weather});

  @override
  State<WeatherSection> createState() => _WeatherSectionState();
}

class _WeatherSectionState extends State<WeatherSection>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rotationController;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();
    
    // Contrôleur pour la lévitation et le changement de couleur (Aller-Retour Fluide)
    _mainController = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);

    // Contrôleur pour la rotation des rayons (Rotation Infinie Continue)
    _rotationController = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();

    _floatingAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors;
    final String iconCode = widget.weather.icon.substring(0, 2);

    switch (iconCode) {
      case '01':
        gradientColors = [const Color(0xFFFF8C00), const Color(0xFFFFD700)];
        break;
      case '02':
        gradientColors = [const Color(0xFFF59E0B), const Color(0xFFFFD700)];
        break;
      case '03':
      case '04':
        gradientColors = [const Color(0xFF1E293B), const Color(0xFF64748B)];
        break;
      case '09':
      case '10':
        gradientColors = [const Color(0xFF1E3A8A), const Color(0xFF60A5FA)];
        break;
      case '11':
        gradientColors = [const Color(0xFF4C1D95), const Color(0xFFA855F7)];
        break;
      case '13':
        gradientColors = [const Color(0xFF0C4A6E), const Color(0xFFBAE6FD)];
        break;
      default:
        gradientColors = [const Color(0xFF0F172A), const Color(0xFF334155)];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Prévision Demain',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Spacer(),
            if (widget.weather.location.isNotEmpty)
              Text(
                widget.weather.location,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: Listenable.merge([_mainController, _rotationController]),
          builder: (context, child) {
            final color1 = Color.lerp(gradientColors[0], gradientColors[1], _mainController.value)!;
            final color2 = Color.lerp(gradientColors[1], gradientColors[0], _mainController.value)!;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _mainController.value, -1.0),
                  end: Alignment(1.0 - _mainController.value, 1.0),
                  colors: [color1, color2],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.last.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.weather.outsideTemp.toStringAsFixed(1)}°',
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.weather.description.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Transform.translate(
                        offset: Offset(0, _floatingAnimation.value),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (iconCode == '01' || iconCode == '02')
                              RotationTransition(
                                turns: _rotationController,
                                child: CustomPaint(
                                  size: const Size(80, 80),
                                  painter: SunRaysPainter(),
                                ),
                              ),
                            Image.network(
                              'https://openweathermap.org/img/wn/${widget.weather.icon}@4x.png',
                              width: 75,
                              height: 75,
                              color: (iconCode == '01' || iconCode == '02') 
                                  ? Colors.orangeAccent 
                                  : null,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    (iconCode == '01' || iconCode == '02') 
                                        ? Icons.wb_sunny 
                                        : LucideIcons.cloudSun,
                                    size: 48, 
                                    color: (iconCode == '01' || iconCode == '02') 
                                        ? Colors.orangeAccent 
                                        : Colors.white,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.sun,
                                color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '${(widget.weather.solarPrediction * 100).toStringAsFixed(0)}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        if (widget.weather.lastUpdated.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              'Valable pour le : ${widget.weather.lastUpdated}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white38,
                    fontSize: 10,
                  ),
            ),
          ),
      ],
    );
  }
}

class SunRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.orangeAccent.withValues(alpha: 0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * math.pi / 180;
      final start = Offset(
        center.dx + math.cos(angle) * 20,
        center.dy + math.sin(angle) * 20,
      );
      final end = Offset(
        center.dx + math.cos(angle) * 35,
        center.dy + math.sin(angle) * 35,
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
