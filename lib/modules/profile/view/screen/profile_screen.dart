import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_urls.dart';
import '../../../../store/important_consts.dart';
import '../../../../utils/to_title_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../editProfile/controller/edit_profile_info_bloc.dart';
import '../../../editProfile/controller/edit_profile_info_event.dart';
import '../../../../utils/enums.dart';
import '../../../editProfile/controller/edit_profile_info_state.dart';



class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.white),
    );

    return BlocConsumer<EditProfileInfoBloc, EditProfileUpdateState>(
      listener: (context, state) {
        if (state.status == EditProfileUpdateStatus.success) {
          final message = loc.locale.languageCode == "bn"
              ? "প্রোফাইল সফলভাবে আপডেট করা হয়েছে!"
              : "Profile updated successfully!";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state.status == EditProfileUpdateStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? "Failed to update profile"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final imageUrl = AppUrls.profileImageUrl;
        final user = ImportantConsts.userData?.data?.user;
        final name = toTiTleCase(user?.fullName ?? loc.translate("user_name"));

        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Name + Rating on left, Avatar on right)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _showEditNameDialog(context, name, user, loc),
                                child: const Icon(Icons.edit, size: 22, color: Colors.black54),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.black87),
                                const SizedBox(width: 4),
                                Text(
                                  loc.translate("5"), // Rating value
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.editProfile);
                      },
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: (imageUrl != null && imageUrl.isNotEmpty)
                            ? NetworkImage(imageUrl)
                            : null,
                        child: (imageUrl == null || imageUrl.isEmpty)
                            ? const Icon(Icons.person, size: 40, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),

                // User Details Card (Mobile, NID, Status)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.translate("user_info") == "user_info" ? "User Info" : loc.translate("user_info"),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showEditProfileDialog(
                              context,
                              fullName: name,
                              phoneNumber: user?.phoneNumber ?? "",
                              email: user?.email ?? "",
                              nidNumber: user?.nidNumber ?? "23423423422",
                              user: user,
                              loc: loc,
                            ),
                            icon: const Icon(Icons.edit_note, color: Colors.blue, size: 24),
                            tooltip: "Edit Info",
                          ),
                        ],
                      ),
                      const Divider(height: 16, thickness: 1),
                      _buildDetailRow(
                        icon: Icons.phone_android_rounded,
                        label: loc.translate("mobile") == "mobile" ? "Mobile" : loc.translate("mobile"),
                        value: user?.phoneNumber ?? "N/A",
                      ),
                      const Divider(height: 24, thickness: 1),
                      _buildDetailRow(
                        icon: Icons.badge_outlined,
                        label: loc.translate("nid_id") == "nid_id" ? "NID ID" : loc.translate("nid_id"),
                        value: user?.nidNumber ?? "23423423422",
                      ),
                      const Divider(height: 24, thickness: 1),
                      _buildDetailRow(
                        icon: Icons.info_outline_rounded,
                        label: loc.translate("status") == "status" ? "Status" : loc.translate("status"),
                        valueWidget: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (user?.isActive ?? false) ? Colors.green.shade50 : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (user?.isActive ?? false) ? "Active" : "Inactive",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: (user?.isActive ?? false) ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Action Cards (Points, Voucher)
                Row(
                  children: [
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        icon: Icons.star_rounded,
                        title: loc.translate("points"),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.points),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionCard(
                        context: context,
                        icon: Icons.local_activity_rounded,
                        title: loc.translate("voucher"),
                        onTap: () => Navigator.pushNamed(context, AppRoutes.voucher),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Divider(color: Color(0xFFEEEEEE), thickness: 8),
                
                // Preferences Section
                _buildSectionHeader(loc.translate("preferences")),
                _buildListTile(
                  icon: Icons.language,
                  title: loc.translate("language"),
                  trailingWidget: Text(
                    loc.translate("english"),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  onTap: () {},
                ),
                _buildListTile(
                  icon: Icons.notifications_none_rounded,
                  title: loc.translate("notification"),
                  trailingWidget: Switch(
                    value: true,
                    onChanged: (val) {},
                    activeColor: Colors.black,
                  ),
                ),
                _buildListTile(
                  icon: Icons.help_outline_rounded,
                  title: loc.translate("tutorial"),
                  onTap: () {},
                ),

                const Divider(color: Color(0xFFEEEEEE), thickness: 8),

                // Legal Section
                _buildSectionHeader(loc.translate("legal")),
                _buildListTile(
                  icon: Icons.support_agent_rounded,
                  title: loc.translate("help"),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
                ),
                _buildListTile(
                  icon: Icons.description_outlined,
                  title: loc.translate("terms_conditions"),
                  onTap: () {},
                ),
                _buildListTile(
                  icon: Icons.policy_outlined,
                  title: loc.translate("trip_terms_conditions"),
                  onTap: () {},
                ),
                _buildListTile(
                  icon: Icons.privacy_tip_outlined,
                  title: loc.translate("privacy_policy"),
                  onTap: () {},
                ),
                _buildListTile(
                  icon: Icons.logout_rounded,
                  title: loc.translate("logout"),
                  iconColor: Colors.redAccent,
                  textColor: Colors.redAccent,
                  hideArrow: true,
                  onTap: () {},
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  },
);
}

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: Colors.black87),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    Widget? trailingWidget,
    Color iconColor = Colors.black87,
    Color textColor = Colors.black87,
    bool hideArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (trailingWidget != null) trailingWidget,
            if (trailingWidget == null && !hideArrow)
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
        ),
        const Spacer(),
        if (valueWidget != null)
          valueWidget
        else
          Text(
            value ?? "N/A",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }

  void _showEditProfileDialog(
    BuildContext context, {
    required String fullName,
    required String phoneNumber,
    required String email,
    required String nidNumber,
    required var user,
    required AppLocalizations loc,
  }) {
    final TextEditingController nameController = TextEditingController(text: fullName);
    final TextEditingController phoneController = TextEditingController(text: phoneNumber);
    final TextEditingController emailController = TextEditingController(text: email);
    final TextEditingController nidController = TextEditingController(text: nidNumber);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            loc.translate("edit_profile") == "edit_profile" ? "Edit Profile" : loc.translate("edit_profile"),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: loc.translate("full_name") == "full_name" ? "Full Name" : loc.translate("full_name"),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: loc.translate("mobile") == "mobile" ? "Mobile" : loc.translate("mobile"),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: loc.translate("email") == "email" ? "Email" : loc.translate("email"),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nidController,
                  decoration: InputDecoration(
                    labelText: loc.translate("nid_id") == "nid_id" ? "NID ID" : loc.translate("nid_id"),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                final newPhone = phoneController.text.trim();
                final newEmail = emailController.text.trim();
                final newNid = nidController.text.trim();

                if (newName.isNotEmpty && newPhone.isNotEmpty) {
                  context.read<EditProfileInfoBloc>().add(
                    EditProfileInfo(
                      languageCode: loc.locale.languageCode,
                      email: newEmail,
                      phoneNumber: newPhone,
                      fullName: newName,
                      nidNumber: newNid,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Save",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName, var user, AppLocalizations loc) {
    final TextEditingController nameController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            loc.translate("update_name") == "update_name" ? "Update Name" : loc.translate("update_name"),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: loc.translate("user_name"),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  context.read<EditProfileInfoBloc>().add(
                    EditProfileInfo(
                      languageCode: loc.locale.languageCode,
                      email: user?.email ?? '',
                      phoneNumber: user?.phoneNumber ?? '',
                      fullName: newName,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                "Save",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
