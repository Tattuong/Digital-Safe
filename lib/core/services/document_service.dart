import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/vault_document.dart';
import 'encryption_service.dart';
import 'storage_service.dart';

class DocumentService {
  static final DocumentService _instance = DocumentService._();
  static DocumentService get instance => _instance;
  DocumentService._();

  static const _docsKey = 'ds_vault_documents';
  static const _activityKey = 'ds_activity_logs';

  List<VaultDocument> _documents = [];
  List<ActivityLog> _activities = [];

  List<VaultDocument> get documents => List.unmodifiable(_documents);
  List<ActivityLog> get activities => List.unmodifiable(_activities);

  Future<void> load() async {
    final enc = EncryptionService.instance;
    final raw = await StorageService.instance.getString(_docsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decrypted = enc.isReady ? enc.decryptString(raw) : raw;
        final list = (jsonDecode(decrypted) as List).cast<Map<String, dynamic>>();
        _documents = list.map(VaultDocument.fromJson).toList();
      } catch (e) {
        debugPrint('Load docs error: $e');
        _documents = [];
      }
    }

    final actRaw = await StorageService.instance.getString(_activityKey);
    if (actRaw != null && actRaw.isNotEmpty) {
      try {
        final decrypted = enc.isReady ? enc.decryptString(actRaw) : actRaw;
        final list = (jsonDecode(decrypted) as List).cast<Map<String, dynamic>>();
        _activities = list.map(ActivityLog.fromJson).toList();
      } catch (e) {
        _activities = [];
      }
    }
  }

  Future<void> _persist() async {
    final enc = EncryptionService.instance;
    final docsJson = jsonEncode(_documents.map((d) => d.toJson()).toList());
    final actJson = jsonEncode(_activities.map((a) => a.toJson()).toList());
    await StorageService.instance.saveString(_docsKey, enc.isReady ? enc.encryptString(docsJson) : docsJson);
    await StorageService.instance.saveString(_activityKey, enc.isReady ? enc.encryptString(actJson) : actJson);
  }

  Future<VaultDocument> add(VaultDocument doc) async {
    _documents.insert(0, doc);
    await _log(ActivityType.added, doc);
    await _persist();
    return doc;
  }

  Future<VaultDocument> update(VaultDocument doc) async {
    final i = _documents.indexWhere((d) => d.id == doc.id);
    if (i >= 0) {
      _documents[i] = doc;
      await _log(ActivityType.edited, doc);
      await _persist();
    }
    return doc;
  }

  Future<void> delete(String id) async {
    final doc = _documents.firstWhere((d) => d.id == id);
    _documents.removeWhere((d) => d.id == id);
    await _log(ActivityType.deleted, doc);
    await _persist();
  }

  Future<void> toggleFavorite(String id) async {
    final i = _documents.indexWhere((d) => d.id == id);
    if (i < 0) return;
    final doc = _documents[i].copyWith(isFavorite: !_documents[i].isFavorite, updatedAt: DateTime.now());
    _documents[i] = doc;
    await _log(ActivityType.favorited, doc);
    await _persist();
  }

  Future<void> markViewed(VaultDocument doc) async {
    await _log(ActivityType.viewed, doc);
    await _persist();
  }

  List<VaultDocument> byCategory(String categoryId) =>
      _documents.where((d) => d.categoryId == categoryId).toList();

  List<VaultDocument> search(String query) {
    final q = query.toLowerCase();
    return _documents.where((d) {
      return d.title.toLowerCase().contains(q) ||
          d.notes.toLowerCase().contains(q) ||
          (d.holderName?.toLowerCase().contains(q) ?? false) ||
          (d.wifiSsid?.toLowerCase().contains(q) ?? false) ||
          (d.licenseProduct?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  List<VaultDocument> get favorites => _documents.where((d) => d.isFavorite).toList();

  List<VaultDocument> get recent => List<VaultDocument>.from(_documents)
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  int countByCategory(String categoryId) => _documents.where((d) => d.categoryId == categoryId).length;

  double storageUsedMb() {
    var bytes = 0;
    for (final d in _documents) {
      bytes += d.title.length + d.notes.length + (d.filePath?.length ?? 0);
    }
    return bytes / (1024 * 1024);
  }

  Future<void> _log(ActivityType type, VaultDocument doc) async {
    _activities.insert(
      0,
      ActivityLog(
        id: const Uuid().v4(),
        type: type,
        documentId: doc.id,
        documentTitle: doc.title,
        categoryId: doc.categoryId,
        timestamp: DateTime.now(),
      ),
    );
    if (_activities.length > 200) _activities = _activities.sublist(0, 200);
  }

  VaultDocument? findById(String id) {
    try {
      return _documents.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAll() async {
    for (final doc in _documents) {
      final path = doc.filePath;
      if (path == null) continue;
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (e) {
        debugPrint('Delete vault file error: $e');
      }
    }
    _documents = [];
    _activities = [];
    await StorageService.instance.remove(_docsKey);
    await StorageService.instance.remove(_activityKey);
    try {
      final base = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(base.path, 'vault_files'));
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (e) {
      debugPrint('Clear vault dir error: $e');
    }
  }
}
