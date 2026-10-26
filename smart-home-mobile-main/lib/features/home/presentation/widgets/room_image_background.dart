import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RoomVisualTheme {
  final IconData icon;
  final List<Color> gradientColors;
  final Color lightColor;

  const RoomVisualTheme({
    required this.icon,
    required this.gradientColors,
    this.lightColor = const Color(0xFFFFD54F),
  });
}

class RoomImageBackground extends StatelessWidget {
  final String roomId;
  final bool isHeader;
  final bool isLightOn;

  const RoomImageBackground({
    super.key,
    required this.roomId,
    this.isHeader = false,
    this.isLightOn = false,
  });

  static RoomVisualTheme getThemeForRoom(String roomId) {
    switch (roomId.toLowerCase()) {
      case 'chambre':
        return const RoomVisualTheme(
          icon: LucideIcons.bedDouble,
          gradientColors: [Color(0xFF2E1A47), Color(0xFF140D26)],
          lightColor: Color(0xFFFFE082),
        );
      case 'douche':
      case 'salle_de_bain':
        return const RoomVisualTheme(
          icon: LucideIcons.bath,
          gradientColors: [Color(0xFF0F3B4C), Color(0xFF081E29)],
          lightColor: Color(0xFF80DEEA),
        );
      case 'cuisine':
        return const RoomVisualTheme(
          icon: LucideIcons.utensils,
          gradientColors: [Color(0xFF4A2B11), Color(0xFF1E1005)],
          lightColor: Color(0xFFFFB74D),
        );
      case 'salon':
      default:
        return const RoomVisualTheme(
          icon: LucideIcons.armchair,
          gradientColors: [Color(0xFF1E2D4A), Color(0xFF0C1322)],
          lightColor: Color(0xFFFFD54F),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = getThemeForRoom(roomId);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Image ou Fond dégradé
        Image.asset(
          'assets/$roomId.webp',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: theme.gradientColors,
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Motif de fond en filigrane
                  Positioned(
                    right: isHeader ? 20 : -10,
                    bottom: isHeader ? 40 : -10,
                    child: Opacity(
                      opacity: 0.12,
                      child: Icon(
                        theme.icon,
                        size: isHeader ? 160 : 96,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Cercles lumineux diffus
                  Positioned(
                    top: -20,
                    left: -20,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            theme.gradientColors.first.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Halo d'éclairage ambiant dynamique si la lumière est allumée
        AnimatedOpacity(
          opacity: isLightOn ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.7),
                radius: isHeader ? 1.3 : 1.0,
                colors: [
                  theme.lightColor.withValues(alpha: 0.28),
                  theme.lightColor.withValues(alpha: 0.10),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
