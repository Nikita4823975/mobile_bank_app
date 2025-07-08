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
            if (user.businessCategory != null) ...[
              const SizedBox(height: 8),
              Text('Категория: ${user.businessCategory}',
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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final accounts = await ApiService.getUserAccounts(user.userId);
      setState(() => _accountsFuture = Future.value(accounts));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки счетов: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createNewAccount(int accountType) async {
    try {
      setState(() {
        _isLoading = true;
      });
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.currentUser!;
      await ApiService.createAccount(user.userId, accountType);
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


  void _showCreateAccountDialog() {
    int selectedType = 1;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Открыть новый счет'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Выберите тип счета:'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<int>(
                    value: selectedType,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Текущий счет (Рубли)'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('Сберегательный счет (Рубли)'),
                      ),
                      DropdownMenuItem(
                        value: 3,
                        child: Text('Депозит (Рубли)'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedType = value!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _createNewAccount(selectedType);
                  },
                  child: const Text('Создать'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAccountCard(Account account) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/account-details',
            arguments: account,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    account.typeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text(
                      account.isActive ? 'Активен' : 'Неактивен',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: account.isActive
                        ? Colors.green
                        : Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Номер: •••• ${account.accountNumber.substring(account.accountNumber.length - 4)}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Text(
                '${account.balance.toStringAsFixed(2)} ${account.currency}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Открыт: ${DateFormat('dd.MM.yyyy').format(account.openingDate)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Счета и вклады'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateAccountDialog,
            tooltip: 'Добавить счет',
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
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('У вас пока нет счетов'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _showCreateAccountDialog,
                          child: const Text('Открыть первый счет'),
                        ),
                      ],
                    ),
                  );
                }
                final accounts = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _loadAccounts,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ...accounts.map(_buildAccountCard),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _showCreateAccountDialog,
                          child: const Text('Открыть новый счет'),
                        ),
                      ],
                    ),
                  ),
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
          currency: _account!.currency,
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
        title: Text(_account!.typeName),
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
                            '${_account!.balance.toStringAsFixed(2)} ${_account!.currency}',
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
      body: FutureBuilder<List<Transaction>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Транзакции не найдены'));
          }

          final transactions = snapshot.data!;
          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return TransactionCard(transaction: transaction);
            },
          );
        },
      ),
    );
  }
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
        title: Text(transaction.typeName),
        subtitle: Text(
          '${transaction.transactionDate.day}.${transaction.transactionDate.month}.${transaction.transactionDate.year} - ${transaction.categoryName ?? ''}',
        ),
        trailing: Text(
          '${transaction.amount > 0 ? '+' : ''}${transaction.amount.toStringAsFixed(2)}${transaction.isBonusPayment ? ' бонусов' : ' ${transaction.currency}'}',
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

class SupportTicketCard extends StatelessWidget {
  final SupportTicket ticket;

  const SupportTicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
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
              '${ticket.createdAt.day}.${ticket.createdAt.month}.${ticket.createdAt.year}',
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
                  Text('Вылет: ${_formatTime(ticket.departureTime)}'),
                  Text('Прилет: ${_formatTime(ticket.arrivalTime)}'),
                ],
              ),
              const SizedBox(height: 8),
              Text('Авиакомпания: ${ticket.airline}'),
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
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
      _bonusAmount = bonus;     }
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
      Navigator.popUntil(context, ModalRoute.withName('/main'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка покупки билета: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Вылет: ${_formatDate(_ticket.departureTime)}'),
            Text('Прилет: ${_formatDate(_ticket.arrivalTime)}'),
            Text('Авиакомпания: ${_ticket.airline}'),
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
                      child: Text('${account.typeName} (${account.balance.toStringAsFixed(2)} ${account.currency})'),
                    );
                  }).toList(),
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

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _bonusController.dispose();
    super.dispose();
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
        title: Text(
          transaction.typeName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.transactionDate.day}.${transaction.transactionDate.month}.${transaction.transactionDate.year}',
        ),
        trailing: Text(
          '${transaction.amount > 0 ? '+' : ''}${transaction.amount.toStringAsFixed(2)}${transaction.isBonusPayment ? ' бонусов' : ' ${transaction.currency}'}',
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
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
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
      _phoneController.text = user.phoneNumber;
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

