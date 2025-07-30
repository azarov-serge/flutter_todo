import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_todo/features/categories/providers/category_query.dart';
import 'package:todo_models/todo_models.dart';

import '../../../../app/routes.dart';
import '../../../../shared/ui_kit/ui_kit.dart';
import '../../providers/category_notifier.dart';
import '../../../../shared/providers/request_provider.dart';
import '../../../auth/providers/auth_notifier.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    // Lazy initialization of categories loading
    if (!_initialized) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final userId = ref.read(categoryNotifierProvider).userId;
        if (userId != null) {
          ref.read(categoryNotifierProvider.notifier).fetchCategories();
        }
      });
    }

    final categories = ref.watch(categoriesProvider);
    final userId = ref.watch(categoryNotifierProvider).userId;
    final isLoading = ref.watch(categoryLoadingProvider);
    final error = ref.watch(categoryErrorProvider);
    final query = userId != null ? CategoryQuery.categories(userId) : null;
    final requestState = query != null
        ? ref.watch(requestStateProvider(query.state.key))
        : null;

    return ErrorWrapper(
      error: requestState?.error ?? error,
      onClosePressed: () {
        if (query != null) {
          ref
              .read(requestNotifierProvider.notifier)
              .clearError(query.state.key);
        }
      },
      child: _buildContent(categories, isLoading, error),
    );
  }

  Widget _buildContent(
    List<CategoryModel> categories,
    bool isLoading,
    String? error,
  ) {
    if (isLoading && categories.isEmpty) {
      return SplashScreen(message: 'Loading categories...');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => AppRoutes.goToCreateCategory(context),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: _buildNavigationDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          final userId = ref.read(categoryNotifierProvider).userId;
          if (userId != null) {
            await ref.read(categoryNotifierProvider.notifier).fetchCategories();
          }
        },
        child: _buildCategoriesList(categories),
      ),
    );
  }

  Widget _buildNavigationDrawer() {
    final currentUser = ref.watch(authNotifierProvider).currentUser;

    return Drawer(
      child: Column(
        children: [
          // Header with user info
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(8, 70, 8, 0),
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentUser?.login ?? 'Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (currentUser != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      'User ID: ${currentUser.id}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop(); // Close drawer
                    try {
                      await ref.read(authNotifierProvider.notifier).signOut();
                      // Verifier will automatically redirect to AuthPage
                    } catch (e) {
                      // Show error if something went wrong
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error signing out: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesList(List<CategoryModel> categories) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No categories',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Click + to add a category',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category);
      },
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Created: ${_formatDate(category.createdAt)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        onTap: () => AppRoutes.goToTasks(context, categoryId: category.id),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'tasks':
                AppRoutes.goToTasks(context, categoryId: category.id);
                break;
              case 'edit':
                AppRoutes.goToEditCategory(context, category.id);
                break;
              case 'delete':
                _showDeleteCategoryDialog(context, category);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'tasks',
              child: Row(
                children: [
                  Icon(Icons.task, size: 16),
                  SizedBox(width: 8),
                  Text('View Tasks'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  void _showDeleteCategoryDialog(BuildContext context, CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(categoryNotifierProvider.notifier)
                  .deleteCategory(category.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
