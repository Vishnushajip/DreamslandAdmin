import 'package:flutter_riverpod/flutter_riverpod.dart';

class PropertyFormModel {
  String? location;
  String? name;
  String? type;
  String? subtype;

  PropertyFormModel({this.location, this.name, this.type, this.subtype});
}

class PropertyFormNotifier extends StateNotifier<PropertyFormModel> {
  PropertyFormNotifier() : super(PropertyFormModel());

  void setLocation(String value) => state = PropertyFormModel(
      location: value, name: state.name, type: state.type, subtype: state.subtype);

  void setName(String value) => state = PropertyFormModel(
      location: state.location, name: value, type: state.type, subtype: state.subtype);

  void setType(String value) => state = PropertyFormModel(
      location: state.location, name: state.name, type: value, subtype: state.subtype);

  void setSubtype(String value) => state = PropertyFormModel(
      location: state.location, name: state.name, type: state.type, subtype: value);
}

final propertyFormProvider = StateNotifierProvider<PropertyFormNotifier, PropertyFormModel>(
  (ref) => PropertyFormNotifier(),
);
