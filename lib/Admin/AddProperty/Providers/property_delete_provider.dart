// ignore_for_file: unused_result
import 'package:dladmin/Admin/AddProperty/Providers/delete_image_provider.dart';
import 'package:dladmin/Admin/DashBoard/Providers/admin_Fetch_All.dart';
import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyDeleteNotifier extends StateNotifier<Map<String, bool>> {
  final Dio _dio;
  final Ref ref;
  PropertyDeleteNotifier(this._dio, this.ref) : super({});

  Future<void> deleteProperty({
    required String propertyId,
    required String ownerName,
    required String phoneNumber,
    required String deletedBy,
    required String id,
    required String whatsapp,
    required List<String> imageurl,
  }) async {
    state = {...state, propertyId: true};

    try {
      final url =
          'https://api-fxz7qcfy4q-uc.a.run.app/deleteproperty/$propertyId';
      final response = await _dio.delete(url);

      if (response.statusCode == 200) {
        ref.refresh(adminallpropertyprovider);
        await _saveDeletionDetailsToFirestore(
          id: id,
          propertyId: propertyId,
          ownerName: ownerName,
          phoneNumber: phoneNumber,
          deletedBy: deletedBy,
          whatsapp: whatsapp,
        );
        ref.refresh(agentPropertiesProvider);

        ref.read(deleteImageProvider.notifier).deleteImages(imageurl);
        Fluttertoast.showToast(
          msg: "Property deleted successfully.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        throw Exception('Failed to delete the property');
      }
    } catch (error) {
      print(error);
      Fluttertoast.showToast(
        msg: "Error",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      state = {...state, propertyId: false};
    }
  }

  Future<void> _saveDeletionDetailsToFirestore({
    required String propertyId,
    required String ownerName,
    required String phoneNumber,
    required String deletedBy,
    required String id,
    required String whatsapp,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final now = Timestamp.fromDate(DateTime.now());

    await firestore.collection('deleted_properties').add({
      'propertyId': propertyId,
      'ownerName': ownerName,
      'phoneNumber': phoneNumber,
      'deletedBy': deletedBy,
      'whatsapp': whatsapp,
      'id': id,
      'deletedAt': now,
    });
  }
}

final dioProvider = Provider((ref) => Dio());

final propertyDeleteNotifierProvider =
    StateNotifierProvider<PropertyDeleteNotifier, Map<String, bool>>(
      (ref) => PropertyDeleteNotifier(ref.read(dioProvider), ref),
    );
