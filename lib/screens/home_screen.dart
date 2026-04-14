import 'package:flutter/material.dart';
import '../services/pet_log_service.dart';

class HomeScreen extends StatelessWidget {
  final PetLogService petLogService;
  final String petName;

  const HomeScreen({
    super.key,
    required this.petLogService,
    required this.petName,
  });

  static const Color _cardBackground = Color(0xFFD3D3D3);
  static const Color _accentOlive = Color(0xFFA4B189);

  Future<void> _dispense(BuildContext context, String type) async {
    try {
      await petLogService.addFeedingLog(type: type);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(type == 'water' ? 'Water dispensed successfully.' : 'Food dispensed successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(type == 'water' ? 'Failed to dispense water.' : 'Failed to dispense food.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showDispenseSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Dispense item',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose what you want to dispense now.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _dispense(context, 'food');
                        },
                        icon: const Icon(Icons.restaurant),
                        label: const Text('Food'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _dispense(context, 'water');
                        },
                        icon: const Icon(Icons.water_drop_outlined),
                        label: const Text('Water'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required Widget child,
    Color borderColor = Colors.transparent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: borderColor == Colors.transparent ? 0 : 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedPetName = petName.trim().isEmpty ? 'Your pet' : petName;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 152,
                child: _buildInfoCard(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.pets, size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Pet Status',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$displayedPetName is Hungry!!',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 152,
                child: _buildInfoCard(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${petLogService.getBarkedCount()}',
                                style: const TextStyle(fontSize: 76, height: 0.95, fontWeight: FontWeight.w500),
                              ),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.graphic_eq, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                'Barking Count',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Center(
          child: InkWell(
            onTap: () => _showDispenseSheet(context),
            borderRadius: BorderRadius.circular(120),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 228,
                  height: 228,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _accentOlive.withValues(alpha: 0.35),
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFB4BF9C), Color(0xFF95A67A)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2A000000),
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pets,
                          color: Colors.white,
                          size: 30,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'FEED NOW',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.97),
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tap to dispense',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 132,
                child: _buildInfoCard(
                  child: Column(
                    children: [
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.restaurant, size: 22),
                              SizedBox(height: 8),
                              Text(
                                'Food level',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          petLogService.foodLevelText,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 132,
                child: _buildInfoCard(
                  child: Column(
                    children: [
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.water_drop_outlined, size: 22),
                              SizedBox(height: 8),
                              Text(
                                'Water level',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          petLogService.waterLevelText,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
