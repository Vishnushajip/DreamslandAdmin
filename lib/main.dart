import 'package:dladmin/Admin/Add_Agent/pages/Agents.dart';
import 'package:dladmin/Admin/DashBoard/Pages/Fetch_location.dart';
import 'package:dladmin/Admin/DashBoard/Providers/admin_Fetch_All.dart';
import 'package:dladmin/Admin/DashBoard/Verfied_Tabs/verfied_docs.dart';
import 'package:dladmin/Login/Splashscreen.dart';
import 'package:dladmin/Services/Providers/activityLogsProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final container = ProviderContainer();

  try {
    container.read(adminallpropertyprovider);
    container.read(propertiesProvider);
    container.read(agentsProvider); 
    container.read(activityLogsProvider);
    container.read(propertyProvider("Verified by Admin"));
    print("✅ Data prefetched successfully.");
  } catch (e) {
    print("❌ Error prefetching data: $e");
  }

  runApp(ProviderScope(parent: container, child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: Color(0xFF273847),
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      debugShowCheckedModeBanner: false,
      title: 'Admin App',
      home: const SplashScreen(),
    );
  }
}
