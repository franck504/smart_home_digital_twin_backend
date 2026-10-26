import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/models/house_state_model.dart';
import '../pages/room_detail_page.dart';
import 'room_image_background.dart';

class RoomCard extends StatelessWidget {
  final String roomId;
  final RoomState room;

  const RoomCard({super.key, required this.roomId, required this.room});

  List<BoxShadow> _buildDynamicShadows() {
    final shadows = <BoxShadow>[];

    // Halo d'éclairage ambré si les lumières sont allumées
    if (room.lights) {
      shadows.add(
        BoxShadow(
          color: const Color(0xFFFFB300).withValues(alpha: 0.28),
          blurRadius: 18,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      );
    }

    // Halo givré cyan si la climatisation est en marche
    if (room.climatisation != 'OFF') {
      shadows.add(
        BoxShadow(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.22),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 3),
        ),
      );
    }

    // Ombre de profondeur naturelle discrète
    if (shadows.isEmpty) {
      shadows.add(
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      );
    }

    return shadows;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _buildDynamicShadows(),
        border: Border.all(
          color: room.lights
              ? const Color(0xFFFFD54F).withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.08),
          width: room.lights ? 1.2 : 0.8,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RoomDetailPage(roomId: roomId),
            ),
          ),
          child: Stack(
            children: [
              // 1. Fond Image avec dégradé radial d'ambiance
              Positioned.fill(
                child: RoomImageBackground(
                  roomId: roomId,
                  isLightOn: room.lights,
                ),
              ),

              // 2. Overlay dégradé cinématographique
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.35, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Contenu
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Ligne 1 : Statuts Climatisation & Éclairage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: room.climatisation == 'OFF'
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.blue.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: room.climatisation == 'OFF'
                                  ? Colors.transparent
                                  : Colors.cyanAccent.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            room.climatisation == 'OFF'
                                ? 'Clim OFF'
                                : 'Clim ${room.climatisation}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  color: room.climatisation == 'OFF'
                                      ? Colors.white60
                                      : Colors.cyanAccent,
                                ),
                          ),
                        ),
                        if (room.lights)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFD54F)
                                  .withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD54F)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              LucideIcons.lightbulb,
                              color: Color(0xFFFFD54F),
                              size: 13,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),

                    // Ligne 2 : Statistiques en direct (Température + Humidité + Présence)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildMiniStat(
                          context,
                          LucideIcons.thermometer,
                          '${room.temperature}°',
                        ),
                        _buildMiniStat(
                          context,
                          LucideIcons.droplet,
                          '${room.humidity.round()}%',
                        ),
                        _buildMiniStat(
                          context,
                          LucideIcons.user,
                          room.presence ? 'Près.' : 'Vide',
                          color: room.presence
                              ? Colors.greenAccent
                              : Colors.white70,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Ligne 3 : Nom de la pièce
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            room.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.2,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 11,
                          color: Colors.white38,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, IconData icon, String text,
      {Color color = Colors.white70}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontSize: 11,
            shadows: [const Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        ),
      ],
    );
  }
}
