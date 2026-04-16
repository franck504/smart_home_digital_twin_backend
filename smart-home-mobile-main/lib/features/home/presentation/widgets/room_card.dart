import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/house_state_model.dart';
import '../pages/room_detail_page.dart';

class RoomCard extends StatelessWidget {
  final String roomId;
  final RoomState room;

  const RoomCard({super.key, required this.roomId, required this.room});

  @override
  Widget build(BuildContext context) {
    return Card(
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
            // 1. Fond Image
            Positioned.fill(
              child: Image.asset(
                'assets/$roomId.webp',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            // 2. Overlay dégradé (Premium)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            // 3. Contenu texte blanc
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 1. Infos techniques en haut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        room.climatisation == 'OFF'
                            ? 'OFF'
                            : 'Clim: ${room.climatisation}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: room.climatisation == 'OFF'
                                  ? Colors.white60
                                  : Colors.blue[300],
                            ),
                      ),
                      if (room.lights)
                        const Icon(LucideIcons.lightbulb,
                            color: Colors.yellow, size: 16),
                    ],
                  ),
                  const Spacer(), // Pousse le reste vers le bas
                  // 2. Statistiques
                  Row(
                    children: [
                      _buildMiniStat(context, LucideIcons.thermometer,
                          '${room.temperature}°'),
                      const SizedBox(width: 8),
                      _buildMiniStat(context, LucideIcons.user,
                          room.presence ? 'Près.' : 'Vide'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 3. NOM DE LA SALLE EN DERNIER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          room.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 12, color: Colors.white38),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
            shadows: [const Shadow(color: Colors.black45, blurRadius: 2)],
          ),
        ),
      ],
    );
  }
}
