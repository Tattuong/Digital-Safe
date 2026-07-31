import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/vault_document.dart';
import '../../providers/vault_provider.dart';
import '../../widgets/app_ui.dart';
import 'add_document_screen.dart';
import 'document_detail_screen.dart';

class DocumentsListScreen extends StatelessWidget {
  final DocumentCategory? category;

  const DocumentsListScreen({super.key, this.category});

  @override
  Widget build(BuildContext context) {
    final vault = context.watch<VaultProvider>();
    final docs = category != null
        ? vault.documents.where((d) => d.categoryId == category!.id).toList()
        : vault.documents;

    return Scaffold(
      appBar: AppBar(
        title: Text(category != null ? AppStrings.t(context, category!.nameKey) : AppStrings.t(context, 'allDocuments')),
      ),
      body: docs.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppStrings.t(context, 'noDocuments'), style: const TextStyle(color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddDocumentScreen(initialCategory: category),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                      label: Text(AppStrings.t(context, 'addDocument')),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _DocListTile(doc: docs[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddDocumentScreen(initialCategory: category),
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DocListTile extends StatelessWidget {
  final VaultDocument doc;

  const _DocListTile({required this.doc});

  @override
  Widget build(BuildContext context) {
    final cat = doc.category;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFmt = DateFormat.yMMMd();

    return Material(
      color: isDark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DocumentDetailScreen(documentId: doc.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cat?.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat?.icon, color: cat?.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.title, style: AppTypography.labelBold(size: 15)),
                    Text(dateFmt.format(doc.updatedAt), style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(doc.isFavorite ? Icons.star_rounded : Icons.star_outline, color: AppColors.coin, size: 22),
                onPressed: () => context.read<VaultProvider>().toggleFavorite(doc.id),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentScreen extends StatelessWidget {
  const RecentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = context.watch<VaultProvider>().activities;
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(AppStrings.t(context, 'recentActivity'), style: AppTypography.titleLarge()),
          ),
        ),
        if (activities.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(AppStrings.t(context, 'noActivity'))),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final act = activities[i];
                final cat = DocumentCategory.fromId(act.categoryId);
                final typeKey = switch (act.type) {
                  ActivityType.added => 'activityAdded',
                  ActivityType.viewed => 'activityViewed',
                  ActivityType.edited => 'activityEdited',
                  ActivityType.deleted => 'activityDeleted',
                  ActivityType.favorited => 'activityFavorited',
                };
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cat?.color.withValues(alpha: 0.2),
                    child: Icon(cat?.icon ?? Icons.description, color: cat?.color, size: 20),
                  ),
                  title: Text('${AppStrings.t(context, typeKey)} — ${act.documentTitle}'),
                  subtitle: Text(dateFmt.format(act.timestamp)),
                );
              },
              childCount: activities.length,
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<VaultProvider>().favorites;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(AppStrings.t(context, 'favorites'), style: AppTypography.titleLarge()),
          ),
        ),
        if (favorites.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(AppStrings.t(context, 'noFavorites'))),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _DocListTile(doc: favorites[i]),
                childCount: favorites.length,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
