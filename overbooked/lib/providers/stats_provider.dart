import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/reading_stats.dart';
import '../services/firestore_service.dart';

/// Manages reading statistics streamed from Firestore.
/// Stats are written by the Cloud Function; this provider only reads them.
class StatsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  ReadingStats _stats = ReadingStats.empty();
  bool _isLoading = true;
  StreamSubscription<ReadingStats>? _statsSubscription;

  // ── Getters ────────────────────────────────────────────────────────────────

  ReadingStats get stats => _stats;
  bool get isLoading => _isLoading;

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Starts listening to the user's stats document in Firestore.
  /// Call once after the user's session is established.
  void init(String userId) {
    _statsSubscription?.cancel();
    _isLoading = true;

    _statsSubscription = _firestoreService.statsStream(userId).listen(
      (stats) {
        _stats = stats;
        _isLoading = false;
        notifyListeners();
      },
      onError: (_) {
        _stats = ReadingStats.empty();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _statsSubscription?.cancel();
    super.dispose();
  }
}
