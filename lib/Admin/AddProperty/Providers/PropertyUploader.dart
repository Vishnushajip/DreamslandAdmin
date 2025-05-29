// ignore_for_file: unused_result

import 'dart:convert';
import 'package:dladmin/Admin/AddProperty/GalleryUploadPage.dart';
import 'package:dladmin/Admin/AddProperty/Providers/Genrate_id.dart';
import 'package:dladmin/Admin/AddProperty/Providers/gallery_upload_provider.dart';
import 'package:dladmin/Admin/AddProperty/Providers/owner_info_provider.dart';
import 'package:dladmin/Admin/AddProperty/Providers/property_form_provider.dart';
import 'package:dladmin/Admin/AddProperty/Providers/property_listing_provider.dart';
import 'package:dladmin/Admin/AddProperty/Providers/status_description_provider.dart';
import 'package:dladmin/Admin/DashBoard/Providers/navigation_provider.dart';
import 'package:dladmin/Landing/floating_bottom_navigation_bar.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Services/action_logger.dart';

final propertyUploadProvider = StateNotifierProvider<PropertyUploader, bool>(
  (ref) => PropertyUploader(),
);

class PropertyUploader extends StateNotifier<bool> {
  PropertyUploader() : super(false);

  Future<bool> uploadProperty({
    required Map<String, String> fields,
    required List<String> imageUrls,
  }) async {
    state = true;

    try {
      final uri = Uri.parse('https://api-fxz7qcfy4q-uc.a.run.app/upload');

      final body = {...fields, 'images': imageUrls};

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      state = false;

      if (response.statusCode == 201) {
        print("✅ Upload successful");
        return true;
      } else {
        print("❌ Upload failed: ${response.statusCode} ${response.body}");
        return false;
      }
    } catch (e) {
      print("🔥 Upload error: $e");
      state = false;
      return false;
    }
  }
}

void submitProperty(WidgetRef ref, context) async {
  final uploader = ref.read(propertyUploadProvider.notifier);
  final value = ref.read(propertyFormProvider);
  final model = ref.read(propertyListingProvider);
  final form = ref.read(statusDescriptionProvider);
  final owner = ref.read(ownerInfoProvider);
  final image = ref.read(imageUploadProvider);
  final imageUrls = image.downloadUrls;
  final prefs = await SharedPreferences.getInstance();
  prefs.getString('username');

  if (imageUrls.isEmpty) {
    print("No images uploaded yet.");
    return;
  }
  final idGenerator = ref.read(uniqueIdProvider);
  final newId = idGenerator.generateId();
  final name = value.name;
  final location = value.location;
  final price = model.price;
  final bhk = model.bhk;
  final sqft = model.sqft;
  final plotArea = model.area;
  final unit = model.unit;
  final status = form.status;
  final verified = form.verified;
  final type = value.type;
  final subtype = value.subtype;
  final pricingOption = form.note;
  final description = form.description;
  final ownerName = owner.name;
  final phoneNumber = owner.phone;
  final whatsappNumber = owner.whatsapp;
  final listed = model.listedOn;
  final id = newId;
  final agentid = model.builder;

  final success = await uploader.uploadProperty(
    fields: {
      "location": location ?? "",
      "name": name ?? "",
      "type": type ?? "",
      "subtype": subtype ?? "",
      "bhk": bhk ?? "0",
      "sqft": sqft ?? "0",
      "price": price ?? "",
      "plotArea": plotArea ?? '',
      "unit": unit ?? "",
      "listedOn": listed.toIso8601String(),
      "status": status ?? "",
      "Pricingoptions": pricingOption ?? "",
      "propertyDescription": description ?? "",
      "ownerName": ownerName ?? "",
      "phoneNumber": phoneNumber ?? "",
      "whatsappNumber": whatsappNumber ?? "",
      "propertyId": id,
      "verified": verified ?? "",
      "agent": agentid ?? "",
    },
    imageUrls: imageUrls,
  );

  if (success) {
    await ActionLogger.log(action: "$agentid. Added New Property With ID:$id");
    ref.refresh(agentPropertiesProvider);
    print("✅ Property uploaded successfully.");
    final prefs = await SharedPreferences.getInstance();
    final builder = prefs.getString('builder');
    if (builder == 'builder') {
      prefs.remove('builder');
    }

    Fluttertoast.showToast(
      msg: "✅ Property uploaded successfully.",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
    ref.refresh(propertyFormProvider);
    ref.refresh(propertyListingProvider);
    ref.refresh(statusDescriptionProvider);
    ref.refresh(ownerInfoProvider);
    ref.refresh(imageUploadProvider);
    ref.refresh(imageloadingProvider);
    ref.refresh(uniqueIdProvider);
    ref.refresh(navigationProvider);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navbar()),
      );
    
  } else {
    print("❌ Failed to upload property.");
  }
}
