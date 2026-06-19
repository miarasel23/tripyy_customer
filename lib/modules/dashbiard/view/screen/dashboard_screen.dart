import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/utils/app_urls.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_bloc.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_events.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_state.dart';
import '../../../../utils/colors_code.dart';
import '../../../../utils/choose_car_bottom_sheet/view/choose_car_bottom_sheet.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context);
      context.read<ChooseCarBottomSheetBloc>().add(
        LoadServices(languageCode: loc.locale.languageCode),
      );
      print("clicked 1");
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Color(0xFF0A0F1C), // Dark placeholder for map
      body: Stack(
        children: [
          // Background Map Placeholder / Center Car Icon
          Center(
            child: Icon(
              Icons.directions_car,
              color: Colors.blue[200],
              size: 50,
            ),
          ),

          // Top App Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: _buildTopBar(context),
          ),

          // Bottom UI
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<ChooseCarBottomSheetBloc, ChooseCarBottomSheetState>(
                  builder: (context, state) {
                    return servicesSection(loc, context, state);
                  },
                ),
                SizedBox(height: 20),
                _buildSearchAndSavedCard(context, loc),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xFF1E2433),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.menu, color: Colors.white70),
              SizedBox(width: 16),
              Text(
                "RapidRide",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[800],
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSavedCard(BuildContext context, AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // timeline dots
              Column(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.grey),
                  Container(height: 30, width: 2, color: Colors.grey.withOpacity(0.3)),
                  Icon(Icons.square, size: 8, color: Colors.blue[200]),
                ],
              ),
              SizedBox(width: 16),
              // text fields
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(loc.translate("current_location") ?? "Current Location", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Text(loc.translate("where_are_you_going") ?? "Where to?", style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16),
              // Action buttons
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.my_location, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Divider(color: Theme.of(context).colorScheme.outlineVariant),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSavedLocItem(context, Icons.home, loc.translate("home") ?? "Home", "2.4 KM", () {
                Navigator.pushNamed(context, AppRoutes.savedLoc);
              }),
              Container(width: 1, height: 30, color: Theme.of(context).colorScheme.outlineVariant),
              _buildSavedLocItem(context, Icons.work, loc.translate("work") ?? "Work", "8.1 KM", () {
                Navigator.pushNamed(context, AppRoutes.savedLoc);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedLocItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Widget servicesSection(
    AppLocalizations loc,
    BuildContext context,
    ChooseCarBottomSheetState state,
  ) {
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
              final cars = state.groups?[key]?.cars ?? [];
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                    heightFactor: 0.845,
                    child: ChooseCarBottomSheet(
                      cars: cars,
                      serviceName: key ?? '',
                    ),
                  );
                },
              );
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
                    padding: EdgeInsets.all(8), // Reduced padding to give image more space
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
        height: 50, // Increased image size
        width: 50,  // Increased image size
        child: Image.network(
          imageUrl!,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
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
    
    // Convert "WEDDING_CAR" to "Wedding Car"
    return key.split('_').map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget additionalServiceSection(AppLocalizations loc, BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              additionalServicesWidget(loc, context),
              SizedBox(width: 10),
            ],
          );
        },
      ),
    );
  }

  Widget additionalServicesWidget(AppLocalizations loc, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.additionalService);
      },
      child: Container(
        width: 220,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 220,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.dashboardAdditionalServiceImg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate("tourist_bus"),
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    loc.translate("tour_bus_description"),
                    style: GoogleFonts.poppins(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 9,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget savedRoutesSection(AppLocalizations loc) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xffeef7fe),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.route_sharp, color: Colors.blue, size: 40),
          SizedBox(height: 3),
          Text(
            loc.translate("no_saved_routes"),
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              loc.translate("save_routes_hint"),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.surface,
              side: BorderSide(
                color: Theme.of(context).colorScheme.outline,
                width: 2,
              ),
            ),
            onPressed: () {},
            child: Text(
              loc.translate("add_routes"),
              style: GoogleFonts.poppins(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget imagePlaceHolderContainer() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget serviceWidget({
    required BuildContext context,
    required Widget icon,
    required String label,
  }) {
    return Column(
      children: [
        icon,
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget locationSaveWidgetRow(AppLocalizations loc, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        locationSaveWidget(
          icon: Icon(
            Icons.home,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          label: loc.translate('home'),
          loc: loc,
        ),
        locationSaveWidget(
          icon: Icon(
            Icons.add_home_work_sharp,
            size: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          label: loc.translate('work'),
          loc: loc,
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.savedLoc);
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget locationSaveWidget({
    required Widget icon,
    required String label,
    required AppLocalizations loc,
  }) {
    return Container(
      width: 130,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 1.5,
        ),
        shape: BoxShape.rectangle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              icon,
              SizedBox(width: 3),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            loc.translate("add_location"),
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget locationSearchingWidget(AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        shape: BoxShape.rectangle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate("where_are_you_going"),
            style: GoogleFonts.poppins(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurface,
                size: 30,
              ),
              SizedBox(width: 3),
              Text(
                loc.translate("find_location"),
                style: GoogleFonts.poppins(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget starPointsWidget(AppLocalizations loc, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.points);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 15,
              ),
            ),
            SizedBox(width: 8),
            Text(
              loc.translate("470"),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*serviceWidget(
            icon: Icon(
              Icons.car_crash,
              size: 70,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            label: loc.translate('ride_share'),
            context: context,
          ),*/
