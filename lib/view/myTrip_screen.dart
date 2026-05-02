import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/core/utils/localization/app_localization.dart';
import 'package:trippy_customer/data/services/service_locator.dart';
import 'package:trippy_customer/routes/app_router.dart';
import 'package:trippy_customer/view/tripDetails_screen.dart';
import 'package:trippy_customer/widgets/timeline_tile.dart';

class MytripScreen extends StatelessWidget {
  const MytripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.white,
        title: Text(
          loc.translate("My_Trip"),
          style: TextStyle(
            color: Colors.black,
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
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        loc.translate("Car_Rental"),
                        style: GoogleFonts.poppins(
                          color: Colors.black,
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
                    decoration: BoxDecoration(color: Colors.white),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        loc.translate("Wedding_Car"),
                        style: GoogleFonts.poppins(
                          color: Colors.black,
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
                  color: Color(0xffedf6ff),
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
                            Icon(Icons.car_crash, color: Colors.blue, size: 35),
                            SizedBox(width: 4),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.translate("Hourly"),
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  loc.translate("08_Feb_2026,_05:30_PM"),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
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
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
                          child: Text(loc.translate("Cancelled")),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: Colors.yellow,
                          size: 25,
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.translate("Pickup"),
                                style: TextStyle(
                                  color: Color(0xffb3b3b3),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                loc.translate(
                                  "Meena_Bazar_-_Ashkhona_Branch,_Airport_-_Dakshinkhan_Road,_Dhaka",
                                ),
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 2),
                              Divider(
                                thickness: 1,
                                color: Colors.grey.shade300,
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
                          color: Colors.yellow,
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
                                loc.translate("Hour"),
                                style: TextStyle(
                                  color: Color(0xffb3b3b3),
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                loc.translate("7"),
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
                    ),
                    SizedBox(height: 18),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            getIt<AppRouter>().push(TripdetailsScreen());
                          },
                          child: Text(
                            loc.translate("View_Details"),
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
                  color: Color(0xffedf6ff),
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
                            Icon(Icons.car_crash, color: Colors.blue, size: 35),
                            SizedBox(width: 4),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.translate("Round_Way"),
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  loc.translate("31_Jan_2026,_07:00_AM"),
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
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
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
                          child: Text(loc.translate("Cancelled")),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    TimelineTile(
                      icon: Icon(
                        Icons.timer_rounded,
                        size: 25,
                        color: Colors.yellow,
                      ),
                      tiles: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate("Pickup"),
                            style: TextStyle(
                              color: Color(0xffb3b3b3),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            loc.translate(
                              "BRTA_mirpur_13_mosjid_moor,_mosque,_BRTA_Road,_Dhaka",
                            ),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                        color: Colors.yellow,
                      ),
                      tiles: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.translate("Drop_Off"),
                            style: TextStyle(
                              color: Color(0xffb3b3b3),
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            loc.translate(
                              "তিন_ভাই_মঞ্জিল,_Jamalpur,_Mymensingh",
                            ),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            getIt<AppRouter>().push(TripdetailsScreen());
                          },
                          child: Text(
                            loc.translate("View_Details"),
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
