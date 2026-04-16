import 'package:flutter/material.dart';
import '../../data/models/house_state_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EnergySection extends StatelessWidget {
  final Energy energy;

  const EnergySection({super.key, required this.energy});

  @override
  Widget build(BuildContext context) {
    final bool isLowBattery = energy.batteryLevel <= 20;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestion Énergétique',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge de Source
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: energy.source == 'solar'
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          energy.source == 'solar' ? LucideIcons.sun : LucideIcons.zap,
                          size: 16,
                          color: energy.source == 'solar' ? Colors.greenAccent : Colors.blueAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          energy.source.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: energy.source == 'solar' ? Colors.greenAccent : Colors.blueAccent,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Pourcentage Batterie
                  Row(
                    children: [
                      Icon(
                        isLowBattery ? LucideIcons.batteryLow : LucideIcons.batteryCharging,
                        color: isLowBattery ? Colors.redAccent : Colors.greenAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${energy.batteryLevel.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Indicateur Batterie Style 'Liquid'
              Stack(
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: 14,
                    width: (MediaQuery.of(context).size.width - 80) * (energy.batteryLevel / 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLowBattery 
                          ? [Colors.redAccent, Colors.orangeAccent]
                          : [Colors.greenAccent, Colors.tealAccent],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: (isLowBattery ? Colors.redAccent : Colors.greenAccent).withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
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
