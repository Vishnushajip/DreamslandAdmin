import 'dart:convert';
import 'package:dladmin/Admin/Update/Pages/Update_More_Details.dart';
import 'package:dladmin/Admin/Update/Providers/updateproperty_form_provider.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyRepository {
  final String baseUrl = "https://api-fxz7qcfy4q-uc.a.run.app/property";

  Future<AgentProperty> updatePropertyWithForm(
      String id, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/$id");

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return AgentProperty.fromJson(json);
    } else {
      throw Exception("Update failed: ${response.body}");
    }
  }
}

final updateProvider = Provider((ref) => PropertyRepository());

final isUpdatingProvider = StateProvider<bool>((ref) => false);

final updateFromFormProvider =
    FutureProvider.family<AgentProperty, String>((ref, id) async {
  final repository = ref.read(updateProvider);
  final form = ref.read(updatepropertyFormProvider);
  final prefs = await SharedPreferences.getInstance();
  final savedAgent = prefs.getString('username');
  final providerAgent = ref.read(agentUsernameProvider);
  final formAgent = form.agent;
  final agent =
      savedAgent?.isNotEmpty ?? false ? savedAgent : providerAgent ?? formAgent;

  if (id.isEmpty) throw Exception("Property ID is missing");

  final data = {
    "location": form.location,
    "name": form.name,
    "type": form.type,
    "subtype": form.subtype,
    "bhk": form.bhk,
    "sqft": form.sqft,
    "price": form.price,
    "plotArea": form.plotArea,
    "unit": form.unit,
    "listedOn": form.listedOn,
    "status": form.status,
    "agent": agent,
    "Pricingoptions": form.pricingOptions,
    "propertyDescription": form.propertyDescription,
    // "images": form.images,
    "ownerName": form.ownerName,
    "phoneNumber": form.phoneNumber,
    "whatsappNumber": form.whatsappNumber,
    "propertyId": form.propertyId,
  };

  return await repository.updatePropertyWithForm(id, data);
});
