import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:flutter/material.dart'
    show BuildContext, MaterialPageRoute, Navigator;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/daily_attendance_report_model.dart';
import '../data/models/lecture_attendance_report_model.dart';
import '../data/models/fee_report_model.dart';
import '../data/models/marks_report_model.dart';
import '../presentation/screens/pdf_preview_screen.dart';
import 'package:cms/features/exams/data/models/exam_results_model.dart';

class ReportPdfService {
  ReportPdfService._();
  static final ReportPdfService instance = ReportPdfService._();

  Future<pw.Document> _createDocument() async {
    try {
      final base = await PdfGoogleFonts.openSansRegular();
      final bold = await PdfGoogleFonts.openSansBold();
      return pw.Document(
        theme: pw.ThemeData.withFont(base: base, bold: bold),
      );
    } catch (_) {
      return pw.Document();
    }
  }

  static const _primaryColor = PdfColor.fromInt(0xFF922B2B);
  static const _secondaryColor = PdfColor.fromInt(0xFFFAE7E3);
  static const _textColor = PdfColor.fromInt(0xFF1D1B20);
  static const _mutedColor = PdfColor.fromInt(0xFF6B7280);
  static const _borderColor = PdfColor.fromInt(0xFFE5E7EB);
  static const _altRowColor = PdfColor.fromInt(0xFFF9FAFB);

  pw.Widget _buildHeader({
    required String title,
    required String subtitle,
    required String scopeDescription,
    required pw.MemoryImage crest,
  }) {
    final nowStr = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(crest, width: 40, height: 40),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'CITY IDEAL SCHOOL',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    subtitle,
                    style: const pw.TextStyle(fontSize: 10, color: _mutedColor),
                  ),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: _secondaryColor,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'OFFICIAL REPORT',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: _primaryColor,
                    ),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generated: $nowStr',
                  style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: pw.BoxDecoration(
            color: _altRowColor,
            border: pw.Border.all(color: _borderColor),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Text(
            'Scope: $scopeDescription',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _textColor,
            ),
          ),
        ),
        pw.SizedBox(height: 12),
        pw.Divider(color: _primaryColor, thickness: 1.5),
        pw.SizedBox(height: 8),
      ],
    );
  }

  pw.Widget _buildKpiBox(String label, String value, {PdfColor? valueColor}) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        margin: const pw.EdgeInsets.symmetric(horizontal: 3),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _borderColor),
          borderRadius: pw.BorderRadius.circular(4),
          color: _altRowColor,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: valueColor ?? _primaryColor,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
            ),
          ],
        ),
      ),
    );
  }

  // 1. Daily Attendance Report PDF
  Future<Uint8List> generateDailyAttendancePdf(
    DailyAttendanceReport report, {
    String scopeDescription = 'Class Attendance',
  }) async {
    final pdf = await _createDocument();
    final crestBytes = await rootBundle.load(
      'lib/core/assets/logo/city_ideal_school.jpeg',
    );
    final crest = pw.MemoryImage(
      crestBytes.buffer.asUint8List(
        crestBytes.offsetInBytes,
        crestBytes.lengthInBytes,
      ),
    );
    final summary = report.summary;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => _buildHeader(
          crest: crest,
          title: 'Daily Student Attendance Report',
          subtitle:
              'Working Days: ${summary.daysRecorded} | Attendance Rate: ${summary.attendancePercentage.toStringAsFixed(1)}%',
          scopeDescription: scopeDescription,
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
          ),
        ),
        build: (ctx) => [
          pw.Row(
            children: [
              _buildKpiBox('Total Students', '${report.students.length}'),
              _buildKpiBox('Working Days', '${summary.daysRecorded}'),
              _buildKpiBox(
                'Attendance %',
                '${summary.attendancePercentage.toStringAsFixed(1)}%',
                valueColor: summary.attendancePercentage >= 75
                    ? PdfColor.fromInt(0xFF16A34A)
                    : PdfColor.fromInt(0xFFDC2626),
              ),
              _buildKpiBox('Present Marks', '${summary.present}'),
              _buildKpiBox('Absents', '${summary.absent}'),
              _buildKpiBox('Leaves', '${summary.leave}'),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Text(
            'Student Attendance Details',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _textColor,
            ),
          ),
          pw.SizedBox(height: 6),

          pw.TableHelper.fromTextArray(
            headers: [
              'Roll #',
              'Student Name',
              'Present',
              'Absent',
              'Late',
              'Leave',
              'Rate %',
            ],
            data: report.students.map((st) {
              return [
                st.rollNumber,
                st.studentName,
                '${st.presentDays}',
                '${st.absentDays}',
                '${st.lateDays}',
                '${st.leaveDays}',
                '${st.attendancePercentage.toStringAsFixed(1)}%',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
              6: pw.Alignment.centerRight,
            },
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: const pw.BoxDecoration(color: _altRowColor),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 5,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // 2. Lecture Attendance Report PDF
  Future<Uint8List> generateLectureAttendancePdf(
    LectureAttendanceReport report, {
    String scopeDescription = 'Lecture Attendance',
  }) async {
    final pdf = await _createDocument();
    final crestBytes = await rootBundle.load(
      'lib/core/assets/logo/city_ideal_school.jpeg',
    );
    final crest = pw.MemoryImage(
      crestBytes.buffer.asUint8List(
        crestBytes.offsetInBytes,
        crestBytes.lengthInBytes,
      ),
    );
    final summary = report.summary;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => _buildHeader(
          crest: crest,
          title: 'Lecture-wise Student Attendance Report',
          subtitle:
              'Scheduled Slots: ${summary.scheduledLectureSlots} | Attendance Rate: ${summary.attendancePercentage.toStringAsFixed(1)}%',
          scopeDescription: scopeDescription,
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
          ),
        ),
        build: (ctx) => [
          pw.Row(
            children: [
              _buildKpiBox(
                'Scheduled Slots',
                '${summary.scheduledLectureSlots}',
              ),
              _buildKpiBox('Total Students', '${report.students.length}'),
              _buildKpiBox(
                'Overall %',
                '${summary.attendancePercentage.toStringAsFixed(1)}%',
                valueColor: summary.attendancePercentage >= 75
                    ? PdfColor.fromInt(0xFF16A34A)
                    : PdfColor.fromInt(0xFFDC2626),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Text(
            'Student Lecture Attendance Summary',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _textColor,
            ),
          ),
          pw.SizedBox(height: 6),

          pw.TableHelper.fromTextArray(
            headers: [
              'Roll #',
              'Student Name',
              'Lectures Attended',
              'Lectures Absent',
              'Attendance %',
            ],
            data: report.students.map((st) {
              return [
                st.rollNumber,
                st.studentName,
                '${st.attendedLectures}',
                '${st.absentCount}',
                '${st.attendancePercentage.toStringAsFixed(1)}%',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.centerRight,
            },
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: const pw.BoxDecoration(color: _altRowColor),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 5,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // 3. Fee Report PDF
  Future<Uint8List> generateFeePdf(
    FeeReport report, {
    String scopeDescription = 'Fee Collection Report',
  }) async {
    final pdf = await _createDocument();
    final crestBytes = await rootBundle.load(
      'lib/core/assets/logo/city_ideal_school.jpeg',
    );
    final crest = pw.MemoryImage(
      crestBytes.buffer.asUint8List(
        crestBytes.offsetInBytes,
        crestBytes.lengthInBytes,
      ),
    );
    final summary = report.summary;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => _buildHeader(
          crest: crest,
          title: 'Fee Collection & Defaulters Report',
          subtitle:
              'Collection Rate: ${summary.collectionPercentage.toStringAsFixed(1)}% | Records: ${summary.feeRecords}',
          scopeDescription: scopeDescription,
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
          ),
        ),
        build: (ctx) => [
          pw.Row(
            children: [
              _buildKpiBox(
                'Total Fee Due',
                'PKR ${summary.totalFeeDue.toStringAsFixed(0)}',
              ),
              _buildKpiBox(
                'Fee Collected',
                'PKR ${summary.totalFeeSubmitted.toStringAsFixed(0)}',
                valueColor: PdfColor.fromInt(0xFF16A34A),
              ),
              _buildKpiBox(
                'Outstanding',
                'PKR ${summary.outstandingFee.toStringAsFixed(0)}',
                valueColor: PdfColor.fromInt(0xFFDC2626),
              ),
              _buildKpiBox(
                'Collection %',
                '${summary.collectionPercentage.toStringAsFixed(1)}%',
              ),
              _buildKpiBox('Unpaid Records', '${summary.unpaidRecords}'),
            ],
          ),
          pw.SizedBox(height: 16),

          pw.Text(
            'Student Fee Statement',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _textColor,
            ),
          ),
          pw.SizedBox(height: 6),

          pw.TableHelper.fromTextArray(
            headers: [
              'Roll #',
              'Student Name',
              'Total Due',
              'Paid',
              'Outstanding',
              'Status',
            ],
            data: report.students.map((st) {
              final status = st.unpaidRecords > 0
                  ? 'OVERDUE'
                  : (st.outstandingFee == 0 ? 'PAID' : 'PARTIAL');

              return [
                st.rollNumber,
                st.studentName,
                'PKR ${st.totalFeeDue.toStringAsFixed(0)}',
                'PKR ${st.totalFeeSubmitted.toStringAsFixed(0)}',
                'PKR ${st.outstandingFee.toStringAsFixed(0)}',
                status,
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.center,
            },
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: const pw.BoxDecoration(color: _altRowColor),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 5,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // 4. Marks Report PDF
  Future<Uint8List> generateMarksPdf(
    MarksReport report, {
    String scopeDescription = 'Exam Marks Report',
  }) async {
    final pdf = await _createDocument();
    final crestBytes = await rootBundle.load(
      'lib/core/assets/logo/city_ideal_school.jpeg',
    );
    final crest = pw.MemoryImage(
      crestBytes.buffer.asUint8List(
        crestBytes.offsetInBytes,
        crestBytes.lengthInBytes,
      ),
    );
    final summary = report.summary;
    final examMeta = report.exam;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => _buildHeader(
          crest: crest,
          title: 'Examination Marks & Merit Report',
          subtitle:
              '${examMeta.title} (${examMeta.academicYear}) | Class Average: ${summary.averagePercentage.toStringAsFixed(1)}%',
          scopeDescription: scopeDescription,
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
          ),
        ),
        build: (ctx) => [
          pw.Row(
            children: [
              _buildKpiBox('Total Candidates', '${summary.studentsCount}'),
              _buildKpiBox(
                'Class Average',
                '${summary.averagePercentage.toStringAsFixed(1)}%',
              ),
              _buildKpiBox(
                'Marks Obtained',
                summary.totalObtainedMarks.toStringAsFixed(1),
              ),
              _buildKpiBox(
                'Total Maximum',
                summary.totalMaximumMarks.toStringAsFixed(0),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // Subject Summaries Table
          if (report.subjects.isNotEmpty) ...[
            pw.Text(
              'Subject Performance Statistics',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: _textColor,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: [
                'Subject',
                'Max Per Student',
                'Class Max',
                'Class Obtained',
                'Candidates Marked',
              ],
              data: report.subjects.map((sub) {
                return [
                  sub.subjectName,
                  sub.maxMarksPerStudent.toStringAsFixed(0),
                  sub.classMaximumMarks.toStringAsFixed(0),
                  sub.classObtainedMarks.toStringAsFixed(1),
                  '${sub.studentsMarked}',
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(color: _primaryColor),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
              oddRowDecoration: const pw.BoxDecoration(color: _altRowColor),
              cellPadding: const pw.EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
            ),
            pw.SizedBox(height: 16),
          ],

          // Merit List Table
          pw.Text(
            'Student Marks Roster',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _textColor,
            ),
          ),
          pw.SizedBox(height: 6),

          pw.TableHelper.fromTextArray(
            headers: [
              'Roll #',
              'Student Name',
              'Total Obtained',
              'Maximum',
              'Percentage',
              'Result',
            ],
            data: report.students.map((st) {
              final isPassed = st.percentage >= 33.0;
              return [
                st.rollNumber,
                st.studentName,
                st.totalObtained.toStringAsFixed(1),
                st.totalMaximum.toStringAsFixed(0),
                '${st.percentage.toStringAsFixed(1)}%',
                isPassed ? 'PASS' : 'FAIL',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.center,
            },
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: const pw.BoxDecoration(color: _altRowColor),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 5,
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  String calculateGrade(double percentage) {
    if (percentage >= 80.0) return 'A+';
    if (percentage >= 70.0) return 'A';
    if (percentage >= 60.0) return 'B';
    if (percentage >= 50.0) return 'C';
    if (percentage >= 33.0) return 'D';
    return 'F';
  }

  // 5. Class Exam Results Merit List PDF (from ExamClassResults)
  Future<Uint8List> generateClassResultsPdf(
    ExamClassResults results, {
    String scopeDescription = 'Class Results',
  }) async {
    final pdf = await _createDocument();
    final crestBytes = await rootBundle.load(
      'lib/core/assets/logo/city_ideal_school.jpeg',
    );
    final crest = pw.MemoryImage(
      crestBytes.buffer.asUint8List(
        crestBytes.offsetInBytes,
        crestBytes.lengthInBytes,
      ),
    );
    final students = results.students;

    double avgPct = 0.0;
    double topPct = 0.0;
    if (students.isNotEmpty) {
      final sum = students.fold<double>(0.0, (acc, s) => acc + s.percentage);
      avgPct = sum / students.length;
      topPct = students
          .map((s) => s.percentage)
          .reduce((a, b) => a > b ? a : b);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => _buildHeader(
          crest: crest,
          title: 'Official Class Examination Merit Roster',
          subtitle:
              '${results.examTitle} (${results.academicYear}) | Class Average: ${avgPct.toStringAsFixed(1)}%',
          scopeDescription: scopeDescription,
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
          ),
        ),
        build: (ctx) => [
          pw.Row(
            children: [
              _buildKpiBox('Total Candidates', '${students.length}'),
              _buildKpiBox('Class Average', '${avgPct.toStringAsFixed(1)}%'),
              _buildKpiBox(
                'Highest Score',
                '${topPct.toStringAsFixed(1)}%',
                valueColor: const PdfColor(0.08, 0.64, 0.29),
              ),
              _buildKpiBox('Status', results.examStatus.value.toUpperCase()),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Merit List & Student Scores',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _textColor,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: [
              'Roll #',
              'Student Name',
              'Total Obtained',
              'Maximum',
              'Percentage',
              'Grade',
              'Result',
            ],
            data: students.map((st) {
              final isPassed = st.percentage >= 33.0;
              return [
                st.rollNumber,
                st.studentName,
                st.totalObtained.toStringAsFixed(1),
                st.totalMaximum.toStringAsFixed(0),
                '${st.percentage.toStringAsFixed(1)}%',
                calculateGrade(st.percentage),
                isPassed ? 'PASS' : 'FAIL',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.center,
              6: pw.Alignment.center,
            },
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: const pw.BoxDecoration(color: _altRowColor),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 5,
            ),
          ),
          pw.SizedBox(height: 32),
          // Signature lines
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 140,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: _textColor, width: 1),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Class Incharge Signature',
                    style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 100,
                    height: 36,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: _borderColor),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'OFFICIAL STAMP',
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: _mutedColor,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 140,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: _textColor, width: 1),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Principal Signature',
                    style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // 6. Individual Student Report Card / Marksheet PDF
  Future<Uint8List> generateStudentReportCardPdf(
    StudentExamResult studentResult, {
    String? className,
    String? academicYear,
  }) async {
    final pdf = await _createDocument();
    final crestBytes = await rootBundle.load(
      'lib/core/assets/logo/city_ideal_school.jpeg',
    );
    final crest = pw.MemoryImage(
      crestBytes.buffer.asUint8List(
        crestBytes.offsetInBytes,
        crestBytes.lengthInBytes,
      ),
    );
    final grade = calculateGrade(studentResult.percentage);
    final isPassed = studentResult.percentage >= 33.0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => _buildHeader(
          crest: crest,
          title: 'STUDENT ACADEMIC REPORT CARD',
          subtitle: 'Official Performance Transcript & Marksheet',
          scopeDescription:
              'Student: ${studentResult.studentName} (${studentResult.rollNumber})',
        ),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
          ),
        ),
        build: (ctx) => [
          // Student Profile Card
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _altRowColor,
              border: pw.Border.all(color: _borderColor),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'STUDENT NAME',
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: _mutedColor,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      studentResult.studentName,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'EXAMINATION',
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: _mutedColor,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      studentResult.examTitle,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'ROLL NUMBER',
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: _mutedColor,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      studentResult.rollNumber,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: _textColor,
                      ),
                    ),
                    if (className != null && className.isNotEmpty) ...[
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'CLASS',
                        style: const pw.TextStyle(
                          fontSize: 7,
                          color: _mutedColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        className,
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // Academic Performance Banner
          pw.Row(
            children: [
              _buildKpiBox(
                'Marks Obtained',
                studentResult.totalObtained.toStringAsFixed(1),
              ),
              _buildKpiBox(
                'Total Maximum',
                studentResult.totalMaximum.toStringAsFixed(0),
              ),
              _buildKpiBox(
                'Percentage',
                '${studentResult.percentage.toStringAsFixed(1)}%',
                valueColor: isPassed
                    ? const PdfColor(0.08, 0.64, 0.29)
                    : const PdfColor(0.86, 0.15, 0.15),
              ),
              _buildKpiBox(
                'Overall Grade',
                grade,
                valueColor: isPassed
                    ? const PdfColor(0.08, 0.64, 0.29)
                    : const PdfColor(0.86, 0.15, 0.15),
              ),
              _buildKpiBox(
                'Result Status',
                isPassed ? 'PASSED' : 'FAILED',
                valueColor: isPassed
                    ? const PdfColor(0.08, 0.64, 0.29)
                    : const PdfColor(0.86, 0.15, 0.15),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // Subject-wise Detailed Breakdown Table
          pw.Text(
            'Subject-wise Evaluation',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: _textColor,
            ),
          ),
          pw.SizedBox(height: 6),

          pw.TableHelper.fromTextArray(
            headers: [
              'Subject',
              'Maximum',
              'Passing',
              'Obtained',
              'Status',
              'Remarks',
            ],
            data: studentResult.subjectResults.map((sub) {
              final subPassed = sub.isAbsent
                  ? false
                  : (sub.marksObtained != null &&
                        sub.marksObtained! >= sub.passingMarks);
              final obtainedStr = sub.isAbsent
                  ? 'ABSENT'
                  : (sub.marksObtained != null
                        ? sub.marksObtained!.toStringAsFixed(1)
                        : '-');
              final statusStr = sub.isAbsent
                  ? 'ABSENT'
                  : (subPassed ? 'PASS' : 'FAIL');

              return [
                sub.subjectName,
                sub.maxMarks.toStringAsFixed(0),
                sub.passingMarks.toStringAsFixed(0),
                obtainedStr,
                statusStr,
                sub.remarks ??
                    (subPassed ? 'Satisfactory' : 'Needs improvement'),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: _primaryColor),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.center,
              5: pw.Alignment.centerLeft,
            },
            rowDecoration: const pw.BoxDecoration(color: PdfColors.white),
            oddRowDecoration: const pw.BoxDecoration(color: _altRowColor),
            cellPadding: const pw.EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 6,
            ),
          ),
          pw.SizedBox(height: 16),

          // Grading Scale Legend
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: pw.BoxDecoration(
              color: _altRowColor,
              border: pw.Border.all(color: _borderColor),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Text(
                  'Grading System: ',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                pw.Text(
                  'A+ (>=80%)',
                  style: const pw.TextStyle(fontSize: 7, color: _mutedColor),
                ),
                pw.Text(
                  'A (70-79%)',
                  style: const pw.TextStyle(fontSize: 7, color: _mutedColor),
                ),
                pw.Text(
                  'B (60-69%)',
                  style: const pw.TextStyle(fontSize: 7, color: _mutedColor),
                ),
                pw.Text(
                  'C (50-59%)',
                  style: const pw.TextStyle(fontSize: 7, color: _mutedColor),
                ),
                pw.Text(
                  'D (33-49%)',
                  style: const pw.TextStyle(fontSize: 7, color: _mutedColor),
                ),
                pw.Text(
                  'F (<33%)',
                  style: const pw.TextStyle(fontSize: 7, color: _mutedColor),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 36),

          // Signatures Block
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 140,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: _textColor, width: 1),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Class Teacher Signature',
                    style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 90,
                    height: 36,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: _borderColor),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'INSTITUTION STAMP',
                      style: const pw.TextStyle(
                        fontSize: 6.5,
                        color: _mutedColor,
                      ),
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Container(
                    width: 140,
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(color: _textColor, width: 1),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Principal Signature',
                    style: const pw.TextStyle(fontSize: 8, color: _mutedColor),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  // Print or Preview
  Future<void> previewOrPrintPdf(
    BuildContext context,
    Uint8List pdfBytes, {
    required String title,
    required String fileName,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PdfPreviewScreen(
          title: title,
          fileName: fileName,
          pdfBytes: pdfBytes,
        ),
      ),
    );
  }
}
