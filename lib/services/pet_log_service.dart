import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory PetLogEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
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

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return 'Today ${DateFormat('h:mm a').format(timestamp)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('h:mm a').format(timestamp)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }
}

class PetLogService extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final String _userId;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _activitySub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _feedingSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _statusSub;

  List<PetLogEntry> _activityLogs = [];
  List<PetLogEntry> _feedingLogs = [];
  double? _foodLevelPercent;
  double? _waterLevelPercent;

  PetLogService({
    required String userId,
    FirebaseFirestore? firestore,
  })  : _userId = userId,
        _firestore = firestore ?? FirebaseFirestore.instance {
    _listenToLogs();
    _listenToStatus();
  }

  CollectionReference<Map<String, dynamic>> get _activityCollection =>
      _firestore.collection('users').doc(_userId).collection('activityLogs');

  CollectionReference<Map<String, dynamic>> get _feedingCollection =>
      _firestore.collection('users').doc(_userId).collection('feedingLogs');

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_userId);

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

  void _listenToStatus() {
    _statusSub = _userDoc.snapshots().listen((snapshot) {
      final data = snapshot.data() ?? <String, dynamic>{};

      _foodLevelPercent = _readPercent(data, const [
        ['foodLevel'],
        ['food_level'],
        ['foodPercent'],
        ['food_percent'],
        ['levels', 'food'],
        ['sensorLevels', 'food'],
      ]);

      _waterLevelPercent = _readPercent(data, const [
        ['waterLevel'],
        ['water_level'],
        ['waterPercent'],
        ['water_percent'],
        ['levels', 'water'],
        ['sensorLevels', 'water'],
      ]);

      notifyListeners();
    });
  }

  double? _readPercent(Map<String, dynamic> source, List<List<String>> keyPaths) {
    for (final path in keyPaths) {
      final dynamic raw = _readAtPath(source, path);
      final value = _normalizePercent(raw);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  dynamic _readAtPath(Map<String, dynamic> source, List<String> path) {
    dynamic current = source;
    for (final key in path) {
      if (current is! Map<String, dynamic> || !current.containsKey(key)) {
        return null;
      }
      current = current[key];
    }
    return current;
  }

  double? _normalizePercent(dynamic raw) {
    if (raw == null) {
      return null;
    }

    num? value;
    if (raw is num) {
      value = raw;
    } else if (raw is String) {
      final cleaned = raw.replaceAll('%', '').trim();
      value = num.tryParse(cleaned);
    }

    if (value == null) {
      return null;
    }

    var percent = value.toDouble();
    if (percent > 0 && percent <= 1) {
      percent *= 100;
    }

    if (percent < 0) {
      return 0;
    }
    if (percent > 100) {
      return 100;
    }
    return percent;
  }

  List<PetLogEntry> get activityLogs => _activityLogs;
  List<PetLogEntry> get feedingLogs => _feedingLogs;
  double? get foodLevelPercent => _foodLevelPercent;
  double? get waterLevelPercent => _waterLevelPercent;
  String get foodLevelText =>
      _foodLevelPercent == null ? '--' : '${_foodLevelPercent!.round()}%';
  String get waterLevelText =>
      _waterLevelPercent == null ? '--' : '${_waterLevelPercent!.round()}%';
  DateTime? get latestFeedingTimestamp =>
      _feedingLogs.isEmpty ? null : _feedingLogs.first.timestamp;

  int getBarkedCount() {
    return _activityLogs
        .where((log) => log.action.toLowerCase().contains('barked'))
        .length;
  }

  Future<void> addFeedingLog({String type = 'food'}) async {
    await _feedingCollection.add({
      'action': type == 'water' ? 'Water dispensed' : 'Food dispensed',
      'timestamp': FieldValue.serverTimestamp(),
      'source': 'feed_now',
      'type': type,
    });
  }

  Future<void> addActivityLog(String activity) async {
    await _activityCollection.add({
      'action': activity,
      'timestamp': FieldValue.serverTimestamp(),
      'source': 'sensor',
    });
  }

  @override
  void dispose() {
    _activitySub?.cancel();
    _feedingSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }
}
