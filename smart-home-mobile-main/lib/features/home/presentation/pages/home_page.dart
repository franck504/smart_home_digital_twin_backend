import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/house_state_provider.dart';
import '../widgets/sensor_card.dart';
import '../widgets/energy_section.dart';
import '../widgets/control_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final houseStateAsync = ref.watch(houseStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Home Jumeau'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            onPressed: () => ref.refresh(houseStateProvider),
          ),
        ],
      ),
      body: houseStateAsync.when(
        data: (state) => RefreshIndicator(
          onRefresh: () async => ref.refresh(houseStateProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Environnement',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  SensorCard(
                    title: 'Température',
                    value: '${state.sensors.temperature.toStringAsFixed(1)}°C',
                    icon: LucideIcons.thermometer,
                    color: Colors.orange,
                  ),
                  SensorCard(
                    title: 'Luminosité',
                    value: '${state.sensors.luminosity.toStringAsFixed(0)} Lx',
                    icon: LucideIcons.sun,
                    color: Colors.yellow,
                  ),
                  SensorCard(
                    title: 'Salon',
                    value: state.sensors.presenceSalon ? 'Présence' : 'Vide',
                    icon: LucideIcons.user,
                    color: state.sensors.presenceSalon
                        ? Colors.green
                        : Colors.grey,
                  ),
                  SensorCard(
                    title: 'Cuisine',
                    value: state.sensors.presenceCuisine ? 'Présence' : 'Vide',
                    icon: LucideIcons.user,
                    color: state.sensors.presenceCuisine
                        ? Colors.green
                        : Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              EnergySection(energy: state.energy),
              const SizedBox(height: 24),
              ControlSection(controls: state.controls),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertTriangle,
                  size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur de connexion : $err'),
              ElevatedButton(
                onPressed: () => ref.refresh(houseStateProvider),
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
