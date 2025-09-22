import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TotalProgressCard extends StatelessWidget {
  final double totalPercentage;
  final bool isMaxReached;
  final double totalWeight; // in kg (converted from grams)
  final double packetSize; // in kg

  const TotalProgressCard({
    super.key,
    required this.totalPercentage,
    required this.isMaxReached,
    required this.totalWeight,
    required this.packetSize,
  });

  @override
  Widget build(BuildContext context) {
    final actualFilledWeight = (totalPercentage * packetSize).toStringAsFixed(
      1,
    );
    final totalPacketSize = packetSize.toInt();

    return Center(
      child: CircularPercentIndicator(
        radius: 100.0,
        lineWidth: 20.0,
        percent: totalPercentage.clamp(0.0, 1.0),
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$actualFilledWeight kg',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'of $totalPacketSize kg',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        circularStrokeCap: CircularStrokeCap.round,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        progressColor: Theme.of(context).colorScheme.primary,
        animation: true,
        animationDuration: 800,
      ),
    );
  }
}
