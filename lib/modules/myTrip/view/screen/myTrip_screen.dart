import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/colors_code.dart';
import '../../../../widgets/timeline_tile.dart';

class MytripScreen extends StatelessWidget {
  const MytripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.myTripScreenBackground,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.myTripScreenAppBarBackground,
        title: Text(
          loc.translate("my_trip"),
          style: TextStyle(
            color: AppColors.myTripScreenAppBarText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.myTripScreenCarRentalContainer,
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        loc.translate("car_rental"),
                        style: GoogleFonts.poppins(
                          color: AppColors.myTripScreenCarRentalText,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.myTripScreenWeddingCarContainer,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        loc.translate("wedding_car"),
                        style: GoogleFonts.poppins(
                          color: AppColors.myTripScreenWeddingCarText,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.only(left: 18, right: 18, top: 18),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.myTripScreenCancelledTripContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.car_crash,
                              color: AppColors.myTripScreenCancelledTripCarIcon,
                              size: 35,
                            ),
                            SizedBox(width: 4),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.translate("hourly"),
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  loc.translate("date_and_time"),
                                  style: TextStyle(
                                    color: AppColors
                                        .myTripScreenCancelledTripDateText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            backgroundColor: AppColors
                                .myTripScreenCancelledTripCancelledButtonbackground,
                            foregroundColor: AppColors
                                .myTripScreenCancelledTripCancelledButtonforeground,
                          ),
                          onPressed: () {},
                          child: Text(loc.translate("cancelled")),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: AppColors.myTripScreenCancelledTripPickupIcon,
                          size: 25,
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.translate("pickup"),
                                style: TextStyle(
                                  color: AppColors
                                      .myTripScreenCancelledTripPickupText,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                loc.translate("trip_address"),
                                style: GoogleFonts.poppins(
                                  color: AppColors
                                      .myTripScreenCancelledTripTripAddressText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Divider(
                                thickness: 1,
                                color: AppColors.myTripScreenCancelledDivider,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: AppColors.myTripScreenCancelledTripPickupIcon,
                          size: 25,
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 2),
                              Text(
                                loc.translate("hour"),
                                style: TextStyle(
                                  color: AppColors
                                      .myTripScreenCancelledTripPickupText,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                loc.translate("7"),
                                style: GoogleFonts.poppins(
                                  color: AppColors
                                      .myTripScreenCancelledTripTripAddressText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.myTripScreenCancelledButtonbackground,
                            foregroundColor:
                                AppColors.myTripScreenCancelledButtonforeground,
                          ),
                          onPressed: () {
                            // getIt<AppRouter>().push(TripdetailsScreen());
                          },
                          child: Text(
                            loc.translate("view_details"),
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(18),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.myTripScreenCancelledTripContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.car_crash,
                              color: AppColors.myTripScreenCancelledTripCarIcon,
                              size: 35,
                            ),
                            SizedBox(width: 4),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.translate("round_way"),
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  loc.translate("date_and_time"),
                                  style: TextStyle(
                                    color: AppColors
                                        .myTripScreenCancelledTripDateText,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            backgroundColor: AppColors
                                .myTripScreenCancelledTripCancelledButtonbackground,
                            foregroundColor: AppColors
                                .myTripScreenCancelledTripCancelledButtonforeground,
                          ),
                          onPressed: () {},
                          child: Text(loc.translate("cancelled")),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    TimelineTile(
                      icon: Icon(
                        Icons.timer_rounded,
                        size: 25,
                        color: AppColors.myTripScreenCancelledTripPickupIcon,
                      ),
                      tiles: 7,
                      child: Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate("pickup"),
                              style: TextStyle(
                                color: AppColors
                                    .myTripScreenCancelledTripPickupText,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              loc.translate("trip_address"),
                              style: GoogleFonts.poppins(
                                color: AppColors
                                    .myTripScreenCancelledTripTripAddressText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Icon(Icons.timer_rounded, color: Colors.yellow, size: 25),
                    //     SizedBox(width: 5,),
                    //     Expanded(
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             "Pickup",
                    //             style: TextStyle(color: Color(0xffb3b3b3),fontSize: 14),
                    //           ),
                    //           Text("BRTA mirpur 13 mosjid moor, mosque, BRTA Road, Dhaka",style: TextStyle(
                    //             color: Colors.black,fontSize: 14,fontWeight: FontWeight.w500
                    //           ),),
                    //           SizedBox(height: 2,),
                    //           Divider(
                    //             thickness: 1,
                    //             color: Colors.grey.shade300,
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 10),
                    TimelineTile(
                      isLast: true,
                      icon: Icon(
                        Icons.timer_rounded,
                        size: 25,
                        color: AppColors.myTripScreenCancelledTripPickupIcon,
                      ),
                      tiles: 7,
                      child: Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.translate("drop_off"),
                              style: TextStyle(
                                color: AppColors
                                    .myTripScreenCancelledTripPickupText,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              loc.translate("trip_address"),
                              style: GoogleFonts.poppins(
                                color: AppColors
                                    .myTripScreenCancelledTripTripAddressText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     Icon(Icons.timer_rounded, color: Colors.yellow, size: 20),
                    //     SizedBox(width: 5),
                    //     Expanded(
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             "Drop Off",
                    //             style: TextStyle(
                    //               color: Color(0xffb3b3b3),
                    //               fontSize: 14,
                    //             ),
                    //           ),
                    //           Text(
                    //             "তিন ভাই মঞ্জিল, Jamalpur, Mymensingh",
                    //             style: TextStyle(
                    //               color: Colors.black,
                    //               fontSize: 14,
                    //               fontWeight: FontWeight.w500,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(height: 18),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.myTripScreenCancelledButtonbackground,
                            foregroundColor:
                                AppColors.myTripScreenCancelledButtonforeground,
                          ),
                          onPressed: () {
                            // getIt<AppRouter>().push(TripdetailsScreen());
                          },
                          child: Text(
                            loc.translate("view_details"),
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
