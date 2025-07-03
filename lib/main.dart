import 'package:flutter/material.dart';

void main() {
  runApp(const AviaBankApp());
}

class AccountDetails {
  final String title;
  final String accountNumber;
  final String balance;
  final bool hasCard;
  final String? cardNumber;

  AccountDetails({
    required this.title,
    required this.accountNumber,
    required this.balance,
    required this.hasCard,
    this.cardNumber,
  });
}

class Account {
  final String name;
  final String accountNumber;
  final double balance;
  final Color color;
  final bool hasCard;
  final DateTime? cardExpiry;

  Account({
    required this.name,
    required this.accountNumber,
    required this.balance,
    required this.color,
    this.hasCard = false,
    this.cardExpiry,
  });
}

class Deposit {
  final String name;
  final double initialAmount;
  final double currentAmount;
  final DateTime openedDate;

  Deposit({
    required this.name,
    required this.initialAmount,
    required this.currentAmount,
    required this.openedDate,
  });

  double get changePercent {
    return ((currentAmount - initialAmount) / initialAmount) * 100;
  }
}

class AviaBankApp extends StatelessWidget {
  const AviaBankApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Авиа-Банк',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthScreen(),
      routes: {
        '/main': (context) => const MainMenuScreen(),
        '/transfer': (context) => const MoneyTransferScreen(),
        '/history': (context) => TransactionHistoryScreen(),
        '/support': (context) => const CustomerSupportScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/accounts': (context) => const AccountsScreen(),
        '/cashback': (context) => const CashbackScreen(),
        '/internal-transfer': (context) => const InternalTransferScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/account-details': (context) => const AccountDetailsScreen(),
        '/change-password': (context) => const ChangePasswordScreen(),
        '/edit-name': (context) => const EditNameScreen(),
        '/edit-phone': (context) => const EditPhoneScreen(),
      },
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Аватар
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),

            // ФИО
            const Text('ФИО: Никита', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),

            // Телефон
            const Text(
              'Телефон: +7 912 345-67-89',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),

            // Email
            const Text(
              'Email: nikita@example.com',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),

            // Безопасность
            const Text(
              'Безопасность',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              context,
              Icons.lock,
              'Сменить пароль',
              '/change-password',
            ),
            const SizedBox(height: 24),

            // Дополнительно
            const Text(
              'Дополнительно',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSettingTile(
              context,
              Icons.edit,
              'Изменить ФИО',
              '/edit-name',
            ),
            _buildSettingTile(
              context,
              Icons.phone,
              'Изменить телефон',
              '/edit-phone',
            ),
            _buildSettingTile(
              context,
              Icons.settings,
              'Настройки',
              '/settings',
            ),
          ],
        ),
      ),
    );
  }

  // Виджет для настроек профиля
  Widget _buildSettingTile(
    BuildContext context,
    IconData icon,
    String text,
    String route,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Внешний вид',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Темная тема'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
                // Здесь можно сохранить состояние или применить тему
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Уведомления',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SwitchListTile(
              title: const Text('Получать уведомления'),
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Счета и вклады')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Активные счета',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Счета
            _buildAccountCard(
              context,
              title: 'Основной счёт',
              accountNumber: '•••• 4587',
              balance: '24 300 руб',
              color: Colors.blue,
              hasCard: true,
              cardNumber: '•••• 1122',
            ),
            _buildAccountCard(
              context,
              title: 'Накопительный счёт',
              accountNumber: '•••• 1234',
              balance: '150 000 руб',
              color: Colors.green,
              hasCard: false,
              cardNumber: null,
            ),
            _buildAccountCard(
              context,
              title: 'Депозит "Выгодный"',
              accountNumber: '•••• 9876',
              balance: '500 000 руб',
              color: Colors.orange,
              hasCard: false,
              cardNumber: null,
            ),

            const SizedBox(height: 30),
            const Text(
              'Доступные действия',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Кнопка перевода между счетами
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Icon(Icons.compare_arrows, color: Colors.blue),
              ),
              title: const Text('Перевод между счетами'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pushNamed(context, '/internal-transfer');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Карточка счёта
  Widget _buildAccountCard(
    BuildContext context, {
    required String title,
    required String accountNumber,
    required String balance,
    required Color color,
    required bool hasCard,
    String? cardNumber,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/account-details',
            arguments: AccountDetails(
              title: title,
              accountNumber: accountNumber,
              balance: balance,
              hasCard: hasCard,
              cardNumber: cardNumber,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.account_balance, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(accountNumber),
                    const SizedBox(height: 5),
                    Text(
                      balance,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasCard && cardNumber != null)
                Row(
                  children: [
                    Icon(Icons.credit_card, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      cardNumber,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late AccountDetails _account;
  late bool _hasCard;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args is AccountDetails) {
      _account = args;
      _hasCard = _account.hasCard;
    } else {
      throw Exception("Expected AccountDetails as an argument");
    }
  }

  void _toggleCard() {
    setState(() {
      _hasCard = !_hasCard;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_hasCard ? 'Карта привязана' : 'Карта отвязана')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_account.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Номер счёта:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_account.accountNumber, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text(
              'Баланс:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              _account.balance,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_hasCard && _account.cardNumber != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Привязанная карта:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _account.cardNumber!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _toggleCard,
                    icon: const Icon(Icons.credit_card_off),
                    label: const Text('Отвязать карту'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _toggleCard,
                icon: const Icon(Icons.credit_card),
                label: const Text('Привязать карту'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
          ],
        ),
      ),
    );
  }
}

// ЭКРАН АВТОРИЗАЦИИ
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.airplanemode_active,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 30),
            const Text(
              'Авиа-Банк',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Номер телефона',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Пароль',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Войти', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// ГЛАВНОЕ МЕНЮ
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Верхняя панель: название банка, уведомления, выход
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            color: Colors.blue[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Авиа-Банк',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/notifications');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                        // Выход из аккаунта
                        Navigator.pushReplacementNamed(context, '/');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Кнопка профиля пользователя
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: const Text('Никита'),
            subtitle: const Text('Личный кабинет'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),

          const Divider(height: 1),

          // Основные функции приложения
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildMainButton(
                  context,
                  Icons.compare_arrows,
                  'Переводы',
                  '/transfer',
                ),
                _buildMainButton(
                  context,
                  Icons.account_balance,
                  'Счета и вклады',
                  '/accounts',
                ),
                _buildMainButton(
                  context,
                  Icons.history,
                  'История транзакций',
                  '/history',
                ),
                _buildMainButton(
                  context,
                  Icons.money_off_csred,
                  'Получить кэшбэк',
                  '/cashback',
                ),
                _buildMainButton(
                  context,
                  Icons.headset_mic,
                  'Поддержка клиентов',
                  '/support',
                ),
                _buildMainButton(
                  context,
                  Icons.settings,
                  'Настройки',
                  '/settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(
    BuildContext context,
    IconData icon,
    String text,
    String route,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          if (route.isNotEmpty) {
            Navigator.pushNamed(context, route);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$text в разработке')));
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfileHeader extends StatelessWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Никита',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text('Основной счет: •••• 4587', style: TextStyle(fontSize: 14)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              // Показать QR код
            },
          ),
        ],
      ),
    );
  }
}

class TransactionSummaryCard extends StatelessWidget {
  const TransactionSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'История транзакций',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              '2474 руб',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'За последние 24 часа',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/history');
                },
                child: const Text('Подробнее'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ЭКРАН ПЕРЕВОДА ДЕНЕГ
class MoneyTransferScreen extends StatefulWidget {
  const MoneyTransferScreen({super.key});

  @override
  _MoneyTransferScreenState createState() => _MoneyTransferScreenState();
}

class _MoneyTransferScreenState extends State<MoneyTransferScreen> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController(); // Новое поле

  String _selectedRecipient = 'Другу';
  final Map<String, String?> _recipientPhones = {
    'Другу': '+7 912 345-67-89',
    'Дружку': '+7 999 888-77-66',
    'На другой счет': null,
  };

  bool get _isCustomPhone => _selectedRecipient == 'На другой счет';

  @override
  void didUpdateWidget(covariant MoneyTransferScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isCustomPhone) {
      _phoneController.clear();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Перевод денег')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Кому перевести',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedRecipient,
              items: _recipientPhones.keys.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedRecipient = newValue!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (_isCustomPhone)
              Column(
                children: [
                  const SizedBox(height: 20),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Номер телефона получателя',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            const Text(
              'Сумма перевода',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '₽ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Перевести',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmTransfer() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите сумму')));
      return;
    }

    if (_isCustomPhone && _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите номер телефона')));
      return;
    }

    final amount = _amountController.text;
    final recipient = _isCustomPhone
        ? _phoneController.text
        : _selectedRecipient;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Подтверждение'),
        content: Text(
          'Вы уверены, что хотите перевести $amount₽ на счёт $recipient?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _completeTransfer();
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  void _completeTransfer() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Перевод ${_amountController.text}₽ выполнен')),
    );
    Navigator.pop(context);
  }
}

// ЭКРАН ИСТОРИИ ТРАНЗАКЦИЙ
class TransactionHistoryScreen extends StatelessWidget {
  final List<Transaction> transactions = [
    Transaction(
      id: '1',
      amount: -1500,
      recipient: 'Авиабилеты',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Путешествия',
    ),
    Transaction(
      id: '2',
      amount: 5000,
      recipient: 'Зарплата',
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Доход',
    ),
    Transaction(
      id: '3',
      amount: -2474,
      recipient: 'Ресторан',
      date: DateTime.now().subtract(const Duration(days: 1)),
      category: 'Еда',
    ),
  ];

  TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История транзакций'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              // Фильтрация транзакций
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return TransactionCard(transaction: transaction);
        },
      ),
    );
  }
}

class Transaction {
  final String id;
  final double amount;
  final String recipient;
  final DateTime date;
  final String category;

  Transaction({
    required this.id,
    required this.amount,
    required this.recipient,
    required this.date,
    required this.category,
  });
}

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: transaction.amount > 0 ? Colors.green[100] : Colors.red[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            transaction.amount > 0 ? Icons.arrow_downward : Icons.arrow_upward,
            color: transaction.amount > 0 ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction.recipient),
        subtitle: Text(
          '${transaction.date.day}.${transaction.date.month}.${transaction.date.year} - ${transaction.category}',
        ),
        trailing: Text(
          '${transaction.amount > 0 ? '+' : ''}${transaction.amount}₽',
          style: TextStyle(
            color: transaction.amount > 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          // Детали транзакции
        },
      ),
    );
  }
}

class CashbackScreen extends StatefulWidget {
  const CashbackScreen({super.key});

  @override
  State<CashbackScreen> createState() => _CashbackScreenState();
}

class _CashbackScreenState extends State<CashbackScreen> {
  String _selectedOption = 'На основной счёт';
  final double _availableCashback = 874.50;

  void _claimCashback() {
    if (_availableCashback <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Нет доступного кэшбэка')));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Подтверждение'),
        content: Text('Вы уверены, что хотите получить $_availableCashback₽?'),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
            },
            child: const Text('Получить'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Успех!'),
        content: Text(
          '$_availableCashback₽ успешно зачислены на $_selectedOption',
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Ок'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Получить кэшбэк')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Доступный кэшбэк',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$_availableCashback ₽',
                      style: const TextStyle(fontSize: 28, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Получить на:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('На основной счёт'),
              leading: Radio<String>(
                value: 'На основной счёт',
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('На другую карту'),
              leading: Radio<String>(
                value: 'На другую карту',
                groupValue: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value!;
                  });
                },
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _claimCashback,
                icon: const Icon(Icons.money_off_csred),
                label: const Text('Получить кэшбэк'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ЭКРАН ПОДДЕРЖКИ КЛИЕНТОВ
class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    const ChatMessage(
      text: 'Здравствуйте! Чем могу помочь?',
      isMe: false,
      time: '12:30',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поддержка клиентов')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return ChatBubble(message: message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Напишите сообщение...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(
          text: _messageController.text,
          isMe: true,
          time: '${TimeOfDay.now().hour}:${TimeOfDay.now().minute}',
        ),
      );
      _messageController.clear();
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          const ChatMessage(
            text:
                'Спасибо за обращение! Мы решим ваш вопрос в ближайшее время.',
            isMe: false,
            time: 'Только что',
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

class InternalTransferScreen extends StatefulWidget {
  const InternalTransferScreen({super.key});
  @override
  State<InternalTransferScreen> createState() => _InternalTransferScreenState();
}

class _InternalTransferScreenState extends State<InternalTransferScreen> {
  final _amountController = TextEditingController();

  String _fromAccount = 'Основной счёт';
  String _toAccount = 'Накопительный счёт';

  final List<String> _accounts = [
    'Основной счёт',
    'Накопительный счёт',
    'Депозит "Выгодный"',
  ];

  void _submitTransfer() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите сумму')));
      return;
    }

    final amount = _amountController.text;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Подтверждение перевода'),
        content: Text('Перевести $amount₽ с $_fromAccount на $_toAccount?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ✅ Исправлено
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog();
            },
            child: const Text('Перевести'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Успех!'),
        content: const Text('Средства успешно переведены'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // ✅ Исправлено
            child: const Text('Ок'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Перевод между счетами')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'С какого счёта',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _fromAccount,
              items: _accounts.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _fromAccount = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'На какой счёт',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _toAccount,
              items: _accounts.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _toAccount = value!;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Сумма перевода',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '₽ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitTransfer,
                icon: const Icon(Icons.compare_arrows),
                label: const Text('Перевести'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления')),
      body: ListView(children: _mockNotifications),
    );
  }

  final List<NotificationItem> _mockNotifications = [
    NotificationItem(
      title: 'Перевод выполнен',
      content: '2474₽ успешно переведены другу',
    ),
    NotificationItem(
      title: 'Кэшбэк начислен',
      content: '874.50₽ зачислены на основной счёт',
    ),
    NotificationItem(
      title: 'Пополнение счёта',
      content: 'Счёт пополнен на 5000₽',
    ),
    NotificationItem(
      title: 'Новая функция!',
      content: 'Теперь вы можете переводить между счетами',
    ),
  ];
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();

  void _changePassword() {
    if (_oldController.text.isEmpty || _newController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
      return;
    }

    // Здесь можно добавить проверку старого пароля
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Пароль успешно изменён')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сменить пароль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _oldController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Старый пароль',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Новый пароль',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _changePassword,
                child: const Text('Сохранить новый пароль'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    super.dispose();
  }
}

class NotificationItem extends StatelessWidget {
  final String title;
  final String content;

  const NotificationItem({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(content),
            const SizedBox(height: 8),
            Text(
              'Только что',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: const Icon(Icons.notifications, color: Colors.blue),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(message.text),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({super.key});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Никита',
  );

  void _saveName() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите корректное имя')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Имя изменено на "${_nameController.text}"')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Изменить имя')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Ваше имя',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveName,
                child: const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

class EditPhoneScreen extends StatefulWidget {
  const EditPhoneScreen({super.key});

  @override
  State<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController(
    text: '+7 912 345-67-89',
  );

  void _savePhone() {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите номер телефона')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Телефон изменён на ${_phoneController.text}')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Изменить телефон')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Номер телефона',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _savePhone,
                child: const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
