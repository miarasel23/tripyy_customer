import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/utils/enums.dart';

import '../../../core/utils/localization/app_localization.dart';
import '../controller/choose_car_bottom_sheet_bloc.dart';
import '../controller/choose_car_bottom_sheet_events.dart';
import '../controller/choose_car_bottom_sheet_state.dart';
import '../../colors_code.dart';
import '../../images.dart';

class CarOption {
  final String name;
  final int seats;
  final String imagePath;

  CarOption({required this.name, required this.seats, required this.imagePath});
}

class ChooseCarBottomSheet extends StatefulWidget {
  const ChooseCarBottomSheet({super.key});

  @override
  State<ChooseCarBottomSheet> createState() => _ChooseCarBottomSheetState();
}

class _ChooseCarBottomSheetState extends State<ChooseCarBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final loc = AppLocalizations.of(context);
      context.read<ChooseCarBottomSheetBloc>().add(
        FetchRides(languageCode: loc.locale.languageCode),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    // final List<CarOption> options = [
    //   CarOption(name: 'Sedan 1', seats: 4, imagePath: Images.carPicture),
    //   CarOption(name: 'Sedan 2', seats: 4, imagePath: Images.carPicture),
    //   CarOption(name: 'Sedan 3', seats: 4, imagePath: Images.carPicture),
    //   CarOption(name: 'Sedan 4', seats: 4, imagePath: Images.carPicture),
    //   CarOption(name: 'Sedan 5', seats: 4, imagePath: Images.carPicture),
    //   CarOption(name: 'Sedan 6', seats: 4, imagePath: Images.carPicture),
    //   CarOption(name: 'Sedan 7', seats: 4, imagePath: Images.carPicture),
    // ];
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
                      itemCount: state.cars?.data?.first.cars?.length ?? 0,
                      itemBuilder: (context, index) {
                        final car = state.cars?.data?.first.cars?[index];
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
                              color: Color(0xFFEDF4FC),
                              border:
                                  (state.currentCarIndex == index.toString())
                                  ? Border.all(
                                      color: Color(0xff0e52ff),
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
                                      final avatar = car?.carAvatar;
                                      if (avatar == null || avatar.isEmpty) {
                                        return Icon(Icons.directions_car);
                                      }

                                      return Image.network(
                                        avatar,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
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
                                        car?.carType ?? "No name",
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
                                            '${car?.setCapacity ?? "No"} Seats',
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
                              onPressed: () {},
                              child: Text(
                                "Continue",
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
              return Center(child: Text("Failed and ${state.error.toString()}"));
            }
            return Icon(Icons.directions_car);
          },
        ),
      ),
    );
  }
}
