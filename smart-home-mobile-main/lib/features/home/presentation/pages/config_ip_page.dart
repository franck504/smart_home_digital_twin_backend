import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/ip_provider.dart';

class ConfigIpPage extends ConsumerStatefulWidget {
  const ConfigIpPage({super.key});

  @override
  ConsumerState<ConfigIpPage> createState() => _ConfigIpPageState();
}

class _ConfigIpPageState extends ConsumerState<ConfigIpPage> {
  final _ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ipController.text = ref.read(ipProvider);
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _saveIp() async {
    final newIp = _ipController.text.trim();
    if (newIp.isNotEmpty) {
      await ref.read(ipProvider.notifier).updateIp(newIp);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion en cours...')),
        );
        // La mise à jour de ipProvider va automatiquement reconstruire les websockets
        // On retourne à la page d'accueil si elle est gérée dynamiquement par Riverpod
        // ou la HomePage gérera la reconnexion automagiquement.
        Navigator.of(context).pop();
      }
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(LucideIcons.wifiOff, size: 60, color: Colors.white54),
            const SizedBox(height: 24),
            Text(
              'Connexion Échouée',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Impossible de se connecter au Jumeau Numérique. Veuillez vérifier l\'adresse IP de votre serveur local.',
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveIp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Se Connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
