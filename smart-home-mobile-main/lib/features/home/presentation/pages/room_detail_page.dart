import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/house_state_provider.dart';

class RoomDetailPage extends ConsumerWidget {
  final String roomId;

  const RoomDetailPage({super.key, required this.roomId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final houseState = ref.watch(houseStateProvider);
    final api = ref.watch(apiServiceProvider);

    return houseState.when(
      data: (state) {
        final room = state.rooms[roomId];
        if (room == null) {
          return const Scaffold(body: Center(child: Text('Pièce introuvable')));
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Header Immersif avec image, nom et capteurs
              SliverAppBar(
                expandedHeight: 300.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.black,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Image de fond
                      Image.asset(
                        'assets/$roomId.webp',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[900]),
                      ),
                      // Overlay Dégradé
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black38,
                              Colors.transparent,
                              Colors.black
                            ],
                          ),
                        ),
                      ),
                      // Contenu du Header
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      const Shadow(
                                          color: Colors.black45, blurRadius: 10)
                                    ],
                                  ),
                            ),
                            const SizedBox(height: 16),
                            // Barre de Capteurs (Glassmorphism)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.1)),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildHeroStat(
                                      context,
                                      LucideIcons.thermometer,
                                      '${room.temperature}°C',
                                      'Temp.',
                                      Colors.orangeAccent,
                                    ),
                                    _buildHeroStat(
                                      context,
                                      LucideIcons.sun,
                                      '${room.luminosity.round()} lx',
                                      'Lux',
                                      Colors.yellowAccent,
                                    ),
                                    _buildHeroStat(
                                      context,
                                      LucideIcons.user,
                                      room.presence ? 'Oui' : 'Non',
                                      'Présence',
                                      room.presence
                                          ? Colors.greenAccent
                                          : Colors.white54,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenu de la page
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        // Contrôle Lumière
                        Text(
                          'Éclairage',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: room.lights
                                    ? Colors.yellow.withValues(alpha: 0.1)
                                    : Colors.white.withValues(alpha: 0.05),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.lightbulb,
                                color:
                                    room.lights ? Colors.yellow : Colors.grey,
                              ),
                            ),
                            title: Text('Lumière principale',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                            subtitle: Text(room.lights ? 'Allumée' : 'Éteinte',
                                style: Theme.of(context).textTheme.labelSmall),
                            trailing: Switch(
                              value: room.lights,
                              onChanged: (val) => api.toggleLight(roomId, val),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Section Climatisation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Climatisation',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: DropdownButton<String>(
                                value: room.climatisationMode,
                                underline: const SizedBox(),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.bold),
                                dropdownColor: const Color(0xFF0A0A0A),
                                iconEnabledColor: Colors.white70,
                                onChanged: (val) =>
                                    api.setClimatisationMode(roomId, val!),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'AUTO', child: Text('AUTO')),
                                  DropdownMenuItem(
                                      value: 'MANUAL', child: Text('MANUAL')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _ModeButton(
                                      icon: LucideIcons.power,
                                      label: 'OFF',
                                      isSelected: room.climatisation == 'OFF',
                                      onPressed: () =>
                                          api.setClimatisation(roomId, 'OFF'),
                                    ),
                                    _ModeButton(
                                      icon: LucideIcons.snowflake,
                                      label: 'COOL',
                                      isSelected: room.climatisation == 'COOL',
                                      onPressed: () =>
                                          api.setClimatisation(roomId, 'COOL'),
                                    ),
                                    _ModeButton(
                                      icon: LucideIcons.flame,
                                      label: 'HEAT',
                                      isSelected: room.climatisation == 'HEAT',
                                      onPressed: () =>
                                          api.setClimatisation(roomId, 'HEAT'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    const Icon(LucideIcons.thermometer,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text('Température cible',
                                        style: Theme.of(context).textTheme.labelSmall),
                                    const Spacer(),
                                    Text('${room.temperatureDeRegulation.toStringAsFixed(1)}°C',
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orangeAccent)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildControlButton(
                                      icon: LucideIcons.minus,
                                      onPressed: () => api.setTargetTemp(
                                        roomId,
                                        (room.temperatureDeRegulation - 0.5)
                                            .clamp(10, 35),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white10),
                                      ),
                                      child: Text(
                                        '${room.temperatureDeRegulation.toStringAsFixed(1)}°',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    _buildControlButton(
                                      icon: LucideIcons.plus,
                                      onPressed: () => api.setTargetTemp(
                                        roomId,
                                        (room.temperatureDeRegulation + 0.5)
                                            .clamp(10, 35),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100), // Espace en bas
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
      error: (e, s) => Scaffold(body: Center(child: Text('Erreur : $e'))),
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
    );
  }

  Widget _buildHeroStat(BuildContext context, IconData icon, String value,
      String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white70,
                fontSize: 10,
              ),
        ),
      ],
    );
  }

  Widget _buildControlButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.blueAccent.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              border: Border.all(
                color: isSelected ? Colors.blueAccent : Colors.white10,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.blueAccent : Colors.white54,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blueAccent : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
