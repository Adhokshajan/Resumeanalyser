// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, unnecessary_null_comparison
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:hr_prob/app_secrets.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;

class UploadResumeScreen extends StatefulWidget {
  @override
  _UploadResumeScreenState createState() => _UploadResumeScreenState();
}

class _UploadResumeScreenState extends State<UploadResumeScreen> with WidgetsBindingObserver {
  List<PlatformFile>? _files;
  String? _pdfPath;
  String _responseText = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      _clearFirestoreData();
    }
  }

  Future<void> _clearFirestoreData() async {
    final collection = _firestore.collection('leaderboard');
    final snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }


  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpeg'],
      allowMultiple: true,
    );
    if (result != null) {
      setState(() {
        _files = result.files;
      });
    }
  }

  Future<void> _uploadFiles() async {
    if (_files != null && _files!.isNotEmpty) {
      List<String> responses = [];
      for (var file in _files!) {
        final filePath = file.path;
        if (filePath != null) {
          final fileToUpload = File(filePath);
          if (await fileToUpload.exists()) {
            try {
              User? user = _auth.currentUser;
              String uid = user?.uid ?? 'unknown';
              // Analyze the document with Google Generative AI
              final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: AppSecrects.apiid);
              final prompt = 'Give me Name,Skills,Knowledge, attitude,STAR Based Questions from the resume, overall rate them out of 10 based on their skill , knowledge. rank them based on the overall rating of the uploaded resume';

              // Render PDF pages as images
              final document = await PdfDocument.openFile(filePath);
              List<Uint8List> images = [];
              for (int i = 1; i <= document.pagesCount; i++) {
                final page = await document.getPage(i);
                final pageImage = await page.render(
                  width: page.width,
                  height: page.height,
                  format: PdfPageImageFormat.png,
                );
                images.add(pageImage!.bytes);
                await page.close();
              }
              await document.close();

              List<Content> contents = [];
              for (var imageBytes in images) {
                contents.add(Content.multi([
                  TextPart(prompt),
                  DataPart('image/png', imageBytes),
                ]));
              }

              final response = await model.generateContent(contents);
              setState(() {
                _responseText=response.text!;
              });
              responses.add(_responseText);
               // Extract name and rank from the response
              String name = extractName(_responseText);  // Implement extractName
              int rank = extractRank(_responseText);  // Implement extractRank

              // Store name and rank in Firestore
              await _firestore.collection(uid).add({
                'name': name,
                'rank': rank,
                'timestamp': FieldValue.serverTimestamp(),
              });
            } catch (e) {
              print('Error uploading file: $e');
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to process file: $e')));
            }
          } else {
            print('File does not exist at path: $filePath');
          }
        }
      }

      // Generate PDF from API responses
final pdf = pw.Document();
for (var response in responses) {
  pdf.addPage(
    pw.MultiPage(
      build: (pw.Context context) => [
        pw.Center(
          child: pw.Paragraph(text: _responseText ?? 'No response'),
        ),
      ],
    ),
  );
}


      // Define custom path for saving PDF
          final directory = await getApplicationDocumentsDirectory();
          final customPath = Directory(path.join(directory.parent.path, 'files'));
          print(customPath);
          if (!await customPath.exists()) {
            await customPath.create(recursive: true);
          }
          final pdfFile = File(path.join(customPath.path, 'response.pdf'));
          await pdfFile.writeAsBytes(await pdf.save());
          setState(() {
            _pdfPath = pdfFile.path;
            _responseText = responses.join('\n\n');
          });

          print(_pdfPath);

      

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Files processed and PDF generated successfully')));
    }
  }





  String extractName(String responseText) {
  // Adjust the regex pattern to match the format in the response text
  final nameRegex = RegExp(r'Name:\s*([^\n]+)', multiLine: true);
  final match = nameRegex.firstMatch(responseText);
  if (match != null) {
    print("Extracted Name: ${match.group(1)}"); // Debug print
    return match.group(1) ?? 'Unknown';
  } else {
    print("Name not found in the response text."); // Debug print
  }
  return 'Unknown';
}
  int extractRank(String responseText) {
  // Adjust the regex pattern to match the format in the response text
  final rankRegex = RegExp(r'Overall Rating:\s*(\d+)', multiLine: true);
  final match = rankRegex.firstMatch(responseText);
  if (match != null) {
    print("Extracted Rank: ${match.group(1)}"); // Debug print
    return int.tryParse(match.group(1) ?? '0') ?? 0;
  } else {
    print("Rank not found in the response text."); // Debug print
  }
  return 0;
}
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Resume')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(228, 42, 226, 5),
              ),
              child: Text(
                'Pick Files',
                style: TextStyle(
                  color: Color.fromARGB(255, 10, 10, 10),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_files != null && _files!.isNotEmpty)
              Column(
                children: _files!.map((file) => Text('File: ${file.name}')).toList(),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFiles,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(226, 42, 226, 5),
              ),
              child: Text(
                'Upload Files',
                style: TextStyle(
                  color: Color.fromARGB(255, 10, 10, 10),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_responseText != null)
              Container(
                padding: EdgeInsets.all(10),
                color: Color.fromARGB(255, 10, 10, 10),
                child: Text('Response: $_responseText'),
              ),
            if (_pdfPath != null)
              Column(
                children: [
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Open the PDF file
                      OpenFile.open(_pdfPath!);
                    },
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(226, 42, 226, 5),
              ),
                    child: Text('Download PDF',style: TextStyle(
                  color: Color.fromARGB(255, 10, 10, 10),
                  fontWeight: FontWeight.bold,
                ),),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}




