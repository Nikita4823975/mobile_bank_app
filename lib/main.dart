import 'package:flutter/material.dart';
<<<<<<< HEAD

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
=======
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
>>>>>>> 8a74308 (AAAAAAAHHHHHHHHHHH)

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: 'Simple iOS App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Тестовый экран'),
=======
      title: 'Mobile Banking App Prototype',
      home: PhoneNumberListScreen(),
>>>>>>> 8a74308 (AAAAAAAHHHHHHHHHHH)
    );
  }
}

<<<<<<< HEAD
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
=======
class PhoneNumberListScreen extends StatefulWidget {
  const PhoneNumberListScreen({super.key});

  @override
  _PhoneNumberListScreenState createState() => _PhoneNumberListScreenState();
}

class _PhoneNumberListScreenState extends State<PhoneNumberListScreen> {
  final List<String> _phoneNumbers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPhoneNumbers();
  }

  Future<void> _fetchPhoneNumbers() async {
    try {
      final url = Uri.parse('http://10.0.2.2:5000/api/phone-numbers');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _phoneNumbers.clear();
          _phoneNumbers.addAll(data.map((item) => item['phone_number']));
          _isLoading = false;
        });
      } else {
        throw Exception('Ошибка загрузки данных: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }
>>>>>>> 8a74308 (AAAAAAAHHHHHHHHHHH)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Номер телефона'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Имя'),
            ),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Фамилия'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Здесь можно добавить логику обработки введённых данных
                print('Номер телефона: ${_phoneController.text}');
                print('Пароль: ${_passwordController.text}');
                print('Имя: ${_firstNameController.text}');
                print('Фамилия: ${_lastNameController.text}');
              },
              child: const Text('Отправить'),
            ),
          ],
        ),
      ),
    );
  }
}
=======
      appBar: AppBar(title: Text('Phone Numbers')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _phoneNumbers.isEmpty
              ? Center(child: Text('Нет номеров телефонов'))
              : ListView.builder(
                  itemCount: _phoneNumbers.length,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(_phoneNumbers[index]));
                  },
                ),
    );
  }
}
>>>>>>> 8a74308 (AAAAAAAHHHHHHHHHHH)
