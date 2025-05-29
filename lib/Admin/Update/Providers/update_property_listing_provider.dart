import 'package:flutter_riverpod/flutter_riverpod.dart';

class PropertyListingModel {
  String? bhk;
  String? sqft;
  String? price;
  String? area;
  String? unit;
  DateTime listedOn;

  PropertyListingModel({
    this.bhk,
    this.sqft,
    this.price,
    this.area,
    this.unit,
    DateTime? listedOn,
  }) : listedOn = listedOn ?? DateTime.now();
}

class PropertyListingNotifier extends StateNotifier<PropertyListingModel> {
  PropertyListingNotifier() : super(PropertyListingModel());

  void setBHK(String val) => state = PropertyListingModel(
    bhk: val,
    sqft: state.sqft,
    price: state.price,
    area: state.area,
    unit: state.unit,
    listedOn: state.listedOn,
  );

  void setSqft(String val) => state = PropertyListingModel(
    bhk: state.bhk,
    sqft: val,
    price: state.price,
    area: state.area,
    unit: state.unit,
    listedOn: state.listedOn,
  );

  void setPrice(String val) => state = PropertyListingModel(
    bhk: state.bhk,
    sqft: state.sqft,
    price: val,
    area: state.area,
    unit: state.unit,
    listedOn: state.listedOn,
  );

  void setArea(String val) => state = PropertyListingModel(
    bhk: state.bhk,
    sqft: state.sqft,
    price: state.price,
    area: val,
    unit: state.unit,
    listedOn: state.listedOn,
  );

  void setUnit(String val) => state = PropertyListingModel(
    bhk: state.bhk,
    sqft: state.sqft,
    price: state.price,
    area: state.area,
    unit: val,
    listedOn: state.listedOn,
  );

  void setListedOn(DateTime val) => state = PropertyListingModel(
    bhk: state.bhk,
    sqft: state.sqft,
    price: state.price,
    area: state.area,
    unit: state.unit,
    listedOn: val,
  );
}

final updatepropertyListingProvider =
    StateNotifierProvider<PropertyListingNotifier, PropertyListingModel>(
  (ref) => PropertyListingNotifier(),
);
