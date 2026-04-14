import 'package:flutter/material.dart';

class FeedControlButtons extends StatelessWidget {
  const FeedControlButtons({super.key});

  Future<void> sendFeedCommand(String type) async {
    // TODO: Replace with actual IoT API/MQTT publish
    debugPrint("Sending $type dispense command...");
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => sendFeedCommand("food"),
          icon: const Icon(Icons.pets),
          label: const Text("Feed Food"),
        ),
        ElevatedButton.icon(
          onPressed: () => sendFeedCommand("water"),
          icon: const Icon(Icons.water_drop),
          label: const Text("Dispense Water"),
        ),
      ],
    );
  }
}
