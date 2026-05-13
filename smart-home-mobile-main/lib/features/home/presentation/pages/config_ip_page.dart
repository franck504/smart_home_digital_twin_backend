import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/ip_provider.dart';
import '../providers/house_state_provider.dart';

class ConfigIpPage extends ConsumerStatefulWidget {
  const ConfigIpPage({super.key});

  @override
  ConsumerState<ConfigIpPage> createState() => _ConfigIpPageState();
}

class _ConfigIpPageState extends ConsumerState<ConfigIpPage> {
  final _ipController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ipController.text = ref.read(ipProvider);
    
    // Initialiser la ville avec la valeur actuelle si disponible
    final state = ref.read(houseStateProvider);
    state.whenData((house) {
      _cityController.text = house.weather.location;
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _saveConfig() async {
    final newIp = _ipController.text.trim();
    final newCity = _cityController.text.trim();
    
    if (newIp.isNotEmpty) {
      await ref.read(ipProvider.notifier).updateIp(newIp);
    }
    
    if (newCity.isNotEmpty) {
      try {
        await ref.read(apiServiceProvider).setWeatherLocation(newCity);
      } catch (e) {
        debugPrint('Error setting city: $e');
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurations enregistrées')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réseau'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.wifiOff, size: 60, color: Colors.white54),
              const SizedBox(height: 24),
              Text(
                'Paramètres Système',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Configurez l\'adresse IP du serveur et la localisation par défaut de la météo.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              Text(
                'ADRESSE IP DU SERVEUR',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _ipController,
                decoration: InputDecoration(
                  hintText: 'Ex: 192.168.1.53',
                  prefixIcon: const Icon(LucideIcons.server),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Text(
                'LOCALISATION MÉTÉO',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'Ex: Fianarantsoa, MG',
                  prefixIcon: const Icon(LucideIcons.mapPin),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              
              // --- NOUVEAUTÉ : AUTO LIGHT OFF ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  title: const Text('Auto-extinction', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Éteint les lampes si aucune présence n\'est détectée (Mode Solaire)'),
                  secondary: const Icon(LucideIcons.lamp),
                  value: ref.watch(houseStateProvider).maybeWhen(
                    data: (state) => state.config.autoLightOff,
                    orElse: () => true,
                  ),
                  onChanged: (val) async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await ref.read(apiServiceProvider).setAutoLightOff(val);
                      ref.invalidate(houseStateProvider);
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Erreur : $e')),
                      );
                    }
                  },
                  activeThumbColor: Colors.blueAccent,
                ),
              ),
              
              // --- NOUVEAUTÉ : AUTO CLIM OFF ---
              Container(
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  title: const Text('Auto-extinction Clim', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Éteint la clim si aucune présence n\'est détectée'),
                  secondary: const Icon(LucideIcons.thermometerSnowflake),
                  value: ref.watch(houseStateProvider).maybeWhen(
                    data: (state) => state.config.autoClimOff,
                    orElse: () => true,
                  ),
                  onChanged: (val) async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await ref.read(apiServiceProvider).setAutoClimOff(val);
                      ref.invalidate(houseStateProvider);
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Erreur : $e')),
                      );
                    }
                  },
                  activeThumbColor: Colors.blueAccent,
                ),
              ),

              const SizedBox(height: 32),
              Text(
                'SEUIL DE LUMINOSITÉ (${ref.watch(houseStateProvider).maybeWhen(data: (s) => s.config.luxThreshold.round().toString(), orElse: () => '200')} LUX)',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: 8),
              // --- NOUVEAUTÉ : LUX THRESHOLD SLIDER ---
              ref.watch(houseStateProvider).maybeWhen(
                data: (state) => Slider(
                  value: state.config.luxThreshold,
                  min: 0,
                  max: 1000,
                  divisions: 20,
                  label: '${state.config.luxThreshold.round()} Lux',
                  onChanged: (val) async {
                    try {
                      await ref.read(apiServiceProvider).setLuxThreshold(val);
                      ref.invalidate(houseStateProvider);
                    } catch (e) {
                       debugPrint('Error: $e');
                    }
                  },
                  activeColor: Colors.blueAccent,
                ),
                orElse: () => const SizedBox(),
              ),

              const SizedBox(height: 40), // Espacement au lieu du Spacer
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveConfig,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Enregistrer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
