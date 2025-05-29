import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerInfoModel {
  String? name;
  String? phone;
  String? whatsapp;

  OwnerInfoModel({this.name, this.phone, this.whatsapp});
}

class OwnerInfoNotifier extends StateNotifier<OwnerInfoModel> {
  OwnerInfoNotifier() : super(OwnerInfoModel());

  void setName(String val) =>
      state = OwnerInfoModel(name: val, phone: state.phone, whatsapp: state.whatsapp);

  void setPhone(String val) =>
      state = OwnerInfoModel(name: state.name, phone: val, whatsapp: state.whatsapp);

  void setWhatsapp(String val) =>
      state = OwnerInfoModel(name: state.name, phone: state.phone, whatsapp: val);
}

final ownerInfoProvider =
    StateNotifierProvider<OwnerInfoNotifier, OwnerInfoModel>(
        (ref) => OwnerInfoNotifier());
