import 'package:flutter/material.dart';

class PetStatusCard extends StatelessWidget {
  final double soundLevel;
  final bool isBarking;
  final String lastFed;

  const PetStatusCard({
    super.key,
    required this.soundLevel,
    required this.isBarking,
    required this.lastFed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sound Level: ${soundLevel.toStringAsFixed(0)} dB"),
            Text("Status: ${isBarking ? "Excessive Barking Detected" : "Calm"}",
                style: TextStyle(
                  color: isBarking ? Colors.redAccent : Colors.green,
                )),
            Text("Last Fed: $lastFed"),
          ],
        ),
      ),
    );
  }
}
