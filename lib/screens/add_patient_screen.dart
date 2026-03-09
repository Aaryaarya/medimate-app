import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final notesController = TextEditingController();

  String gender = "Male";
  bool isLoading = false;

  Future<void> savePatient() async {
    if (nameController.text.isEmpty || ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final response = await http.post(
      Uri.parse("https://medimate-backend-wzk0.onrender.com/add-patient"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "caretaker_uid": uid,
        "name": nameController.text.trim(),
        "age": int.parse(ageController.text.trim()),
        "gender": gender,
        "notes": notesController.text.trim(),
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true); // return success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add patient")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A5C8A),
        title: const Text("Add Patient"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildField("Patient Name", nameController, Icons.person),
            const SizedBox(height: 16),
            _buildField("Age", ageController, Icons.calendar_today,
                isNumber: true),
            const SizedBox(height: 16),

            // Gender Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(border: InputBorder.none),
                items: ["Male", "Female", "Other"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) => setState(() => gender = value!),
              ),
            ),

            const SizedBox(height: 16),
            _buildField("Notes (Optional)", notesController, Icons.note),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading ? null : savePatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A5C8A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Save Patient",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String hint, TextEditingController controller, IconData icon,
      {bool isNumber = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType:
        isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF2A5C8A)),
          hintText: hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}