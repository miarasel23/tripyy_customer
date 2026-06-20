import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trippy_customer/utils/app_urls.dart';
import '../../choose_car_bottom_sheet/controller/choose_car_bottom_sheet_state.dart';
import '../../choose_car_bottom_sheet/view/choose_car_bottom_sheet.dart';

class ServicesSectionWidget extends StatelessWidget {
  final ChooseCarBottomSheetState state;
  final Function(String serviceKey, List<dynamic> defaultCars) onServiceTap;

  const ServicesSectionWidget({Key? key, required this.state, required this.onServiceTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keys = state.groups?.keys.toList() ?? [];
    final isLight = Theme.of(context).brightness == Brightness.light;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: keys.map((key) {
          final serviceGroup = state.groups?[key];
          final avatar = serviceGroup?.avatar;
          return GestureDetector(
            onTap: () {
              if (key != null) {
                final cars = state.groups?[key]?.cars ?? [];
                onServiceTap(key, cars);
              }
            },
            child: Container(
              margin: EdgeInsets.only(right: 12),
              width: 100,
              height: 130,
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: isLight ? Colors.white : Color(0xFF2A2F3D),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isLight ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isLight ? Colors.grey[100] : Color(0xFF3B4155),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildServiceIcon(avatar, context),
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _formatServiceName(key),
                          style: GoogleFonts.poppins(
                            color: isLight ? Colors.black87 : Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
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

  Widget _buildServiceIcon(String? avatar, BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final iconColor = isLight ? Colors.blue[600] : Colors.blue[200];
    
    if (avatar != null && avatar.isNotEmpty) {
      final imageUrl = AppUrls.getImageUrl(avatar);
      return SizedBox(
        height: 50,
        width: 50,
        child: Image.network(
          imageUrl!,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Shimmer.fromColors(
              baseColor: isLight ? Colors.grey[300]! : Colors.grey[700]!,
              highlightColor: isLight ? Colors.grey[100]! : Colors.grey[500]!,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isLight ? Colors.white : Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.car_crash, color: iconColor, size: 50);
          },
        ),
      );
    }
    return Icon(Icons.directions_car, color: iconColor, size: 50);
  }

  String _formatServiceName(String? key) {
    if (key == null) return "";
    if (key == "INTER_CITY_RENTER") return "Intercity";
    
    return key.split('_').map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
