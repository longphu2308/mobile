import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile/User/presentation/widgets/widgets.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:mobile/User/utils/strings.dart';
import 'package:mobile/User/utils/assets.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/config/routes.dart';
import 'package:mobile/core/models/user_model.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Scaffold(
          backgroundColor: whiteColor,
          body: Column(
            children: [
              // Login image ở phía trên
              SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(radius),
                      bottomRight: Radius.circular(radius),
                    ),
                    child: Image.asset(
                      FoodieAssets.login,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        debugPrint('Error loading login.png: $error');
                        return Container(
                          height: 200,
                          padding: const EdgeInsets.all(20),
                          color: primaryColor,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                FoodieAssets.logo,
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // TabBar dưới ảnh
              Container(
                color: whiteColor,
                child: TabBar(
                  indicatorColor: primaryColor,
                  indicatorWeight: 3,
                  labelColor: primaryColor,
                  unselectedLabelColor: greyColor,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                  tabs: [
                    Tab(text: FoodieStrings.login),
                    Tab(text: FoodieStrings.signUp),
                  ],
                ),
              ),
              // Form content với background trắng
              Expanded(
                child: Container(
                  color: whiteColor,
                  child: TabBarView(
                    children: [_LogInSection(), _SignUpSection()],
                  ),
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
        child: GetBuilder<AuthController>(
          builder: (authController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
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
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  controller: _passwordController,
                  enabled: !authController.isLoading,
                ),
                YBox(15),
                if (authController.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      authController.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
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
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                YBox(50),
                authController.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                      )
                    : FoodieButton(
                        text: FoodieStrings.login,
                        onPressed: () async {
                          if (_emailController.text.isEmpty ||
                              _passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng điền đầy đủ thông tin'),
                              ),
                            );
                            return;
                          }
                          bool success = await authController.signIn(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          if (success && mounted) {
                            final user = authController.currentUser;
                            final route = (user?.role == UserRole.owner)
                                ? ownerDashboardRoute
                                : (user?.role == UserRole.shipper
                                      ? shipperDashboardRoute
                                      : userDashboardRoute);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              route,
                              (route) => false,
                            );
                          }
                        },
                      ),
                const SizedBox(height: 30),
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
  
  // Role-specific controllers
  late TextEditingController _vehicleTypeController;
  late TextEditingController _vehiclePlateController;
  late TextEditingController _licenseNumberController;
  late TextEditingController _restaurantNameController;
  late TextEditingController _restaurantAddressController;
  late TextEditingController _restaurantPhoneController;
  
  UserRole _selectedRole = UserRole.user;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _vehicleTypeController = TextEditingController();
    _vehiclePlateController = TextEditingController();
    _licenseNumberController = TextEditingController();
    _restaurantNameController = TextEditingController();
    _restaurantAddressController = TextEditingController();
    _restaurantPhoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _vehicleTypeController.dispose();
    _vehiclePlateController.dispose();
    _licenseNumberController.dispose();
    _restaurantNameController.dispose();
    _restaurantAddressController.dispose();
    _restaurantPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: GetBuilder<AuthController>(
          builder: (authController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                // Role Selection Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Loại tài khoản',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<UserRole>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: InputBorder.none,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: UserRole.user,
                            child: Text('Khách hàng'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.shipper,
                            child: Text('Shipper'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.owner,
                            child: Text('Chủ nhà hàng'),
                          ),
                        ],
                        onChanged: authController.isLoading ? null : (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                YBox(25),
                FoodieTextField(
                  label: FoodieStrings.name,
                  hint: 'Nguyen Van A',
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
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  enabled: !authController.isLoading,
                ),
                YBox(25),
                // Shipper-specific fields
                if (_selectedRole == UserRole.shipper) ...[
                  FoodieTextField(
                    label: 'Loại xe',
                    hint: 'Xe máy',
                    keyboardType: TextInputType.text,
                    controller: _vehicleTypeController,
                    enabled: !authController.isLoading,
                  ),
                  YBox(25),
                  FoodieTextField(
                    label: 'Biển số xe',
                    hint: '59A-12345',
                    keyboardType: TextInputType.text,
                    controller: _vehiclePlateController,
                    enabled: !authController.isLoading,
                  ),
                  YBox(25),
                  FoodieTextField(
                    label: 'Số bằng lái',
                    hint: 'B123456789',
                    keyboardType: TextInputType.text,
                    controller: _licenseNumberController,
                    enabled: !authController.isLoading,
                  ),
                  YBox(25),
                ],
                // Owner-specific fields
                if (_selectedRole == UserRole.owner) ...[
                  FoodieTextField(
                    label: 'Tên nhà hàng',
                    hint: 'Nhà hàng ABC',
                    keyboardType: TextInputType.text,
                    controller: _restaurantNameController,
                    enabled: !authController.isLoading,
                  ),
                  YBox(25),
                  FoodieTextField(
                    label: 'Địa chỉ nhà hàng',
                    hint: '123 Đường XYZ, Quận 1, TP.HCM',
                    keyboardType: TextInputType.text,
                    controller: _restaurantAddressController,
                    enabled: !authController.isLoading,
                  ),
                  YBox(25),
                  FoodieTextField(
                    label: 'Số điện thoại nhà hàng',
                    hint: '0287654321',
                    keyboardType: TextInputType.phone,
                    controller: _restaurantPhoneController,
                    enabled: !authController.isLoading,
                  ),
                  YBox(25),
                ],
                FoodieTextField(
                  label: FoodieStrings.password,
                  hint: '**********',
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  controller: _passwordController,
                  enabled: !authController.isLoading,
                ),
                YBox(15),
                if (authController.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      authController.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                YBox(50),
                authController.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor,
                          ),
                        ),
                      )
                    : FoodieButton(
                        text: FoodieStrings.signUp,
                        onPressed: () async {
                          // Validate basic fields
                          if (_nameController.text.isEmpty ||
                              _emailController.text.isEmpty ||
                              _phoneController.text.isEmpty ||
                              _passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Vui lòng điền đầy đủ thông tin bắt buộc',
                                ),
                              ),
                            );
                            return;
                          }
                          
                          // Validate role-specific fields
                          if (_selectedRole == UserRole.shipper) {
                            if (_vehicleTypeController.text.isEmpty ||
                                _vehiclePlateController.text.isEmpty ||
                                _licenseNumberController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vui lòng điền đầy đủ thông tin shipper',
                                  ),
                                ),
                              );
                              return;
                            }
                          }
                          
                          if (_selectedRole == UserRole.owner) {
                            if (_restaurantNameController.text.isEmpty ||
                                _restaurantAddressController.text.isEmpty ||
                                _restaurantPhoneController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Vui lòng điền đầy đủ thông tin nhà hàng',
                                  ),
                                ),
                              );
                              return;
                            }
                          }
                          
                          if (!_isValidEmail(_emailController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email không hợp lệ'),
                              ),
                            );
                            return;
                          }
                          if (_passwordController.text.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mật khẩu phải có ít nhất 6 ký tự',
                                ),
                              ),
                            );
                            return;
                          }
                          
                          // Prepare role-specific data
                          Map<String, String>? additionalData;
                          if (_selectedRole == UserRole.shipper) {
                            additionalData = {
                              'vehicle_type': _vehicleTypeController.text,
                              'vehicle_plate': _vehiclePlateController.text,
                              'license_number': _licenseNumberController.text,
                            };
                          } else if (_selectedRole == UserRole.owner) {
                            additionalData = {
                              'restaurant_name': _restaurantNameController.text,
                              'restaurant_address': _restaurantAddressController.text,
                              'restaurant_phone': _restaurantPhoneController.text,
                            };
                          }
                          
                          bool success = await authController.signUp(
                            email: _emailController.text,
                            password: _passwordController.text,
                            fullName: _nameController.text,
                            phone: _phoneController.text,
                            role: _selectedRole,
                            additionalData: additionalData,
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đăng ký thành công'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            final user = authController.currentUser;
                            final route = (user?.role == UserRole.owner)
                                ? ownerDashboardRoute
                                : (user?.role == UserRole.shipper
                                      ? shipperDashboardRoute
                                      : userDashboardRoute);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              route,
                              (route) => false,
                            );
                          }
                        },
                      ),
                const SizedBox(height: 30),
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
