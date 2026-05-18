import 'package:flutter/material.dart';
import '../../../core/utils/localization/app_localization.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/colors_code.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _profileImagePath;
  String _userName = "John Doe";
  String _phoneNumber = "+1 (555) 123-4567";
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Stack(
        children: [
          // Background
          GestureDetector(
            onTap: () => Navigator.pop(context),
            // ignore: deprecated_member_use
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          // Half-width Drawer Panel
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.dashboardScreenDrawerBackground,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(-5, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Profile Section
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Image with Upload
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              backgroundImage: _profileImagePath != null
                                  ? AssetImage(_profileImagePath!)
                                  : null,
                              child: _profileImagePath == null
                                  ? Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _uploadProfileImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.textHighlight,
                                      width: 2,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        // Name
                        Text(
                          _userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8),
                        // Phone Number
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            SizedBox(width: 6),
                            Text(
                              _phoneNumber,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Menu Items
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildMenuSection(
                            title: "Account",
                            items: [
                              _buildMenuItem(
                                icon: Icons.person_outline,
                                label: loc.translate("edit_profile"),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.editProfile,
                                  );
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.lock_outline,
                                label:
                                    loc.translate("change_password") ??
                                    "Change Password",
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.security,
                                label: "Security",
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                          _buildMenuSection(
                            title: "Settings",
                            items: [
                              _buildMenuItem(
                                icon: Icons.settings_outlined,
                                label: loc.translate("settings") ?? "Settings",
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              _buildNotificationTile(),
                            ],
                          ),
                          _buildMenuSection(
                            title: "More",
                            items: [
                              _buildMenuItem(
                                icon: Icons.star_outline,
                                label: loc.translate("review") ?? "Review",
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                              _buildMenuItem(
                                icon: Icons.help_outline,
                                label: loc.translate("help_center"),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.helpCenter,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                        bottom: 20,
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.numberInput);
                        },
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: Text(
                          loc.translate("logout"),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
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
  }

  void _uploadProfileImage() {
    // TODO: Implement image picker
    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Image upload functionality coming soon"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22, color: Color(0xFF6366F1)),
      title: Text(
        label,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
      horizontalTitleGap: 16,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildNotificationTile() {
    return ListTile(
      leading: Icon(
        Icons.notifications_outlined,
        size: 22,
        color: Color(0xFF6366F1),
      ),
      title: Text(
        "Enable Notifications",
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: _notificationsEnabled,
        onChanged: (value) {
          setState(() {
            _notificationsEnabled = value;
          });
        },
        activeColor: Color(0xFF6366F1),
      ),
      horizontalTitleGap: 16,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
