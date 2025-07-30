import 'package:flutter/material.dart';
import 'package:flutter_todo/pages/category/categories_page/categories_page.dart';
import 'package:flutter_todo/shared/widgets/verifier/verifier.dart';

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
