// ================== IMPORT LIBRARIES ==================
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lab10_053/models/BookModel.dart';
import 'package:http/http.dart' as http;
import 'package:lab10_053/page/add_product.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ================== STATEFUL WIDGET ==================

class Showproducts extends StatefulWidget {
  const Showproducts({super.key});

  @override
  State<Showproducts> createState() => _ShowproductsState();
}

// ================== STATE CLASS ==================

class _ShowproductsState extends State<Showproducts> {
  List<BookModel> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getList();
  }

  // ================== LOGOUT ==================

 Future<void> _logout() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    // 🔥 ใช้เซิร์ฟเวอร์เดียวกับ login
    final url = Uri.parse("http://10.0.2.2:3000/api/auth/logout");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    // ถ้า logout สำเร็จ
    if (response.statusCode == 200) {
      prefs.remove("token");
    }

    // ไปหน้า login
    Navigator.pushReplacementNamed(context, '/login');
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Logout Error: $e")),
    );
  }
}

  // ================== BUILD UI ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายการหนังสือ',
          style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF020A06),
        foregroundColor: const Color.fromARGB(255, 255, 81, 0),
        elevation: 0,

        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF020A06), Color(0xFF04130C), Color(0xFF020A06)],
          ),
        ),
        child: RefreshIndicator(
          color: const Color.fromARGB(255, 255, 81, 0),
          backgroundColor: const Color(0xFF020A06),
          onRefresh: getList,
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00FF88)),
                )
              : books.isEmpty
              ? _buildNoDataView()
              : _buildBookList(),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductpage()),
          ).then((value) => getList());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ================== NO DATA ==================

  Widget _buildNoDataView() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.4),
        const Center(
          child: Text(
            'NO DATA FOUND',
            style: TextStyle(color: Color(0xFF00FF88), letterSpacing: 1.5),
          ),
        ),
      ],
    );
  }

  // ================== BOOK LIST ==================

  Widget _buildBookList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF04110A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromARGB(255, 255, 115, 0).withOpacity(0.5),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),

            leading: const CircleAvatar(
              backgroundColor: Color(0xFF020A06),
              child: Icon(
                Icons.menu_book_rounded,
                color: Color.fromARGB(255, 255, 145, 0),
              ),
            ),

            title: Text(
              book.title,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 224, 156),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'ผู้เขียน: ${book.author}\n'
                'ปีที่พิมพ์: ${book.publishedYear}',
                style: const TextStyle(
                  color: Color.fromARGB(255, 255, 240, 102),
                  fontSize: 13,
                ),
              ),
            ),

            // ✅ ปุ่มถังขยะ
            trailing: IconButton(
              onPressed: () {
                _showDeleteDialog(book.id);
              },
              icon: const Icon(Icons.delete_forever, color: Colors.red),
            ),

            isThreeLine: true,
          ),
        );
      },
    );
  }

  // ================== DELETE DIALOG ==================

  Future<void> _showDeleteDialog(int id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Product Confirmation'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteBook(id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // ================== DELETE API ==================

  Future<void> deleteBook(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) return;

      final url = Uri.parse('http://10.0.2.2:3000/api/books/$id');

      final response = await http.delete(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ลบสำเร็จ')));

        getList();
      } else {
        throw Exception('Delete failed: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ================== GET LIST API ==================

  Future<void> getList() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      final url = Uri.parse('http://10.0.2.2:3000/api/books');

      final response = await http.get(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List list = decoded is List ? decoded : decoded['payload'] ?? [];

        setState(() {
          books = list
              .map<BookModel>((json) => BookModel.fromJson(json))
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() => isLoading = false);
    }
  }
}
