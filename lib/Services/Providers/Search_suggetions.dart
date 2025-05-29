import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final searchPropertyProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, query) async {
  if (query.trim().isEmpty) return [];

  final response = await http.get(
    Uri.parse("https://api-fxz7qcfy4q-uc.a.run.app/searchproperty?searchQuery=$query"),
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);

    final List<dynamic> data =
        decoded is List ? decoded : (decoded['data'] ?? []);

    return data.cast<Map<String, dynamic>>();
  } else {
    throw Exception('Failed to fetch search results');
  }
});
