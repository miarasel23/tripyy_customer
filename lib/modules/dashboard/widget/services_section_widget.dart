import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/enums.dart';
import '../../../core/utils/localization/app_localization.dart';
import '../choose_car_bottom_sheet/controller/choose_car_bottom_sheet_bloc.dart';
import '../choose_car_bottom_sheet/controller/choose_car_bottom_sheet_events.dart';
import '../choose_car_bottom_sheet/controller/choose_car_bottom_sheet_state.dart';

class ServicesSectionWidget extends StatelessWidget {
  final ChooseCarBottomSheetState state;
  final Function(String serviceKey, List<dynamic> defaultCars) onServiceTap;
  final String? selectedServiceKey;

  const ServicesSectionWidget({Key? key, required this.state, required this.onServiceTap, this.selectedServiceKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keys = state.groups?.keys.toList() ?? [];
    final isLight = Theme.of(context).brightness == Brightness.light;
    final loc = AppLocalizations.of(context);
    final langCode = loc.locale.languageCode;

    if (keys.isEmpty) {
      if (state.status == ChooseCarBottomSheetStatus.loading) {
        return _buildShimmerLoading(isLight);
      }
      if (state.status == ChooseCarBottomSheetStatus.failure) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Text(
                loc.translate("error_loading"),
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  context.read<ChooseCarBottomSheetBloc>().add(
                    LoadServices(languageCode: langCode),
                  );
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Retry", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: keys.map((key) {
          final serviceGroup = state.groups?[key];
          final avatar = serviceGroup?.avatar;
          final bool isSelected = key == selectedServiceKey;

          return GestureDetector(
            onTap: () {
              if (key.isNotEmpty) {
                final cars = state.groups?[key]?.cars ?? [];
                onServiceTap(key, cars);
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 100,
              height: 102,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              decoration: BoxDecoration(
                color: isSelected ? (isLight ? Colors.blue[50] : Colors.blue[900]?.withValues(alpha: 0.3)) : (isLight ? Colors.white : const Color(0xFF2A2F3D)),
                borderRadius: BorderRadius.circular(14),
                border: isSelected ? Border.all(color: Colors.blue, width: 1.5) : null,
                boxShadow: isLight ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 54,
                    decoration: BoxDecoration(
                      color: isLight ? Colors.grey[100] : const Color(0xFF3B4155),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildServiceIcon(avatar, key, context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Expanded(
                    child: Center(
                      child: Text(
                        _formatServiceName(key, langCode),
                        style: GoogleFonts.poppins(
                          color: isLight ? Colors.black87 : Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        softWrap: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShimmerLoading(bool isLight) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: List.generate(4, (index) {
          return Shimmer.fromColors(
            baseColor: isLight ? Colors.grey[300]! : Colors.grey[800]!,
            highlightColor: isLight ? Colors.grey[100]! : Colors.grey[700]!,
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 100,
              height: 102,
              decoration: BoxDecoration(
                color: isLight ? Colors.white : const Color(0xFF2A2F3D),
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildServiceIcon(String? avatar, String? serviceKey, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final iconColor = isLight ? Colors.blue[600] : Colors.blue[200];
    
    if (avatar != null && avatar.trim().isNotEmpty) {
      final imageUrl = AppUrls.getImageUrl(avatar);
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Shimmer.fromColors(
              baseColor: isLight ? Colors.grey[300]! : Colors.grey[700]!,
              highlightColor: isLight ? Colors.grey[100]! : Colors.grey[500]!,
              child: Container(
                color: isLight ? Colors.white : Colors.black,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildAssetOrFallback(serviceKey, iconColor);
          },
        );
      }
    }
    return _buildAssetOrFallback(serviceKey, iconColor);
  }

  Widget _buildAssetOrFallback(String? serviceKey, Color? iconColor) {
    final relevantAsset = _getRelevantServiceAsset(serviceKey);
    if (relevantAsset != null) {
      return Image.asset(
        relevantAsset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _buildNoImagePlaceholder(iconColor);
        },
      );
    }
    return _buildNoImagePlaceholder(iconColor);
  }

  String? _getRelevantServiceAsset(String? serviceKey) {
    if (serviceKey == null || serviceKey.trim().isEmpty) return null;
    final normalized = serviceKey.toUpperCase().trim();

    const validAssets = {
      'RIDE_SHARE': 'assets/services/RIDE_SHARE.png',
      'INTER_CITY_RENTER': 'assets/services/INTER_CITY_RENTER.png',
      'RETURN': 'assets/services/RETURN.png',
      'HOURLY': 'assets/services/HOURLY.png',
      'AIRPORT_RENTER': 'assets/services/AIRPORT_RENTER.png',
      'WEDDING_CAR': 'assets/services/WEDDING_CAR.png',
      'PACKAGE_DELIVERY': 'assets/services/PACKAGE_DELIVERY.png',
      'OUTSTATION_RIDE': 'assets/services/OUTSTATION_RIDE.png',
    };

    if (validAssets.containsKey(normalized)) {
      return validAssets[normalized];
    }

    if (normalized.contains('OUTSTATION')) return 'assets/services/OUTSTATION_RIDE.png';
    if (normalized.contains('PACKAGE') || normalized.contains('DELIVERY') || normalized.contains('PARCEL')) {
      return 'assets/services/PACKAGE_DELIVERY.png';
    }
    if (normalized.contains('HOUR')) return 'assets/services/HOURLY.png';
    if (normalized.contains('AIRPORT')) return 'assets/services/AIRPORT_RENTER.png';
    if (normalized.contains('WEDDING')) return 'assets/services/WEDDING_CAR.png';
    if (normalized.contains('RIDE') || normalized.contains('SHARE')) return 'assets/services/RIDE_SHARE.png';
    if (normalized.contains('INTER') || normalized.contains('CITY')) return 'assets/services/INTER_CITY_RENTER.png';
    if (normalized.contains('RETURN')) return 'assets/services/RETURN.png';

    return null;
  }

  Widget _buildNoImagePlaceholder(Color? iconColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: iconColor?.withValues(alpha: 0.6) ?? Colors.grey.shade400,
            size: 22,
          ),
          const SizedBox(height: 2),
          Text(
            "No Image",
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: iconColor?.withValues(alpha: 0.7) ?? Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  String _formatServiceName(String? key, String langCode) {
    if (key == null || key.isEmpty) return "";
    
    final bool isBn = langCode == 'bn';
    final normalizedKey = key.toUpperCase().trim();

    if (isBn) {
      if (normalizedKey.contains('OUTSTATION')) {
        return 'আউটস্টেশন রাইড';
      }
      if (normalizedKey.contains('PACKAGE') || normalizedKey.contains('DELIVERY')) {
        return 'পার্সেল ডেলিভারি';
      }
      if (normalizedKey.contains('HOURLY') || normalizedKey.contains('HOUR')) {
        return 'ঘণ্টাভিত্তিক';
      }
      if (normalizedKey.contains('AIRPORT')) {
        return 'এয়ারপোর্ট রেন্টাল';
      }
      if (normalizedKey.contains('WEDDING')) {
        return 'ওয়েডিং কার';
      }
      if (normalizedKey.contains('RIDE') || normalizedKey.contains('SHARE')) {
        return 'রাইড শেয়ার';
      }
      if (normalizedKey.contains('INTER') || normalizedKey.contains('CITY')) {
        return 'ইন্টারসিটি';
      }
      if (normalizedKey.contains('RETURN')) {
        return 'রিটার্ন';
      }
      if (normalizedKey.contains('SINGLE')) {
        return 'একমুখী ট্রিপ';
      }
      if (normalizedKey.contains('DAILY')) {
        return 'দৈনিক রেন্টাল';
      }
      if (normalizedKey.contains('MONTHLY')) {
        return 'মাসিক রেন্টাল';
      }
    }

    if (normalizedKey == "INTER_CITY_RENTER") return "Intercity";
    if (normalizedKey == "OUTSTATION_RIDE") return "Outstation Ride";
    if (normalizedKey == "PACKAGE_DELIVERY") return "Package Delivery";
    
    return key.split('_').map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
