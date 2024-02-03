import 'package:advance_pdf_viewer_fork/advance_pdf_viewer_fork.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '';

class PdfViewerScreen extends StatelessWidget {
  final String url;
  PdfViewerScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: MyPdfViewer(url : url),
    );
  }
}

class MyPdfViewer extends StatefulWidget {
  final String url;

  MyPdfViewer({required this.url});

  @override
  _MyPdfViewerState createState() => _MyPdfViewerState();
}

class _MyPdfViewerState extends State<MyPdfViewer> {
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument(); // Initialize the PDF document in initState
  }

  Future<void> loadDocument() async {
    try {
      document = await PDFDocument.fromURL(widget.url);
      setState(() {});
    } catch (e) {
      print('Error loading PDF document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return document == null
        ? Center(child: CircularProgressIndicator())
        : PDFViewer(document: document);
  }
}