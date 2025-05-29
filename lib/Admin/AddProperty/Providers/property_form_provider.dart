import 'package:flutter_riverpod/flutter_riverpod.dart';

class PropertyFormModel {
  final String? location;
  final String? name;
  final String? type;
  final String? subtype;

  PropertyFormModel({this.location, this.name, this.type, this.subtype});

  PropertyFormModel copyWith({
    String? location,
    String? name,
    String? type,
    String? subtype,
  }) {
    return PropertyFormModel(
      location: location ?? this.location,
      name: name ?? this.name,
      type: type ?? this.type,
      subtype: subtype ?? this.subtype,
    );
  }
}
class PropertyFormNotifier extends StateNotifier<PropertyFormModel> {
  PropertyFormNotifier() : super(PropertyFormModel());

  void setLocation(String value) => state = state.copyWith(location: value);
  void setName(String value) => state = state.copyWith(name: value);
  void setType(String value) => state = state.copyWith(type: value);
  void setSubtype(String value) => state = state.copyWith(subtype: value);
}
final propertyFormProvider = StateNotifierProvider<PropertyFormNotifier, PropertyFormModel>(
  (ref) => PropertyFormNotifier(),
);
