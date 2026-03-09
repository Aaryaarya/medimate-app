import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'add_patient_screen.dart';
import 'login_screen.dart';

class CaretakerDashboardScreen extends StatefulWidget {
  const CaretakerDashboardScreen({super.key});

  @override
  State<CaretakerDashboardScreen> createState() =>
      _CaretakerDashboardScreenState();
}

class _CaretakerDashboardScreenState extends State<CaretakerDashboardScreen> {
  List patients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  Future<void> fetchPatients() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final response = await http.get(
      Uri.parse(
          "https://medimate-backend-wzk0.onrender.com/caretaker-patients/$uid"),
    );

    if (response.statusCode == 200) {
      setState(() {
        patients = jsonDecode(response.body);
        isLoading = false;
      });
    }
  }

  void openPatient(dynamic patient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Opening ${patient["name"]} dashboard")),
    );
  }

  void addPatient() async {
    print("ADD BUTTON PRESSED");

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddPatientScreen(),
      ),
    );

    print("RETURNED FROM ADD PATIENT");

    if (result == true) {
      fetchPatients();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2A5C8A),
        title: const Text(
          "Caretaker Dashboard",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,

        // ✅ FIX ADDED HERE (Logout Button)
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addPatient,
        backgroundColor: const Color(0xFF2A5C8A),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patients.isEmpty
          ? const Center(
        child: Text(
          "No Patients Added",
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];

          return GestureDetector(
            onTap: () => openPatient(patient),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A5C8A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF2A5C8A),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient["name"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A3F5F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Age: ${patient["age"]}   Gender: ${patient["gender"]}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: Colors.black38,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}