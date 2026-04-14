import 'package:flutter/material.dart';
import '../services/pet_log_service.dart';

class DashboardScreen extends StatelessWidget {
  final PetLogService petLogService;

  const DashboardScreen({super.key, required this.petLogService});

  static const Color _sectionCard = Color(0xFFD3D3D3);

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required int count,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.black87),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Pet Activity Logs Section
        Container(
          decoration: BoxDecoration(
            color: _sectionCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SizedBox(
            height: 320,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                    icon: Icons.graphic_eq,
                    title: 'Pet Activity Logs',
                    count: petLogService.activityLogs.length,
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Colors.black54),
                  const SizedBox(height: 12),
                  Expanded(
                    child: petLogService.activityLogs.isEmpty
                        ? const Text(
                            'No activity logs yet.',
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          )
                        : ListView.builder(
                            primary: false,
                            itemCount: petLogService.activityLogs.length,
                            itemBuilder: (context, index) {
                              final log = petLogService.activityLogs[index];
                              return _buildActivityLog(
                                log.action,
                                log.getFormattedTime(),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Feeding History Section
        Container(
          decoration: BoxDecoration(
            color: _sectionCard,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 14,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SizedBox(
            height: 320,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(
                    icon: Icons.food_bank_outlined,
                    title: 'Feeding History',
                    count: petLogService.feedingLogs.length,
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: Colors.black54),
                  const SizedBox(height: 12),
                  Expanded(
                    child: petLogService.feedingLogs.isEmpty
                        ? const Text(
                            'No feeding logs yet.',
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          )
                        : ListView.builder(
                            primary: false,
                            itemCount: petLogService.feedingLogs.length,
                            itemBuilder: (context, index) {
                              final log = petLogService.feedingLogs[index];
                              return _buildFeedingLog(
                                log.action,
                                log.getFormattedTime(),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLog(String activity, String timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              activity,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timestamp,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingLog(String action, String timestamp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              action,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timestamp,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
