import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_screen.dart';
import 'main_menu.dart';
import 'api_service.dart';
import 'models.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Глобальный ключ для SnackBar
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const AviaBankApp(),
    ),
  );
}

// Упрощенный провайдер для управления состоянием пользователя
class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> setUser(User user) async {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> clearUser() async {
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loadUser(int userId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final user = await ApiService.getUser(userId);
      _currentUser = user;
    } catch (e) {
      _currentUser = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class AviaBankApp extends StatelessWidget {
  const AviaBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Авиа-Банк',
        supportedLocales: const [
          Locale('ru'), // русский
          Locale('en'), // английский, если нужен
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
  locale: const Locale('ru'), // по умолчанию русский
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          // Если пользователь загружается, показываем индикатор
          if (userProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // Показываем главное меню если пользователь авторизован
          if (userProvider.currentUser != null) {
            return MainMenuScreen(user: userProvider.currentUser!);
          }
          
          // Иначе показываем экран авторизации
          return const AuthScreen();
        },
      ),
      routes: {
        '/transfer': (context) => const MoneyTransferScreen(),
        '/history': (context) => TransactionHistoryScreen(),
        '/support': (context) => const CustomerSupportScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/cashback': (context) => const CashbackScreen(),
        '/internal-transfer': (context) => const InternalTransferScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/account-details': (context) {
          final account = ModalRoute.of(context)?.settings.arguments as Account?;
          if (account != null) {
            return AccountDetailsScreen(account: account);
          }
          return const Scaffold(
            body: Center(child: Text('Ошибка: Данные счета не получены')),
          );
        },
        '/change-password': (context) => const ChangePasswordScreen(),
        '/edit-name': (context) => const EditNameScreen(),
        '/edit-phone': (context) => const EditPhoneScreen(),
        '/flights': (context) => const FlightsScreen(),
        '/flight-booking': (context) => const FlightBookingScreen(),
      },
    );
  }
}