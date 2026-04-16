import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/house_state_provider.dart';
import '../widgets/weather_section.dart';
import '../widgets/energy_section.dart';
import '../widgets/room_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final houseState = ref.watch(houseStateProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: houseState.when(
        data: (state) => RefreshIndicator(
          onRefresh: () async => ref.refresh(houseStateProvider),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            children: [
              const SizedBox(height: 60), // Espace pour la barre de statut

              // Header Premium
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour Franck,',
                        style:
                            Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                      ),
                      Text(
                        'Bienvenue dans votre maison intelligente',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.blue),
                      onPressed: () => ref.refresh(houseStateProvider),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Météo (Données réelles API)
              WeatherSection(weather: state.weather),
              const SizedBox(height: 24),

              // Énergie (Batterie & Source)
              EnergySection(energy: state.energy),
              const SizedBox(height: 32),

              // Titre Section Pièces
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mes Pièces',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${state.rooms.length} Actives',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grille des pièces
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                itemCount: state.rooms.length,
                itemBuilder: (context, index) {
                  final roomId = state.rooms.keys.elementAt(index);
                  final room = state.rooms[roomId]!;
                  return RoomCard(roomId: roomId, room: room);
                },
              ),

              const SizedBox(height: 32),

              // Note d'information stylisée
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Contrôlez chaque pièce individuellement en cliquant sur sa carte.',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wifi_off, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text('Impossible de se connecter au serveur',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(err.toString(),
              style: const TextStyle(color: Colors.white24, fontSize: 10)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(houseStateProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ])),
      ),
    );
  }
}
