import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/encryption_service.dart';
import '../../models/vault_document.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/app_ui.dart';
import 'add_document_screen.dart';

class DocumentDetailScreen extends StatefulWidget {
  final String documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  @override
  State<DocumentDetailScreen> createState() => _DocumentDetailScreenState();
}

class _DocumentDetailScreenState extends State<DocumentDetailScreen> {
  bool _showPassword = false;
  bool _showKey = false;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final doc = context.read<VaultProvider>().findById(widget.documentId);
    if (doc == null) return;
    await context.read<VaultProvider>().markViewed(doc);
    if (doc.filePath != null && File(doc.filePath!).existsSync()) {
      final bytes = await EncryptionService.instance.decryptFile(doc.filePath!);
      if (mounted) setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _delete(VaultDocument doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(context, 'deleteConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(context, 'cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(context, 'delete'))),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<VaultProvider>().deleteDocument(doc.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _share(VaultDocument doc) async {
    final buffer = StringBuffer('${doc.title}\n');
    if (doc.holderName != null) buffer.writeln('${AppStrings.t(context, 'name')}: ${doc.holderName}');
    if (doc.wifiSsid != null) buffer.writeln('SSID: ${doc.wifiSsid}');
    if (doc.licenseProduct != null) buffer.writeln('${AppStrings.t(context, 'product')}: ${doc.licenseProduct}');
    await Share.share(buffer.toString());
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t(context, 'copied'))));
  }

  @override
  Widget build(BuildContext context) {
    final doc = context.watch<VaultProvider>().findById(widget.documentId);
    if (doc == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Not found')));
    }

    final cat = doc.category;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(doc.title),
        actions: [
          IconButton(
            icon: Icon(doc.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.coin),
            onPressed: () => context.read<VaultProvider>().toggleFavorite(doc.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_imageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.memory(_imageBytes!, fit: BoxFit.cover),
            ),
          const SizedBox(height: 20),
          _InfoTile(label: AppStrings.t(context, 'name'), value: doc.holderName ?? doc.title),
          _InfoTile(label: AppStrings.t(context, 'category'), value: AppStrings.t(context, cat?.nameKey ?? '')),
          _InfoTile(label: AppStrings.t(context, 'dateAdded'), value: dateFmt.format(doc.createdAt)),
          if (doc.expiryDate != null)
            _InfoTile(label: AppStrings.t(context, 'expiryDate'), value: doc.expiryDate!),
          if (doc.isWifi) ...[
            _InfoTile(label: AppStrings.t(context, 'ssid'), value: doc.wifiSsid ?? ''),
            _SecretTile(
              label: AppStrings.t(context, 'password'),
              value: doc.wifiPassword ?? '',
              visible: _showPassword,
              onToggle: () => setState(() => _showPassword = !_showPassword),
              onCopy: () => _copy(doc.wifiPassword ?? ''),
            ),
            _InfoTile(label: AppStrings.t(context, 'securityType'), value: doc.wifiSecurity ?? ''),
          ],
          if (doc.isLicenseKey) ...[
            _InfoTile(label: AppStrings.t(context, 'product'), value: doc.licenseProduct ?? ''),
            _SecretTile(
              label: AppStrings.t(context, 'licenseKey'),
              value: doc.licenseKey ?? '',
              visible: _showKey,
              onToggle: () => setState(() => _showKey = !_showKey),
              onCopy: () => _copy(doc.licenseKey ?? ''),
            ),
            _InfoTile(label: AppStrings.t(context, 'provider'), value: doc.licenseProvider ?? ''),
          ],
          if (doc.fileName != null)
            _InfoTile(label: AppStrings.t(context, 'attachedFiles'), value: doc.fileName!),
          if (doc.notes.isNotEmpty) _InfoTile(label: AppStrings.t(context, 'notes'), value: doc.notes),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _DetailActionButton(
                  label: AppStrings.t(context, 'share'),
                  icon: Icons.share_outlined,
                  onPressed: () => _share(doc),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DetailActionButton(
                  label: AppStrings.t(context, 'edit'),
                  icon: Icons.edit_outlined,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AddDocumentScreen(existing: doc)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DetailActionButton(
                  label: AppStrings.t(context, 'delete'),
                  icon: Icons.delete_outline_rounded,
                  onPressed: () => _delete(doc),
                  isDestructive: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _DetailActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));

    if (isDestructive) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: shape,
        ),
        child: _ActionContent(label: label, icon: icon),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.neonBlue,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        minimumSize: const Size(0, 48),
        side: BorderSide(color: isDark ? Colors.white24 : AppColors.primaryBlue.withValues(alpha: 0.35)),
        shape: shape,
      ),
      child: _ActionContent(label: label, icon: icon, color: AppColors.neonBlue),
    );
  }
}

class _ActionContent extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _ActionContent({required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13))),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: AppTypography.labelBold(size: 14))),
        ],
      ),
    );
  }
}

class _SecretTile extends StatelessWidget {
  final String label;
  final String value;
  final bool visible;
  final VoidCallback onToggle;
  final VoidCallback onCopy;

  const _SecretTile({
    required this.label,
    required this.value,
    required this.visible,
    required this.onToggle,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkCard : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13))),
          Text(visible ? value : '••••••••', style: AppTypography.labelBold(size: 14)),
          IconButton(onPressed: onToggle, icon: Icon(visible ? Icons.visibility_off : Icons.visibility)),
          IconButton(onPressed: onCopy, icon: const Icon(Icons.copy_outlined)),
        ],
      ),
    );
  }
}
