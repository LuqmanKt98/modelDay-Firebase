import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:new_flutter/models/event.dart';
import 'package:new_flutter/models/job.dart';
import 'package:new_flutter/models/agent.dart';
import 'package:new_flutter/models/agency.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ExportService {
  static const String _csvSeparator = ',';

  // Export events to CSV
  static Future<void> exportEvents(List<Event> events, {String? filename}) async {
    try {
      final csvData = _generateEventsCsv(events);
      final fileName = filename ?? 'events_${_getTimestamp()}.csv';
      
      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting events: $e');
      rethrow;
    }
  }

  // Export jobs to CSV
  static Future<void> exportJobs(List<Job> jobs, {String? filename}) async {
    try {
      final csvData = _generateJobsCsv(jobs);
      final fileName = filename ?? 'jobs_${_getTimestamp()}.csv';
      
      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting jobs: $e');
      rethrow;
    }
  }

  // Export agents to CSV
  static Future<void> exportAgents(List<Agent> agents, {String? filename}) async {
    try {
      final csvData = _generateAgentsCsv(agents);
      final fileName = filename ?? 'agents_${_getTimestamp()}.csv';
      
      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting agents: $e');
      rethrow;
    }
  }

  // Export agencies to CSV
  static Future<void> exportAgencies(List<Agency> agencies, {String? filename}) async {
    try {
      final csvData = _generateAgenciesCsv(agencies);
      final fileName = filename ?? 'agencies_${_getTimestamp()}.csv';
      
      if (kIsWeb) {
        await _downloadWebFile(csvData, fileName);
      } else {
        await _shareFile(csvData, fileName);
      }
    } catch (e) {
      debugPrint('Error exporting agencies: $e');
      rethrow;
    }
  }

  // Generate CSV for events
  static String _generateEventsCsv(List<Event> events) {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln([
      'Type',
      'Client Name',
      'Date',
      'End Date',
      'Start Time',
      'End Time',
      'Location',
      'Day Rate',
      'Usage Rate',
      'Currency',
      'Status',
      'Payment Status',
      'Option Status',
      'Notes',
      'Created Date'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final event in events) {
      buffer.writeln([
        event.type.displayName,
        event.clientName ?? '',
        event.date != null ? DateFormat('yyyy-MM-dd').format(event.date!) : '',
        event.endDate != null ? DateFormat('yyyy-MM-dd').format(event.endDate!) : '',
        event.startTime ?? '',
        event.endTime ?? '',
        event.location ?? '',
        event.dayRate?.toString() ?? '',
        event.usageRate?.toString() ?? '',
        event.currency ?? '',
        event.status?.toString().split('.').last ?? '',
        event.paymentStatus?.toString().split('.').last ?? '',
        event.optionStatus?.toString().split('.').last ?? '',
        event.notes ?? '',
        event.createdDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(event.createdDate!) : '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for jobs
  static String _generateJobsCsv(List<Job> jobs) {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln([
      'Client Name',
      'Type',
      'Date',
      'Time',
      'End Time',
      'Location',
      'Rate',
      'Currency',
      'Payment Status',
      'Status',
      'Notes',
      'Created Date'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final job in jobs) {
      buffer.writeln([
        job.clientName,
        job.type,
        job.createdDate != null ? DateFormat('yyyy-MM-dd').format(job.createdDate!) : '',
        job.time ?? '',
        job.endTime ?? '',
        job.location,
        job.rate.toString(),
        job.currency ?? '',
        job.paymentStatus ?? '',
        job.status ?? '',
        job.notes ?? '',
        job.createdDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(job.createdDate!) : '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for agents
  static String _generateAgentsCsv(List<Agent> agents) {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln([
      'Name',
      'Email',
      'Phone',
      'Agency',
      'City',
      'Country',
      'Instagram',
      'Notes',
      'Created Date'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final agent in agents) {
      buffer.writeln([
        agent.name,
        agent.email ?? '',
        agent.phone ?? '',
        agent.agency ?? '',
        agent.city ?? '',
        agent.country ?? '',
        agent.instagram ?? '',
        agent.notes ?? '',
        agent.createdDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(agent.createdDate!) : '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Generate CSV for agencies
  static String _generateAgenciesCsv(List<Agency> agencies) {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln([
      'Name',
      'Type',
      'Website',
      'Address',
      'City',
      'Country',
      'Commission Rate',
      'Main Booker Name',
      'Main Booker Email',
      'Main Booker Phone',
      'Finance Contact Name',
      'Finance Contact Email',
      'Finance Contact Phone',
      'Contract Signed',
      'Contract Expired',
      'Status',
      'Notes',
      'Created Date'
    ].map(_escapeCsvField).join(_csvSeparator));

    // Data rows
    for (final agency in agencies) {
      buffer.writeln([
        agency.name,
        agency.agencyType ?? '',
        agency.website ?? '',
        agency.address ?? '',
        agency.city ?? '',
        agency.country ?? '',
        agency.commissionRate.toString(),
        agency.mainBooker?.name ?? '',
        agency.mainBooker?.email ?? '',
        agency.mainBooker?.phone ?? '',
        agency.financeContact?.name ?? '',
        agency.financeContact?.email ?? '',
        agency.financeContact?.phone ?? '',
        agency.contractSigned != null ? DateFormat('yyyy-MM-dd').format(agency.contractSigned!) : '',
        agency.contractExpired != null ? DateFormat('yyyy-MM-dd').format(agency.contractExpired!) : '',
        agency.status ?? '',
        agency.notes ?? '',
        agency.createdDate != null ? DateFormat('yyyy-MM-dd HH:mm').format(agency.createdDate!) : '',
      ].map(_escapeCsvField).join(_csvSeparator));
    }

    return buffer.toString();
  }

  // Escape CSV field (handle commas, quotes, newlines)
  static String _escapeCsvField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }

  // Get timestamp for filename
  static String _getTimestamp() {
    return DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  }

  // Share file on mobile/desktop
  static Future<void> _shareFile(String content, String filename) async {
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: Use share_plus
      await SharePlus.instance.share(ShareParams(text: content));
    } else {
      // Desktop: Save to downloads folder
      final directory = await getDownloadsDirectory();
      if (directory != null) {
        final file = File('${directory.path}/$filename');
        await file.writeAsString(content);
        debugPrint('File saved to: ${file.path}');
      }
    }
  }

  // Download file on web
  static Future<void> _downloadWebFile(String content, String filename) async {
    try {
      // Create data URL with CSV content
      final bytes = utf8.encode(content);
      final base64Data = base64Encode(bytes);
      final dataUrl = 'data:text/csv;charset=utf-8;base64,$base64Data';

      // Create download URL
      final downloadUrl = Uri.parse(dataUrl);

      if (await canLaunchUrl(downloadUrl)) {
        await launchUrl(
          downloadUrl,
          mode: LaunchMode.platformDefault,
        );
        debugPrint('Web download initiated for: $filename');
      } else {
        debugPrint('Could not launch download URL for web');

        // Fallback: Try to open in new tab
        await launchUrl(
          downloadUrl,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Web download error: $e');
      // Additional fallback: show content in new tab
      try {
        final contentUrl = Uri.dataFromString(
          content,
          mimeType: 'text/csv',
          encoding: utf8,
        );
        await launchUrl(contentUrl, mode: LaunchMode.externalApplication);
      } catch (fallbackError) {
        debugPrint('Fallback web download also failed: $fallbackError');
      }
    }
  }
}
