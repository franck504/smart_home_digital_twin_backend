import 'package:flutter/material.dart';
import '../../data/models/house_state_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EnergySection extends StatelessWidget {
  final Energy energy;

  const EnergySection({super.key, required this.energy});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gestion Énergétique',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          energy.source == 'solar'
                              ? LucideIcons.sun
                              : LucideIcons.zap,
                          color: energy.source == 'solar'
                              ? Colors.orange
                              : Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Source : ${energy.source.toUpperCase()}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    Text(
                      '${energy.batteryLevel.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: energy.batteryLevel / 100,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    energy.batteryLevel > 20 ? Colors.green : Colors.red,
                  ),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
