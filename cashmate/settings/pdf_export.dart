import 'dart:io';
import 'package:intl/intl.dart';
import  'package:pdf/widgets.dart' as pw;

import 'package:app/import_export.dart';

class PDFExporter {
  /// Generate PDF file with summary + transaction table
  static Future<File> generatePdf(List<TransactionModel> transactions) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat('dd-MM-yyyy');

    // Formatter for comma-separated numbers
    final numberFormatter = NumberFormat.decimalPattern('en_IN');

    // ---- Summary calculations ----
    final totalIncome = transactions
        .where((e) => e.type == "Income")
        .fold(0.0, (sum, e) => sum + e.amount);

    final totalExpense = transactions
        .where((e) => e.type == "Expense")
        .fold(0.0, (sum, e) => sum + e.amount);

    final totalSavings = transactions
        .where((e) => e.type == "Saving")
        .fold(0.0, (sum, e) => sum + e.amount);

    final balance = totalIncome - totalExpense + totalSavings;

    // ---- Add content to PDF ----
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Text(
              "Transaction Report",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),

          // Summary Section
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey, width: 1),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Summary",
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                pw.Text("Total Income: ${numberFormatter.format(totalIncome)}"),
                pw.Text("Total Expense: ${numberFormatter.format(totalExpense)}"),
                //pw.Text("Total Savings: ${numberFormatter.format(totalSavings)}"),
                pw.Divider(),
                pw.Text("Balance: ${numberFormatter.format(balance)}",
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Transactions Table
          pw.Text("Transaction History",
              style: pw.TextStyle(
                  fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),

          pw.Table.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignments: {
              0: pw.Alignment.center,
              3: pw.Alignment.centerRight,
            },
            cellAlignments: {
              0: pw.Alignment.center,
              3: pw.Alignment.centerRight,
            },
            headers: ["Date", "Category", "Type", "Amount", ],
            data: transactions.map((txn) {
              return [
                dateFormatter.format(DateTime.parse(txn.date)),
                txn.category,
                txn.type,
                numberFormatter.format(txn.amount),
                txn.note ?? "",
              ];
            }).toList(),
          ),
        ],
      ),
    );

    // ---- Save file ----
    final output = await getApplicationDocumentsDirectory();
    final fileName =
        "transaction_report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf";
    final file = File("${output.path}/$fileName");

    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
