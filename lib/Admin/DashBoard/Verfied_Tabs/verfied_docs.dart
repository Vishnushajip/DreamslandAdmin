// ignore_for_file: unused_result

import 'dart:convert';
import 'dart:io';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class AgentPropertyNotifier
    extends StateNotifier<AsyncValue<List<AgentProperty>>> {
  final String status;
  static const String baseUrl = 'https://api-fxz7qcfy4q-uc.a.run.app';
  static const String updateStatusEndpoint = '/updateVerificationStatus';

  AgentPropertyNotifier(this.status) : super(const AsyncValue.loading()) {
    fetchPropertiesByStatus();
  }

  Future<void> fetchPropertiesByStatus() async {
    try {
      if (!mounted) return;
      state = const AsyncValue.loading();

      final response = await http.get(
        Uri.parse('$baseUrl/getVerifiedDocuments?status=$status'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> responseData = jsonData['data']['documents'];
        final properties =
            responseData.map((json) => AgentProperty.fromJson(json)).toList();

        if (!mounted) return; 
        state = AsyncValue.data(properties);
      } else {
        throw HttpException('Failed to fetch properties');
      }
    } catch (e) {
      if (!mounted) return;
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> updatePropertyStatus({
    required String propertyId,
    required String newStatus,
    required WidgetRef ref,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$updateStatusEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'propertyId': propertyId, 'status': newStatus}),
      );

      if (response.statusCode == 200) {
        await fetchPropertiesByStatus();
        ref.refresh(propertyProvider(status));
      } else {
        throw HttpException('Failed to update status');
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> approveProperty(String propertyId, WidgetRef ref) async {
    await updatePropertyStatus(
      propertyId: propertyId,
      newStatus: 'Verified by Admin',
      ref: ref,
    );
  }

  Future<void> rejectProperty(String propertyId, WidgetRef ref) async {
    await updatePropertyStatus(
      ref: ref,
      propertyId: propertyId,
      newStatus: 'Rejected by Admin',
    );
  }
}

final propertyProvider = StateNotifierProvider.family.autoDispose<
  AgentPropertyNotifier,
  AsyncValue<List<AgentProperty>>,
  String
>((ref, status) => AgentPropertyNotifier(status));
