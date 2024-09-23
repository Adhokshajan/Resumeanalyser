// ignore_for_file: prefer_const_constructors

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import  'package:hr_prob/upload_resume_screen.dart';


class PdfService {
  Future<void> generateStarPdf(Map<String, dynamic> resumeData) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('STAR Based Questions', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 10),
              pw.Text('Rank: ${resumeData['rank']}'),
              pw.SizedBox(height: 10),
              pw.Text('Attitude: ${resumeData['attitude']}'),
              pw.SizedBox(height: 10),
              pw.Text('Skills: ${resumeData['skills']}'),
              pw.SizedBox(height: 10),
              pw.Text('Knowledge: ${resumeData['knowledge']}'),
              pw.SizedBox(height: 20),
              pw.Text('STAR Questions:', style: pw.TextStyle(fontSize: 18)),
              pw.Bullet(text: 'Situation: Describe a situation where you demonstrated ${resumeData['skills']}.'),
              pw.Bullet(text: 'Task: What tasks were involved in that situation?'),
              pw.Bullet(text: 'Action: What actions did you take to handle the tasks?'),
              pw.Bullet(text: 'Result: What were the outcomes of your actions?'),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
