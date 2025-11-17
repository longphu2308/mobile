import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mobile/User/presentation/widgets/widgets.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:mobile/User/utils/assets.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/config/routes.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 4.0),
                        blurRadius: 30.0,
                        color: blackColor.withValues(alpha: 0.06),
                      ),
                    ],
                    color: whiteColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding + 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Center(
                          child: Image.asset(
                            FoodieAssets.logo,
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TabBar(
                        tabs: [
                          Tab(text: FoodieStrings.login),
                          Tab(text: FoodieStrings.signUp),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              YBox(30),
              Expanded(
                flex: 4,
                child: TabBarView(
                  children: [_LogInSection(), _SignUpSection()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogInSection extends StatefulWidget {
  @override
  State<_LogInSection> createState() => _LogInSectionState();
}

class _LogInSectionState extends State<_LogInSection> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Consumer<AuthController>(
          builder: (context, authController, _) {
            return Column(
              children: [
                FoodieTextField(
                  label: FoodieStrings.email,
                  hint: 'example@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  enabled: !authController.isLoading,
                ),
                YBox(25),
                FoodieTextField(
                  label: FoodieStrings.password,
                  hint: '**********',
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  controller: _passwordController,
                  enabled: !authController.isLoading,
                ),
                YBox(15),
                // Hiển thị error message nếu có
                if (authController.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      authController.errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: authController.isLoading ? null : () {},
                    borderRadius: BorderRadius.circular(radius),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5.0, 0, 5.0),
                      child: Text(
                        FoodieStrings.forgotPasscode,
                        style: TextStyle(color: primaryColor, fontSize: 15),
                      ),
                    ),
                  ),
                ),
                YBox(50),
                authController.isLoading
                    ? CircularProgressIndicator()
                    : FoodieButton(
                        text: FoodieStrings.login,
                        onPressed: () async {
                          // Validate input
                          if (_emailController.text.isEmpty ||
                              _passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Vui lòng điền đầy đủ thông tin'),
                              ),
                            );
                            return;
                          }

                          // Call signIn
                          bool success = await authController.signIn(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );

                          if (success && mounted) {
                            // Check user role and navigate to appropriate dashboard
                            final user = authController.currentUser;
                            final route = (user?.role == 'owner')
                                ? ownerDashboardRoute
                                : userDashboardRoute;

                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              route,
                              (route) => false,
                            );
                          }
                        },
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SignUpSection extends StatefulWidget {
  @override
  State<_SignUpSection> createState() => _SignUpSectionState();
}

class _SignUpSectionState extends State<_SignUpSection> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Consumer<AuthController>(
          builder: (context, authController, _) {
            return Column(
              children: [
                FoodieTextField(
                  label: FoodieStrings.name,
                  hint: 'Phu Tran',
                  keyboardType: TextInputType.text,
                  controller: _nameController,
                  enabled: !authController.isLoading,
                ),
                YBox(25),
                FoodieTextField(
                  label: FoodieStrings.email,
                  hint: 'example@gmail.com',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  enabled: !authController.isLoading,
                ),
                YBox(25),
                FoodieTextField(
                  label: FoodieStrings.phone,
                  hint: '0123456789',
                  keyboardType: TextInputType.number,
                  controller: _phoneController,
                  enabled: !authController.isLoading,
                ),
                YBox(25),
                FoodieTextField(
                  label: FoodieStrings.password,
                  hint: '**********',
                  keyboardType: TextInputType.emailAddress,
                  obscureText: true,
                  controller: _passwordController,
                  enabled: !authController.isLoading,
                ),
                YBox(15),
                // Hiển thị error message nếu có
                if (authController.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      authController.errorMessage!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                YBox(50),
                authController.isLoading
                    ? CircularProgressIndicator()
                    : FoodieButton(
                        text: FoodieStrings.signUp,
                        onPressed: () async {
                          // Validate input
                          if (_nameController.text.isEmpty ||
                              _emailController.text.isEmpty ||
                              _phoneController.text.isEmpty ||
                              _passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Vui lòng điền đầy đủ thông tin bắt buộc',
                                ),
                              ),
                            );
                            return;
                          }

                          // Validate email format
                          if (!_isValidEmail(_emailController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Email không hợp lệ')),
                            );
                            return;
                          }

                          // Validate password length
                          if (_passwordController.text.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Mật khẩu phải có ít nhất 6 ký tự',
                                ),
                              ),
                            );
                            return;
                          }

                          // Call signUp
                          bool success = await authController.signUp(
                            email: _emailController.text,
                            password: _passwordController.text,
                            fullName: _nameController.text,
                            phone: _phoneController.text,
                          );

                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đăng ký thành công'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Check user role and navigate to appropriate dashboard
                            final user = authController.currentUser;
                            final route = (user?.role == 'owner')
                                ? ownerDashboardRoute
                                : userDashboardRoute;

                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              route,
                              (route) => false,
                            );
                          }
                        },
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
