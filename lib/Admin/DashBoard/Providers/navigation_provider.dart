import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppPage {
  dashboard,
  addAgent,
  addLocation,
  propertyverfyreq,
  propertyrejected,
  propertyverified,
  deletedproperties,}

final navigationProvider = StateProvider<AppPage>((ref) => AppPage.dashboard);
