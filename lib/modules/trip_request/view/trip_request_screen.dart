import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trippy_customer/modules/trip_request/widgets/choose_car_bottom_sheet_trip_request.dart';
import '../../../core/utils/localization/app_localization.dart';
import '../../../utils/app_urls.dart';
import '../../../utils/choose_car_args.dart';
import '../../../utils/choose_car_bottom_sheet/models/choose_car_model.dart';
import '../../../utils/colors_code.dart';

class TripRequestScreen extends StatefulWidget {
  const TripRequestScreen({super.key, required this.args});
  final ChooseCarArgs args;

  @override
  State<TripRequestScreen> createState() => _TripRequestScreenState();
}

class _TripRequestScreenState extends State<TripRequestScreen> {
  late Car selectedCar;
  late int selectedCarIndex;

  @override
  void initState() {
    super.initState();

    selectedCar = widget.args.car![widget.args.index!];
    selectedCarIndex = widget.args.index!;
  }

  Future<void> _showCarSelector() async {
    final Car? car = await showModalBottomSheet<Car>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.845,
          child: ChooseCarBottomSheetTripRequest(
            cars: widget.args.car!,
            selectedIndex: selectedCarIndex,
          ),
        );
      },
    );

    if (car != null) {
      setState(() {
        selectedCar = car;
        selectedCarIndex = widget.args.car!.indexOf(car);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Car currentRide = widget.args.car![widget.args.index!];
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.tripRequestScreenBackground,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.tripRequestScreenAppBarBackground,
        title: Text(
          loc.translate("intercity"),
          style: GoogleFonts.poppins(
            color: AppColors.tripRequestScreenAppBarText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(14, 12, 14, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.tripRequestScreenCarContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildcarImage(selectedCar),

                    const SizedBox(width: 16),

                    _buildRideName_Seats(selectedCar),
                    GestureDetector(
                      onTap: () {
                        _showCarSelector();
                      },
                      child: Icon(Icons.keyboard_arrow_down),
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

  Widget _buildRideName_Seats(Car currentRide) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currentRide.carType, style: GoogleFonts.poppins(fontSize: 14,fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.people_alt_rounded, size: 18, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                "${currentRide.setCapacity.toString()} seats",
                style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildcarImage(Car currentRide) {
    return SizedBox(
      width: 80,
      height: 55,
      child: Builder(
        builder: (context) {
          final imageUrl = AppUrls.getImageUrl(currentRide.carAvatar);
          if (imageUrl == null || imageUrl.isEmpty) {
            return Icon(Icons.directions_car);
          }

          return Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.tripRequestScreenCircularIndicator,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
