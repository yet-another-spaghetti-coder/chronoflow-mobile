import 'dart:convert';
import 'dart:io';

import 'package:chronoflow/core/constants.dart';
import 'package:chronoflow/providers/auth_provider.dart';
import 'package:chronoflow/providers/storage_provider.dart';
import 'package:chronoflow/services/pinned_http_client.dart';
import 'package:chronoflow/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : Colors.green.shade800,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleAuthError() async {
    _showSnackBar('Session expired. Please sign in again.', isError: true);
    await ref.read(authProvider.notifier).signOut();
    if (mounted) {
      await Navigator.pushReplacementNamed(context, Constants.authScreen);
    }
  }

  String _getErrorMessage(dynamic error, int? statusCode, Map<String, dynamic>? payload) {
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }
    if (error is FormatException) {
      return 'Invalid response from server. Please try again.';
    }
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return payload?['msg']?.toString().isNotEmpty ?? false
              ? payload!['msg'].toString()
              : 'Bad request. Please check your input.';
        case 401:
          return 'Session expired. Please sign in again.';
        case 403:
          return 'You do not have permission to perform this action.';
        case 404:
          return 'Event not found. It may have been deleted.';
        case 409:
          return payload?['msg']?.toString().isNotEmpty ?? false
              ? payload!['msg'].toString()
              : 'Conflict. The event may already exist.';
        case 422:
          return payload?['msg']?.toString().isNotEmpty ?? false
              ? payload!['msg'].toString()
              : 'Invalid data. Please check your input.';
        case 429:
          return 'Too many requests. Please wait a moment.';
        case >= 500:
          return 'Server error. Please try again later.';
        default:
          return payload?['msg']?.toString().isNotEmpty ?? false
              ? payload!['msg'].toString()
              : 'An unexpected error occurred (HTTP $statusCode).';
      }
    }
    return 'Something went wrong. Please try again.';
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

    return null;
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cookieHeader = await _getCookieHeader();
      if (cookieHeader == null) {
        setState(() {
          _errorMessage = 'No auth cookie found. Please sign in again.';
          _isLoading = false;
        });
        _showSnackBar('Please sign in to view events.', isError: true);
        return;
      }

      final response = await PinnedHttpClient.get(
        Uri.parse('${Constants.chronoflowBackend}/events'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Cookie': cookieHeader,
        },
      );

      if (response.statusCode == 401) {
        await _handleAuthError();
        return;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final code = payload['code'];
      final data = payload['data'];

      if (mounted) {
        setState(() {
          if (response.statusCode == 200 && code == 0 && data is List) {
            _events = data.whereType<Map<String, dynamic>>().toList();
          } else {
            _errorMessage = _getErrorMessage(null, response.statusCode, payload);
            _showSnackBar(_errorMessage!, isError: true);
          }
          _isLoading = false;
        });
      }
    } on SocketException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e, null, null);
          _isLoading = false;
        });
        _showSnackBar(_errorMessage!, isError: true);
      }
    } on FormatException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e, null, null);
          _isLoading = false;
        });
        _showSnackBar(_errorMessage!, isError: true);
      }
    } on Exception catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to retrieve events: $e';
          _isLoading = false;
        });
        _showSnackBar(_errorMessage!, isError: true);
      }
    }
  }

  String _toUtcIsoWithoutMillis(DateTime dt) {
    return dt.toUtc().toIso8601String().replaceFirst(RegExp(r'\.\d{3}Z$'), 'Z');
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } on Exception catch (_) {
        return null;
      }
    }
    return null;
  }

  String _formatDateTime(String? iso) {
    if (iso == null || iso == '-') return '-';
    try {
      final dt = DateTime.parse(iso);
      final yyyy = dt.year.toString().padLeft(4, '0');
      final mm = dt.month.toString().padLeft(2, '0');
      final dd = dt.day.toString().padLeft(2, '0');
      final hh = dt.hour.toString().padLeft(2, '0');
      final mi = dt.minute.toString().padLeft(2, '0');
      return '$dd/$mm/$yyyy $hh:$mi';
    } on Exception catch (_) {
      return iso;
    }
  }

  String _getStatusLabel(int? status) {
    switch (status) {
      case 0:
        return 'Inactive';
      case 1:
        return 'Active';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Future<void> _createEvent() async {
    final result = await _showEventForm();
    if (result == null) return;

    final cookieHeader = await _getCookieHeader();
    if (cookieHeader == null) {
      if (!mounted) return;
      _showSnackBar('No auth cookie found. Please sign in again.', isError: true);
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      final response = await PinnedHttpClient.post(
        Uri.parse('${Constants.chronoflowBackend}/events'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Cookie': cookieHeader,
        },
        body: jsonEncode(result),
      );

      if (response.statusCode == 401) {
        await _handleAuthError();
        return;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final ok = response.statusCode == 200 && payload['code'] == 0;

      if (!mounted) return;
      if (ok) {
        _showSnackBar('Event created successfully!');
        await _loadEvents();
      } else {
        final msg = _getErrorMessage(null, response.statusCode, payload);
        _showSnackBar(msg, isError: true);
      }
    } on SocketException catch (e) {
      if (!mounted) return;
      _showSnackBar(_getErrorMessage(e, null, null), isError: true);
    } on FormatException catch (e) {
      if (!mounted) return;
      _showSnackBar(_getErrorMessage(e, null, null), isError: true);
    } on Exception catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to create event: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }

  Future<void> _editEvent(Map<String, dynamic> event) async {
    final result = await _showEventForm(event: event);
    if (result == null) return;

    final eventId = event['id'];
    if (eventId == null) {
      if (!mounted) return;
      _showSnackBar('Event ID missing.', isError: true);
      return;
    }

    final cookieHeader = await _getCookieHeader();
    if (cookieHeader == null) {
      if (!mounted) return;
      _showSnackBar('No auth cookie found. Please sign in again.', isError: true);
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final response = await PinnedHttpClient.patch(
        Uri.parse('${Constants.chronoflowBackend}/events/$eventId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Cookie': cookieHeader,
        },
        body: jsonEncode(result),
      );

      if (response.statusCode == 401) {
        await _handleAuthError();
        return;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final ok = response.statusCode == 200 && payload['code'] == 0;

      if (!mounted) return;
      if (ok) {
        _showSnackBar('Event updated successfully!');
        await _loadEvents();
      } else {
        final msg = _getErrorMessage(null, response.statusCode, payload);
        _showSnackBar(msg, isError: true);
      }
    } on SocketException catch (e) {
      if (!mounted) return;
      _showSnackBar(_getErrorMessage(e, null, null), isError: true);
    } on FormatException catch (e) {
      if (!mounted) return;
      _showSnackBar(_getErrorMessage(e, null, null), isError: true);
    } on Exception catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to update event: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _deleteEvent(Map<String, dynamic> event) async {
    final eventId = event['id'];
    final eventName = (event['name'] ?? 'Unnamed event').toString();

    if (eventId == null) {
      if (!mounted) return;
      _showSnackBar('Event ID missing.', isError: true);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "$eventName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final cookieHeader = await _getCookieHeader();
    if (cookieHeader == null) {
      if (!mounted) return;
      _showSnackBar('No auth cookie found. Please sign in again.', isError: true);
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      final response = await PinnedHttpClient.delete(
        Uri.parse('${Constants.chronoflowBackend}/events/$eventId'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Cookie': cookieHeader,
        },
      );

      if (response.statusCode == 401) {
        await _handleAuthError();
        return;
      }

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final ok = response.statusCode == 200 && payload['code'] == 0;

      if (!mounted) return;
      if (ok) {
        _showSnackBar('"$eventName" deleted successfully!');
        await _loadEvents();
      } else {
        final msg = _getErrorMessage(null, response.statusCode, payload);
        _showSnackBar(msg, isError: true);
      }
    } on SocketException catch (e) {
      if (!mounted) return;
      _showSnackBar(_getErrorMessage(e, null, null), isError: true);
    } on FormatException catch (e) {
      if (!mounted) return;
      _showSnackBar(_getErrorMessage(e, null, null), isError: true);
    } on Exception catch (e) {
      if (!mounted) return;
      _showSnackBar('Failed to delete event: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>?> _showEventForm({Map<String, dynamic>? event}) async {
    final isEdit = event != null;
    final nameController = TextEditingController(text: event?['name']?.toString() ?? '');
    final descriptionController = TextEditingController(text: event?['description']?.toString() ?? '');
    final locationController = TextEditingController(text: event?['location']?.toString() ?? '');
    final remarkController = TextEditingController(text: event?['remark']?.toString() ?? '');
    var startAt = _parseDateTime(event?['startTime']);
    var endAt = _parseDateTime(event?['endTime']);

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
              title: Text(isEdit ? 'Edit Event' : 'Create Event'),
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
                  onPressed: () {
                    final name = nameController.text.trim();
                    final location = locationController.text.trim();
                    if (name.isEmpty || location.isEmpty || startAt == null || endAt == null) {
                      _showSnackBar('Please fill all required fields.', isError: true);
                      return;
                    }
                    if (endAt!.isBefore(startAt!)) {
                      _showSnackBar('End time cannot be before start time.', isError: true);
                      return;
                    }
                    Navigator.pop(dialogContext, true);
                  },
                  child: Text(isEdit ? 'Save' : 'Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (submitted != true) return null;

    return {
      'name': nameController.text.trim(),
      'description': descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
      'location': locationController.text.trim(),
      'startTime': _toUtcIsoWithoutMillis(startAt!),
      'endTime': _toUtcIsoWithoutMillis(endAt!),
      'remark': remarkController.text.trim().isEmpty ? null : remarkController.text.trim(),
    };
  }

  Future<void> _handleSignOut(BuildContext context) async {
    await ref.read(authProvider.notifier).signOut();
    if (context.mounted) {
      await Navigator.pushReplacementNamed(context, Constants.authScreen);
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'View and manage all events within your organisation. You can create new events, update details, track participants, and monitor progress — all in one place.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _isCreating ? null : _createEvent,
              icon: _isCreating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add),
              label: const Text('Create Event'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final name = (event['name'] ?? '').toString();
    final location = (event['location'] ?? '-').toString();
    final startTime = _formatDateTime(event['startTime']?.toString());
    final endTime = _formatDateTime(event['endTime']?.toString());
    final status = event['status'] as int?;
    final groups = event['groups'];
    final groupCount = (groups is List) ? groups.length : 0;
    final participants = event['joiningParticipants'] ?? 0;
    final taskStatus = event['taskStatus'];
    final taskStatusMap = taskStatus is Map<String, dynamic> ? taskStatus : null;
    final totalTasks = (taskStatusMap?['total'] as int?) ?? 0;
    final completedTasks = (taskStatusMap?['completed'] as int?) ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getStatusColor(status)),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _isUpdating ? null : () => _editEvent(event),
                  icon: _isUpdating
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: _isDeleting ? null : () => _deleteEvent(event),
                  icon: _isDeleting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete, size: 18, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name.isEmpty ? 'Unnamed event' : name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, 'Location', location),
            _buildInfoRow(Icons.calendar_today, 'Start', startTime),
            _buildInfoRow(Icons.calendar_today, 'End', endTime),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatChip(Icons.group, 'Groups', groupCount.toString()),
                const SizedBox(width: 8),
                _buildStatChip(Icons.people, 'Participants', participants.toString()),
                const SizedBox(width: 8),
                _buildStatChip(Icons.task_alt, 'Tasks', '$completedTasks/$totalTasks'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
          Text(value, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text('$label: $value'),
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadEvents,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No events found.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap "Create Event" to add one.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              children: [
                _buildHeader(),
                _buildEventCard(_events[index]),
              ],
            );
          }
          return _buildEventCard(_events[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return Scaffold(
            body: Row(
              children: [
                MainDrawer(
                  color: Colors.white.withValues(alpha: 0.9),
                  signOut: () => _handleSignOut(context),
                ),
                Expanded(child: _buildBody()),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Event Management')),
          drawer: MainDrawer(
            color: Colors.white.withValues(alpha: 0.9),
            signOut: () => _handleSignOut(context),
          ),
          body: _buildBody(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _isCreating ? null : _createEvent,
            icon: _isCreating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.add),
            label: const Text('Create Event'),
          ),
        );
      },
    );
  }
}
