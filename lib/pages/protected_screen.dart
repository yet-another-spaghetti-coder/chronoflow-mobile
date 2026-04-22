import 'dart:convert';

import 'package:chronoflow/core/constants.dart';
import 'package:chronoflow/providers/auth_provider.dart';
import 'package:chronoflow/providers/storage_provider.dart';
import 'package:chronoflow/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ProtectedEventsScreen extends ConsumerStatefulWidget {
  const ProtectedEventsScreen({super.key});

  @override
  ConsumerState<ProtectedEventsScreen> createState() => _ProtectedEventsScreenState();
}

class _ProtectedEventsScreenState extends ConsumerState<ProtectedEventsScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  bool _isCreating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProtectedEvents();
  }

  Future<void> _loadProtectedEvents() async {
    try {
      final cookieHeader = await _getCookieHeader();
      if (cookieHeader == null) {
        setState(() {
          _errorMessage = 'No auth cookie found. Please sign in again.';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${Constants.chronoflowBackend}/events'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Cookie': cookieHeader,
        },
      );
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final code = payload['code'];
      final data = payload['data'];

      if (mounted) {
        setState(() {
          if (response.statusCode == 200 && code == 0 && data is List) {
            _events = data.whereType<Map<String, dynamic>>().toList();
          } else {
            _errorMessage = (payload['msg']?.toString().isNotEmpty ?? false)
                ? payload['msg'].toString()
                : 'Failed to retrieve events.';
          }
          _isLoading = false;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to retrieve events.';
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _getCookieHeader() async {
    final storage = ref.read(secureStorageServiceProvider);
    final refreshCookie = await storage.getRefreshCookie();
    final authorizationCookie = await storage.getAuthorizationCookie();

    final parts = <String>[];

    if (refreshCookie != null && refreshCookie.isNotEmpty) {
      if (refreshCookie.contains('=')) {
        parts.add(refreshCookie);
      } else {
        parts.add('refreshToken=$refreshCookie');
      }
    }

    if (authorizationCookie != null && authorizationCookie.isNotEmpty) {
      if (authorizationCookie.contains('=')) {
        parts.add(authorizationCookie);
      } else {
        parts.add('Authorization=$authorizationCookie');
      }
    }

    if (parts.isNotEmpty) {
      return parts.join('; ');
    }

    // Backward compatibility for previously stored raw Set-Cookie format.
    final legacyRaw = await storage.getRefreshCookie();
    if (legacyRaw == null || legacyRaw.isEmpty) {
      return null;
    }
    final cookiePair = _extractCookiePair(legacyRaw);
    if (cookiePair == null) {
      return null;
    }
    return '${cookiePair.$1}=${cookiePair.$2}';
  }

  String _toUtcIsoWithoutMillis(DateTime dt) {
    return dt.toUtc().toIso8601String().replaceFirst(RegExp(r'\.\d{3}Z$'), 'Z');
  }

  Future<void> _openCreateEventForm() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final remarkController = TextEditingController();
    DateTime? startAt;
    DateTime? endAt;

    final submitted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickDateTime({required bool isStart}) async {
              final now = DateTime.now();
              final initial = (isStart ? startAt : endAt) ?? now;
              final date = await showDatePicker(
                context: context,
                initialDate: initial,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 5),
              );
              if (!context.mounted || date == null) return;
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.fromDateTime(initial),
              );
              if (!context.mounted || time == null) return;
              final selected = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );
              setDialogState(() {
                if (isStart) {
                  startAt = selected;
                } else {
                  endAt = selected;
                }
              });
            }

            String fmt(DateTime? dt) {
              if (dt == null) return 'Not selected';
              final yyyy = dt.year.toString().padLeft(4, '0');
              final mm = dt.month.toString().padLeft(2, '0');
              final dd = dt.day.toString().padLeft(2, '0');
              final hh = dt.hour.toString().padLeft(2, '0');
              final mi = dt.minute.toString().padLeft(2, '0');
              return '$yyyy-$mm-$dd $hh:$mi';
            }

            return AlertDialog(
              title: const Text('Create Event'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Event Name *'),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(labelText: 'Location *'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Description'),
                    ),
                    TextField(
                      controller: remarkController,
                      decoration: const InputDecoration(labelText: 'Remark'),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Start Time *'),
                      subtitle: Text(fmt(startAt)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => pickDateTime(isStart: true),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('End Time *'),
                      subtitle: Text(fmt(endAt)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => pickDateTime(isStart: false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final location = locationController.text.trim();
                    if (name.isEmpty || location.isEmpty || startAt == null || endAt == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields.')),
                      );
                      return;
                    }
                    if (endAt!.isBefore(startAt!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('End time cannot be before start time.')),
                      );
                      return;
                    }
                    Navigator.pop(dialogContext, true);
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted != true) return;

    final cookieHeader = await _getCookieHeader();
    if (cookieHeader == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No auth cookie found. Please sign in again.')),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${Constants.chronoflowBackend}/events'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Cookie': cookieHeader,
        },
        body: jsonEncode({
          'name': nameController.text.trim(),
          'description': descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
          'location': locationController.text.trim(),
          'startTime': _toUtcIsoWithoutMillis(startAt!),
          'endTime': _toUtcIsoWithoutMillis(endAt!),
          'remark': remarkController.text.trim().isEmpty ? null : remarkController.text.trim(),
        }),
      );

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final ok = response.statusCode == 200 && payload['code'] == 0;
      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully.')),
        );
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
        await _loadProtectedEvents();
      } else {
        final msg = (payload['msg']?.toString().isNotEmpty ?? false)
            ? payload['msg'].toString()
            : 'Failed to create event.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } on Exception catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create event.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  (String, String)? _extractCookiePair(String rawSetCookie) {
    var normalized = rawSetCookie.trim();
    final lower = normalized.toLowerCase();
    if (lower.startsWith('set-cookie:')) {
      normalized = normalized.substring('set-cookie:'.length).trim();
    }
    final firstCookie = normalized.split(',').first.trim();
    final firstSegment = firstCookie.split(';').first.trim();
    final separatorIndex = firstSegment.indexOf('=');
    if (separatorIndex <= 0 || separatorIndex == firstSegment.length - 1) {
      return null;
    }

    final name = firstSegment.substring(0, separatorIndex).trim();
    final value = firstSegment.substring(separatorIndex + 1).trim();
    if (name.isEmpty || value.isEmpty) {
      return null;
    }
    return (name, value);
  }

  Future<void> _handleSignOut(BuildContext context) async {
    await ref.read(authProvider.notifier).signOut();
    if (context.mounted) {
      await Navigator.pushReplacementNamed(context, Constants.authScreen);
    }
  }

  Widget _buildScreenBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_events.isEmpty) {
      return const Center(child: Text('No events found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final event = _events[index];
        final name = (event['name'] ?? '').toString();
        final location = (event['location'] ?? '-').toString();
        final startTime = (event['startTime'] ?? '-').toString();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.event),
            title: Text(name.isEmpty ? 'Unnamed event' : name),
            subtitle: Text('Location: $location\nStart: $startTime'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Scaffold(
            floatingActionButton: FloatingActionButton.extended(
              onPressed: _isCreating ? null : _openCreateEventForm,
              icon: _isCreating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add),
              label: const Text('Create Event'),
            ),
            body: Row(
              children: [
                MainDrawer(
                  color: Colors.white.withValues(alpha: 0.9),
                  signOut: () => _handleSignOut(context),
                ),
                Expanded(child: _buildScreenBody()),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('My events')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isCreating ? null : _openCreateEventForm,
            icon: _isCreating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add),
            label: const Text('Create Event'),
          ),
          drawer: MainDrawer(
            color: Colors.white.withValues(alpha: 0.9),
            signOut: () => _handleSignOut(context),
          ),
          body: _buildScreenBody(),
        );
      },
    );
  }
}
