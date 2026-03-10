import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';

class PastPrescriptionsScreen extends StatefulWidget {
  final String? patientId;
  final bool isCaretakerMode;

  const PastPrescriptionsScreen({
    super.key,
    this.patientId,
    this.isCaretakerMode = false,
  });
  @override
  State<PastPrescriptionsScreen> createState() =>
      _PastPrescriptionsScreenState();
}

class _PastPrescriptionsScreenState extends State<PastPrescriptionsScreen> {
  List prescriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPrescriptions();
  }

  Future<void> fetchPrescriptions() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final url = (widget.isCaretakerMode && widget.patientId != null)
        ? "https://medimate-backend-wzk0.onrender.com/patient-prescriptions/${widget.patientId}"
        : "https://medimate-backend-wzk0.onrender.com/past-prescriptions/$uid";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        prescriptions = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      print("Failed to load prescriptions");
    }
  }

  void openPrescription(dynamic item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PrescriptionDetailScreen(
          prescriptionId: item["id"],
          prescription: item["structured_json"],
          date: item["created_at"],
          imageBase64: item["image_base64"],
        ),
      ),
    );
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
                            Icons.history_outlined,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "History",
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

              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Past Prescriptions",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "View and manage your prescription history",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Body
              Expanded(
                child: isLoading
                    ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Loading your prescriptions...",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : prescriptions.isEmpty
                    ? Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 80,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No Prescriptions Found",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Upload a prescription to get started",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: prescriptions.length,
                  itemBuilder: (context, index) {
                    final item = prescriptions[index];
                    final date = item["created_at"].toString();
                    final formattedDate = date.length >= 10
                        ? date.substring(0, 10)
                        : date;
                    final medCount = (item["structured_json"]["medications"] as List).length;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.description_outlined,
                            color: Colors.white.withOpacity(0.7),
                            size: 28,
                          ),
                        ),
                        title: Text(
                          "Prescription - $formattedDate",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "$medCount ${medCount == 1 ? 'medicine' : 'medicines'}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.access_time_outlined,
                              size: 14,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        onTap: () => openPrescription(item),
                      ),
                    );
                  },
                ),
              ),

              // Decorative Dots
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrescriptionDetailScreen extends StatefulWidget {
  final int prescriptionId;
  final Map<String, dynamic> prescription;
  final String date;
  final String? imageBase64;

  const PrescriptionDetailScreen({
    super.key,
    required this.prescriptionId,
    required this.prescription,
    required this.date,
    this.imageBase64,
  });

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  bool reminderEnabled = false;

  TimeOfDay? breakfastTime;
  TimeOfDay? lunchTime;
  TimeOfDay? dinnerTime;

  Future<TimeOfDay?> pickTime(TimeOfDay initial) async {
    return await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2A5C8A),
              onPrimary: Colors.white,
              surface: Color(0xFF1A3F5F),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> selectMealTimes() async {
    breakfastTime = await pickTime(const TimeOfDay(hour: 8, minute: 0));
    if (breakfastTime == null) return;

    lunchTime = await pickTime(const TimeOfDay(hour: 13, minute: 0));
    if (lunchTime == null) return;

    dinnerTime = await pickTime(const TimeOfDay(hour: 20, minute: 0));
    if (dinnerTime == null) return;

    await generateReminder();
  }

  String formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  Future<void> generateReminder() async {
    await http.post(
      Uri.parse("https://medimate-backend-wzk0.onrender.com/generate-reminders"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "firebase_uid": FirebaseAuth.instance.currentUser!.uid,
        "prescription_id": widget.prescriptionId,
        "medications": widget.prescription["medications"],
        "meal_times": {
          "breakfast": formatTime(breakfastTime!),
          "lunch": formatTime(lunchTime!),
          "dinner": formatTime(dinnerTime!)
        }
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Reminders Generated Successfully"),
        backgroundColor: const Color(0xFF2A5C8A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pw.MemoryImage? pdfImage;
    if (widget.imageBase64 != null) {
      pdfImage = pw.MemoryImage(base64Decode(widget.imageBase64!));
    }

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) {
          return [
            pw.Text("MediMate Prescription Report",
                style: pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 20),

            if (pdfImage != null) ...[
              pw.Image(pdfImage, height: 200),
              pw.SizedBox(height: 20),
            ],

            pw.Table.fromTextArray(
              headers: [
                "Tablet Name",
                "Quantity",
                "Dosage",
                "Duration",
                "Remarks"
              ],
              data: (widget.prescription["medications"] as List)
                  .map<List<String>>((med) => [
                med["name"].toString(),
                med["quantity"].toString(),
                med["dosage"].toString(),
                med["durationDays"].toString(),
                med["remarks"].toString(),
              ])
                  .toList(),
            ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "Prescription_${widget.date.substring(0, 10)}.pdf",
    );
  }

  String formatDisplayDate(String date) {
    if (date.length >= 10) {
      return date.substring(0, 10);
    }
    return date;
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = formatDisplayDate(widget.date);

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
                            Icons.calendar_today_outlined,
                            color: Colors.white.withOpacity(0.9),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formattedDate,
                            style: const TextStyle(
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

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Prescription Details",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "View and manage your prescription",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Reminder Card
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
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    "Enable Reminders",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Switch(
                                  value: reminderEnabled,
                                  onChanged: (value) async {
                                    setState(() {
                                      reminderEnabled = value;
                                    });

                                    if (value) {
                                      await selectMealTimes();
                                    }
                                  },
                                  activeColor: Colors.white,
                                  activeTrackColor: const Color(0xFF2A5C8A),
                                  inactiveThumbColor: Colors.white,
                                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                                ),
                              ],
                            ),

                            if (reminderEnabled && breakfastTime != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildMealTimeChip("Breakfast", breakfastTime!),
                                    _buildMealTimeChip("Lunch", lunchTime!),
                                    _buildMealTimeChip("Dinner", dinnerTime!),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Prescription Image
                      if (widget.imageBase64 != null) ...[
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
                                    Icons.image_outlined,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Prescription Image",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  base64Decode(widget.imageBase64!),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // PDF Download Button
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => generatePdf(context),
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
                                Icons.picture_as_pdf_outlined,
                                color: const Color(0xFF1A3F5F),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Download PDF",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A3F5F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Medications Table
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
                                  Icons.medication_outlined,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Medications",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Table
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
                                  columnSpacing: 20,
                                  headingRowColor: MaterialStateProperty.all(
                                    Colors.white.withOpacity(0.15),
                                  ),
                                  dataRowColor: MaterialStateProperty.all(
                                    Colors.transparent,
                                  ),
                                  headingTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                  dataTextStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                  columns: const [
                                    DataColumn(label: Text("Tablet")),
                                    DataColumn(label: Text("Qty")),
                                    DataColumn(label: Text("Dosage")),
                                    DataColumn(label: Text("Days")),
                                    DataColumn(label: Text("Remarks")),
                                  ],
                                  rows: (widget.prescription["medications"] as List)
                                      .map<DataRow>((med) => DataRow(
                                    cells: [
                                      DataCell(Container(
                                        constraints: const BoxConstraints(maxWidth: 100),
                                        child: Text(
                                          med["name"].toString(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                      DataCell(Text(med["quantity"].toString())),
                                      DataCell(Text(med["dosage"].toString())),
                                      DataCell(Text(med["durationDays"].toString())),
                                      DataCell(Container(
                                        constraints: const BoxConstraints(maxWidth: 100),
                                        child: Text(
                                          med["remarks"].toString(),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )),
                                    ],
                                  ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

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

  Widget _buildMealTimeChip(String meal, TimeOfDay time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            meal,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            formatTime(time),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}