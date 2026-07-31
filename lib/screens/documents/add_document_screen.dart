import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/encryption_service.dart';
import '../../models/vault_document.dart';
import '../../providers/shop_provider.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/app_toast.dart';

class AddDocumentScreen extends StatefulWidget {
  final VaultDocument? existing;
  final DocumentCategory? initialCategory;

  const AddDocumentScreen({super.key, this.existing, this.initialCategory});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen> {
  late DocumentCategory _category;
  final _categoryScroll = ScrollController();
  final _titleCtrl = TextEditingController();
  final _titleFocus = FocusNode();
  final _notesCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _ssidCtrl = TextEditingController();
  final _wifiPassCtrl = TextEditingController();
  final _wifiSecCtrl = TextEditingController(text: 'WPA2/WPA3');
  final _productCtrl = TextEditingController();
  final _licenseKeyCtrl = TextEditingController();
  final _providerCtrl = TextEditingController();
  String? _filePath;
  String? _fileName;
  bool _saving = false;
  bool _titleError = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _category = e.category ?? DocumentCategory.cccd;
      _titleCtrl.text = e.title;
      _notesCtrl.text = e.notes;
      _holderCtrl.text = e.holderName ?? '';
      _expiryCtrl.text = e.expiryDate ?? '';
      _ssidCtrl.text = e.wifiSsid ?? '';
      _wifiPassCtrl.text = e.wifiPassword ?? '';
      _wifiSecCtrl.text = e.wifiSecurity ?? 'WPA2/WPA3';
      _productCtrl.text = e.licenseProduct ?? '';
      _licenseKeyCtrl.text = e.licenseKey ?? '';
      _providerCtrl.text = e.licenseProvider ?? '';
      _filePath = e.filePath;
      _fileName = e.fileName;
    } else {
      _category = widget.initialCategory ?? DocumentCategory.cccd;
    }
    _titleCtrl.addListener(() {
      if (_titleError && _titleCtrl.text.trim().isNotEmpty) {
        setState(() => _titleError = false);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCategory(_category));
  }

  void _scrollToCategory(DocumentCategory cat) {
    final index = DocumentCategory.values.indexOf(cat);
    if (index < 0 || !_categoryScroll.hasClients) return;
    const itemStride = 66.0;
    final offset = (index * itemStride).clamp(0.0, _categoryScroll.position.maxScrollExtent);
    _categoryScroll.animateTo(offset, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _titleFocus.dispose();
    _notesCtrl.dispose();
    _holderCtrl.dispose();
    _expiryCtrl.dispose();
    _ssidCtrl.dispose();
    _wifiPassCtrl.dispose();
    _wifiSecCtrl.dispose();
    _productCtrl.dispose();
    _licenseKeyCtrl.dispose();
    _providerCtrl.dispose();
    _categoryScroll.dispose();
    super.dispose();
  }

  String? _resolveTitle() {
    final title = _titleCtrl.text.trim();
    if (title.isNotEmpty) return title;

    if (_category.isWifi) {
      final ssid = _ssidCtrl.text.trim();
      if (ssid.isNotEmpty) return ssid;
    }
    if (_category.isLicenseKey) {
      final product = _productCtrl.text.trim();
      if (product.isNotEmpty) return product;
    }
    final holder = _holderCtrl.text.trim();
    if (holder.isNotEmpty) return holder;

    return null;
  }

  void _showMessage(String text, {bool isError = false}) {
    AppToast.show(
      context,
      title: text,
      icon: isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
      color: isError ? AppColors.error : AppColors.success,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor: isError ? AppColors.error : AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    try {
      final encPath = await EncryptionService.instance.encryptFile(picked.path);
      if (!mounted) return;
      setState(() {
        _filePath = encPath;
        _fileName = picked.name;
      });
    } catch (_) {
      if (mounted) _showMessage(AppStrings.t(context, 'saveFailed'), isError: true);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final resolvedTitle = _resolveTitle();
    if (resolvedTitle == null) {
      HapticFeedback.heavyImpact();
      setState(() => _titleError = true);
      _titleFocus.requestFocus();
      _showMessage(AppStrings.t(context, 'titleRequired'), isError: true);
      return;
    }

    final vault = context.read<VaultProvider>();
    final shop = context.read<ShopProvider>();

    if (widget.existing == null && !vault.canAddDocument(shop.hasUnlimitedDocs)) {
      _showMessage(AppStrings.t(context, 'documentLimitReached'), isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final doc = VaultDocument(
        id: widget.existing?.id ?? const Uuid().v4(),
        title: resolvedTitle,
        categoryId: _category.id,
        notes: _notesCtrl.text.trim(),
        filePath: _filePath,
        fileName: _fileName,
        wifiSsid: _ssidCtrl.text.trim().isEmpty ? null : _ssidCtrl.text.trim(),
        wifiPassword: _wifiPassCtrl.text.trim().isEmpty ? null : _wifiPassCtrl.text.trim(),
        wifiSecurity: _wifiSecCtrl.text.trim().isEmpty ? null : _wifiSecCtrl.text.trim(),
        licenseProduct: _productCtrl.text.trim().isEmpty ? null : _productCtrl.text.trim(),
        licenseKey: _licenseKeyCtrl.text.trim().isEmpty ? null : _licenseKeyCtrl.text.trim(),
        licenseProvider: _providerCtrl.text.trim().isEmpty ? null : _providerCtrl.text.trim(),
        expiryDate: _expiryCtrl.text.trim().isEmpty ? null : _expiryCtrl.text.trim(),
        holderName: _holderCtrl.text.trim().isEmpty ? null : _holderCtrl.text.trim(),
        isFavorite: widget.existing?.isFavorite ?? false,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.existing != null) {
        await vault.updateDocument(doc);
      } else {
        await vault.addDocument(doc);
        await shop.rewardForDocumentAdd();
      }

      if (!mounted) return;
      _showMessage(AppStrings.t(context, 'saveSuccess'));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showMessage(AppStrings.t(context, 'saveFailed'), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.t(context, isEdit ? 'editDocument' : 'addDocument')),
            Text(
              AppStrings.t(context, _category.nameKey),
              style: TextStyle(fontSize: 13, color: _category.color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          SizedBox(
            height: 90,
            child: ListView.separated(
              controller: _categoryScroll,
              scrollDirection: Axis.horizontal,
              itemCount: DocumentCategory.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final cat = DocumentCategory.values[i];
                final selected = cat == _category;
                return GestureDetector(
                  onTap: () {
                    setState(() => _category = cat);
                    _scrollToCategory(cat);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? cat.color.withValues(alpha: 0.25) : (isDark ? AppColors.darkCard : AppColors.surfaceVariant),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? cat.color : Colors.transparent, width: 2),
                    ),
                    child: Icon(cat.icon, color: cat.color),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleCtrl,
            focusNode: _titleFocus,
            decoration: InputDecoration(
              labelText: AppStrings.t(context, 'documentTitle'),
              errorText: _titleError ? AppStrings.t(context, 'titleRequired') : null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: InputDecoration(labelText: AppStrings.t(context, 'notes')),
          ),
          if (!_category.isWifi && !_category.isLicenseKey) ...[
            const SizedBox(height: 12),
            TextField(controller: _holderCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'name'))),
            const SizedBox(height: 12),
            TextField(controller: _expiryCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'expiryDate'))),
          ],
          if (_category.isWifi) ...[
            const SizedBox(height: 12),
            TextField(controller: _ssidCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'ssid'))),
            const SizedBox(height: 12),
            TextField(
              controller: _wifiPassCtrl,
              obscureText: true,
              decoration: InputDecoration(labelText: AppStrings.t(context, 'password')),
            ),
            const SizedBox(height: 12),
            TextField(controller: _wifiSecCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'securityType'))),
          ],
          if (_category.isLicenseKey) ...[
            const SizedBox(height: 12),
            TextField(controller: _productCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'product'))),
            const SizedBox(height: 12),
            TextField(
              controller: _licenseKeyCtrl,
              decoration: InputDecoration(labelText: AppStrings.t(context, 'licenseKey')),
            ),
            const SizedBox(height: 12),
            TextField(controller: _providerCtrl, decoration: InputDecoration(labelText: AppStrings.t(context, 'provider'))),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(_fileName ?? AppStrings.t(context, 'selectFileOrPhoto')),
          ),
          if (_fileName != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_fileName!, style: const TextStyle(color: AppColors.success, fontSize: 12)),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _saving
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(AppStrings.t(context, 'saveDocument')),
          ),
        ),
      ),
    );
  }
}
