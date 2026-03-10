import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dashboard_screen.dart';

class PatientListScreen extends StatelessWidget {
  final List patients;

  const PatientListScreen({super.key, required this.patients});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Patients"),
        backgroundColor: const Color(0xFF2A5C8A),
      ),
      body: patients.isEmpty
          ? const Center(child: Text("No patients added"))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.person),

              title: Text(patient["name"]),

              subtitle: Text(
                  "Age: ${patient["age"]} | Gender: ${patient["gender"]}"),

              // 👆 OPEN PATIENT DASHBOARD
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DashboardScreen(
                      role: "Patient",
                      patientId: patient["id"],
                      patientName: patient["name"],
                      isCaretakerMode: true,
                    ),
                  ),
                );
              },

              // 🗑 DELETE BUTTON
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    deletePatient(context, patient["id"]),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🗑 DELETE FUNCTION
  Future<void> deletePatient(BuildContext context, String patientId) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Patient"),
        content: const Text(
            "Are you sure you want to delete this patient?\n\nThis will remove all prescriptions and reminders."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete",
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final response = await http.delete(
      Uri.parse(
          "https://medimate-backend-wzk0.onrender.com/delete-patient/$patientId"),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Patient deleted successfully")),
      );

      Navigator.pop(context, true); // go back to dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete failed")),
      );
    }
  }
}