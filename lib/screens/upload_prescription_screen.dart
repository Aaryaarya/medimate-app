import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:convert';

class UploadPrescriptionScreen extends StatefulWidget {
  const UploadPrescriptionScreen({super.key});

  @override
  State<UploadPrescriptionScreen> createState() =>
      _UploadPrescriptionScreenState();
}

class _UploadPrescriptionScreenState
    extends State<UploadPrescriptionScreen> {

  XFile? selectedImage;
  Uint8List? webImageBytes;

  bool isLoading = false;
  String? extractedText;
  Map<String, dynamic>? result;

  final FlutterTts flutterTts = FlutterTts();

  // ================= IMAGE PICKER =================
  Future<void> pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        webImageBytes = await picked.readAsBytes();
      }

      setState(() {
        selectedImage = picked;
        extractedText = null;
        result = null;
      });
    }
  }

  // ================= ANALYZE =================
  Future<void> analyzePrescription() async {
    if (selectedImage == null) return;

    setState(() => isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            "https://medimate-backend-wzk0.onrender.com/analyze-prescription"),
      );

      // IMPORTANT: Send UID
      request.fields["firebase_uid"] =
          FirebaseAuth.instance.currentUser!.uid;

      request.files.add(
        http.MultipartFile.fromBytes(
          "image",
          await selectedImage!.readAsBytes(),
          filename: selectedImage!.name,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      var data = jsonDecode(responseBody);

      setState(() {
        extractedText = data["raw_text"];
        result = data["structured_json"];
        isLoading = false;
      });

    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Analysis failed")),
      );
    }
  }

  // ================= PDF GENERATION =================
  Future<void> generatePdf() async {
    if (result == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("MediMate Prescription Report",
                  style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              ...result!["medications"].map<pw.Widget>((med) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 10),
                  child: pw.Text(
                      "${med["name"]}\n${med["dosesPerDay"]}\n${med["dosageDetails"]}\n${med["remarks"]}\n"),
                );
              }).toList(),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  // ================= VOICE =================
  Future<void> speakPrescription() async {
    if (result == null) return;

    String textToSpeak = "";

    for (var med in result!["medications"]) {
      textToSpeak +=
      "${med["name"]}, ${med["dosesPerDay"]}, ${med["dosageDetails"]}. ";
    }

    await flutterTts.speak(textToSpeak);
  }

  // ================= COPY =================
  void copyToClipboard() {
    if (result == null) return;

    Clipboard.setData(
      ClipboardData(text: jsonEncode(result)),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard")),
    );
  }

  // ================= UI =================
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
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.upload_file_outlined,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "Upload",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.medical_services_outlined,
                              size: 50,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Upload Prescription",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Take a photo or select from gallery",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Image Preview Card
                      if (selectedImage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? Image.memory(
                                  webImageBytes!,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                                    : Image.network(
                                  selectedImage!.path,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green.shade300,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Image selected successfully",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        // Empty State
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 50),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 70,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No Image Selected",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: pickImage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.photo_library_outlined,
                                      color: Colors.white.withOpacity(0.9),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Select Image",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: selectedImage == null
                                    ? null
                                    : const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white,
                                  ],
                                ),
                                color: selectedImage == null
                                    ? Colors.white.withOpacity(0.1)
                                    : null,
                                boxShadow: selectedImage == null
                                    ? null
                                    : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: const Offset(0, 4),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: selectedImage == null
                                    ? null
                                    : analyzePrescription,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF1A3F5F),
                                    ),
                                  ),
                                )
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.analytics_outlined,
                                      color: selectedImage == null
                                          ? Colors.white.withOpacity(0.3)
                                          : const Color(0xFF1A3F5F),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Analyze",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: selectedImage == null
                                            ? Colors.white.withOpacity(0.3)
                                            : const Color(0xFF1A3F5F),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Extracted Text Section
                      if (extractedText != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.text_snippet_outlined,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Extracted Text:",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  extractedText!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Structured Data Section
                      if (result?["medications"] != null &&
                          (result!["medications"] as List).isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.analytics_outlined,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Structured Prescription",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Data Table
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: DataTable(
                                    columnSpacing: 25,
                                    headingRowColor: MaterialStateProperty.all(
                                      Colors.white.withOpacity(0.15),
                                    ),
                                    dataRowColor: MaterialStateProperty.all(
                                      Colors.transparent,
                                    ),
                                    headingTextStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    dataTextStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                    columns: const [
                                      DataColumn(label: Text("Tablet")),
                                      DataColumn(label: Text("Qty")),
                                      DataColumn(label: Text("Dosage")),
                                      DataColumn(label: Text("Days")),
                                      DataColumn(label: Text("Remarks")),
                                    ],
                                    rows: (result!["medications"] as List)
                                        .map<DataRow>((med) => DataRow(
                                      cells: [
                                        DataCell(Container(
                                          constraints: const BoxConstraints(maxWidth: 100),
                                          child: Text(
                                            (med["name"] ?? "").toString(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )),
                                        DataCell(Text((med["quantity"] ?? "-").toString())),
                                        DataCell(Text((med["dosage"] ?? "").toString())),
                                        DataCell(Text((med["durationDays"] ?? "").toString())),
                                        DataCell(Container(
                                          constraints: const BoxConstraints(maxWidth: 100),
                                          child: Text(
                                            (med["remarks"] ?? "-").toString(),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        )),
                                      ],
                                    ))
                                        .toList(),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Action Buttons Row
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _buildActionButton(
                                    icon: Icons.picture_as_pdf_outlined,
                                    label: "PDF",
                                    onPressed: generatePdf,
                                    color: Colors.red.shade300,
                                  ),
                                  _buildActionButton(
                                    icon: Icons.volume_up_outlined,
                                    label: "Voice",
                                    onPressed: speakPrescription,
                                    color: Colors.blue.shade300,
                                  ),
                                  _buildActionButton(
                                    icon: Icons.copy_outlined,
                                    label: "Copy",
                                    onPressed: copyToClipboard,
                                    color: Colors.green.shade300,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]

                      else if (result != null) ...[
                  Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      "This is not a valid prescription.",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                  ],

                  const SizedBox(height: 30),



                      // Past Prescriptions Button (New Feature)
                      if (result != null || extractedText != null)
                        Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to past prescriptions
                              // Add your navigation logic here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history_outlined,
                                  color: Colors.white.withOpacity(0.9),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "View Past Prescriptions",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
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
                              color: Colors.white.withOpacity(0.2),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}