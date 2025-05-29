import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

final adminloginControllerProvider =
    StateNotifierProvider<LoginController, LoginState>((ref) {
  return LoginController();
});

class LoginState {
  final bool isLoading;
  final String? error;

  LoginState({this.isLoading = false, this.error});

  LoginState copyWith({bool? isLoading, String? error}) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(LoginState());

  Future<bool> login(String username, String password) async {
    print("🔐 Logging in with: $username / $password");

    state = state.copyWith(isLoading: true, error: null);

    try {
      final query = await FirebaseFirestore.instance
          .collection('admin')
          .where('Username', isEqualTo: username)
          .where('Password', isEqualTo: password)
          .get();

      print("📦 Query completed. Docs returned: ${query.docs.length}");

      if (query.docs.isNotEmpty) {
        final rawDoc = query.docs.first;
        final Map<String, dynamic> data = rawDoc.data();
        final fetchedUsername = data['username']?.toString() ?? 'Unknown';
        final fetchedPassword = data['password']?.toString() ?? 'Not provided';

        print("✅ Logged in as: $fetchedUsername");
        print("🔑 Password: $fetchedPassword");

        state = state.copyWith(isLoading: false);
        return true;
      } else {
        Fluttertoast.showToast(
          msg: "❌ Invalid username or password.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        state = state.copyWith(isLoading: false, error: 'Invalid credentials');
        return false;
      }
    } catch (e, stacktrace) {
      print("🔥 Login error: $e");
      print("📉 Stacktrace: $stacktrace");
      state = state.copyWith(isLoading: false, error: 'Error: $e');
      return false;
    }
  }
}
