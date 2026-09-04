import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cms/core/utils/error_utils.dart';
import '../../application/add_calendar_entry_controller.dart';
import '../../data/models/calendar_entry_create_request.dart';

class AddCalendarEntryScreen extends ConsumerStatefulWidget {
  const AddCalendarEntryScreen({super.key});

  @override
  ConsumerState<AddCalendarEntryScreen> createState() => _AddCalendarEntryScreenState();
}

class _AddCalendarEntryScreenState extends ConsumerState<AddCalendarEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _isRange = false;
  DateTime? _singleDate;
  DateTime? _rangeFrom;
  DateTime? _rangeTo;
  String _type = 'holiday';
  bool _attendanceRequired = false;
  dynamic _result;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickSingleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _singleDate = picked);
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: (_rangeFrom != null && _rangeTo != null)
          ? DateTimeRange(start: _rangeFrom!, end: _rangeTo!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _rangeFrom = picked.start;
        _rangeTo = picked.end;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isRange && _singleDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick a date')));
      return;
    }
    if (_isRange && (_rangeFrom == null || _rangeTo == null)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please pick a date range')));
      return;
    }

    final request = CalendarEntryCreateRequest(
      date: _isRange ? null : _singleDate,
      dateFrom: _isRange ? _rangeFrom : null,
      dateTo: _isRange ? _rangeTo : null,
      type: _type,
      title: _titleController.text.trim(),
      attendanceRequired: _attendanceRequired,
    );

    final result =
        await ref.read(addCalendarEntryControllerProvider.notifier).createEntries(request);
    if (!mounted || result == null) return;
    setState(() => _result = result);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addCalendarEntryControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Calendar Entry')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Single Date'),
                    selected: !_isRange,
                    onSelected: (v) => setState(() => _isRange = false),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Date Range'),
                    selected: _isRange,
                    onSelected: (v) => setState(() => _isRange = true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_isRange)
                InkWell(
                  onTap: _pickSingleDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Text(_singleDate == null ? 'Tap to select' : _fmt(_singleDate!)),
                  ),
                )
              else
                InkWell(
                  onTap: _pickRange,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date Range'),
                    child: Text((_rangeFrom == null || _rangeTo == null)
                        ? 'Tap to select'
                        : '${_fmt(_rangeFrom!)} to ${_fmt(_rangeTo!)}'),
                  ),
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'holiday', child: Text('Holiday')),
                  DropdownMenuItem(value: 'event', child: Text('Event')),
                  DropdownMenuItem(value: 'half_day', child: Text('Half Day')),
                ],
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Attendance Required'),
                subtitle: const Text('On for a half-day where classes still run'),
                value: _attendanceRequired,
                onChanged: (v) => setState(() => _attendanceRequired = v),
              ),
              const SizedBox(height: 24),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('Failed: ${friendlyErrorMessage(state.error!)}',
                      style: const TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Create'),
              ),
              if (_result != null) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Created ${_result.created.length} entr${_result.created.length == 1 ? 'y' : 'ies'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (_result.skipped.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Skipped', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  ...List.generate(
                    _result.skipped.length,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '${_result.skipped[i].date}: ${_result.skipped[i].reason}',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Done'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}