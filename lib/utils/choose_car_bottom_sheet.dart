import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trippy_customer/utils/choose_car_bottom_sheet_controller/choose_car_bottom_sheet_bloc.dart';
import 'package:trippy_customer/utils/choose_car_bottom_sheet_controller/choose_car_bottom_sheet_events.dart';
import 'package:trippy_customer/utils/choose_car_bottom_sheet_controller/choose_car_bottom_sheet_state.dart';

import '../core/utils/localization/app_localization.dart';
import 'colors_code.dart';
import 'images.dart';

class CarOption {
  final String name;
  final int seats;
  final String imagePath;

  CarOption({required this.name, required this.seats, required this.imagePath});
}

class ChooseCarBottomSheet extends StatelessWidget {
  const ChooseCarBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final List<CarOption> options = [
      CarOption(name: 'Sedan 1', seats: 4, imagePath: Images.carPicture),
      CarOption(name: 'Sedan 2', seats: 4, imagePath: Images.carPicture),
      CarOption(name: 'Sedan 3', seats: 4, imagePath: Images.carPicture),
      CarOption(name: 'Sedan 4', seats: 4, imagePath: Images.carPicture),
      CarOption(name: 'Sedan 5', seats: 4, imagePath: Images.carPicture),
      CarOption(name: 'Sedan 6', seats: 4, imagePath: Images.carPicture),
      CarOption(name: 'Sedan 7', seats: 4, imagePath: Images.carPicture),
    ];
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
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(24, 20, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        loc.translate("choose_car"),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dashboardBottomSheetChooseCarColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close, color: Colors.black87, size: 26),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView.separated(
                    physics: ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final car = options[index];
                      return GestureDetector(
                        onTap: (){
                          context.read<ChooseCarBottomSheetBloc>().add(ChooseCar(selectedCarIndex: index.toString()));
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Color(0xFFEDF4FC),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                height: 55,
                                child: Image.asset(
                                  car.imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.directions_car,
                                    size: 40,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              //Text Details
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      car.name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
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
                                          '${car.seats} Seats',
                                          style: TextStyle(
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
                
                (state.clicked == true) ? ElevatedButton(onPressed: (){}, child: Text("continue")) : SizedBox()
              ],
            );
          }
        ),
      ),
    );
  }
}
