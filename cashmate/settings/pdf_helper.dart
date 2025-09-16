// lib/utils/pdf_helper.dart
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:app/import_export.dart';
import 'package:intl/intl.dart';


// ✅ Helper function for Indian Rupees formatting
String formatRupees(num value) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN', // Indian format with commas
    symbol: '₹',    // Rupee symbol
    decimalDigits: 0,
  );
  return formatter.format(value);
}

Future<void> generateAndSavePdf(BuildContext context) async {
  final pdf = pw.Document();

  // Example expenses
  final expenses = [1200, 3400, 500, 75000];

  // 📝 Example content
  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Center(
          child: pw.Text(
            'SaveMate Report',
            style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text("Generated on: ${DateTime.now()}"),
        pw.Divider(),
        pw.Text("This is a sample SaveMate report."),
        pw.SizedBox(height: 20),

        // ✅ Showing formatted amounts
        pw.Text("Expenses:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        ...expenses.map((e) => pw.Text("• ${formatRupees(e)}")),
      ],
    ),
  );

  // ✅ Permission request
  var status = await Permission.manageExternalStorage.request();
  if (!status.isGranted) {
    status = await Permission.storage.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Storage permission denied")),
      );
      return;
    }
  }

  // ✅ Save location
  final dir = Directory('/storage/emulated/0/Download/SaveMate/Reports');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }

  final fileName =
      "report_${DateTime.now().toIso8601String().replaceAll(":", "-")}.pdf";
  final file = File("${dir.path}/$fileName");
  await file.writeAsBytes(await pdf.save());

  // ✅ Show message + actions
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text("📄 PDF saved: ${file.path}"),
      action: SnackBarAction(
        label: "Open",
        onPressed: () => Printing.layoutPdf(
          onLayout: (_) async => pdf.save(),
        ),
      ),
    ),
  );

  // ✅ Optionally open share dialog immediately
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Report Saved"),
      content: Text("PDF has been saved at:\n${file.path}"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await Printing.sharePdf(bytes: await pdf.save(), filename: fileName);
          },
          child: const Text("Share"),
        ),
      ],
    ),
  );
}
