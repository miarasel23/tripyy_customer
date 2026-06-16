import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../utils/custom_map_body_builder.dart';
import '../../../splash/models/current_user_model.dart';


import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_urls.dart';
import '../../../../utils/colors_code.dart';
import '../../../../store/important_consts.dart';
import '../../../../utils/to_title_case.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final imageUrl = AppUrls.profileImageUrl;
    final loc = AppLocalizations.of(context);
    final user = ImportantConsts.userData?.data?.user;
    final name = toTiTleCase(user?.fullName ?? loc.translate("user_name"));
    final phone = user?.phoneNumber ?? 'N/A';
    final email = user?.email ?? 'N/A';
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, size: 14, color: Colors.black),
                                    const SizedBox(width: 4),
                                    Text(
                                      loc.translate("5"),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () => _showProfilePopup(context, name, email, phone, loc.locale.languageCode),
                                child: Text(
                                  loc.translate("view_profile"),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        if (imageUrl != null && imageUrl.isNotEmpty) {
                          return CircleAvatar(
                            radius: 40,
                            backgroundImage: NetworkImage(imageUrl),
                            backgroundColor: Colors.grey.shade200,
                          );
                        }
                        return CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade200,
                          child: const Icon(Icons.person, size: 40, color: Colors.grey),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // POINTS & VOUCHERS (Horizontal Cards)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.points),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.wallet_giftcard, color: Colors.black, size: 28),
                              const SizedBox(height: 12),
                              Text(
                                loc.translate("points"),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.voucher),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.local_offer_outlined, color: Colors.black, size: 28),
                              const SizedBox(height: 12),
                              Text(
                                loc.translate("voucher"),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

              // PREFERENCES LIST
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  loc.translate("preferences"),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              _buildListItem(
                icon: Icons.language,
                title: loc.translate("language"),
                trailingText: loc.translate("english"),
                onTap: () {},
              ),
              _buildListItem(
                icon: Icons.notifications_none,
                title: loc.translate("notification"),
                trailingWidget: Switch(
                  value: true,
                  onChanged: (val) {},
                  activeColor: Colors.black,
                ),
                onTap: () {},
              ),
              _buildListItem(
                icon: Icons.menu_book,
                title: loc.translate("tutorial"),
                onTap: () {},
              ),

              const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

              // LEGAL LIST
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  loc.translate("legal"),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              _buildListItem(
                icon: Icons.help_outline,
                title: loc.translate("help"),
                onTap: () => Navigator.pushNamed(context, AppRoutes.helpCenter),
              ),
              _buildListItem(
                icon: Icons.article_outlined,
                title: loc.translate("terms_conditions"),
                onTap: () {},
              ),
              _buildListItem(
                icon: Icons.description_outlined,
                title: loc.translate("trip_terms_conditions"),
                onTap: () {},
              ),
              _buildListItem(
                icon: Icons.privacy_tip_outlined,
                title: loc.translate("privacy_policy"),
                onTap: () {},
              ),
              _buildListItem(
                icon: Icons.logout,
                title: loc.translate("logout"),
                onTap: () {},
                isDestructive: true,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? trailingText,
    Widget? trailingWidget,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isDestructive ? Colors.red.shade600 : Colors.black87,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red.shade600 : Colors.black87,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (trailingWidget != null)
                trailingWidget
              else
                Icon(
                  Icons.chevron_right,
                  color: isDestructive ? Colors.red.shade600 : Colors.grey.shade400,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  
  void _showProfilePopup(BuildContext context, String initialName, String initialEmail, String initialPhone, String langCode) {
    TextEditingController nameController = TextEditingController(text: initialName);
    TextEditingController emailController = TextEditingController(text: initialEmail);
    TextEditingController phoneController = TextEditingController(text: initialPhone);
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                  ],
                ),
              ),
              actions: [
                if (!isLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: Colors.grey.shade600),
                    ),
                  ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  TextButton(
                    onPressed: () async {
                      setDialogState(() => isLoading = true);
                      
                      final Map<String, dynamic> data = CustomMapBodyBuilder.build(
                        actionWhen: "customer_profile_edit",
                        languageCode: langCode,
                        data: {
                          "phone_number": phoneController.text,
                          "country_code": "BD",
                          "uuid": ImportantConsts.uuid,
                          "full_name": nameController.text,
                          "email": emailController.text,
                          "nid_number": "",
                          "is_notification_enabled": "false",
                          "device_token_for_notification": "",
                        },
                      );

                      try {
                        final response = await http.post(
                          Uri.parse(AppUrls.customerProfileUpdate),
                          body: data,
                          headers: {'Authorization': 'Bearer ${ImportantConsts.accessToken}'},
                        );

                        if (response.statusCode == 200) {
                          // Success! Now fetch updated user
                          final getResponse = await http.get(
                            Uri.parse(AppUrls.getCurrentCustomerUser).replace(
                              queryParameters: {
                                "platform": CustomMapBodyBuilder.getPlatform(),
                                "language_code": langCode,
                                "action_when": "admin_login",
                              },
                            ),
                            headers: {
                              'Content-Type': 'application/json',
                              'Accept': 'application/json',
                              'Authorization': 'Bearer ${ImportantConsts.accessToken}'
                            }
                          );

                          if (getResponse.statusCode == 200) {
                            final jsonData = jsonDecode(getResponse.body);
                            CurrentUserModel currentUserModel = CurrentUserModel.fromJson(jsonData);
                            await ImportantConsts.saveUserData(currentUserModel);
                            
                            // Rebuild profile screen
                            setState(() {});
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(content: Text('Profile updated successfully')),
                              );
                            }
                          } else {
                            throw Exception("Failed to fetch user");
                          }
                        } else {
                           throw Exception("Failed to update profile");
                        }
                      } catch (e) {
                         if (mounted) {
                           ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                           );
                         }
                      } finally {
                        if (mounted) {
                          setDialogState(() => isLoading = false);
                        }
                      }
                    },
                    child: Text(
                      'Save',
                      style: GoogleFonts.poppins(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

