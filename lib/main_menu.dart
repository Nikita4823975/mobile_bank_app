import 'package:flutter/material.dart';
import 'package:mobile_bank_app/main.dart';
import 'api_service.dart';
import 'models.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// Главное меню
class MainMenuScreen extends StatefulWidget {
  final User user;

  const MainMenuScreen({super.key, required this.user});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  Future<User>? _userFuture;
  bool _isLoading = true;
  late User user; // Используем переданный параметр user

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = widget.user; // Инициализируем user из параметра
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _userFuture = Future.value(user);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user; // Объявляем переменную user

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<User>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('Данные не найдены'));
                }
                user = snapshot.data!; // Инициализируем переменную user
                return Column(
                  children: [
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
                                  Navigator.pushReplacementNamed(context, '/');
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text('${user.firstName} ${user.lastName}'),
                      subtitle: const Text('Личный кабинет'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(user: user),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
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
                            Icons.airplanemode_active,
                            'Авиабилеты',
                            '/flights',
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
                );
              },
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
            switch (route) {
              case '/accounts':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountsScreen(),
                  ),
                );
                break;
              case '/profile':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: user),
                  ),
                );
                break;
              default:
                Navigator.pushNamed(context, route);
            }
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

// Профиль пользователя
class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 16),
            Text('ФИО: ${user.firstName} ${user.lastName}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Телефон: ${user.phoneNumber}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Тип: ${user.userType == 'individual' ? 'Физ. лицо' : 'Юр. лицо'}',
                style: const TextStyle(fontSize: 18)),
            if (user.historyType != null) ...[
              const SizedBox(height: 8),
              Text('Категория: ${user.historyType}',
                  style: const TextStyle(fontSize: 18)),
            ],
            const SizedBox(height: 24),
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
              arguments: user,
            ),
            const SizedBox(height: 24),
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
              arguments: user,
            ),
            _buildSettingTile(
              context,
              Icons.phone,
              'Изменить телефон',
              '/edit-phone',
              arguments: user,
            ),
            _buildSettingTile(
              context,
              Icons.settings,
              'Настройки',
              '/settings',
              arguments: user,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    IconData icon,
    String text,
    String route, {
    Object? arguments,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, route, arguments: arguments),
    );
  }
}

// Настройки
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

// Счета и вклады
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  Future<List<Account>> _accountsFuture = Future.value([]);
  bool _isLoading = true;
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.currentUser != null) {
      _userId = userProvider.currentUser!.userId;
      _loadAccounts();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAccounts() async {
    try {
      _accountsFuture = ApiService.getUserAccounts(_userId!);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки счетов: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createNewAccount(int accountType) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await ApiService.createAccount(_userId!, accountType);
      await _loadAccounts();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Счет успешно создан')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка создания счета: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Счета и вклады'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Создать новый счет'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => _createNewAccount(1),
                        child: const Text('Создать счет'),
                      ),
                      ElevatedButton(
                        onPressed: () => _createNewAccount(2),
                        child: const Text('Создать вклад'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Account>>(
              future: _accountsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Счета не найдены'));
                }

                final accounts = snapshot.data!;
                return ListView.builder(
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final account = accounts[index];
                    return ListTile(
                      title: Text(account.typeName ?? 'Неизвестный тип'),
                      subtitle: Text(
                        account.accountNumber != null && account.accountNumber.length >= 4
                          ? '••••${account.accountNumber.substring(account.accountNumber.length - 4)}'
                          : 'Номер счета неизвестен',
                      ),
                      trailing: Text('${account.balance.toStringAsFixed(2)}'),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/account-details',
                          arguments: account,
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}

// Детали счета
class AccountDetailsScreen extends StatefulWidget {
  final Account account;

  const AccountDetailsScreen({super.key, required this.account}); // Исправленный конструктор

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  Account? _account;
  final _amountController = TextEditingController();
  bool _isProcessing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final account = ModalRoute.of(context)?.settings.arguments as Account?;
    if (account != null) {
      _account = account;
    }
  }

  Future<void> _depositToAccount() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректную сумму')),
      );
            return;
    }
    try {
      setState(() {
        _isProcessing = true;
      });
      await ApiService.depositToAccount(_account!.accountId, amount);
      setState(() {
        _account = Account(
          accountId: _account!.accountId,
          accountNumber: _account!.accountNumber,
          userId: _account!.userId,
          typeId: _account!.typeId,
          balance: _account!.balance + amount,
          openingDate: _account!.openingDate,
          isActive: _account!.isActive,
          typeName: _account!.typeName,
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Счет успешно пополнен на ${amount.toStringAsFixed(2)} ₽')),
      );
      _amountController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка пополнения счета: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _closeAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Закрытие счета'),
        content: const Text('Вы уверены, что хотите закрыть этот счет?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Закрыть', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      setState(() {
        _isProcessing = true;
      });
      await ApiService.closeAccount(_account!.accountId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Счет успешно закрыт')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка закрытия счета: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_account == null) {
      return const Scaffold(
        body: Center(child: Text('Данные счета не найдены')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_account!.typeName ?? 'Неизвестный тип'),
        actions: [
          if (_account!.isActive)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _closeAccount,
              tooltip: 'Закрыть счет',
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Баланс',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_account!.balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Номер счета',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      _account!.accountNumber,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Дата открытия',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd.MM.yyyy').format(_account!.openingDate),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Статус: ${_account!.isActive ? 'Активен' : 'Закрыт'}',
                            style: TextStyle(
                              color: _account!.isActive ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_account!.isActive) ...[
                    const Text(
                      'Пополнение счета',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Сумма пополнения',
                        prefixText: '₽ ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _depositToAccount,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Пополнить счет'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

// Перевод денег
class MoneyTransferScreen extends StatefulWidget {
  const MoneyTransferScreen({super.key});

  @override
  _MoneyTransferScreenState createState() => _MoneyTransferScreenState();
}

class _MoneyTransferScreenState extends State<MoneyTransferScreen> {
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  Future<List<Account>> _accountsFuture = Future.value([]);
  int? _selectedAccountId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _accountsFuture = ApiService.getUserAccounts(user.userId);
    } else {
      _accountsFuture = Future.value([]);
    }
  }

  void _confirmTransfer() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите сумму')));
      return;
    }
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Введите номер телефона')));
      return;
    }
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Выберите счет для списания')));
      return;
    }
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Некорректная сумма')));
      return;
    }
    try {
      await ApiService.transferByPhone(
        _selectedAccountId!,
        _phoneController.text,
        amount,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Перевод $amount₽ выполнен')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка перевода: $e')),
      );
    }
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
              'Счет списания',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            FutureBuilder<List<Account>>(
              future: _accountsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Ошибка: ${snapshot.error}');
                }                 else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Счета не найдены');
                }

                final accounts = snapshot.data!;
                return DropdownButtonFormField<int>(
                  value: _selectedAccountId,
                  items: accounts.map((account) {
                    return DropdownMenuItem<int>(
                      value: account.accountId,
                      child: Text('${account.typeName} (••••${account.accountNumber.substring(account.accountNumber.length - 4)})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountId = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Телефон получателя',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+7 XXX XXX-XX-XX',
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

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}

// История транзакций
class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  Future<List<TransactionWithDirection>>? _transactionsWithDirectionFuture;
  int? _userId;
  List<Account> _userAccounts = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _userId = user.userId;
      _loadAccountsAndTransactions();
    }
  }

  Future<void> _loadAccountsAndTransactions() async {
    if (_userId == null) return;

    try {
      // Загружаем счета
      _userAccounts = await ApiService.getUserAccounts(_userId!);
      final userAccountIds = _userAccounts.map((a) => a.accountId).toSet();

      // Загружаем транзакции
      final transactions = await ApiService.getUserTransactions(_userId!);

      // Формируем список с флагом isOutgoing
      final decoratedTransactions = transactions.map((tr) {
        final isOutgoing = userAccountIds.contains(tr.fromAccountId);
        return TransactionWithDirection(transaction: tr, isOutgoing: isOutgoing);
      }).toList();

      setState(() {
        _transactionsWithDirectionFuture = Future.value(decoratedTransactions);
      });
    } catch (e) {
      setState(() {
        _transactionsWithDirectionFuture = Future.error(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История транзакций')),
      body: FutureBuilder<List<TransactionWithDirection>>(
        future: _transactionsWithDirectionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Транзакции не найдены'));
          }

          final transactionsWithDirection = snapshot.data!;
          return ListView.builder(
            itemCount: transactionsWithDirection.length,
            itemBuilder: (context, index) {
              final trWithDir = transactionsWithDirection[index];
              return TransactionCard(
                transaction: trWithDir.transaction,
                isOutgoing: trWithDir.isOutgoing,
              );
            },
          );
        },
      ),
    );
  }
}


class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final bool isOutgoing; // true если расход

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.isOutgoing,
  });

  @override
  Widget build(BuildContext context) {
    final color = isOutgoing ? Colors.red : Colors.green;
    final icon = isOutgoing ? Icons.arrow_upward : Icons.arrow_downward;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(transaction.categoryName ?? 'Неизвестованная категория'),
        subtitle: Text(
          transaction.transactionDate != null
              ? '${transaction.transactionDate.day}.${transaction.transactionDate.month}.${transaction.transactionDate.year}'
              : 'Неизвестная дата',
        ),
        trailing: Text(
          '${isOutgoing ? '-' : '+'}${transaction.amount.toStringAsFixed(2)}${transaction.isBonusPayment ? ' бонусов' : ''}',
          style: TextStyle(
            color: color,
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


class TransactionWithDirection {
  final Transaction transaction;
  final bool isOutgoing;

  TransactionWithDirection({
    required this.transaction,
    required this.isOutgoing,
  });
}

// Кэшбэк
class CashbackScreen extends StatefulWidget {
  const CashbackScreen({super.key});

  @override
  State<CashbackScreen> createState() => _CashbackScreenState();
}

class _CashbackScreenState extends State<CashbackScreen> {
  Future<User>? _userFuture;
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _userId = user.userId;
      _userFuture = Future.value(user);
    } else {
      _userFuture = Future.error("User data not provided");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Получить кэшбэк')),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Данные не найдены'));
          }

          final user = snapshot.data!;
          return Padding(
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
                          '${user.bonusBalance.toStringAsFixed(2)} бонусов',
                          style: const TextStyle(fontSize: 28, color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/flights');
                    },
                    icon: const Icon(Icons.airplanemode_active),
                    label: const Text('Потратить на авиабилеты'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Поддержка клиентов
class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({super.key});

  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final _messageController = TextEditingController();
  Future<List<SupportTicket>> _ticketsFuture = Future.value([]);
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _userId = user.userId;
      if (_userId != null) {
        _ticketsFuture = ApiService.getUserTickets(_userId!);
      } else {
        _ticketsFuture = Future.value([]);
      }
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    try {
      await ApiService.createSupportTicket(
        _userId!,
        'Новый запрос',
        _messageController.text,
      );
      setState(() {
        _messageController.clear();
        _ticketsFuture = ApiService.getUserTickets(_userId!);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки сообщения: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поддержка клиентов')),
      body: FutureBuilder<List<SupportTicket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final tickets = snapshot.data ?? [];
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return SupportTicketCard(ticket: ticket);
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({Key? key}) : super(key: key);

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<SupportMessage> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await ApiService.getSupportChat();
      setState(() {
        _messages = messages;
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки сообщений: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(SupportMessage(
        messageId: 0,
        userId: 0,
        employeeId: 0,
        messageText: text,
        sendTime: DateTime.now(),
        senderType: 'user',
      ));
      _controller.clear();
    });
    _scrollToBottom();

    try {
      await ApiService.sendSupportMessage(text);
      await _loadMessages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки сообщения: $e')),
      );
    }
  }

  Widget _buildMessage(SupportMessage message) {
    final isUser = message.senderType == 'user';
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser ? Colors.blue[200] : Colors.grey[300];
    final radius = isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          );

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: radius,
        ),
        child: Text(message.messageText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поддержка')),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessage(_messages[index]);
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Введите сообщение',
                        border: OutlineInputBorder(),
                      ),
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SupportTicketCard extends StatelessWidget {
  final SupportTicket ticket;

  const SupportTicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ticket.subject,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(ticket.messageText),
            if (ticket.replyText != null) ...[
              const SizedBox(height: 16),
              Text(
                'Ответ поддержки:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(ticket.replyText!),
            ],
            const SizedBox(height: 8),
            Text(
              ticket.createdAt != null
                  ? dateFormat.format(ticket.createdAt!)
                  : 'Неизвестная дата',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}


// Авиабилеты
class FlightsScreen extends StatefulWidget {
  const FlightsScreen({super.key});

  @override
  State<FlightsScreen> createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  Future<List<AirTicket>> _flightsFuture = Future.value([]);
  Future<User>? _userFuture;
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _userId = user.userId;
      _flightsFuture = ApiService.getFlights();
      _userFuture = Future.value(user);
    }
  }

  void _bookFlight(AirTicket ticket) {
    Navigator.pushNamed(
      context,
      '/flight-booking',
      arguments: {'ticket': ticket, 'userId': _userId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Авиабилеты')),
      body: FutureBuilder<List<AirTicket>>(
        future: _flightsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Авиабилеты не найдены'));
          }

          final flights = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: flights.length,
            itemBuilder: (context, index) {
              final ticket = flights[index];
              return FlightCard(ticket: ticket, onTap: () => _bookFlight(ticket));
            },
          );
        },
      ),
    );
  }
}

class FlightCard extends StatelessWidget {
  final AirTicket ticket;
  final VoidCallback onTap;

  const FlightCard({super.key, required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticket.departureCity,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.arrow_forward, size: 20),
                  Text(
                    ticket.arrivalCity,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Вылет: ${ticket.departureTime != null ? timeFormat.format(ticket.departureTime!) : 'Неизвестное время'}'),
                  Text('Прилет: ${ticket.arrivalTime != null ? timeFormat.format(ticket.arrivalTime!) : 'Неизвестное время'}'),
                ],
              ),
              const SizedBox(height: 8),
              Text('Авиакомпания: ${ticket.airline ?? 'Неизвестная авиакомпания'}'),
              const SizedBox(height: 8),
              Text(
                'Цена: ${ticket.price.toStringAsFixed(2)} руб.',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class FlightBookingScreen extends StatefulWidget {
  const FlightBookingScreen({super.key});

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen> {
  final _bonusController = TextEditingController();
  late AirTicket _ticket;
  Future<List<Account>> _accountsFuture = Future.value([]);
  int? _selectedAccountId;
  int? _userId;
  double _cashAmount = 0;
  double _bonusAmount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _ticket = args['ticket'] as AirTicket;
      _userId = args['userId'] as int;
      _accountsFuture = ApiService.getUserAccounts(_userId!);

      // Инициализируем значения
      _bonusAmount = _ticket.price * 0.5;
      _cashAmount = _ticket.price - _bonusAmount;
      _bonusController.text = _bonusAmount.toStringAsFixed(2);
    }
  }

  void _updateAmounts() {
    final bonus = double.tryParse(_bonusController.text) ?? 0;
    if (bonus > _ticket.price * 0.5) {
      _bonusController.text = (_ticket.price * 0.5).toStringAsFixed(2);
      _bonusAmount = _ticket.price * 0.5;
    } else {
      _bonusAmount = bonus;
    }
    _cashAmount = _ticket.price - _bonusAmount;
    setState(() {});
  }

  void _bookFlight() async {
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите счет для оплаты')),
      );
      return;
    }
    try {
      await ApiService.bookFlight(
        _ticket.ticketId,
        _selectedAccountId!,
        _bonusAmount,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Билет успешно куплен!')),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка покупки билета: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Оформление билета')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_ticket.departureCity} → ${_ticket.arrivalCity}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Вылет: ${_ticket.departureTime != null ? dateFormat.format(_ticket.departureTime!) : 'Неизвестная дата'}'),
            Text('Прилет: ${_ticket.arrivalTime != null ? dateFormat.format(_ticket.arrivalTime!) : 'Неизвестная дата'}'),
            Text('Авиакомпания: ${_ticket.airline ?? 'Неизвестная авиакомпания'}'),
            const SizedBox(height: 20),
            const Text(
              'Оплата бонусами',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _bonusController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: 'бонусов',
                hintText: 'Макс. ${(_ticket.price * 0.5).toStringAsFixed(2)}',
              ),
              onChanged: (value) => _updateAmounts(),
            ),
            const SizedBox(height: 10),
            Text(
              'К оплате деньгами: ${_cashAmount.toStringAsFixed(2)} руб.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Счет для оплаты',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<List<Account>>(
              future: _accountsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return DropdownButton<int>(
                  value: _selectedAccountId,
                  items: snapshot.data?.map((account) {
                    return DropdownMenuItem<int>(
                      value: account.accountId,
                      child: Text(
                        '${account.typeName ?? 'Неизвестный тип'} (${account.balance.toStringAsFixed(2)})',
                      ),
                    );
                  }).toList() ?? [],
                  onChanged: (value) => setState(() => _selectedAccountId = value),
                );
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _bookFlight,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Подтвердить покупку'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Неизвестная дата';
    }
    final dateFormat = DateFormat('dd.MM.yyyy');
    return dateFormat.format(date);
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return 'Неизвестное время';
    }
    final timeFormat = DateFormat('HH:mm');
    return timeFormat.format(time);
  }

  @override
  void dispose() {
    _bonusController.dispose();
    super.dispose();
  }
}

class EmployeeSupportScreen extends StatefulWidget {
  const EmployeeSupportScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeSupportScreen> createState() => _EmployeeSupportScreenState();
}

class _EmployeeSupportScreenState extends State<EmployeeSupportScreen> {
  late Future<List<SupportTicket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  void _loadTickets() {
    _ticketsFuture = ApiService.getAllTickets(); // Нужно реализовать метод в ApiService
  }

  void _openTicket(SupportTicket ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeTicketDetailScreen(ticket: ticket),
      ),
    ).then((_) {
      // Обновить список после возврата
      setState(() {
        _loadTickets();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поддержка клиентов')),
      body: FutureBuilder<List<SupportTicket>>(
        future: _ticketsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          final tickets = snapshot.data ?? [];
          if (tickets.isEmpty) {
            return const Center(child: Text('Нет тикетов'));
          }
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return ListTile(
                title: Text(ticket.subject),
                subtitle: Text(
                  'От: ${ticket.firstName ?? ''} ${ticket.lastName ?? ''}\n${ticket.messageText}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Icon(
                  ticket.isAnswered ? Icons.check_circle : Icons.pending,
                  color: ticket.isAnswered ? Colors.green : Colors.orange,
                ),
                onTap: () => _openTicket(ticket),
              );
            },
          );
        },
      ),
    );
  }
}

class EmployeeTicketDetailScreen extends StatefulWidget {
  final SupportTicket ticket;

  const EmployeeTicketDetailScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  State<EmployeeTicketDetailScreen> createState() => _EmployeeTicketDetailScreenState();
}

class _EmployeeTicketDetailScreenState extends State<EmployeeTicketDetailScreen> {
  late TextEditingController _subjectController;
  late TextEditingController _replyController;
  bool _isAnswered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.ticket.subject);
    _replyController = TextEditingController(text: widget.ticket.replyText ?? '');
    _isAnswered = widget.ticket.isAnswered;
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.replyToTicket(
        widget.ticket.ticketId,
        _replyController.text,
      );
      // Обновляем тему и статус тикета через API (нужно реализовать)
      await ApiService.updateTicketSubjectAndStatus(
        widget.ticket.ticketId,
        _subjectController.text,
        _replyController.text.isNotEmpty,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Изменения сохранены')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Детали тикета')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(labelText: 'Тема'),
                  ),
                  const SizedBox(height: 16),
                  Text('Сообщение клиента:'),
                  Text(widget.ticket.messageText),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _replyController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Ответ поддержки',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAnswered,
                        onChanged: (val) {
                          setState(() {
                            _isAnswered = val ?? false;
                          });
                        },
                      ),
                      const Text('Тикет обработан'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveChanges,
                    child: const Text('Сохранить'),
                  ),
                ],
              ),
            ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Future<List<UserActivity>>? _userActivityFuture;
  Future<List<SupportTicket>>? _allTicketsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    _userActivityFuture = ApiService.getUserActivity();
    _allTicketsFuture = ApiService.getAllTickets();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Администратор'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Активность пользователей'),
            Tab(text: 'Чаты поддержки'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserActivityTab(),
          _buildSupportChatsTab(),
        ],
      ),
    );
  }

  Widget _buildUserActivityTab() {
    return FutureBuilder<List<UserActivity>>(
      future: _userActivityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки активности: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Активность не найдена'));
        }

        final activities = snapshot.data!;
        return ListView.separated(
          itemCount: activities.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return ListTile(
              title: Text('${activity.firstName} ${activity.lastName}'),
              subtitle: Text('Всего транзакций: ${activity.totalTransactions}, Баланс: ${activity.totalBalance.toStringAsFixed(2)}'),
              trailing: Text('Кэшбэк: ${activity.bonusBalance.toStringAsFixed(2)}'),
              onTap: () {
                // Можно добавить детали активности, если нужно
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSupportChatsTab() {
    return FutureBuilder<List<SupportTicket>>(
      future: _allTicketsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Ошибка загрузки тикетов: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Тикеты не найдены'));
        }

        final tickets = snapshot.data!;
        return ListView.separated(
          itemCount: tickets.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return ListTile(
              title: Text(ticket.subject),
              subtitle: Text('От: ${ticket.firstName ?? ''} ${ticket.lastName ?? ''}\n${ticket.messageText}'),
              trailing: Icon(
                ticket.isAnswered ? Icons.check_circle : Icons.pending,
                color: ticket.isAnswered ? Colors.green : Colors.orange,
              ),
              onTap: () {
                // Открыть детали тикета (можно переиспользовать EmployeeTicketDetailScreen)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EmployeeTicketDetailScreen(ticket: ticket),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Внутренний перевод
class InternalTransferScreen extends StatefulWidget {
  const InternalTransferScreen({super.key});

  @override
  State<InternalTransferScreen> createState() => _InternalTransferScreenState();
}

class _InternalTransferScreenState extends State<InternalTransferScreen> {
  final _amountController = TextEditingController();
  Future<List<Account>> _accountsFuture = Future.value([]);
  int? _fromAccountId;
  int? _toAccountId;
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _userId = user.userId;
      if (_userId != null) {
        _accountsFuture = ApiService.getUserAccounts(_userId!);
      } else {
        _accountsFuture = Future.value([]);
      }
    }
  }

  void _submitTransfer() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите сумму')));
      return;
    }
    if (_fromAccountId == null || _toAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Выберите счета')));
      return;
    }
    if (_fromAccountId == _toAccountId) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Нельзя перевести на тот же счет')));
      return;
    }
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Некорректная сумма')));
      return;
    }
    try {
      await ApiService.transfer(_fromAccountId!, _toAccountId!, amount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Перевод $amount выполнен')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка перевода: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Перевод между счетами')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<Account>>(
          future: _accountsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Ошибка: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Счета не найдены'));
            }

            final accounts = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'С какого счёта',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _fromAccountId,
                  items: accounts.map((account) {
                    return DropdownMenuItem<int>(
                      value: account.accountId,
                      child: Text(
                          '${account.typeName} (••••${account.accountNumber.substring(account.accountNumber.length - 4)})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _fromAccountId = value;
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
                DropdownButtonFormField<int>(
                  value: _toAccountId,
                  items: accounts.map((account) {
                    return DropdownMenuItem<int>(
                      value: account.accountId,
                      child: Text(
                          '${account.typeName} (••••${account.accountNumber.substring(account.accountNumber.length - 4)})'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _toAccountId = value;
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
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}

// Уведомления
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Future<List<Transaction>> _transactionsFuture = Future.value([]);
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _userId = user.userId;
      if (_userId != null) {
        _transactionsFuture = ApiService.getUserTransactions(_userId!);
      } else {
        _transactionsFuture = Future.value([]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Уведомления')),
      body: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет уведомлений'));
          }

          final transactions = snapshot.data!
              .where((t) => t.amount.abs() > 10000 || t.typeId == 6)
              .toList();

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return NotificationCard(transaction: transaction);
            },
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final Transaction transaction;

  const NotificationCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: transaction.amount > 0
                ? Colors.green[100]
                : Colors.red[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            transaction.amount > 0
                ? Icons.notifications_active
                : Icons.warning,
            color: transaction.amount > 0 ? Colors.green : Colors.red,
          ),
        ),
        title: Text(transaction.typeName ?? 'Неизвестованный тип'),
        subtitle: Text(
          transaction.transactionDate != null
            ? '${transaction.transactionDate.day}.${transaction.transactionDate.month}.${transaction.transactionDate.year}'
            : 'Неизвестная дата',
        ),
        trailing: Text(
          '${transaction.amount > 0 ? '+' : ''}${transaction.amount.toStringAsFixed(2)}${transaction.isBonusPayment ? ' бонусов' : ''}', // убрал currency
          style: TextStyle(
            color: transaction.amount > 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Сменить пароль
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _userId = user.userId;
    }
  }

  void _changePassword() async {
    if (_oldController.text.isEmpty ||
        _newController.text.isEmpty ||
        _confirmController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заполните все поля')));
      return;
    }
    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пароли не совпадают')));
      return;
    }
    try {
      await ApiService.changePassword(
          _userId!, _oldController.text, _newController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пароль успешно изменён')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка изменения пароля: $e')),
      );
    }
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
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Подтвердите новый пароль',
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
    _confirmController.dispose();
    super.dispose();
  }
}

// Изменить имя
class EditNameScreen extends StatefulWidget {
  const EditNameScreen({super.key});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _userId = user.userId;
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
    }
  }

  void _saveName() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите корректное имя')));
      return;
    }
    try {
      await ApiService.updateUserName(
          _userId!, _firstNameController.text, _lastNameController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Имя изменено на "${_firstNameController.text} ${_lastNameController.text}"')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка изменения имени: $e')),
      );
    }
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
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'Имя',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Фамилия',
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }
}

// Изменить телефон
class EditPhoneScreen extends StatefulWidget {
  const EditPhoneScreen({super.key});

  @override
  State<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  int? _userId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _userId = user.userId;
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  void _savePhone() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Введите номер телефона')));
      return;
    }
    try {
      await ApiService.updateUserPhone(_userId!, _phoneController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Телефон изменён на ${_phoneController.text}')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка изменения телефона: $e')),
      );
    }
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

