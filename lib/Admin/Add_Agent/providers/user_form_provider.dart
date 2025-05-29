import 'package:flutter_riverpod/flutter_riverpod.dart';

final userFormProvider =
    StateNotifierProvider<UserFormNotifier, UserFormModel>(
  (ref) => UserFormNotifier(),
);

class UserFormModel {
  final String firstName;
  final String lastName;
  final String username;
  final String password;
  final String address;
  final String district;
  final String age;
  final String contactNumber;
  final String whatsappNumber;
  final List<String> allocatedLocations;

  const UserFormModel({
    this.firstName = '',
    this.lastName = '',
    this.username = '',
    this.password = '',
    this.address = '',
    this.district = '',
    this.age = '',
    this.contactNumber = '',
    this.whatsappNumber = '',
    this.allocatedLocations = const [],
  });

  UserFormModel copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? password,
    String? address,
    String? district,
    String? age,
    String? contactNumber,
    String? whatsappNumber,
    List<String>? allocatedLocations,
  }) {
    return UserFormModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      password: password ?? this.password,
      address: address ?? this.address,
      district: district ?? this.district,
      age: age ?? this.age,
      contactNumber: contactNumber ?? this.contactNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      allocatedLocations: allocatedLocations ?? this.allocatedLocations,
    );
  }
}

class UserFormNotifier extends StateNotifier<UserFormModel> {
  UserFormNotifier() : super(const UserFormModel());

  void updateField(String key, String value) {
    switch (key) {
      case 'firstName':
        state = state.copyWith(firstName: value);
        break;
      case 'lastName':
        state = state.copyWith(lastName: value);
        break;
      case 'username':
        state = state.copyWith(username: value);
        break;
      case 'password':
        state = state.copyWith(password: value);
        break;
      case 'address':
        state = state.copyWith(address: value);
        break;
      case 'district':
        state = state.copyWith(district: value);
        break;
      case 'age':
        state = state.copyWith(age: value);
        break;
      case 'contactNumber':
        state = state.copyWith(contactNumber: value);
        break;
      case 'whatsappNumber':
        state = state.copyWith(whatsappNumber: value);
        break;
    }
  }

  void addAllocatedLocation(String location) {
    if (!state.allocatedLocations.contains(location)) {
      state = state.copyWith(
        allocatedLocations: [...state.allocatedLocations, location],
      );
    }
  }

  void removeAllocatedLocation(String location) {
    final updatedList = [...state.allocatedLocations]..remove(location);
    state = state.copyWith(allocatedLocations: updatedList);
  }

  void setAllocatedLocations(List<String> locations) {
    state = state.copyWith(allocatedLocations: locations);
  }

  void resetForm() {
    state = const UserFormModel();
  }
}
