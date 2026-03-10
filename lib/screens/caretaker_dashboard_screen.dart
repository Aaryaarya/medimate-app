import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'add_patient_screen.dart';
import 'login_screen.dart';
import 'patient_list_screen.dart'; // 👈 NEW IMPORT

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

  void addPatient() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddPatientScreen(),
      ),
    );

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

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ➕ Add Patient
            _buildMenuCard(
              icon: Icons.person_add_alt_1_rounded,
              title: "Add Patient",
              subtitle: "Register a new patient",
              onTap: addPatient,
            ),

            const SizedBox(height: 20),

            // 📋 View Patients
            _buildMenuCard(
              icon: Icons.people_alt_rounded,
              title: "View Patients",
              subtitle: "See and manage your patients",
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientListScreen(patients: patients),
                    ),
                  );

                  if (result == true) {
                    fetchPatients(); // refresh list after delete
                  }
                },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
              child: Icon(icon, color: const Color(0xFF2A5C8A), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 18, color: Colors.black38)
          ],
        ),
      ),
    );
  }
}