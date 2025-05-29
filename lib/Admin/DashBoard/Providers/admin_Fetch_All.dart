import 'dart:convert';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:http/http.dart'as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminallpropertyprovider = FutureProvider<List<AgentProperty>>((ref) async {
  final uri = Uri.parse('https://api-fxz7qcfy4q-uc.a.run.app/getProperties');
  final res = await http.get(uri);

  if (res.statusCode == 200) {
    final List<dynamic> data = jsonDecode(res.body);
    return data.map((json) => AgentProperty.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load properties');
  }
});
