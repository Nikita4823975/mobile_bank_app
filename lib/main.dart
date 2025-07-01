import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Banking App Prototype',
      home: PhoneNumberListScreen(),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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