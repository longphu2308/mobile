import 'package:flutter/material.dart';
import 'package:mobile/User/presentation/controllers/edit_profile_controller.dart';
import 'package:mobile/User/presentation/controllers/auth_controller.dart';
import 'package:mobile/User/utils/utils.dart';
import 'package:provider/provider.dart';

class UserEditProfileScreen extends StatefulWidget {
  const UserEditProfileScreen({super.key});

  @override
  State<UserEditProfileScreen> createState() => _UserEditProfileScreenState();
}

class _UserEditProfileScreenState extends State<UserEditProfileScreen> {
  final UserEditProfileController _controller = UserEditProfileController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initFromUser(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: blackColor, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: blackColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(horizontalPadding),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar
            Consumer<AuthController>(
              builder: (context, authController, child) {
                final user = authController.currentUser;
                final selectedImage = _controller.selectedImage;
                final currentAvatarUrl = _controller.currentAvatarUrl ?? user?.avatarUrl;
                
                return Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () async {
                await _controller.showImageSourceDialog(context);
                if (mounted) {
                  setState(() {}); // Refresh UI after image selection
                }
              },
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          backgroundImage: selectedImage != null
                              ? FileImage(selectedImage)
                              : (currentAvatarUrl != null && currentAvatarUrl.isNotEmpty
                                  ? NetworkImage(currentAvatarUrl)
                                  : null),
                          child: selectedImage == null && 
                                 (currentAvatarUrl == null || currentAvatarUrl.isEmpty)
                              ? const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: primaryColor,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: GestureDetector(
                          onTap: () async {
                await _controller.showImageSourceDialog(context);
                if (mounted) {
                  setState(() {}); // Refresh UI after image selection
                }
              },
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: primaryColor,
                            child: _controller.isUploadingImage
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: whiteColor,
                                    size: 18,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            // Name
            TextField(
              controller: _controller.nameCtrl,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Phone
            TextField(
              controller: _controller.phoneCtrl,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            // Address
            TextField(
              controller: _controller.addressCtrl,
              decoration: const InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const Spacer(),
            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: _controller.isUploadingImage
                    ? null
                    : () async {
                        final success = await _controller.save(context);
                        if (success && mounted) {
                          setState(() {}); // Refresh UI
                        }
                      },
                child: _controller.isUploadingImage
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                        ),
                      )
                    : const Text(
                        "Lưu thay đổi",
                        style: TextStyle(color: whiteColor, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


