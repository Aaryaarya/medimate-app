import 'package:flutter/material.dart';

class ScanPrescriptionPage extends StatefulWidget {
  @override
  State<ScanPrescriptionPage> createState() =>
      _ScanPrescriptionPageState();
}

class _ScanPrescriptionPageState
    extends State<ScanPrescriptionPage> {

  // Dummy data (later replaced by Gemini response)
  String rawText = """
Headache / x 1wk
Cough
Nasal block

Rx:
1. Moxclav 625mg 1-0-1 x5d
2. Cetirizine 10mg 0-0-1 x3d
3. Cough Syrup 5ml TDS
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Extract Text from Prescriptions",
          style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ================= Upload Card =================
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Prescription Reader",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),

                  SizedBox(height: 15),

                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_upload,
                              size: 40,
                              color: Colors.grey),
                          SizedBox(height: 10),
                          Text(
                              "Tap to upload prescription image"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),

            /// ================= RAW TEXT SECTION =================
            Text(
              "Complete Prescription Text (Raw Extracted)",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),

            SizedBox(height: 10),

            Container(
              height: 200,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.shade300),
              ),
              child: SingleChildScrollView(
                child: Text(
                  rawText,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),

            SizedBox(height: 30),

            /// ================= Prescription Analysis =================
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  "Prescription Analysis",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),

                Row(
                  children: [
                    IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () {}),
                    IconButton(
                        icon: Icon(Icons.volume_up),
                        onPressed: () {}),
                    IconButton(
                        icon: Icon(Icons.picture_as_pdf),
                        onPressed: () {}),
                    IconButton(
                        icon: Icon(Icons.share),
                        onPressed: () {}),
                  ],
                )
              ],
            ),

            SizedBox(height: 15),

            /// Table
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.shade300),
              ),
              child: Column(
                children: [

                  buildRow("Medicine", "Dose", "Duration"),
                  Divider(),

                  buildRow("Moxclav 625mg", "1-0-1", "5 days"),
                  buildRow("Cetirizine 10mg", "0-0-1", "3 days"),
                  buildRow("Cough Syrup", "TDS", "3 days"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(String c1, String c2, String c3) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(c1)),
          Expanded(child: Text(c2)),
          Expanded(child: Text(c3)),
        ],
      ),
    );
  }
}
