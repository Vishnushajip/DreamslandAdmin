import 'package:flutter_riverpod/flutter_riverpod.dart';

class PropertyListingModel {
  final String? bhk;
  final String? sqft;
  final String? price;
  final String? area;
  final String? unit;
  final DateTime listedOn;

  PropertyListingModel({
    this.bhk,
    this.sqft,
    this.price,
    this.area,
    this.unit,
    DateTime? listedOn,
  }) : listedOn = listedOn ?? DateTime.now();

  PropertyListingModel copyWith({
    String? bhk,
    String? sqft,
    String? price,
    String? area,
    String? unit,
    DateTime? listedOn,
  }) {
    return PropertyListingModel(
      bhk: bhk ?? this.bhk,
      sqft: sqft ?? this.sqft,
      price: price ?? this.price,
      area: area ?? this.area,
      unit: unit ?? this.unit,
      listedOn: listedOn ?? this.listedOn,
    );
  }
}

class PropertyListingNotifier extends StateNotifier<PropertyListingModel> {
  PropertyListingNotifier() : super(PropertyListingModel());

  void setBHK(String val) => state = state.copyWith(bhk: val);
  void setSqft(String val) => state = state.copyWith(sqft: val);
  void setPrice(String val) => state = state.copyWith(price: val);
  void setArea(String val) => state = state.copyWith(area: val);
  void setUnit(String val) => state = state.copyWith(unit: val);
  void setListedOn(DateTime val) => state = state.copyWith(listedOn: val);
}

final propertyListingProvider =
    StateNotifierProvider<PropertyListingNotifier, PropertyListingModel>(
      (ref) => PropertyListingNotifier(),
    );
