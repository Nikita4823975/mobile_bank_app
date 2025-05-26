import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple iOS App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Тестовый экран'),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
