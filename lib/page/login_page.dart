// ================== IMPORT LIBRARIES ==================

// ใช้สำหรับแปลงข้อมูล JSON เช่น jsonEncode / jsonDecode
import 'dart:convert';

// เรียกใช้ Widget และ UI ของ Flutter
import 'package:flutter/material.dart';

// ใช้สำหรับส่ง HTTP Request ไปยัง API
import 'package:http/http.dart' as http;

// เรียกหน้าแสดงรายการสินค้า หลังจาก Login สำเร็จ
import 'package:lab10_053/page/showproduct.dart';

// ใช้เก็บข้อมูลในเครื่อง เช่น token ที่ได้จากการ login
import 'package:shared_preferences/shared_preferences.dart';


// ================== STATEFUL WIDGET ==================

// สร้างหน้า LoginPage เป็น StatefulWidget
// เพราะต้องมีการเปลี่ยนแปลงข้อมูล เช่น กรอกฟอร์ม และเรียก API
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


// ================== STATE CLASS ==================

class _LoginPageState extends State<LoginPage> {

  // ใช้ควบคุมและตรวจสอบความถูกต้องของ Form
  final _formKey = GlobalKey<FormState>();

  // Controller สำหรับรับค่าชื่อผู้ใช้
  final TextEditingController usernameController = TextEditingController();

  // Controller สำหรับรับค่ารหัสผ่าน
  final TextEditingController passwordController = TextEditingController();


  // ================== BUILD UI ==================

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // กำหนดสีพื้นหลังทั้งหน้า
      backgroundColor: const Color(0xFF121212),

      body: Center(
        child: SingleChildScrollView(
          // ป้องกันหน้าล้นเมื่อคีย์บอร์ดขึ้น
          child: Padding(
            padding: const EdgeInsets.all(24.0),

            child: Container(
              padding: const EdgeInsets.all(24),

              // ตกแต่งกล่อง Login
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),

              child: Form(
                key: _formKey, // เชื่อมกับตัวตรวจสอบฟอร์ม

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // ไอคอนรูปกุญแจ
                    const Icon(
                      Icons.lock_outline,
                      size: 60,
                      color: Color(0xFF1E88E5),
                    ),

                    const SizedBox(height: 10),

                    // หัวข้อหน้า Login
                    const Text(
                      "ระบบเข้าสู่ระบบ",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // ================== ช่องกรอก Username ==================

                    TextFormField(
                      controller: usernameController, // รับค่าชื่อผู้ใช้
                      style: const TextStyle(color: Colors.white),

                      decoration: _darkInput("ชื่อผู้ใช้"),

                      // ตรวจสอบว่ากรอกข้อมูลหรือไม่
                      validator: (value) =>
                          value == null || value.isEmpty
                              ? "กรุณากรอกชื่อผู้ใช้"
                              : null,
                    ),

                    const SizedBox(height: 16),

                    // ================== ช่องกรอก Password ==================

                    TextFormField(
                      controller: passwordController, // รับค่ารหัสผ่าน
                      obscureText: true, // ซ่อนรหัสผ่าน
                      style: const TextStyle(color: Colors.white),

                      decoration: _darkInput("รหัสผ่าน"),

                      validator: (value) =>
                          value == null || value.isEmpty
                              ? "กรุณากรอกรหัสผ่าน"
                              : null,
                    ),

                    const SizedBox(height: 30),

                    // ================== ปุ่มเข้าสู่ระบบ ==================

                    SizedBox(
                      width: double.infinity,
                      height: 50,

                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),

                        // เมื่อกดปุ่ม
                        onTap: () async {

                          // ตรวจสอบว่าฟอร์มถูกต้องหรือไม่
                          if (_formKey.currentState!.validate()) {

                            // เตรียมข้อมูลส่งไป API
                            final jsonData = {
                              "username": usernameController.text,
                              "password": passwordController.text,
                            };

                            // URL สำหรับ login
                            final url = Uri.parse(
                                "http://10.0.2.2:3000/api/auth/login");

                            try {

                              // ส่ง POST Request ไปยัง Server
                              final response = await http.post(
                                url,
                                headers: {
                                  "Content-Type": "application/json"
                                },
                                body: jsonEncode(jsonData),
                              );

                              // ================== ถ้า Login สำเร็จ ==================
                              if (response.statusCode == 200) {

                                // เรียก SharedPreferences
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();

                                // แปลงข้อมูลที่ server ส่งกลับมา
                                var decoded =
                                    jsonDecode(response.body);

                                // บันทึก token ลงในเครื่อง
                                await prefs.setString(
                                    "token",
                                    decoded["accessToken"]);

                                // ไปหน้า Showproducts
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const Showproducts(),
                                  ),
                                );

                                // แสดงข้อความสำเร็จ
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color(0xFF1E1E1E),
                                    content: Text("เข้าสู่ระบบสำเร็จ"),
                                  ),
                                );

                              } else {
                                // ================== ถ้า Login ไม่สำเร็จ ==================
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    backgroundColor: Color(0xFF1E1E1E),
                                    content: Text(
                                        "ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง"),
                                  ),
                                );
                              }

                            } catch (e) {
                              // ================== ถ้าเชื่อมต่อ Server ไม่ได้ ==================
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF1E1E1E),
                                  content: Text(
                                      "ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้"),
                                ),
                              );
                            }
                          }
                        },

                        // ตกแต่งปุ่ม Gradient
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1565C0),
                                Color(0xFF1E88E5),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          child: const Center(
                            child: Text(
                              "เข้าสู่ระบบ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ปุ่มสมัครสมาชิก (ยังไม่ได้เขียนฟังก์ชัน)
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "สมัครสมาชิก",
                        style: TextStyle(
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      
    );
  }


  // ================== INPUT DECORATION STYLE ==================

  // ฟังก์ชันสำหรับตกแต่ง TextField ให้เป็นธีม Dark
  InputDecoration _darkInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF2A2A2A),

      // กรอบตอนยังไม่กด
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),

      // กรอบตอนกดเลือก
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Color(0xFF1E88E5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
