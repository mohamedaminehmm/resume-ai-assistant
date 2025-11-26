import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'models/resume_model.dart';
import 'services/database_service.dart';
import 'form_page.dart';

class ResumePreviewPage extends StatelessWidget {
  final ResumeData resumeData;

  const ResumePreviewPage({
    super.key,
    required this.resumeData,
  });

  Future<void> _generatePdf(BuildContext context) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        resumeData.fullName.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          if (resumeData.email.isNotEmpty)
                            pw.Text(
                              resumeData.email,
                              style: pw.TextStyle(fontSize: 12),
                            ),
                          if (resumeData.phone.isNotEmpty) ...[
                            pw.Text(' • ', style: pw.TextStyle(fontSize: 12)),
                            pw.Text(
                              resumeData.phone,
                              style: pw.TextStyle(fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                      if (resumeData.address.isNotEmpty)
                        pw.Text(
                          resumeData.address,
                          style: pw.TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),

                // Summary
                if (resumeData.summary.isNotEmpty) ...[
                  pw.Text(
                    'PROFESSIONAL SUMMARY',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    resumeData.summary,
                    style: pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
                    textAlign: pw.TextAlign.justify,
                  ),
                  pw.SizedBox(height: 20),
                ],

                // Skills
                if (resumeData.skills.isNotEmpty) ...[
                  pw.Text(
                    'SKILLS',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: resumeData.skills
                        .map((skill) => pw.Container(
                              padding: const pw.EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(color: PdfColors.grey),
                                borderRadius: pw.BorderRadius.circular(4),
                              ),
                              child: pw.Text(
                                skill,
                                style: pw.TextStyle(fontSize: 11),
                              ),
                            ))
                        .toList(),
                  ),
                  pw.SizedBox(height: 20),
                ],

                // Experience
                if (resumeData.experiences.isNotEmpty) ...[
                  pw.Text(
                    'WORK EXPERIENCE',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  ...resumeData.experiences.map((exp) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                exp.position,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                exp.duration,
                                style: pw.TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          pw.Text(
                            exp.company,
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                          if (exp.description.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              exp.description,
                              style:
                                  pw.TextStyle(fontSize: 11, lineSpacing: 1.3),
                            ),
                          ],
                          pw.SizedBox(height: 12),
                        ],
                      )),
                  pw.SizedBox(height: 20),
                ],

                // Education
                if (resumeData.education.isNotEmpty) ...[
                  pw.Text(
                    'EDUCATION',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  ...resumeData.education.map((edu) => pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                edu.degree,
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                edu.year,
                                style: pw.TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          pw.Text(
                            edu.institution,
                            style: pw.TextStyle(fontSize: 12),
                          ),
                          pw.SizedBox(height: 8),
                        ],
                      )),
                ],
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Generation Error: $e')),
      );
    }
  }

  Future<void> _saveResume(BuildContext context) async {
    try {
      await DatabaseService().saveResume(resumeData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save resume: $e')),
      );
    }
  }

  Future<void> _editResume(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormPage(existingResume: resumeData),
      ),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume updated!')),
      );
    }
  }

  Future<void> _duplicateResume(BuildContext context) async {
    final duplicatedResume = ResumeData.create(
      fullName: '${resumeData.fullName} (Copy)',
      email: resumeData.email,
      phone: resumeData.phone,
      address: resumeData.address,
      summary: resumeData.summary,
      skills: List.from(resumeData.skills),
      experiences: resumeData.experiences
          .map((e) => Experience(
                company: e.company,
                position: e.position,
                duration: e.duration,
                description: e.description,
              ))
          .toList(),
      education: resumeData.education
          .map((e) => Education(
                institution: e.institution,
                degree: e.degree,
                year: e.year,
              ))
          .toList(),
    );

    await DatabaseService().saveResume(duplicatedResume);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume duplicated successfully!')),
      );

      // Navigate to the new duplicated resume
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResumePreviewPage(resumeData: duplicatedResume),
        ),
      );
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${resumeData.fullName}\'s Resume'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editResume(context),
            tooltip: 'Edit Resume',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveResume(context),
            tooltip: 'Save Resume',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _duplicateResume(context),
            tooltip: 'Duplicate Resume',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _generatePdf(context),
            tooltip: 'Export as PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
            tooltip: 'Share Resume',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Text(
                    resumeData.fullName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      if (resumeData.email.isNotEmpty)
                        Text(
                          resumeData.email,
                          style: const TextStyle(fontSize: 16),
                        ),
                      if (resumeData.phone.isNotEmpty) ...[
                        const Text(' • ', style: TextStyle(fontSize: 16)),
                        Text(
                          resumeData.phone,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ],
                  ),
                  if (resumeData.address.isNotEmpty)
                    Text(
                      resumeData.address,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 24),

            // Summary
            if (resumeData.summary.isNotEmpty)
              _buildSection('PROFESSIONAL SUMMARY', [
                Text(
                  resumeData.summary,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  textAlign: TextAlign.justify,
                ),
              ]),

            // Skills
            if (resumeData.skills.isNotEmpty)
              _buildSection('SKILLS', [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: resumeData.skills
                      .map((skill) => Chip(
                            label: Text(skill),
                            backgroundColor: Colors.blue[50],
                          ))
                      .toList(),
                ),
              ]),

            // Experience
            if (resumeData.experiences.isNotEmpty)
              _buildSection('WORK EXPERIENCE', [
                ...resumeData.experiences.map((exp) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    exp.position,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  exp.duration,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exp.company,
                              style: const TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            if (exp.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                exp.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )),
              ]),

            // Education
            if (resumeData.education.isNotEmpty)
              _buildSection('EDUCATION', [
                ...resumeData.education.map((edu) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    edu.degree,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  edu.year,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              edu.institution,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    )),
              ]),

            // Metadata
            _buildSection('RESUME INFORMATION', [
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Created: ${_formatDate(resumeData.createdAt)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.update, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Updated: ${_formatDate(resumeData.updatedAt)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ]),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _editResume(context),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            mini: true,
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => _duplicateResume(context),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            mini: true,
            child: const Icon(Icons.copy),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () => _generatePdf(context),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            child: const Icon(Icons.picture_as_pdf),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
