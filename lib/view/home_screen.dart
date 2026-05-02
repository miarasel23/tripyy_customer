import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/data/services/service_locator.dart';
import 'package:trippy_customer/routes/app_router.dart';
import 'package:trippy_customer/view/additionalService_screen.dart';
import 'package:trippy_customer/view/editProfile_screen.dart';
import 'package:trippy_customer/view/helpCenter_screen.dart';
import 'package:trippy_customer/view/points_screen.dart';
import 'package:trippy_customer/view/savedLocation_screen.dart';
import 'package:trippy_customer/view/savedRoutes_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            SizedBox(height: 50),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(loc.translate("Edit_Profile")),
              onTap: () {
                getIt<AppRouter>().push(EditprofileScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.help_center),
              title: Text(loc.translate("Help_Center")),
              onTap: () {
                getIt<AppRouter>().push(HelpcenterScreen());
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                starPointsWidget(loc),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Color(0xffeef7fe),
                    shape: BoxShape.circle,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.notifications_outlined, size: 24),
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
              locationSaveWidgetRow(loc),
              SizedBox(height: 10),
              Text(
                loc.translate("Services"),
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 13),
              servicesSection(loc),
              SizedBox(height: 13),
              imagePlaceHolderContainer(),
              SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate("Saved_Routes"),
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      getIt<AppRouter>().push(SavedroutesScreen());
                    },
                    child: Text(
                      loc.translate("See_All"),
                      style: GoogleFonts.poppins(
                        color: Color(0xffa5a5a5),
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
                loc.translate("Additional_Services"),
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              additionalServiceSection(loc),
            ],
          ),
        ),
      ),
    );
  }

  Widget servicesSection(AppLocalizations loc) {
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: 0),
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        serviceWidget(
          icon: Icon(Icons.car_crash, size: 70, color: Colors.blue),
          label: loc.translate('Intercity'),
        ),
        serviceWidget(
          icon: Icon(Icons.car_crash, size: 70, color: Colors.blue),
          label: loc.translate('Hourly'),
        ),
        serviceWidget(
          icon: Icon(Icons.car_crash, size: 70, color: Colors.blue),
          label: loc.translate('Airport_Rental'),
        ),
        serviceWidget(
          icon: Icon(Icons.car_crash, size: 70, color: Colors.blue),
          label: loc.translate('Return_Trip'),
        ),
        serviceWidget(
          icon: Icon(Icons.car_crash, size: 70, color: Colors.blue),
          label: loc.translate('Ride_Share'),
        ),
      ],
    );
  }

  Widget additionalServiceSection(AppLocalizations loc) {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [additionalServicesWidget(loc), SizedBox(width: 10)],
          );
        },
      ),
    );
  }

  Widget additionalServicesWidget(AppLocalizations loc) {
    return GestureDetector(
      onTap: () {
        getIt<AppRouter>().push(AdditionalserviceScreen());
      },
      child: Container(
        width: 220,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: Color(0xffeef7fe),
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
                color: Colors.green,
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
                    loc.translate("Tourist_Bus"),
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    loc.translate(
                      "Comfortable_and_reliable_buses_for_group_tours_and_long_journeys",
                    ),
                    style: GoogleFonts.poppins(
                      color: Color(0xff656c74),
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
            loc.translate("No_Saved_Routes"),
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              loc.translate(
                "Save_your_favorite_pickup_and_drop_-_off_locations_to_book_faster_next_time.",
              ),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Color(0xffbfc6ce),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 5),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Color(0xffeef7fe),
              side: BorderSide(color: Colors.blue, width: 2),
            ),
            onPressed: () {},
            child: Text(
              loc.translate("Add_Routes"),
              style: GoogleFonts.poppins(
                color: Colors.blue,
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
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget serviceWidget({required Widget icon, required String label}) {
    return Column(
      children: [
        icon,
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget locationSaveWidgetRow(AppLocalizations loc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        locationSaveWidget(
          icon: Icon(Icons.home, size: 14, color: Colors.black),
          label: loc.translate('Home'),
          loc: loc,
        ),
        locationSaveWidget(
          icon: Icon(Icons.add_home_work_sharp, size: 14, color: Colors.black),
          label: loc.translate('Work'),
          loc: loc,
        ),
        GestureDetector(
          onTap: () {
            getIt<AppRouter>().push(SavedlocationScreen());
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xffeef7fe),
              shape: BoxShape.circle,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Icon(
                Icons.arrow_forward_ios,
                color: Color(0xff5681e6),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xffebebeb), width: 1.5),
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
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            loc.translate("Add_Locaton"),
            style: GoogleFonts.poppins(color: Color(0xffa7a7a7), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget locationSearchingWidget(AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xffeef7fe),
        borderRadius: BorderRadius.circular(12),
        shape: BoxShape.rectangle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.translate("Where_are_you_going?"),
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.search, color: Colors.blue, size: 30),
              SizedBox(width: 3),
              Text(
                loc.translate("Find_the_location"),
                style: GoogleFonts.poppins(
                  color: Colors.black,
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

  Widget starPointsWidget(AppLocalizations loc) {
    return GestureDetector(
      onTap: () {
        getIt<AppRouter>().push(PointsScreen());
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xfffff9d6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xfffdc205),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.star, color: Colors.white, size: 15),
            ),
            SizedBox(width: 8),
            Text(
              loc.translate("470"),
              style: TextStyle(
                color: Colors.black,
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
