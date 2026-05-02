import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/widgets/custom_appBar.dart';
import 'package:trippy_customer/widgets/timeline_tile.dart';

class TripdetailsScreen extends StatelessWidget {
  const TripdetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(loc),
              SizedBox(height: 30),
              tripVehicleInfo(loc),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xffeef7fe),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    pickUpToDropOff(loc),
                    SizedBox(height: 15),
                    tripOthersInformation(
                      loc,
                      Icon(
                        Icons.document_scanner_outlined,
                        color: Colors.black,
                      ),
                      "Booking_ID",
                      Text(
                        "123456789123",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    tripOthersInformation(
                      loc,
                      Icon(Icons.wallet, color: Colors.black),
                      "Total_fare",
                      Text(
                        "Fare not Available",
                        style: GoogleFonts.poppins(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    tripOthersInformation(
                      loc,
                      Icon(Icons.date_range, color: Colors.black),
                      "PickUp_date_and_Time",
                      Text(
                        "28 Apr 2026, 05:30 PM",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tripOthersInformation(
    AppLocalizations loc,
    Widget icon,
    String label,
    Text value,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon(Icons.document_scanner_outlined, color: Colors.black),
        icon,
        SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.translate(label),
                style: GoogleFonts.poppins(
                  color: Color(0xffb3b3b3),
                  fontSize: 14,
                ),
              ),
              value,
            ],
          ),
        ),
      ],
    );
  }

  Widget pickUpToDropOff(AppLocalizations loc) {
    return Column(
      children: [
        TimelineTile(
          icon: Icon(Icons.star),
          isLast: false,
          tiles: 7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate("Pickup"),
                style: GoogleFonts.poppins(
                  color: Color(0xffb3b3b3),
                  fontSize: 14,
                ),
              ),
              Text(
                "Narayanganj, Dhaka",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        TimelineTile(
          icon: Icon(Icons.star),
          isLast: true,
          tiles: 7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate("Drop_Off"),
                style: GoogleFonts.poppins(
                  color: Color(0xffb3b3b3),
                  fontSize: 14,
                ),
              ),
              Text(
                "Notre Dame Universiy Bangladesh",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget tripVehicleInfo(AppLocalizations loc) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Color(0xffeef7fe),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.car_crash, color: Colors.black, size: 60),
              SizedBox(width: 7),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.translate("Sedan"),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.people, size: 18, color: Colors.grey),
                      SizedBox(width: 5),
                      Text(
                        loc.translate("4_seats"),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          IntrinsicWidth(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                side: BorderSide(color: Colors.blue, width: 1.5),
                minimumSize: Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
                backgroundColor: Color(0xffeef7fe),
                foregroundColor: Colors.blue,
              ),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.straight),
                  SizedBox(width: 2),
                  Center(
                    child: Text(
                      loc.translate("One_Way"),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations loc) {
    return CustomAppBar(loc: loc, title: 'Trip_Details');
  }
}


