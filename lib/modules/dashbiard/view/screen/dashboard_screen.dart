import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/app_urls.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_bloc.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_events.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_state.dart';
import '../../../../utils/choose_car_bottom_sheet/view/choose_car_bottom_sheet.dart';
import '../../../../utils/colors_code.dart';
import '../../../../utils/enums.dart';
import '../../../customs/drawer.dart';

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
      drawer: AppDrawer(),
      backgroundColor: AppColors.dashboardScreenBackground,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.dashboardScreenAppBarBackground,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                starPointsWidget(loc, context),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.notification);
                  },
                  child: Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.dashboardNotificationIconBackground,
                      shape: BoxShape.circle,
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.notifications_outlined, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 2),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              locationSearchingWidget(loc),
              SizedBox(height: 6),
              locationSaveWidgetRow(loc, context),
              SizedBox(height: 10),
              Text(
                loc.translate("services"),
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  color: AppColors.dashboardServiceText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 13),
              BlocBuilder<ChooseCarBottomSheetBloc, ChooseCarBottomSheetState>(
                builder: (context, state) {
                  return servicesSection(loc, context, state);
                },
              ),
              SizedBox(height: 13),
              imagePlaceHolderContainer(),
              SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate("saved_routes"),
                    style: GoogleFonts.poppins(
                      color: AppColors.dashboardSavedRoutesText,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.savedRoute);
                    },
                    child: Text(
                      loc.translate("see_all"),
                      style: GoogleFonts.poppins(
                        color: AppColors.dashboardSeeAllText,
                        fontSize: 17,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              savedRoutesSection(loc),
              SizedBox(height: 25),
              Text(
                loc.translate("additional_services"),
                style: GoogleFonts.poppins(
                  color: AppColors.dashboardAdditionalServiceText,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              additionalServiceSection(loc, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget servicesSection(
    AppLocalizations loc,
    BuildContext context,
    ChooseCarBottomSheetState state,
  ) {
    if (state.status == ChooseCarBottomSheetStatus.loading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: AppColors.shimmerBase,
            highlightColor: AppColors.shimmerHighlight,
            child: Column(
              children: [
                Container(
                  height: 70,
                  width: 70,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(height: 12, width: 60, color: Colors.white),
              ],
            ),
          );
        },
      );
    }

    if (state.status == ChooseCarBottomSheetStatus.failure) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          state.error ?? 'Failed to load services',
          style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
        ),
      );
    }
    final keys = state.groups?.keys.toList();
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: keys?.length ?? 0,
      itemBuilder: (context, index) {
        var key = keys?[index];
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
            print("clicked 2");
          },
          child: serviceWidget(
            icon: Builder(
              builder: (context) {
                final imageUrl = AppUrls.getImageUrl(avatar);
                if (avatar != null && avatar.isNotEmpty) {
                  return SizedBox(
                    height: 70,
                    width: 70,
                    child: Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.cancel);
                      },
                    ),
                  );
                }
                return Icon(
                  Icons.car_crash,
                  size: 70,
                  color: AppColors.dashboardServiceIcon,
                );
              },
            ),
            label: (key == "INTER_CITY_RENTER") ? "INTERCITY " : (key ?? ""),
            context: context,
          ),
        );
      },
    );
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
          color: AppColors.dashboardAdditionalServiceBackground,
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
                      color: AppColors.dashboardAdditionalServiceTitle,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    loc.translate("tour_bus_description"),
                    style: GoogleFonts.poppins(
                      color: AppColors.dashboardAdditionalServiceDescription,
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
              color: AppColors.dashboardNoSavedRoutesText,
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
                color: AppColors.dashboardNoSavedRoutesHintText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.dashboardElevatedButtonBackground,
              side: BorderSide(
                color: AppColors.dashboardElevatedButtonSide,
                width: 2,
              ),
            ),
            onPressed: () {},
            child: Text(
              loc.translate("add_routes"),
              style: GoogleFonts.poppins(
                color: AppColors.dashboardElevatedButtonForeground,
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
        color: AppColors.dashboardImageContainer,
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
            color: AppColors.dashboardServiceLabel,
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
            color: AppColors.dashboardSavedLocationIcon,
          ),
          label: loc.translate('home'),
          loc: loc,
        ),
        locationSaveWidget(
          icon: Icon(
            Icons.add_home_work_sharp,
            size: 14,
            color: AppColors.dashboardSavedLocationIcon,
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
              color: AppColors.dashboardSavedMoreLocationIconBackground,
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.dashboardSavedMoreLocationIcon,
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
        color: AppColors.dashboardSavedLocationContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.dashboardSavedLocationContainerSide,
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
                  color: AppColors.dashboardSavedLocationText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            loc.translate("add_location"),
            style: GoogleFonts.poppins(
              color: AppColors.dashboardSavedLocationDetails,
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
        color: AppColors.dashboardLocationSearchContainer,
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
              color: AppColors.dashboardLocationSearchQuestionText,
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
                color: AppColors.dashboardLocationSearchFindLocationIcon,
                size: 30,
              ),
              SizedBox(width: 3),
              Text(
                loc.translate("find_location"),
                style: GoogleFonts.poppins(
                  color: AppColors.dashboardLocationSearchFindLocationText,
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
          color: AppColors.dashboardStarPointsWidget,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.dashboardStarPointsIconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                color: AppColors.dashboardStarPointsIconForeground,
                size: 15,
              ),
            ),
            SizedBox(width: 8),
            Text(
              loc.translate("470"),
              style: TextStyle(
                color: AppColors.dashboardStarPointsWidgetText,
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
              color: AppColors.dashboardServiceIcon,
            ),
            label: loc.translate('ride_share'),
            context: context,
          ),*/
