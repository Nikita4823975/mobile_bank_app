import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'main.dart'; // Для доступа к rootScaffoldMessengerKey
import 'main_menu.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Ключ для управления формой
  final _formKey = GlobalKey<FormState>();

  // Контроллеры для полей ввода
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();

  // Состояние UI
  bool _isLoading = false;
  bool _isRegistering = false;

  @override
  void dispose() {
    // Очищаем контроллеры при уничтожении виджета
    _phoneController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  // Основной метод входа
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await ApiService.login(
        _phoneController.text,
        _passwordController.text,
      );
      final user = await _loadUserData(response['user_id'] as int);
      await _navigateToMainMenu(user);
    } catch (e) {
      _showError('Ошибка входа: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Метод регистрации
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ApiService.register(
        _phoneController.text,
        _passwordController.text,
        _firstNameController.text,
        _lastNameController.text,
        _birthDateController.text,
      );

      // Автовход после регистрации
      await _login();
    } catch (e) {
      _showError('Ошибка регистрации: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Загрузка данных пользователя
  Future<User> _loadUserData(int userId) async {
    try {
      return await ApiService.getUser(userId);
    } catch (e) {
      _showError('Ошибка загрузки данных');
      rethrow;
    }
  }

  // Навигация на главный экран
  Future<void> _navigateToMainMenu(User user) async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainMenuScreen(user: user),
      ),
      (route) => false,
    );
  }


  // Показ ошибки
  void _showError(String message) {
    rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  }

  // Переключение между входом и регистрацией
  void _toggleAuthMode() {
    _formKey.currentState?.reset();
    setState(() {
      _isRegistering = !_isRegistering;
    });
  }

  // Валидация телефона
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Введите телефон';
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
      return 'Неверный формат телефона';
    }
    return null;
  }

  // Валидация пароля
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Введите пароль';
    if (value.length < 8) return 'Пароль должен быть ≥8 символов';
    return null;
  }

  // Валидация имени
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Введите имя';
    return null;
  }

  // Построение поля ввода
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Логотип
                const Icon(
                  Icons.airplanemode_active,
                  size: 100,
                  color: Colors.white,
                ),
                const SizedBox(height: 20),

                // Заголовок
                const Text(
                  'Авиа-Банк',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Поля формы
                if (_isRegistering) ...[
                  _buildInputField(
                    controller: _firstNameController,
                    label: 'Имя',
                    icon: Icons.person,
                    validator: _validateName,
                  ),
                  const SizedBox(height: 15),
                  _buildInputField(
                    controller: _lastNameController,
                    label: 'Фамилия',
                    icon: Icons.person_outline,
                    validator: _validateName,
                  ),
                  const SizedBox(height: 15),
                  _buildInputField(
                    controller: _birthDateController,
                    label: 'Дата рождения (ГГГГ-ММ-ДД)',
                    icon: Icons.calendar_today,
                    keyboardType: TextInputType.datetime,
                  ),
                  const SizedBox(height: 15),
                ],

                // Обязательные поля
                _buildInputField(
                  controller: _phoneController,
                  label: 'Телефон',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  controller: _passwordController,
                  label: 'Пароль',
                  icon: Icons.lock,
                  obscureText: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),

                // Кнопка переключения режима
                TextButton(
                  onPressed: _isLoading ? null : _toggleAuthMode,
                  child: Text(
                    _isRegistering
                        ? 'Уже есть аккаунт? Войти'
                        : 'Нет аккаунта? Зарегистрироваться',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                // Основная кнопка
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _isRegistering ? _register : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isRegistering ? 'ЗАРЕГИСТРИРОВАТЬСЯ' : 'ВОЙТИ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
