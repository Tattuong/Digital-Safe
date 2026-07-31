import 'package:flutter/foundation.dart';

import '../core/constants/iap_constants.dart';
import '../core/services/auth_service.dart';
import '../core/services/document_service.dart';
import '../models/vault_document.dart';

class VaultProvider extends ChangeNotifier {
  final DocumentService _docs = DocumentService.instance;
  final AuthService _auth = AuthService.instance;

  bool _loaded = false;
  String _searchQuery = '';

  bool get isLoaded => _loaded;
  String get searchQuery => _searchQuery;
  String get userName => _auth.userName;
  List<VaultDocument> get documents => _docs.documents;
  List<VaultDocument> get favorites => _docs.favorites;
  List<VaultDocument> get recent => _docs.recent;
  List<ActivityLog> get activities => _docs.activities;

  List<VaultDocument> get filteredDocuments {
    if (_searchQuery.isEmpty) return documents;
    return _docs.search(_searchQuery);
  }

  int documentLimit(bool hasPremium) =>
      hasPremium ? IapConstants.premiumDocumentLimit : IapConstants.freeDocumentLimit;

  bool canAddDocument(bool hasPremium) => documents.length < documentLimit(hasPremium);

  double storageUsedMb() => _docs.storageUsedMb();
  double storageLimitGb(bool hasPremium) => hasPremium ? 50 : 5;

  int countByCategory(String categoryId) => _docs.countByCategory(categoryId);

  Future<void> init() async {
    if (_loaded) return;
    await _auth.loadUserName();
    await _docs.load();
    _loaded = true;
    notifyListeners();
  }

  Future<void> reload() async {
    await _docs.load();
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  Future<VaultDocument?> addDocument(VaultDocument doc) async {
    final result = await _docs.add(doc);
    notifyListeners();
    return result;
  }

  Future<void> updateDocument(VaultDocument doc) async {
    await _docs.update(doc);
    notifyListeners();
  }

  Future<void> deleteDocument(String id) async {
    await _docs.delete(id);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    await _docs.toggleFavorite(id);
    notifyListeners();
  }

  Future<void> markViewed(VaultDocument doc) async {
    await _docs.markViewed(doc);
    notifyListeners();
  }

  VaultDocument? findById(String id) => _docs.findById(id);

  Future<void> resetVault() async {
    await _docs.clearAll();
    await _auth.resetPin();
    _searchQuery = '';
    _loaded = false;
    notifyListeners();
  }
}
