import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trippy_customer/utils/app_urls.dart';
import '../../../../core/utils/localization/app_localization.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_bloc.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_events.dart';
import '../../../../utils/choose_car_bottom_sheet/controller/choose_car_bottom_sheet_state.dart';
import '../../../../utils/colors_code.dart';
import '../../../../utils/choose_car_bottom_sheet/view/choose_car_bottom_sheet.dart';

// Import extracted widgets
import '../widget/top_bar_widget.dart';
import '../widget/search_and_saved_card_widget.dart';
import '../widget/services_section_widget.dart';
import '../widget/dashboard_helper_widgets.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = AppLocalizations.of(context);
      context.read<ChooseCarBottomSheetBloc>().add(
        LoadServices(languageCode: loc.locale.languageCode),
      );
      print("clicked 1");
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    
    setState(() {
      _currentPosition = position;
      _circles = {
        Circle(
          circleId: CircleId("radius"),
          center: LatLng(position.latitude, position.longitude),
          radius: 5000, // 5km radius
          fillColor: Colors.blue.withOpacity(0.2),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        )
      };
    });

    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 12.0, // Zoom level to fit ~5km radius
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Top portion: Map and Top App Bar
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(23.8103, 90.4125), // Default to Dhaka or adjust as needed
                      zoom: 10,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    circles: _circles,
                    onTap: (LatLng location) {
                      setState(() {
                        _currentPosition = Position(
                          longitude: location.longitude,
                          latitude: location.latitude,
                          timestamp: DateTime.now(),
                          accuracy: 0.0,
                          altitude: 0.0,
                          altitudeAccuracy: 0.0,
                          heading: 0.0,
                          headingAccuracy: 0.0,
                          speed: 0.0,
                          speedAccuracy: 0.0,
                        );
                        _circles = {
                          Circle(
                            circleId: CircleId("radius"),
                            center: location,
                            radius: 5000,
                            fillColor: Colors.blue.withOpacity(0.2),
                            strokeColor: Colors.blue,
                            strokeWidth: 2,
                          )
                        };
                      });
                      if (_mapController != null) {
                        _mapController!.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(target: location, zoom: 15.0),
                        ));
                      }
                    },
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      if (_currentPosition != null) {
                        _mapController!.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                            zoom: 12.0,
                          ),
                        ));
                      }
                    },
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20,
                  right: 20,
                  child: TopBarWidget(),
                ),
              ],
            ),
          ),
          
          // Bottom portion: Services and Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<ChooseCarBottomSheetBloc, ChooseCarBottomSheetState>(
                  builder: (context, state) {
                    return ServicesSectionWidget(state: state);
                  },
                ),
                SizedBox(height: 20),
                SearchAndSavedCardWidget(
                  loc: loc,
                  onPickupSelected: (location) {
                    if (location.latitude != null && location.longitude != null) {
                      final latLng = LatLng(location.latitude!, location.longitude!);
                      setState(() {
                        _currentPosition = Position(
                          longitude: latLng.longitude,
                          latitude: latLng.latitude,
                          timestamp: DateTime.now(),
                          accuracy: 0.0,
                          altitude: 0.0,
                          altitudeAccuracy: 0.0,
                          heading: 0.0,
                          headingAccuracy: 0.0,
                          speed: 0.0,
                          speedAccuracy: 0.0,
                        );
                        _circles = {
                          Circle(
                            circleId: CircleId("radius"),
                            center: latLng,
                            radius: 5000,
                            fillColor: Colors.blue.withOpacity(0.2),
                            strokeColor: Colors.blue,
                            strokeWidth: 2,
                          )
                        };
                      });
                      if (_mapController != null) {
                        _mapController!.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(target: latLng, zoom: 15.0),
                        ));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


