import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/data/services/service_locator.dart';
import 'package:trippy_customer/routes/app_router.dart';
import 'package:trippy_customer/view/editProfile_screen.dart';
import 'package:trippy_customer/view/helpCenter_screen.dart';

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
              title: Text("Edit Profile"),
              onTap: () {
                getIt<AppRouter>().push(EditprofileScreen());
              },
            ),
            ListTile(
              leading: Icon(Icons.help_center),
              title: Text("Help Center"),
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
              locationSearchingWidget(),
              SizedBox(height: 6),
              locationSaveWidgetRow(),
              SizedBox(height: 10),
              Text(
                "Services",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 13),
              servicesSection(),
              SizedBox(height: 13),
              imagePlaceHolderContainer(),
              SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Saved Routes",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      "See All",
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
              savedRoutesSection(),
              SizedBox(height: 25),
              Text(
                "Additional Services",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              additionalServiceSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget servicesSection() {
    return GridView.count(
      padding: EdgeInsets.symmetric(horizontal: 0),
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        serviceWidget(
          icon: Icon(Icons.car_crash, size: 70, color: Colors.blue),
          label: 'Intercity',
        ),
        serviceWidget(
          icon: Icon(Icons.car_crash, size: 70, color: Colors.blue),
          label: 'Hourly',
        ),
        serviceWidget(
          icon: Icon(Icons.car_crash, size: 70, color: Colors.blue),
          label: 'Airport Rental',
        ),
        serviceWidget(
          icon: Icon(Icons.car_crash, size: 70, color: Colors.blue),
          label: 'Return Trip',
        ),
        serviceWidget(
          icon: Icon(Icons.car_crash, size: 70, color: Colors.blue),
          label: 'Ride Share',
        ),
      ],
    );
  }

  Widget additionalServiceSection() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [additionalServicesWidget(), SizedBox(width: 10)],
          );
        },
      ),
    );
  }

  Widget additionalServicesWidget() {
    return Container(
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
                  "Tourist Bus",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Comfortable and reliable buses for group tours and long journeys",
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
    );
  }

  Widget savedRoutesSection() {
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
            "No Saved Routes",
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
              "Save your favorite pickup and drop - off locations to book faster next time.",
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
              "Add Routes",
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

  Widget locationSaveWidgetRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        locationSaveWidget(
          icon: Icon(Icons.home, size: 14, color: Colors.black),
          label: 'Home',
        ),
        locationSaveWidget(
          icon: Icon(Icons.add_home_work_sharp, size: 14, color: Colors.black),
          label: 'Work',
        ),
        Container(
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
      ],
    );
  }

  Widget locationSaveWidget({required Widget icon, required String label}) {
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
            "Add Locaton",
            style: GoogleFonts.poppins(color: Color(0xffa7a7a7), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget locationSearchingWidget() {
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
            "Where are you going?",
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
                "Find the location",
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
    return Container(
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
    );
  }
}
