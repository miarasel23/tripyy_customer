import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/localization/app_localization.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/choose_car_bottom_sheet/models/choose_car_model.dart';
import '../../../utils/colors_code.dart';

class ChooseCarBottomSheetTripRequest extends StatefulWidget {
  const ChooseCarBottomSheetTripRequest({
    super.key,
    required this.cars,
    required this.selectedIndex,
  });

  final List<Car> cars;
  final int selectedIndex;

  @override
  State<ChooseCarBottomSheetTripRequest> createState() =>
      _ChooseCarBottomSheetTripRequestState();
}

class _ChooseCarBottomSheetTripRequestState
    extends State<ChooseCarBottomSheetTripRequest> {
  late int currentSelectedIndex;

  @override
  void initState() {
    super.initState();
    currentSelectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dashboardBottomSheetBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24, 2, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.translate("choose_car"),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.dashboardBottomSheetChooseCarColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.close, color: Colors.black87, size: 24),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.separated(
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                itemCount: widget.cars.length,
                itemBuilder: (context, index) {
                  final car = widget.cars[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentSelectedIndex = index;
                      });
                      Navigator.pop(context, car);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            AppColors.dashboardBottomSheetCarShowingContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: currentSelectedIndex == index
                            ? Border.all(
                                color: AppColors
                                    .dashboardBottomSheetCarShowingContainerBorder,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 55,
                            child: Builder(
                              builder: (context) {
                                final avatar = car.carAvatar;
                                final imageUrl = AppUrls.getImageUrl(avatar);
                                if (imageUrl == null || imageUrl.isEmpty) {
                                  return Icon(Icons.directions_car);
                                }

                                return Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }

                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors
                                                .dashboardBottomSheetCircularIndicator,
                                          ),
                                        );
                                      },
                                  errorBuilder: (_, _, _) {
                                    return Icon(Icons.directions_car);
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          //Text Details
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.carType,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors
                                        .dashboardBottomSheetChooseCarNameColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.people,
                                      size: 16,
                                      color: AppColors
                                          .dashboardBottomSheetChooseCarSeatsLogo,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${car.setCapacity} Seats',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: AppColors
                                            .dashboardBottomSheetChooseCarSeatsInfo,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return SizedBox(height: 12);
                },
              ),
            ),

            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
