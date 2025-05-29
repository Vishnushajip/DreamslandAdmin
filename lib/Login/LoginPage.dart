// ignore_for_file: unused_result
import 'package:dladmin/Admin/AddProperty/Providers/Login_Provider.dart';
import 'package:dladmin/Admin/DashBoard/Custom/reusable_text_field.dart';
import 'package:dladmin/Landing/floating_bottom_navigation_bar.dart';
import 'package:dladmin/Services/Scaffold_Messanger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AgentLoginPageState createState() => _AgentLoginPageState();
}

class _AgentLoginPageState extends ConsumerState<AdminLoginPage> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(adminloginControllerProvider);
    final notifier = ref.read(adminloginControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width:
                            MediaQuery.of(context).size.width < 600
                                ? double.infinity
                                : 400,
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset('assets/logodream.png', height: 80),
                            const SizedBox(height: 16),
                            Text(
                              "Admin Login",
                              style: GoogleFonts.nunito(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ReusableTextField(
                              hint: "Enter your username",
                              label: "Enter your username",
                              controller: usernameController,
                            ),
                            const SizedBox(height: 16),
                            ReusableTextField(
                              text: true,
                              label: 'Password',
                              hint: "Password",
                              controller: passwordController,
                            ),
                            const SizedBox(height: 24),
                            controller.isLoading
                                ? LoadingAnimationWidget.threeArchedCircle(
                                  color: Color.fromARGB(255, 17, 70, 114),
                                  size: 25,
                                )
                                : SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      backgroundColor: Color.fromARGB(
                                        255,
                                        17,
                                        70,
                                        114,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final success = await notifier.login(
                                        usernameController.text.trim(),
                                        passwordController.text.trim(),
                                      );

                                      if (success && context.mounted) {
                                        CustomMessenger(
                                          duration: Duration(seconds: 1),
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          context: context,
                                          message: "Login successful",
                                        ).show;
                                        final prefs =
                                            await SharedPreferences.getInstance();
                                        await prefs.setString('role', 'admin');
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                            type:
                                                PageTransitionType.bottomToTop,
                                            child: Navbar(),
                                            duration: Duration(
                                              milliseconds: 400,
                                            ),
                                          ),
                                        );
                                        FocusScope.of(context).unfocus();
                                      } else if (controller.error != null) {
                                        if (controller.error != null &&
                                            controller.error!.isNotEmpty) {
                                          Fluttertoast.showToast(
                                            msg: controller.error!,
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0,
                                          );
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Login",
                                      style: GoogleFonts.nunito(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
