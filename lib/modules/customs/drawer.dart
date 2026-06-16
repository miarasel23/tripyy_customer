import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../store/important_consts.dart';
import '../../utils/app_urls.dart';
import '../../utils/colors_code.dart';
import '../../utils/to_title_case.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppUrls.profileImageUrl;
    final name = toTiTleCase(ImportantConsts.userData?.data?.user?.fullName ?? 'John Doe');
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 HEADER - Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.black),
                            const SizedBox(width: 4),
                            Text(
                              '4.8',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      if (imageUrl != null && imageUrl.isNotEmpty) {
                        return CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(imageUrl),
                          backgroundColor: Colors.grey.shade200,
                        );
                      }
                      return CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(Icons.person, size: 30, color: Colors.grey),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, height: 1, color: Color(0xFFEEEEEE)),
            
            // 📋 MENU ITEMS
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    context,
                    title: 'Trips',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Wallet',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Settings',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Messages',
                    onTap: () => Navigator.pop(context),
                  ),
                  const Divider(thickness: 8, color: Color(0xFFF5F5F5)),
                  _buildDrawerItem(
                    context,
                    title: 'Help',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'About',
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // 🚪 LOGOUT SECTION
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Log Out',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.red.shade600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
