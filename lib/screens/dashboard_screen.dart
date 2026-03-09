import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'upload_prescription_screen.dart';
import 'past_prescriptions_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String role;

  const DashboardScreen({super.key, required this.role});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    registerFCMToken();
  }

  Future<void> registerFCMToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      await messaging.requestPermission();

      String? token = await messaging.getToken();

      if (token != null) {
        await http.post(
          Uri.parse("https://medimate-backend-wzk0.onrender.com/save-token"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "firebase_uid": FirebaseAuth.instance.currentUser!.uid,
            "fcm_token": token,
          }),
        );
      }
    } catch (e) {
      print("FCM token error: $e");
    }
  }

  String getRoleIcon() {
    switch (widget.role) {
      case "Patient":
        return "👤";
      case "Pharmacist":
        return "💊";
      case "Caretaker":
        return "❤️";
      default:
        return "📋";
    }
  }

  String getRoleGreeting() {
    switch (widget.role) {
      case "Patient":
        return "Manage your prescriptions";
      case "Pharmacist":
        return "Scan and process prescriptions";
      case "Caretaker":
        return "Manage patient medications";
      default:
        return "Welcome back";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A5C8A),
              Color(0xFF1A3F5F),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Logout
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            getRoleIcon(),
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.role} Dashboard",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              getRoleGreeting(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Main Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Decorative Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2A5C8A),
                                    Color(0xFF1A3F5F),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Quick Actions",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A3F5F),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Buttons
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // PATIENT ROLE
                                if (widget.role == "Patient") ...[
                                  _buildActionCard(
                                    icon: Icons.upload_file_outlined,
                                    title: "Upload Prescription",
                                    description: "Take a photo or select from gallery",
                                    color: const Color(0xFF2A5C8A),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const UploadPrescriptionScreen(),
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  _buildActionCard(
                                    icon: Icons.history_outlined,
                                    title: "View Past Prescriptions",
                                    description: "Access your prescription history",
                                    color: const Color(0xFF1A3F5F),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const PastPrescriptionsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],

                                // PHARMACIST ROLE
                                if (widget.role == "Pharmacist") ...[
                                  _buildActionCard(
                                    icon: Icons.qr_code_scanner_outlined,
                                    title: "Scan Prescription",
                                    description: "Quick scan and process prescriptions",
                                    color: const Color(0xFF2A5C8A),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const UploadPrescriptionScreen(),
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  _buildActionCard(
                                    icon: Icons.inventory_2_outlined,
                                    title: "Pending Scans",
                                    description: "View prescriptions waiting for processing",
                                    color: const Color(0xFF1A3F5F),
                                    onTap: () {
                                      // Future functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text("Coming soon!"),
                                          backgroundColor: const Color(0xFF2A5C8A),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],

                                // CARETAKER ROLE
                                if (widget.role == "Caretaker") ...[
                                  _buildActionCard(
                                    icon: Icons.person_add_outlined,
                                    title: "Add Patient",
                                    description: "Register a new patient",
                                    color: const Color(0xFF2A5C8A),
                                    onTap: () {
                                      // Future functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text("Coming soon!"),
                                          backgroundColor: const Color(0xFF2A5C8A),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  _buildActionCard(
                                    icon: Icons.people_outlined,
                                    title: "View Patients",
                                    description: "Manage your patients",
                                    color: const Color(0xFF1A3F5F),
                                    onTap: () {
                                      // Future functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text("Coming soon!"),
                                          backgroundColor: const Color(0xFF2A5C8A),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],

                                const SizedBox(height: 30),

                                // Stats/Info Section
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2A5C8A).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              Icons.info_outline,
                                              color: const Color(0xFF2A5C8A),
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Expanded(
                                            child: Text(
                                              "MediMate Assistant",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF1A3F5F),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "We are here to help you manage medications efficiently.",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Decorative Dots
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    5,
                                        (index) => Container(
                                      width: 6,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2A5C8A).withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A3F5F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: color,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}