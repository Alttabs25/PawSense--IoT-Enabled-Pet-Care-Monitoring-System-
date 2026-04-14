import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart'; // REQUIRED FOR ESP32 DATA
import 'package:intl/intl.dart';
import 'dart:async';

class PetLogEntry {
  final String id;
  final String action;
  final DateTime timestamp;

  PetLogEntry({
    required this.id,
    required this.action,
    required this.timestamp,
  });

  factory PetLogEntry.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final ts = data['timestamp'];

    return PetLogEntry(
      id: doc.id,
      action: (data['action'] as String?) ?? 'Unknown action',
      timestamp: ts is Timestamp ? ts.toDate() : DateTime.now(),
    );
  }

  String getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24)
      return 'Today ${DateFormat('h:mm a').format(timestamp)}';
    if (difference.inDays == 1)
      return 'Yesterday ${DateFormat('h:mm a').format(timestamp)}';
    return DateFormat('MMM d, h:mm a').format(timestamp);
  }
}

class PetLogService extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance; // ADDED THIS
  final String _userId;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activitySub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _feedingSub;
  StreamSubscription<DatabaseEvent>? _realtimeSub; // CHANGED THIS

  List<PetLogEntry> _activityLogs = [];
  List<PetLogEntry> _feedingLogs = [];
  double? _foodLevelPercent;
  double? _waterLevelPercent;

  PetLogService({required String userId, FirebaseFirestore? firestore})
    : _userId = userId,
      _firestore = firestore ?? FirebaseFirestore.instance {
    _listenToLogs();
    _listenToStatus(); // This now points to Realtime Database
  }

  // --- Firestore Collections (For Logs) ---
  CollectionReference<Map<String, dynamic>> get _activityCollection =>
      _firestore.collection('users').doc(_userId).collection('activityLogs');

  CollectionReference<Map<String, dynamic>> get _feedingCollection =>
      _firestore.collection('users').doc(_userId).collection('feedingLogs');

  // --- Realtime Database Logic (For Live Sensors) ---
  void _listenToStatus() {
    // Listens to the 'status' path where ESP32 sends food/water
    _realtimeSub = _realtimeDb.ref('status').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        // Match the keys exactly as written in the ESP32 code
        _foodLevelPercent = (data['food'] as num?)?.toDouble();
        _waterLevelPercent = (data['water'] as num?)?.toDouble();

        notifyListeners(); // Updates the UI immediately
      }
    });
  }

  // --- Manual Feed Trigger ---
  Future<void> triggerManualFeed() async {
    try {
      // 1. Tell ESP32 to feed via Realtime Database
      await _realtimeDb.ref('control').update({'manual_feed': true});

      // 2. Save a log of this action in Firestore
      await addFeedingLog(type: 'food');

      print("Manual feed triggered successfully");
    } catch (e) {
      print("Error triggering feed: $e");
    }
  }

  // --- Existing Log Logic ---
  void _listenToLogs() {
    _activitySub = _activityCollection
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) {
          _activityLogs = snapshot.docs.map(PetLogEntry.fromFirestore).toList();
          notifyListeners();
        });

    _feedingSub = _feedingCollection
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) {
          _feedingLogs = snapshot.docs.map(PetLogEntry.fromFirestore).toList();
          notifyListeners();
        });
  }

  // Getters
  List<PetLogEntry> get activityLogs => _activityLogs;
  List<PetLogEntry> get feedingLogs => _feedingLogs;
  double? get foodLevelPercent => _foodLevelPercent;
  double? get waterLevelPercent => _waterLevelPercent;

  String get foodLevelText =>
      _foodLevelPercent == null ? '--' : '${_foodLevelPercent!.round()}%';
  String get waterLevelText =>
      _waterLevelPercent == null ? '--' : '${_waterLevelPercent!.round()}%';

  Future<void> addFeedingLog({String type = 'food'}) async {
    await _feedingCollection.add({
      'action': type == 'water' ? 'Water dispensed' : 'Food dispensed',
      'timestamp': FieldValue.serverTimestamp(),
      'source': 'manual_app',
      'type': type,
    });
  }

  @override
  void dispose() {
    _activitySub?.cancel();
    _feedingSub?.cancel();
    _realtimeSub?.cancel(); // Cancel realtime sub
    super.dispose();
  }
}
