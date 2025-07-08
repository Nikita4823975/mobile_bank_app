import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ApiService {
  // Для эмулятора Android:
  static const String _baseUrl = "http://10.0.2.2:5000/api";

  static Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw Exception('Invalid token');
    final payload = parts[1];
    final padded = payload + '=' * ((4 - payload.length % 4) % 4);
    final decoded = utf8.decode(base64Url.decode(padded));
    return json.decode(decoded);
  }

  // Сохранение и получение токена
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    // Для отладки
    final displayLength = token.length < 20 ? token.length : 20;
    print('Token saved: ${token.substring(0, displayLength)}...');
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      print("❌ Токен не найден");
      throw Exception('Токен не найден');
    }
    print("✅ Токен найден: ${token.substring(0, min(token.length, 20))}...");
    return token;
  }

  static Future<void> closeAccount(int accountId) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/accounts/$accountId/close'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Не удалось закрыть счет: ${response.body}');
    }
  }


  static Future<void> depositToAccount(int? accountId, double amount) async {
    if (accountId == null) {
      throw Exception('Account ID is required');
    }
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/accounts/$accountId/deposit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'amount': amount}),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка пополнения: ${response.statusCode}');
    }
  }

  // Авторизация
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Сохраняем токен в SharedPreferences
      await saveToken(data['token']); // <-- ключевой момент

      return data;
    } else {
      throw Exception('Ошибка авторизации: ${response.statusCode}');
    }
  }

  // Регистрация
  static Future<Map<String, dynamic>> register(
    String phone,
    String password,
    String firstName,
    String lastName,
    String birthDate,
    {String userType = 'individual', int? historyType}
  ) async {
    final Map<String, dynamic> body = {
      'phone': phone,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate,
      'user_type': userType,
    };
    if (userType == 'business' && historyType != null) {
      body['history_type'] = historyType;
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка регистрации: ${response.statusCode} ${response.body}');
    }
  }


  // Получение информации о пользователе
  static Future<User> getUser(int userId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/user/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final dynamic json = jsonDecode(response.body);
        if (json == null || json is! Map<String, dynamic>) {
          throw Exception('Пустой или некорректный ответ сервера');
        }
        return User.fromJson(json);
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUser: $e');
      rethrow;
    }
  }


  // Получение счетов пользователя
  static Future<List<Account>> getUserAccounts(int userId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/user/$userId/accounts'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final dynamic jsonData = jsonDecode(response.body);
      if (jsonData == null || jsonData is! List) {
        return [];
      }
      return jsonData.map<Account>((json) {
        try {
          return Account.fromJson(json);
        } catch (e) {
          print('Ошибка парсинга Account: $e');
          // Возвращаем дефолтный объект или пропускаем
          return Account(
            accountId: 0,
            accountNumber: 'unknown',
            userId: 0,
            typeId: 0,
            balance: 0.0,
            openingDate: DateTime.now(),
            isActive: false,
            typeName: 'unknown',
          );
        }
      }).toList();
    } else {
      throw Exception('Failed to load accounts: ${response.statusCode}');
    }
  }


  // Перевод по номеру телефона
  static Future<void> transferByPhone(
    int? fromAccountId,
    String recipientPhone,
    double amount,
  ) async {
    if (fromAccountId == null) {
      throw Exception('Account ID is required');
    }

    final token = await getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/transfer-by-phone'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'from_account_id': fromAccountId,
        'recipient_phone': recipientPhone,
        'amount': amount,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Ошибка перевода: ${response.statusCode}');
    }
  }

  static DateTime? parseDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  try {
    return DateTime.parse(dateStr);
  } catch (e) {
    print('Ошибка парсинга даты: $dateStr, ошибка: $e');
    return null;
  }
}


  static Future<Account> createAccount(int? userId, int typeId) async {
  if (userId == null) {
    throw Exception('User ID is required');
  }
  final token = await getToken();
  final response = await http.post(
    Uri.parse('$_baseUrl/user/$userId/accounts'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({'type_id': typeId}),
  );
  if (response.statusCode == 201) {
    return Account.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Ошибка создания счета: ${response.statusCode}');
  }
}

  // Получение истории транзакций
  static Future<List<Transaction>> getUserTransactions(int userId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/user/$userId/transactions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final dynamic jsonData = jsonDecode(response.body);
      if (jsonData == null || jsonData is! List) {
        return [];
      }
      return jsonData.map<Transaction>((json) {
        try {
          return Transaction.fromJson(json);
        } catch (e) {
          print('Ошибка парсинга Transaction: $e');
          return Transaction(
            transactionId: 0,
            transactionUuid: '',
            amount: 0.0,
            transactionDate: DateTime.now(),
            typeId: 0,
            isBonusPayment: false,
            // остальные поля null или дефолт
          );
        }
      }).toList();
    } else {
      throw Exception('Failed to load transactions: ${response.statusCode}');
    }
  }


  // Получение доступных авиабилетов
  static Future<List<AirTicket>> getFlights() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/flights'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AirTicket.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка получения авиабилетов');
    }
  }

  // Покупка авиабилета
  static Future<void> bookFlight(
    int? ticketId,
    int? accountId,
    double bonusAmount,
  ) async {
    if (ticketId == null || accountId == null) {
      throw Exception('Ticket ID and Account ID are required');
    }

    final token = await getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/flights/book'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ticket_id': ticketId,
        'account_id': accountId,
        'bonus_amount': bonusAmount,
      }),
    );
    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'Ошибка покупки билета');
    }
  }

  // Создание тикета поддержки
  static Future<void> createSupportTicket(
    int? userId,
    String subject,
    String message,
  ) async {
    if (userId == null) {
      throw Exception('User ID is required');
    }

    final token = await getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/support/tickets'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'subject': subject,
        'message': message,
      }),
    );
    if (response.statusCode != 201) {
      throw Exception('Ошибка создания тикета');
    }
  }

  // Получение тикетов пользователя
  static Future<List<SupportTicket>> getUserTickets(int userId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/support/tickets'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SupportTicket.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load support tickets: ${response.statusCode}');
    }
  }

  static Future<bool> isServerAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 404;
    } catch (e) {
      print('Server check error: $e');
      return false;
    }
  }

    static Future<void> transfer(int fromAccountId, int toAccountId, double amount) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/transfer'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'from_account_id': fromAccountId,
        'to_account_id': toAccountId,
        'amount': amount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка перевода: ${response.statusCode}');
    }
  }

  // Метод для изменения пароля
  static Future<void> changePassword(int userId, String oldPassword, String newPassword) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/user/$userId/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );
    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Ошибка изменения пароля');
    }
  }


  // Метод для обновления имени пользователя
  static Future<void> updateUserName(int userId, String firstName, String lastName) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'first_name': firstName,
        'last_name': lastName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка обновления имени: ${response.statusCode}');
    }
  }

  // Метод для обновления номера телефона пользователя
  static Future<void> updateUserPhone(int userId, String phoneNumber) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse('$_baseUrl/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Ошибка обновления телефона: ${response.statusCode}');
    }
  }

  // Вспомогательная функция для безопасного взятия подстроки
  static int min(int a, int b) => a < b ? a : b;
}
