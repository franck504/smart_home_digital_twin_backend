import 'package:flutter/material.dart';
import '../../data/models/house_state_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class WeatherSection extends StatelessWidget {
  final Weather weather;

  const WeatherSection({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    // Sélection de la couleur du dégradé selon le code icône (plus fiable que la description)
    final List<Color> gradientColors;
    final String iconCode = weather.icon.substring(0, 2); // Ex: '01d' -> '01'
    
    switch (iconCode) {
      case '01': // Ensoleillé
        gradientColors = [const Color(0xFFFACC15), const Color(0xFFEAB308)];
        break;
      case '02':
      case '03':
      case '04': // Nuageux
        gradientColors = [const Color(0xFF64748B), const Color(0xFF475569)];
        break;
      case '09':
      case '10': // Pluie
        gradientColors = [const Color(0xFF3B82F6), const Color(0xFF1E40AF)];
        break;
      case '11': // Orage
        gradientColors = [const Color(0xFF6B21A8), const Color(0xFF4C1D95)];
        break;
      case '13': // Neige
        gradientColors = [const Color(0xFF7DD3FC), const Color(0xFF0EA5E9)];
        break;
      default: // Par défaut
        gradientColors = [const Color(0xFF334155), const Color(0xFF1E293B)];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Météo Locale',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
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
                      '${weather.outsideTemp.toStringAsFixed(1)}°',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.description.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                  Image.network(
                    'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                    width: 70,
                    height: 70,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(LucideIcons.cloudSun, size: 48, color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.sun, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${(weather.solarPrediction * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
        ),
      ],
    );
  }
}
