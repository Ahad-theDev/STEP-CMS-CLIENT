import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String title;
  final String fileName;
  final Uint8List pdfBytes;

  const PdfPreviewScreen({
    super.key,
    required this.title,
    required this.fileName,
    required this.pdfBytes,
  });

  @override
  Widget build(BuildContext context) {
    return CampusPage(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Share PDF',
            icon: const Icon(Icons.share_rounded),
            onPressed: () async {
              await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) async => pdfBytes,
        pdfFileName: fileName,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        maxPageWidth: 700,
        actionBarTheme: const PdfActionBarTheme(
          backgroundColor: CampusStyle.primary,
          iconColor: Colors.white,
        ),
        onPrintError: (context, error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Printing issue: $error. You can use the Save/Download icon to save the PDF file directly.',
              ),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        },
      ),
    );
  }
}
