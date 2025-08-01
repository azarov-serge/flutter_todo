# Архитектура Flutter Todo App

## 🎯 Обзор

Данный проект представляет собой современное Flutter приложение для управления задачами, построенное с использованием **Riverpod** для управления состоянием и **feature-based архитектуры** для организации кода.

## 🏗️ Архитектурные принципы

### **SOLID принципы**
- ✅ **Single Responsibility Principle (SRP)** - каждый класс имеет одну ответственность
- ✅ **Open/Closed Principle (OCP)** - открыт для расширения, закрыт для модификации
- ✅ **Liskov Substitution Principle (LSP)** - компоненты взаимозаменяемы
- ✅ **Interface Segregation Principle (ISP)** - интерфейсы разделены по назначению
- ✅ **Dependency Inversion Principle (DIP)** - зависимости от абстракций

### **Clean Architecture**
- ✅ **Разделение слоев** - UI, Business Logic, Data
- ✅ **Инверсия зависимостей** - внутренние слои не зависят от внешних
- ✅ **Тестируемость** - каждый слой можно тестировать независимо

## 📁 Структура проекта

```
lib/
├── app/                          # Конфигурация приложения
│   ├── app.dart                  # Главный App widget
│   ├── routes.dart               # Роутинг приложения
│   └── store/                    # Redux store (устаревший)
├── features/                     # Feature-based архитектура
│   ├── auth/                     # Модуль аутентификации
│   │   ├── providers/            # Riverpod провайдеры
│   │   │   ├── auth_notifier.dart
│   │   │   ├── auth_query.dart
│   │   │   └── auth_providers.dart
│   │   └── views/                # UI компоненты
│   │       └── auth_page/
│   │           ├── auth_page.dart        # Smart wrapper
│   │           ├── auth_page_view.dart   # Dumb view
│   │           ├── auth_page_view_model.dart
│   │           └── widgets/
│   │               ├── sign_in_form.dart
│   │               └── sign_up_form.dart
│   ├── categories/               # Модуль категорий
│   │   ├── providers/
│   │   │   ├── category_notifier.dart
│   │   │   ├── category_query.dart
│   │   │   └── category_providers.dart
│   │   └── views/
│   │       ├── categories_page/
│   │       └── category_editor_page/
│   ├── tasks/                    # Модуль задач
│   │   ├── providers/
│   │   │   ├── task_notifier.dart
│   │   │   ├── task_query.dart
│   │   │   └── task_providers.dart
│   │   └── views/
│   │       ├── tasks_page/
│   │       └── task_editor/
│   └── shared/                   # Общие компоненты
│       └── home/
│           └── home_page.dart
├── shared/                       # Общие утилиты
│   ├── providers/
│   │   ├── request_provider.dart # Централизованное управление запросами
│   │   └── query_factory.dart   # Фабрика запросов
│   ├── widgets/
│   │   └── verifier/            # Проверка аутентификации
│   ├── ui_kit/                  # UI компоненты
│   │   ├── error_wrapper/
│   │   ├── spinner/
│   │   └── splash_screen/
│   └── get_it/                  # Dependency Injection
│       └── di_setup.dart
└── main.dart                     # Точка входа
```

## 🔄 Поток данных

### **1. Аутентификация**
```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│  AuthPage   │    │ AuthPageView │    │ AuthPageViewModel │
│ (Business)  │◄──►│   (UI)       │    │ (UI Logic)  │
│             │    │              │    │             │
│ • Auth State│    │ • Rendering  │    │ • TabController │
│ • Redirects │    │ • No Logic   │    │ • Tab Switching │
│ • Loading   │    │ • Reusable   │    │ • UI State   │
└─────────────┘    └──────────────┘    └─────────────┘
```

### **2. Управление состоянием**
```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   UI        │    │  Notifier    │    │   Query     │
│ (Widgets)   │◄──►│ (State)      │◄──►│ (API)       │
│             │    │              │    │             │
│ • Consumer  │    │ • StateNotifier│  │ • Query Factory │
│ • Provider  │    │ • Business Logic│ │ • API Calls  │
│ • UI Logic  │    │ • State Management│ │ • Error Handling │
└─────────────┘    └──────────────┘    └─────────────┘
```

## 🎯 Ключевые компоненты

### **1. RequestNotifier**
**Файл:** `lib/shared/providers/request_provider.dart`

Централизованное управление состоянием всех API запросов.

```dart
class RequestNotifier extends StateNotifier<Map<String, RequestState>> {
  // Управляет loading, success, error состояниями
  void setLoading(String key);
  void setSuccess(String key);
  void setError(String key, String error);
}
```

**Преимущества:**
- ✅ **Единообразие** - все запросы используют один паттерн
- ✅ **Централизация** - ошибки и загрузки в одном месте
- ✅ **Переиспользование** - общие компоненты для всех состояний

### **2. Query Factory Pattern**
**Файл:** `lib/shared/providers/query_factory.dart`

Фабрика для создания типизированных запросов к API.

```dart
class AuthQuery {
  static Query signIn() => Query(
    key: 'auth_signin',
    request: () => authApi.signIn(data),
  );
  
  static Query checkAuth() => Query(
    key: 'auth_check',
    request: () => authApi.checkAuth(),
  );
}
```

**Преимущества:**
- ✅ **Типобезопасность** - каждый запрос имеет свой тип
- ✅ **Централизация** - все ключи запросов в одном месте
- ✅ **Переиспользование** - общая логика для всех запросов

### **3. Smart/Dumb Pattern**
**Пример:** `AuthPage` и `AuthPageView`

```dart
// Smart wrapper (Business Logic)
class AuthPage extends ConsumerStatefulWidget {
  // Управляет аутентификацией, редиректами, состоянием
}

// Dumb view (UI only)
class AuthPageView extends StatefulWidget {
  // Только рендеринг UI, никакой бизнес-логики
}
```

**Преимущества:**
- ✅ **Разделение ответственности** - UI отдельно от логики
- ✅ **Тестируемость** - можно тестировать UI и логику отдельно
- ✅ **Переиспользование** - UI можно использовать в разных контекстах

### **4. Verifier Pattern**
**Файл:** `lib/shared/widgets/verifier/verifier.dart`

Компонент для проверки аутентификации и условного рендеринга.

```dart
class Verifier extends ConsumerStatefulWidget {
  // Проверяет аутентификацию
  // Показывает SplashScreen во время проверки
  // Рендерит child или AuthPage
}
```

**Преимущества:**
- ✅ **Автоматизация** - автоматическая проверка аутентификации
- ✅ **UX** - плавные переходы между состояниями
- ✅ **Безопасность** - защита от несанкционированного доступа

## 🛠️ Технологический стек

### **State Management**
- **Riverpod** - современное управление состоянием
- **StateNotifier** - для изменяемого состояния
- **Provider** - для чтения состояния в UI

### **Architecture Patterns**
- **Feature-based** - организация по функциональности
- **MVVM** - Model-View-ViewModel для UI логики
- **Repository** - для работы с данными
- **Dependency Injection** - GetIt для DI

### **UI/UX**
- **Material Design** - современный дизайн
- **Responsive Design** - адаптивность
- **Error Handling** - централизованная обработка ошибок
- **Loading States** - индикаторы загрузки

### **Data Layer**
- **Hive** - локальное хранение
- **HTTP Client** - сетевые запросы
- **Query Factory** - типизированные запросы

## 🔧 Принципы разработки

### **1. Feature-based Architecture**
```
features/
├── auth/          # Все связанное с аутентификацией
├── categories/    # Все связанное с категориями
├── tasks/         # Все связанное с задачами
└── shared/        # Общие компоненты
```

### **2. Separation of Concerns**
- **UI Layer** - только презентация
- **Business Logic** - логика приложения
- **Data Layer** - работа с данными

### **3. Dependency Inversion**
- Высокоуровневые модули не зависят от низкоуровневых
- Оба зависят от абстракций

### **4. Testability**
- Каждый слой можно тестировать независимо
- Моки и стабы для изоляции тестов

## 🚀 Преимущества архитектуры

### **1. Масштабируемость**
- ✅ Легко добавлять новые фичи
- ✅ Модульная структура
- ✅ Независимые компоненты

### **2. Поддерживаемость**
- ✅ Четкая структура кода
- ✅ Понятные имена и организация
- ✅ Документированные компоненты

### **3. Тестируемость**
- ✅ Изолированные тесты
- ✅ Моки для внешних зависимостей
- ✅ Покрытие всех слоев

### **4. Производительность**
- ✅ Оптимизированные ребилды
- ✅ Эффективное управление состоянием
- ✅ Минимальные перерисовки

## 📚 Рекомендации по разработке

### **1. Создание новой фичи**
```
features/new_feature/
├── providers/
│   ├── new_feature_notifier.dart
│   ├── new_feature_query.dart
│   └── new_feature_providers.dart
└── views/
    ├── new_feature_page/
    └── new_feature_editor/
```

### **2. Создание UI компонента**
```dart
// Smart wrapper
class NewFeaturePage extends ConsumerStatefulWidget {
  // Business logic
}

// Dumb view
class NewFeaturePageView extends StatefulWidget {
  // UI only
}

// ViewModel
class NewFeaturePageViewModel extends ChangeNotifier {
  // UI logic
}
```

### **3. Создание API запроса**
```dart
class NewFeatureQuery {
  static Query getData() => Query(
    key: 'new_feature_get_data',
    request: () => api.getData(),
  );
}
```

Эта архитектура обеспечивает чистый, масштабируемый и поддерживаемый код, соответствующий современным стандартам Flutter разработки. 