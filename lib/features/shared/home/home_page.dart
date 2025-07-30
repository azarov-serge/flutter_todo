import 'package:flutter/material.dart';
import '../../../shared/widgets/verifier/verifier.dart';
import '../../categories/views/categories_page/categories_page.dart';

/// Главная страница приложения
/// Использует Verifier для проверки авторизации
/// Показывает CategoryPage как основной контент
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Verifier(child: CategoriesPage());
  }
}
