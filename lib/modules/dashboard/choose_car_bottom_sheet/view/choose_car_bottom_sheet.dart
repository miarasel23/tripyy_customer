import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/utils/localization/app_localization.dart';
import '../../../../utils/app_urls.dart';
import '../../../../utils/enums.dart';
import '../controller/choose_car_bottom_sheet_bloc.dart';
import '../controller/choose_car_bottom_sheet_events.dart';
import '../controller/choose_car_bottom_sheet_state.dart';
import '../../../../utils/colors_code.dart';
import '../models/choose_car_model.dart';

class CarOption {
  final String name;
  final int seats;
  final String imagePath;

  CarOption({required this.name, required this.seats, required this.imagePath});
}

class ChooseCarBottomSheet extends StatefulWidget {
  const ChooseCarBottomSheet({
    super.key,
    required this.cars,
    required this.serviceName,
    required this.pickupAddress,
    required this.dropoffAddress,
  });

  final List<Car> cars;
  final String serviceName;
  final String pickupAddress;
  final String dropoffAddress;
  @override
  State<ChooseCarBottomSheet> createState() => _ChooseCarBottomSheetState();
}

class _ChooseCarBottomSheetState extends State<ChooseCarBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Timeline graphics
                            Column(
                              children: [
                                SizedBox(height: 6),
                                Icon(Icons.circle, size: 8, color: Colors.grey[400]),
                                Container(
                                  height: 20, 
                                  width: 2, 
                                  margin: EdgeInsets.symmetric(vertical: 2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(4, (index) => Container(
                                      width: 2, height: 2, color: Colors.grey[600],
                                    )),
                                  ),
                                ),
                                Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[400]),
                              ],
                            ),
                            SizedBox(width: 12),
                            // Text info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "PICKUP & DROP-OFF",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[500],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "${widget.pickupAddress.split(',').first} · ${widget.dropoffAddress.split(',').first}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Edit button
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "EDIT",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo.shade200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
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
                        final isSelected = state.currentCarIndex == index.toString();
                        return GestureDetector(
                          onTap: () {
                            context.read<ChooseCarBottomSheetBloc>().add(
                              ChooseCar(selectedCarIndex: index.toString()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? const Color(0xFF2B2B36) 
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected 
                                    ? const Color(0xFF8C9EFF) 
                                    : Colors.grey.withOpacity(0.3),
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Car Image
                                Container(
                                  width: 80,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                  child: Builder(
                                    builder: (context) {
                                      final avatar = car.carAvatar;
                                      final imageUrl = AppUrls.getImageUrl(avatar);
                                      if (imageUrl == null || imageUrl.isEmpty) {
                                        return const Icon(Icons.directions_car, color: Colors.grey);
                                      }

                                      return Image.network(
                                        imageUrl,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        height: double.infinity,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.directions_car, color: Colors.grey),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Text Details (Middle)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        car.carType,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${car.setCapacity} Seats',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Price & Distance (Right)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (car.minimumBookingPrice != null)
                                      Text(
                                        '${loc.translate("up_to") ?? "Up to"} ' + 
                                        (loc.locale.languageCode == 'bn' 
                                            ? '৳${car.minimumBookingPrice}' 
                                            : 'BDT ${car.minimumBookingPrice}'),
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      ),
                                    if (car.distance != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '${car.distance} km',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 12);
                      },
                    ),
                  ),

                  if (state.clicked == true && state.currentCarIndex != null && int.tryParse(state.currentCarIndex!) != null)
                    Builder(builder: (context) {
                      final idx = int.parse(state.currentCarIndex!);
                      if (idx < 0 || idx >= widget.cars.length) return SizedBox();
                      final selectedCar = widget.cars[idx];
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 21),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              elevation: 0,
                              backgroundColor: Color(0xff0e52ff),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Builder(builder: (context) {
                                        final avatar = selectedCar.carAvatar;
                                        final imageUrl = AppUrls.getImageUrl(avatar);
                                        if (imageUrl == null || imageUrl.isEmpty) {
                                          return Icon(Icons.directions_car, color: Colors.white);
                                        }
                                        return Image.network(
                                          imageUrl, 
                                          fit: BoxFit.contain,
                                          errorBuilder: (_,__,___) => Icon(Icons.directions_car, color: Colors.white),
                                        );
                                      }),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "TRIPPY ${selectedCar.carType}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),

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
