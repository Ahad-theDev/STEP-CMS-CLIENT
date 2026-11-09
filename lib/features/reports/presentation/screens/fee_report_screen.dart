import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/theme/campus_page.dart';
import 'package:cms/core/theme/campus_style.dart';
import 'package:cms/features/classes/application/all_classes_controller.dart';
import 'package:cms/features/reports/application/reports_repository_provider.dart';
import 'package:cms/features/reports/data/models/fee_report_model.dart';
import 'package:cms/features/reports/services/report_pdf_service.dart';

class FeeReportScreen extends ConsumerStatefulWidget {
  const FeeReportScreen({super.key});

  @override
  ConsumerState<FeeReportScreen> createState() => _FeeReportScreenState();
}

class _FeeReportScreenState extends ConsumerState<FeeReportScreen> {
  String? _selectedClassId;
  String? _selectedStatus; // null = all, or 'paid', 'partial', 'pending', 'overdue'
  String _searchQuery = '';

  Future<FeeReport>? _reportFuture;
  FeeReport? _loadedReport;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  void _generateReport() {
    final repo = ref.read(reportsRepositoryProvider);
    setState(() {
      _reportFuture = repo.getFeeReport(
        classId: _selectedClassId,
      );
    });
  }

  Future<void> _exportPdf() async {
    if (_loadedReport == null) return;
    setState(() => _isExporting = true);
    try {
      final scope = _selectedClassId != null
          ? 'Class Fee Report (ID: $_selectedClassId)'
          : 'All Classes';
      final pdfBytes = await ReportPdfService.instance
          .generateFeePdf(_loadedReport!, scopeDescription: scope);
      if (!mounted) return;
      await ReportPdfService.instance.previewOrPrintPdf(
        context,
        pdfBytes,
        title: 'Fee Collection Report',
        fileName: 'fee_collection_report.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export PDF: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF2E7D32);
      case 'partial':
        return Colors.orange.shade800;
      case 'overdue':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green.shade50;
      case 'partial':
        return Colors.orange.shade50;
      case 'overdue':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(allClassesControllerProvider);

    return CampusPage(
      appBar: AppBar(
        title: const Text('Fee Collection & Defaulters'),
        actions: [
          if (_loadedReport != null)
            IconButton(
              tooltip: 'Export PDF / Print',
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded),
              onPressed: _isExporting ? null : _exportPdf,
            ),
        ],
      ),
      body: CampusScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CampusSectionIntro(
              title: 'Fee Revenue & Receivables',
              subtitle:
                  'Monitor tuition fee collections, outstanding receivables, recovery rate, and student defaulters.',
            ),
            const SizedBox(height: 16),

            // Filter Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 650;
                        final classDropdown = classesAsync.when(
                          data: (classes) {
                            final activeClasses =
                                classes.where((c) => c.isActive).toList();
                            return DropdownButtonFormField<String?>(
                              initialValue: _selectedClassId,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Select Class',
                                prefixIcon: Icon(Icons.class_rounded),
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All Classes'),
                                ),
                                ...activeClasses.map((c) => DropdownMenuItem(
                                      value: c.id,
                                      child: Text('${c.name} - ${c.section}'),
                                    )),
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedClassId = val),
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => Text('Error: $e'),
                        );

                        final statusDropdown =
                            DropdownButtonFormField<String?>(
                          initialValue: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Fee Status',
                            prefixIcon: Icon(Icons.filter_list_rounded),
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Statuses'),
                            ),
                            DropdownMenuItem(value: 'paid', child: Text('Paid')),
                            DropdownMenuItem(
                                value: 'partial', child: Text('Partial')),
                            DropdownMenuItem(
                                value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(
                                value: 'overdue', child: Text('Overdue')),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedStatus = val),
                        );

                        if (isDesktop) {
                          return Row(
                            children: [
                              Expanded(flex: 3, child: classDropdown),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: statusDropdown),
                              const SizedBox(width: 12),
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                ),
                                onPressed: _generateReport,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Update'),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              classDropdown,
                              const SizedBox(height: 12),
                              statusDropdown,
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _generateReport,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Generate Report'),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Output
            if (_reportFuture != null)
              FutureBuilder<FeeReport>(
                future: _reportFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(48),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    final err = snapshot.error
                        .toString()
                        .replaceFirst('Exception: ', '');
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.error_outline_rounded,
                                size: 48, color: Colors.red.shade400),
                            const SizedBox(height: 12),
                            Text(
                              'Failed to generate fee report',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(err, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  }

                  final report = snapshot.data;
                  if (report == null) return const SizedBox.shrink();
                  _loadedReport = report;

                  final summary = report.summary;
                  final students = report.students;

                  final filteredStudents = students.where((s) {
                    if (_selectedStatus != null &&
                        _selectedStatus!.isNotEmpty &&
                        s.paymentStatus.toLowerCase() !=
                            _selectedStatus!.toLowerCase()) {
                      return false;
                    }
                    if (_searchQuery.isEmpty) return true;
                    final q = _searchQuery.toLowerCase();
                    return s.studentName.toLowerCase().contains(q) ||
                        s.rollNumber.toLowerCase().contains(q);
                  }).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KPI Row
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 700;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildKpiCard(
                                'Total Fee Due',
                                'PKR ${summary.totalFeeDue.toStringAsFixed(0)}',
                                Icons.receipt_long_rounded,
                                CampusStyle.primary,
                                isWide,
                              ),
                              _buildKpiCard(
                                'Fee Collected',
                                'PKR ${summary.totalFeeSubmitted.toStringAsFixed(0)}',
                                Icons.check_circle_rounded,
                                const Color(0xFF2E7D32),
                                isWide,
                              ),
                              _buildKpiCard(
                                'Outstanding',
                                'PKR ${summary.outstandingFee.toStringAsFixed(0)}',
                                Icons.pending_actions_rounded,
                                summary.outstandingFee > 0
                                    ? Colors.red.shade700
                                    : const Color(0xFF2E7D32),
                                isWide,
                              ),
                              _buildKpiCard(
                                'Collection Rate',
                                '${summary.collectionPercentage.toStringAsFixed(1)}%',
                                Icons.trending_up_rounded,
                                summary.collectionPercentage >= 80
                                    ? const Color(0xFF2E7D32)
                                    : Colors.orange.shade800,
                                isWide,
                              ),
                              _buildKpiCard(
                                'Unpaid Records',
                                '${summary.unpaidRecords}',
                                Icons.warning_amber_rounded,
                                summary.unpaidRecords > 0
                                    ? Colors.red.shade700
                                    : const Color(0xFF2E7D32),
                                isWide,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // Section Header & Search
                      Row(
                        children: [
                          Text(
                            'Student Fee Roster (${filteredStudents.length})',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: CampusStyle.ink,
                                ),
                          ),
                          const Spacer(),
                          FilledButton.tonalIcon(
                            onPressed: _isExporting ? null : _exportPdf,
                            icon: const Icon(Icons.picture_as_pdf_rounded,
                                size: 18),
                            label: const Text('Export PDF'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Search student by name or roll number...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onChanged: (val) =>
                            setState(() => _searchQuery = val.trim()),
                      ),
                      const SizedBox(height: 12),

                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowHeight: 44,
                              dataRowMinHeight: 44,
                              dataRowMaxHeight: 52,
                              columns: const [
                                DataColumn(label: Text('Roll #')),
                                DataColumn(label: Text('Student Name')),
                                DataColumn(label: Text('Total Due')),
                                DataColumn(label: Text('Fee Paid')),
                                DataColumn(label: Text('Outstanding')),
                                DataColumn(label: Text('Status')),
                              ],
                              rows: filteredStudents.map((st) {
                                final status = st.unpaidRecords > 0
                                    ? 'OVERDUE'
                                    : (st.outstandingFee == 0
                                        ? 'PAID'
                                        : 'PARTIAL');
                                final color = _getStatusColor(status);
                                final bgColor = _getStatusBgColor(status);

                                return DataRow(
                                  cells: [
                                    DataCell(Text(st.rollNumber,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold))),
                                    DataCell(Text(st.studentName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600))),
                                    DataCell(Text(
                                        'PKR ${st.totalFeeDue.toStringAsFixed(0)}')),
                                    DataCell(Text(
                                        'PKR ${st.totalFeeSubmitted.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                            color: Color(0xFF2E7D32)))),
                                    DataCell(Text(
                                        'PKR ${st.outstandingFee.toStringAsFixed(0)}',
                                        style: TextStyle(
                                            color: st.outstandingFee > 0
                                                ? Colors.red.shade700
                                                : Colors.black,
                                            fontWeight: FontWeight.bold))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(
      String label, String value, IconData icon, Color color, bool isWide) {
    return Container(
      width: isWide ? 170 : 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
