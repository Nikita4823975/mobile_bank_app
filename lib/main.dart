import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_screen.dart';
import 'main_menu.dart';
import 'api_service.dart';
import 'models.dart';

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

// Провайдер для управления состоянием пользователя
class UserProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}

class AviaBankApp extends StatelessWidget {
  const AviaBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'Авиа-Банк',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
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