import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/localization/app_localization.dart';
import '../../../routes/app_routes.dart';
import '../../app_urls.dart';
import '../../choose_car_args.dart';
import '../../enums.dart';
import '../controller/choose_car_bottom_sheet_bloc.dart';
import '../controller/choose_car_bottom_sheet_events.dart';
import '../controller/choose_car_bottom_sheet_state.dart';
import '../../colors_code.dart';
import '../models/choose_car_model.dart';

class ChooseCarBottomSheet extends StatefulWidget {
  const ChooseCarBottomSheet({
    super.key,
    required this.cars,
    required this.serviceName,
  });

  final List<Car> cars;
  final String serviceName;
  @override
  State<ChooseCarBottomSheet> createState() => _ChooseCarBottomSheetState();
}

class _ChooseCarBottomSheetState extends State<ChooseCarBottomSheet> {
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
        child: BlocBuilder<ChooseCarBottomSheetBloc, ChooseCarBottomSheetState>(
          builder: (context, state) {
            if (state.status == ChooseCarBottomSheetStatus.success) {
              return Column(
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
                          icon: Icon(
                            Icons.close,
                            color: Colors.black87,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView.separated(
                      physics: ClampingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: widget.cars.length,
                      itemBuilder: (context, index) {
                        final car = widget.cars[index];
                        return GestureDetector(
                          onTap: () {
                            context.read<ChooseCarBottomSheetBloc>().add(
                              ChooseCar(selectedCarIndex: index.toString()),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors
                                  .dashboardBottomSheetCarShowingContainer,
                              border:
                                  (state.currentCarIndex == index.toString())
                                  ? Border.all(
                                      color: AppColors
                                          .dashboardBottomSheetCarShowingContainerBorder,
                                      width: 2,
                                    )
                                  : null,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 55,
                                  child: Builder(
                                    builder: (context) {
                                      final avatar = car.carAvatar;
                                      final imageUrl = AppUrls.getImageUrl(
                                        avatar,
                                      );
                                      if (imageUrl == null ||
                                          imageUrl.isEmpty) {
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
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.blue,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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

                  (state.clicked == true)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 21),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                elevation: 0,
                                backgroundColor: Color(0xff0e52ff),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () {
                                final selectedIndex = int.parse(
                                  state.currentCarIndex!,
                                );
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.tripRequest,
                                  arguments: ChooseCarArgs(
                                    serviceName: widget.serviceName,
                                    car: widget.cars,
                                    index: selectedIndex,
                                  ),
                                );
                              },
                              child: Text(
                                loc.translate("continue"),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),

                  SizedBox(height: 10),
                ],
              );
            }
            if (state.status == ChooseCarBottomSheetStatus.loading) {
              return Center(
                child: CircularProgressIndicator(color: Colors.blue),
              );
            }
            if (state.status == ChooseCarBottomSheetStatus.failure) {
              return Center(
                child: Text("Failed and ${state.error.toString()}"),
              );
            }
            return Icon(Icons.directions_car);
          },
        ),
      ),
    );
  }
}
