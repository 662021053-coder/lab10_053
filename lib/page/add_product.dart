import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddProductpage extends StatefulWidget {
  const AddProductpage({super.key});

  @override
  State<AddProductpage> createState() => _AddProductpageState();
}

class _AddProductpageState extends State<AddProductpage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _publishedYearController =
      TextEditingController();

  final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  Future<void> addProductpage() async {
    SharedPreferences prefs = await _prefs;

    String? token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token not found')),
      );
      return;
    }

    var data = jsonEncode({
  "title": _titleController.text,
  "author": _authorController.text,
  "published_year": int.tryParse(_publishedYearController.text) ?? 0,
  });

    var url =
        Uri.parse('http://10.0.2.2:3000/api/books');

    var response = await http.post(
      url,
      body: data,
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    debugPrint('response status: ${response.statusCode}');
    debugPrint('response body: ${response.body}');

    if (response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add book')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B16),
      appBar: AppBar(
        title: const Text(
          'เพิ่มหนังสือ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF020A06),
        foregroundColor: const Color(0xFFFF5100),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  style:
                      const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.book,
                        color: Color(0xFFFF5100)),
                    labelText: 'ชื่อหนังสือ',
                    labelStyle: TextStyle(
                        color: Color(0xFFFF5100)),
                    filled: true,
                    fillColor: Color(0xFF1A2A22),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _authorController,
                  style:
                      const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person,
                        color: Color(0xFFFF5100)),
                    labelText: 'ผู้แต่ง',
                    labelStyle: TextStyle(
                        color: Color(0xFFFF5100)),
                    filled: true,
                    fillColor: Color(0xFF1A2A22),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller:
                      _publishedYearController,
                  keyboardType:
                      TextInputType.number,
                  style:
                      const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                        Icons.calendar_today,
                        color: Color(0xFFFF5100)),
                    labelText: 'ปีที่พิมพ์',
                    labelStyle: TextStyle(
                        color: Color(0xFFFF5100)),
                    filled: true,
                    fillColor: Color(0xFF1A2A22),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFF5100),
                    ),
                    onPressed: () {
                      addProductpage();
                    },
                    icon: const Icon(Icons.add,
                        color: Colors.white),
                    label: const Text(
                      'เพิ่มหนังสือ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                        color: Colors.white,
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