import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusDescriptionModel {
  String? status;
  String? note;
  String? description;
  String? verified;

  StatusDescriptionModel({
    this.status,
    this.note,
    this.description,
    this.verified,
  });
}

class StatusDescriptionNotifier extends StateNotifier<StatusDescriptionModel> {
  StatusDescriptionNotifier() : super(StatusDescriptionModel());

  void setStatus(String value) => state = StatusDescriptionModel(
      status: value,
      note: state.note,
      description: state.description,
      verified: state.verified,
      );

  void setNote(String value) => state = StatusDescriptionModel(
      status: state.status,
      note: value,
      description: state.description,
      verified: state.verified,
      );

  void setDescription(String value) => state = StatusDescriptionModel(
      status: state.status,
      note: state.note,
      description: value,
      verified: state.verified,
      );

  void setVerified(String value) => state = StatusDescriptionModel(
      status: state.status,
      note: state.note,
      description: state.description,
      verified: value,
      );
}

final statusDescriptionProvider =
    StateNotifierProvider<StatusDescriptionNotifier, StatusDescriptionModel>(
  (ref) => StatusDescriptionNotifier(),
);