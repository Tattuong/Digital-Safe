import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/vault_document.dart';
import '../../providers/shop_provider.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/app_ui.dart';
import '../../widgets/coin_balance_chip.dart';
import '../../widgets/coin_promo_banner.dart';
import '../documents/document_detail_screen.dart';
import '../documents/documents_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultProvider>();
    final shop = context.watch<ShopProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final used = vault.storageUsedMb() / 1024;
    final total = vault.storageLimitGb(shop.hasUnlimitedDocs);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.t(context, 'helloUser', {'name': vault.userName}),
                    style: AppTypography.titleLarge(color: isDark ? Colors.white : AppColors.onSurface),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white70 : AppColors.onSurfaceVariant),
                ),
                const CoinBalanceChip(),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              onChanged: vault.setSearchQuery,
              style: TextStyle(color: isDark ? Colors.white : AppColors.onSurface),
              decoration: InputDecoration(
                hintText: AppStrings.t(context, 'searchDocuments'),
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
        if (vault.searchQuery.isEmpty) const SliverToBoxAdapter(child: CoinPromoBanner(compact: true)),
        if (vault.searchQuery.isNotEmpty)
          _DocumentResults(docs: vault.filteredDocuments)
        else ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.18,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final cat = DocumentCategory.values[i];
                  final count = vault.countByCategory(cat.id);
                  return _CategoryCard(
                    category: cat,
                    count: count,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DocumentsListScreen(category: cat),
                      ),
                    ),
                  );
                },
                childCount: DocumentCategory.values.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppDecorations.journalCard(isDark: isDark, skin: shop.activeCardStyle),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.storage_outlined, color: AppColors.neonBlue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.t(context, 'storageUsed', {
                            'used': used.toStringAsFixed(2),
                            'total': total.toStringAsFixed(0),
                          }),
                          style: AppTypography.labelBold(size: 14, color: isDark ? Colors.white : AppColors.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (used / total).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: isDark ? AppColors.darkBackground : AppColors.surfaceVariant,
                        color: AppColors.neonBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final DocumentCategory category;
  final int count;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: isDark ? 0 : 2,
      shadowColor: category.color.withValues(alpha: 0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: category.color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(category.icon, color: category.color, size: 22),
              ),
              const Spacer(),
              Text(
                AppStrings.t(context, category.nameKey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelBold(size: 13, color: isDark ? Colors.white : AppColors.onSurface),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.t(context, 'documentsCount', {'count': count.toString()}),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: isDark ? Colors.white54 : AppColors.onSurfaceVariant, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentResults extends StatelessWidget {
  final List<VaultDocument> docs;

  const _DocumentResults({required this.docs});

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: Text(AppStrings.t(context, 'noDocuments'))),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => _DocTile(doc: docs[i]),
        childCount: docs.length,
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final VaultDocument doc;

  const _DocTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    final cat = doc.category;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cat?.color.withValues(alpha: 0.2),
        child: Icon(cat?.icon ?? Icons.description, color: cat?.color),
      ),
      title: Text(doc.title),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DocumentDetailScreen(documentId: doc.id)),
      ),
    );
  }
}
