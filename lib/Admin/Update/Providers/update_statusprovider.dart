import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusDescriptionModel {
  String? status;
  String? note;
  String? description;

  StatusDescriptionModel({
    this.status,
    this.note,
    this.description,
  });
}

class StatusDescriptionNotifier extends StateNotifier<StatusDescriptionModel> {
  StatusDescriptionNotifier() : super(StatusDescriptionModel());

  void setStatus(String value) => state = StatusDescriptionModel(
      status: value,
      note: state.note,
      description: state.description,
      );

  void setNote(String value) => state = StatusDescriptionModel(
      status: state.status,
      note: value,
      description: state.description,
      );

  void setDescription(String value) => state = StatusDescriptionModel(
      status: state.status,
      note: state.note,
      description: value,
      );
}

final updatestatusDescriptionProvider =
    StateNotifierProvider<StatusDescriptionNotifier, StatusDescriptionModel>(
  (ref) => StatusDescriptionNotifier(),
);
