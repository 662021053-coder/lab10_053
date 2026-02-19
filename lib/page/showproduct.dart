// ================== IMPORT LIBRARIES ==================

// ใช้สำหรับ HttpHeaders เช่น Authorization
import 'dart:io';

// ใช้สำหรับแปลง JSON (jsonDecode / jsonEncode)
import 'dart:convert';

// เรียกใช้ Widget พื้นฐานของ Flutter
import 'package:flutter/material.dart';

// เรียกใช้โมเดล BookModel (ตรวจสอบตัวพิมพ์เล็ก/ใหญ่ให้ตรงกับไฟล์จริง)
import 'package:lab10_053/models/BookModel.dart';

// ใช้ส่ง HTTP Request ไปยัง API
import 'package:http/http.dart' as http;

// ใช้เก็บข้อมูลในเครื่อง เช่น token login
import 'package:shared_preferences/shared_preferences.dart';


// ================== STATEFUL WIDGET ==================

class Showproducts extends StatefulWidget {
  const Showproducts({super.key});

  @override
  State<Showproducts> createState() => _ShowproductsState();
}


// ================== STATE CLASS ==================

class _ShowproductsState extends State<Showproducts> {

  // เก็บรายการหนังสือทั้งหมด
  List<BookModel> books = [];

  // ใช้ตรวจสอบสถานะกำลังโหลดข้อมูล
  bool isLoading = true;

  // เรียกทำงานทันทีเมื่อหน้าเปิด
  @override
  void initState() {
    super.initState();
    getList(); // โหลดข้อมูลจาก API
  }


  // ================== LOGOUT FUNCTION ==================

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    // ลบข้อมูลทั้งหมดในเครื่อง (เช่น token)
    await prefs.clear();

    // ตรวจสอบว่า widget ยังอยู่ในหน้าจอ
    if (mounted) {
      // กลับไปหน้า Login และไม่สามารถกดย้อนกลับได้
      Navigator.pushReplacementNamed(context, '/login');
    }
  }


  // ================== BUILD UI ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // ---------- APP BAR ----------
      appBar: AppBar(
        title: const Text(
          'BOOK DATABASE',
          style: TextStyle(
            letterSpacing: 2.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF020A06),
        foregroundColor: const Color.fromARGB(255, 255, 81, 0),
        elevation: 0,

        // ปุ่ม Logout ด้านขวา
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          )
        ],
      ),

      // ---------- BODY ----------
      body: Container(

        // ทำพื้นหลังแบบไล่สี Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF020A06),
              Color(0xFF04130C),
              Color(0xFF020A06),
            ],
          ),
        ),

        // ใช้ RefreshIndicator เพื่อดึงลงรีเฟรชได้
        child: RefreshIndicator(
          color: const Color.fromARGB(255, 255, 81, 0),
          backgroundColor: const Color(0xFF020A06),

          // เมื่อดึงลงจะเรียก getList()
          onRefresh: getList,

          // ตรวจสอบสถานะการโหลด
          child: isLoading
              ? const Center(
                  // แสดงวงโหลด
                  child: CircularProgressIndicator(
                    color: Color(0xFF00FF88),
                  ),
                )
              : books.isEmpty
                  ? _buildNoDataView()   // ถ้าไม่มีข้อมูล
                  : _buildBookList(),   // ถ้ามีข้อมูล
        ),
      ),
    );
  }


  // ================== NO DATA VIEW ==================

  Widget _buildNoDataView() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.4),
        const Center(
          child: Text(
            'NO DATA FOUND',
            style: TextStyle(
              color: Color(0xFF00FF88),
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }


  // ================== BOOK LIST VIEW ==================

  Widget _buildBookList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: books.length, // จำนวนหนังสือทั้งหมด

      itemBuilder: (context, index) {
        final book = books[index]; // ดึงข้อมูลแต่ละเล่ม

        return Container(
          margin: const EdgeInsets.only(bottom: 16),

          decoration: BoxDecoration(
            color: const Color(0xFF04110A).withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromARGB(255, 255, 115, 0)
                  .withOpacity(0.5),
            ),
          ),

          child: ListTile(
            contentPadding: const EdgeInsets.all(12),

            // ไอคอนหนังสือ
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF020A06),
              child: Icon(
                Icons.menu_book_rounded,
                color: Color.fromARGB(255, 255, 145, 0),
              ),
            ),

            // ชื่อหนังสือ
            title: Text(
              book.title,
              style: const TextStyle(
                color: Color.fromARGB(255, 255, 224, 156),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            // ผู้เขียน และ ปีที่พิมพ์
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

            isThreeLine: true,
          ),
        );
      },
    );
  }


  // ================== API CALL FUNCTION ==================

  Future<void> getList() async {

    // เริ่มโหลดข้อมูล
    setState(() => isLoading = true);

    try {
      // ดึง token จาก SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // ถ้าไม่มี token ให้กลับหน้า Login
      if (token == null || token.isEmpty) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      // เรียก API (10.0.2.2 = localhost สำหรับ Android Emulator)
      final url = Uri.parse('http://10.0.2.2:3000/api/books');

      final response = await http.get(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      // ถ้าเรียกสำเร็จ
      if (response.statusCode == 200) {

        final decoded = jsonDecode(response.body);

        // ตรวจสอบว่า API ส่ง List ตรง ๆ หรืออยู่ใน payload
        final List list =
            decoded is List ? decoded : decoded['payload'] ?? [];

        setState(() {
          // แปลง JSON เป็น BookModel
          books = list
              .map<BookModel>((json) => BookModel.fromJson(json))
              .toList();

          isLoading = false;
        });

      } else {
        throw Exception('Server Error: ${response.statusCode}');
      }

    } catch (e) {

      // แสดงข้อความแจ้งเตือนเมื่อเกิด Error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() => isLoading = false);
    }
  }
}
