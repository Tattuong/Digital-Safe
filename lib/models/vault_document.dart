import 'package:flutter/material.dart';

enum DocumentCategory {
  cccd('cccd', 'catCccd', Icons.badge_outlined, Color(0xFF22C55E)),
  passport('passport', 'catPassport', Icons.flight_outlined, Color(0xFFF97316)),
  gplx('gplx', 'catGplx', Icons.directions_car_outlined, Color(0xFFEAB308)),
  degree('degree', 'catDegree', Icons.school_outlined, Color(0xFFEF4444)),
  certificate('certificate', 'catCertificate', Icons.workspace_premium_outlined, Color(0xFFEC4899)),
  insurance('insurance', 'catInsurance', Icons.health_and_safety_outlined, Color(0xFFF97316)),
  wifi('wifi', 'catWifi', Icons.wifi_outlined, Color(0xFF3B82F6)),
  licenseKey('license_key', 'catLicenseKey', Icons.vpn_key_outlined, Color(0xFFFBBF24));

  final String id;
  final String nameKey;
  final IconData icon;
  final Color color;

  const DocumentCategory(this.id, this.nameKey, this.icon, this.color);

  bool get isWifi => this == DocumentCategory.wifi;
  bool get isLicenseKey => this == DocumentCategory.licenseKey;

  static DocumentCategory? fromId(String? id) {
    if (id == null) return null;
    for (final c in DocumentCategory.values) {
      if (c.id == id) return c;
    }
    return null;
  }
}

enum ActivityType { added, viewed, edited, deleted, favorited }

class ActivityLog {
  final String id;
  final ActivityType type;
  final String documentId;
  final String documentTitle;
  final String categoryId;
  final DateTime timestamp;

  const ActivityLog({
    required this.id,
    required this.type,
    required this.documentId,
    required this.documentTitle,
    required this.categoryId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'documentId': documentId,
        'documentTitle': documentTitle,
        'categoryId': categoryId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
        id: json['id'] as String,
        type: ActivityType.values.firstWhere((e) => e.name == json['type']),
        documentId: json['documentId'] as String,
        documentTitle: json['documentTitle'] as String,
        categoryId: json['categoryId'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class VaultDocument {
  final String id;
  final String title;
  final String categoryId;
  final String notes;
  final String? filePath;
  final String? fileName;
  final String? wifiSsid;
  final String? wifiPassword;
  final String? wifiSecurity;
  final String? licenseProduct;
  final String? licenseKey;
  final String? licenseProvider;
  final String? expiryDate;
  final String? holderName;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VaultDocument({
    required this.id,
    required this.title,
    required this.categoryId,
    this.notes = '',
    this.filePath,
    this.fileName,
    this.wifiSsid,
    this.wifiPassword,
    this.wifiSecurity,
    this.licenseProduct,
    this.licenseKey,
    this.licenseProvider,
    this.expiryDate,
    this.holderName,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  DocumentCategory? get category => DocumentCategory.fromId(categoryId);

  bool get isWifi => categoryId == DocumentCategory.wifi.id;
  bool get isLicenseKey => categoryId == DocumentCategory.licenseKey.id;

  VaultDocument copyWith({
    String? title,
    String? categoryId,
    String? notes,
    String? filePath,
    String? fileName,
    String? wifiSsid,
    String? wifiPassword,
    String? wifiSecurity,
    String? licenseProduct,
    String? licenseKey,
    String? licenseProvider,
    String? expiryDate,
    String? holderName,
    bool? isFavorite,
    DateTime? updatedAt,
  }) =>
      VaultDocument(
        id: id,
        title: title ?? this.title,
        categoryId: categoryId ?? this.categoryId,
        notes: notes ?? this.notes,
        filePath: filePath ?? this.filePath,
        fileName: fileName ?? this.fileName,
        wifiSsid: wifiSsid ?? this.wifiSsid,
        wifiPassword: wifiPassword ?? this.wifiPassword,
        wifiSecurity: wifiSecurity ?? this.wifiSecurity,
        licenseProduct: licenseProduct ?? this.licenseProduct,
        licenseKey: licenseKey ?? this.licenseKey,
        licenseProvider: licenseProvider ?? this.licenseProvider,
        expiryDate: expiryDate ?? this.expiryDate,
        holderName: holderName ?? this.holderName,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'categoryId': categoryId,
        'notes': notes,
        'filePath': filePath,
        'fileName': fileName,
        'wifiSsid': wifiSsid,
        'wifiPassword': wifiPassword,
        'wifiSecurity': wifiSecurity,
        'licenseProduct': licenseProduct,
        'licenseKey': licenseKey,
        'licenseProvider': licenseProvider,
        'expiryDate': expiryDate,
        'holderName': holderName,
        'isFavorite': isFavorite,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory VaultDocument.fromJson(Map<String, dynamic> json) => VaultDocument(
        id: json['id'] as String,
        title: json['title'] as String,
        categoryId: json['categoryId'] as String,
        notes: json['notes'] as String? ?? '',
        filePath: json['filePath'] as String?,
        fileName: json['fileName'] as String?,
        wifiSsid: json['wifiSsid'] as String?,
        wifiPassword: json['wifiPassword'] as String?,
        wifiSecurity: json['wifiSecurity'] as String?,
        licenseProduct: json['licenseProduct'] as String?,
        licenseKey: json['licenseKey'] as String?,
        licenseProvider: json['licenseProvider'] as String?,
        expiryDate: json['expiryDate'] as String?,
        holderName: json['holderName'] as String?,
        isFavorite: json['isFavorite'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
}
