import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/staff_list_controller.dart';
import '../../data/models/staff_member.dart';

class StaffSearchSection extends ConsumerStatefulWidget {
  const StaffSearchSection({super.key});

  @override
  ConsumerState<StaffSearchSection> createState() => StaffSearchSectionState();
}

class StaffSearchSectionState extends ConsumerState<StaffSearchSection> {
  int _page = 1;
  String _query = '';

  Future<void> refresh() async {
    await ref.read(staffListControllerProvider(page: _page).notifier).refresh();
  }

  void _exportStub() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Export — coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final staffAsync = ref.watch(staffListControllerProvider(page: _page));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('All Staff',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search Staff',
                        prefixIcon: Icon(Icons.search, size: 20),
                        isDense: true,
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _exportStub,
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text('Export'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              staffAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('Failed to load staff: $e', style: const TextStyle(color: Colors.red)),
                ),
                data: (staffList) => _buildTableAndPagination(staffList),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableAndPagination(List<StaffMember> staffList) {
    final filtered = _query.isEmpty
        ? staffList
        : staffList.where((s) {
            final q = _query.toLowerCase();
            return s.fullName.toLowerCase().contains(q) ||
                (s.designation?.toLowerCase().contains(q) ?? false);
          }).toList();

    if (staffList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('No staff members yet')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Full Name')),
              DataColumn(label: Text('Designation')),
              DataColumn(label: Text('Join Date')),
              DataColumn(label: Text('Status')),
            ],
            rows: filtered
                .map((s) => DataRow(cells: [
                      DataCell(Text(s.fullName)),
                      DataCell(Text(s.designation ?? '-')),
                      DataCell(Text(s.joinDate == null
                          ? '-'
                          : '${s.joinDate!.year}-${s.joinDate!.month.toString().padLeft(2, '0')}-${s.joinDate!.day.toString().padLeft(2, '0')}')),
                      DataCell(Text(
                        s.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(color: s.isActive ? Colors.green : Colors.grey),
                      )),
                    ]))
                .toList(),
          ),
        ),
        const SizedBox(height: 12),
        if (_query.isEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _page > 1 ? () => setState(() => _page -= 1) : null,
              ),
              Text('Page $_page'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: staffList.length == staffPageSize
                    ? () => setState(() => _page += 1)
                    : null,
              ),
            ],
          ),
      ],
    );
  }
}