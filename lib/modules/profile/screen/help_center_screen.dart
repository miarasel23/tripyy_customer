import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/localization/app_localization.dart';
import '../../../routes/app_routes.dart';
import '../../../store/app_globals.dart';
import '../../../store/user_data_store.dart';
import '../repository/legal_repository.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  bool _isLoading = true;
  List<String> _phoneNumbers = [];
  List<String> _emailAddresses = [];
  static const String _emergencyPhone = '999';
  bool _hasFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetched) {
      _hasFetched = true;
      final loc = AppLocalizations.of(context);
      _fetchSupportData(loc.locale.languageCode);
    }
  }

  Future<void> _fetchSupportData(String languageCode) async {
    final countryCode = AppGlobals.countryCode;
    final repo = LegalRepository();
    final policyModel = await repo.fetchPolicies(
      languageCode: languageCode,
      countryCode: countryCode,
    );

    final phones = <String>[];
    final emails = <String>[];

    if (policyModel != null && policyModel.data.containsKey('HELP_AND_SUPPORT')) {
      final helpItems = policyModel.data['HELP_AND_SUPPORT']!;
      for (final item in helpItems) {
        final rawContent = item.content;
        final parts = rawContent.split(RegExp(r'[\n,]'));
        for (var part in parts) {
          part = part.trim();
          if (part.isEmpty) continue;

          if (part.contains('@')) {
            final emailMatch = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+').firstMatch(part);
            final email = emailMatch != null ? emailMatch.group(0)! : part;
            if (!emails.contains(email)) {
              emails.add(email);
            }
          } else {
            final phoneMatch = RegExp(r'[\+0-9\s\-]{6,}').firstMatch(part);
            if (phoneMatch != null) {
              final phone = phoneMatch.group(0)!.trim();
              if (!phones.contains(phone)) {
                phones.add(phone);
              }
            }
          }
        }
      }
    }

    if (phones.isEmpty) {
      phones.add('01997709990');
    }
    if (emails.isEmpty) {
      emails.add('help.tripyservice@gmail.com');
    }

    if (mounted) {
      setState(() {
        _phoneNumbers = phones;
        _emailAddresses = emails;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: urlString.startsWith('mailto:') 
            ? LaunchMode.externalApplication 
            : LaunchMode.platformDefault,
      );
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open support option: $urlString')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryTextColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceContainer,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    loc.translate('help'),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    children: [
                      // Live Chat Option
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _HelpOptionCard(
                          icon: Icons.chat_bubble_outline_rounded,
                          iconBgColor: const Color(0xFF10B981),
                          title: loc.translate('live_chat_support') == 'live_chat_support'
                              ? 'Live Support Chat'
                              : loc.translate('live_chat_support'),
                          subtitle: 'Chat directly with our support team',
                          cardBgColor: cardBgColor,
                          borderColor: borderColor,
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          onTap: () {
                            final customerUuid = UserDataStore.uuid ?? '';
                            Navigator.pushNamed(
                              context,
                              AppRoutes.chat,
                              arguments: {
                                'customerUuid': customerUuid,
                                'receiverType': 'ADMIN',
                                'title': 'Support Team',
                              },
                            );
                          },
                        ),
                      ),

                      // Phone Numbers
                      ..._phoneNumbers.map((phone) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _HelpOptionCard(
                            icon: Icons.phone_in_talk_rounded,
                            iconBgColor: const Color(0xFF0D6EFD),
                            title: phone,
                            subtitle: loc.translate('phone_support_sub') == 'phone_support_sub'
                                ? 'Available 24/7 for customer support'
                                : loc.translate('phone_support_sub'),
                            cardBgColor: cardBgColor,
                            borderColor: borderColor,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                            onTap: () => _launchUrl(context, 'tel:$phone'),
                          ),
                        );
                      }),

                      // Emails
                      ..._emailAddresses.map((email) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _HelpOptionCard(
                            icon: Icons.mark_email_unread_rounded,
                            iconBgColor: const Color(0xFF3B82F6),
                            title: email,
                            subtitle: loc.translate('email_support_sub') == 'email_support_sub'
                                ? 'Send us an email anytime'
                                : loc.translate('email_support_sub'),
                            cardBgColor: cardBgColor,
                            borderColor: borderColor,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                            onTap: () => _launchUrl(context, 'mailto:$email'),
                          ),
                        );
                      }),

                      // Emergency 999
                      _HelpOptionCard(
                        iconWidget: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'জাতীয়',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 7,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  height: 1,
                                ),
                              ),
                              Text(
                                '৯৯৯',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        title: loc.translate('emergency_service_999') == 'emergency_service_999'
                            ? 'National Emergency 999'
                            : loc.translate('emergency_service_999'),
                        subtitle: loc.translate('emergency_service_sub') == 'emergency_service_sub'
                            ? 'National emergency helpline'
                            : loc.translate('emergency_service_sub'),
                        cardBgColor: cardBgColor,
                        borderColor: borderColor,
                        primaryTextColor: primaryTextColor,
                        secondaryTextColor: secondaryTextColor,
                        isEmergency: true,
                        onTap: () => _launchUrl(context, 'tel:$_emergencyPhone'),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _HelpOptionCard extends StatelessWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final Color? iconBgColor;
  final String title;
  final String subtitle;
  final Color cardBgColor;
  final Color borderColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final bool isEmergency;
  final VoidCallback onTap;

  const _HelpOptionCard({
    this.icon,
    this.iconWidget,
    this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.cardBgColor,
    required this.borderColor,
    required this.primaryTextColor,
    required this.secondaryTextColor,
    this.isEmergency = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEmergency ? const Color(0xFFFCA5A5) : borderColor,
          width: isEmergency ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                if (iconWidget != null)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: iconWidget,
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor ?? const Color(0xFF0D6EFD),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (iconBgColor ?? const Color(0xFF0D6EFD))
                              .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isEmergency
                        ? const Color(0xFFFEE2E2)
                        : (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF334155)
                            : const Color(0xFFF1F5F9)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isEmergency
                        ? const Color(0xFFDC2626)
                        : secondaryTextColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
