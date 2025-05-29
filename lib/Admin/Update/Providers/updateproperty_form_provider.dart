import 'package:dladmin/Services/Fetch_docs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class updatemodel {
  final String? id;
  final String? location;
  final String? name;
  final String? type;
  final String? subtype;
  final int? bhk;
  final String? sqft;
  final num? price;
  final String? plotArea;
  final String? unit;
  final int? listedOn;
  final String? status;
  final String? agent;
  final String? pricingOptions;
  final String? propertyDescription;
  final List<String>? images;
  final int? createdAt;
  final int? updatedAt;
  final String? ownerName;
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? propertyId;

  const updatemodel({
    this.id,
    this.location,
    this.name,
    this.type,
    this.subtype,
    this.bhk,
    this.sqft,
    this.price,
    this.plotArea,
    this.unit,
    this.listedOn,
    this.status,
    this.agent,
    this.pricingOptions,
    this.propertyDescription,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
    this.phoneNumber,
    this.whatsappNumber,
    this.propertyId,
  });

  updatemodel copyWith({
    String? id,
    String? location,
    String? name,
    String? type,
    String? subtype,
    int? bhk,
    String? sqft,
    num? price,
    String? plotArea,
    String? unit,
    int? listedOn,
    String? status,
    String? agent,
    String? pricingOptions,
    String? propertyDescription,
    List<String>? images,
    int? createdAt,
    int? updatedAt,
    String? ownerName,
    String? phoneNumber,
    String? whatsappNumber,
    String? propertyId,
  }) {
    return updatemodel(
      id: id ?? this.id,
      location: location ?? this.location,
      name: name ?? this.name,
      type: type ?? this.type,
      subtype: subtype ?? this.subtype,
      bhk: bhk ?? this.bhk,
      sqft: sqft ?? this.sqft,
      price: price ?? this.price,
      plotArea: plotArea ?? this.plotArea,
      unit: unit ?? this.unit,
      listedOn: listedOn ?? this.listedOn,
      status: status ?? this.status,
      agent: agent ?? this.agent,
      pricingOptions: pricingOptions ?? this.pricingOptions,
      propertyDescription: propertyDescription ?? this.propertyDescription,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ownerName: ownerName ?? this.ownerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      propertyId: propertyId ?? this.propertyId,
    );
  }
}

class PropertyFormNotifier extends StateNotifier<updatemodel> {
  PropertyFormNotifier() : super(const updatemodel());

  void initializeFromProperty(AgentProperty property) {
    state = state.copyWith(
      id: property.id,
      location: property.location,
      name: property.name,
      type: property.type,
      subtype: property.subtype,
      bhk: property.bhk,
      sqft: property.sqft,
      price: property.price,
      plotArea: property.plotArea,
      unit: property.unit,
      listedOn: property.listedOn,
      status: property.status,
      agent: property.agent,
      pricingOptions: property.pricingOptions,
      propertyDescription: property.propertyDescription,
      images: property.images,
      createdAt: property.createdAt.millisecondsSinceEpoch,
      updatedAt: property.updatedAt.millisecondsSinceEpoch,
      ownerName: property.ownerName,
      phoneNumber: property.phoneNumber,
      whatsappNumber: property.whatsappNumber,
      propertyId: property.propertyId,
    );
  }

  void setLocation(String value) => state = state.copyWith(location: value);
  void setName(String value) => state = state.copyWith(name: value);
  void setType(String value) => state = state.copyWith(type: value);
  void setSubtype(String value) => state = state.copyWith(subtype: value);
  void setBHK(int value) => state = state.copyWith(bhk: value);
  void setPrice(num value) => state = state.copyWith(price: value);
  void setPlotArea(String value) => state = state.copyWith(plotArea: value);
  void setUnit(String value) => state = state.copyWith(unit: value);
  void setSqft(String value) => state = state.copyWith(sqft: value);
  void setPhoneNumber(String value) =>
      state = state.copyWith(phoneNumber: value);
  void setWhatsAppNumber(String value) =>
      state = state.copyWith(whatsappNumber: value);
  void setOwnerName(String value) => state = state.copyWith(ownerName: value);
  void setStatus(String value) => state = state.copyWith(status: value);
  void setDescription(String value) =>
      state = state.copyWith(propertyDescription: value);
  void setImages(List<String> list) => state = state.copyWith(images: list);
  void setPricingOptions(String value) =>
      state = state.copyWith(pricingOptions: value);
  void setListedOn(int timestamp) =>
      state = state.copyWith(listedOn: timestamp);
}

final updatepropertyFormProvider =
    StateNotifierProvider<PropertyFormNotifier, updatemodel>(
  (ref) => PropertyFormNotifier(),
);
