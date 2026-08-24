import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveTripHelper {
  static Future<void> launchCallOrUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Action Unavailable"),
            content: Text("Cannot launch $url."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  static IconData getVehicleIcon(String? carType) {
    if (carType == null) return Icons.directions_car;
    final lower = carType.toLowerCase();
    if (lower.contains('bike') || lower.contains('motor')) {
      return Icons.motorcycle;
    } else if (lower.contains('cng') || lower.contains('auto')) {
      return Icons.electric_rickshaw;
    } else if (lower.contains('micro') || lower.contains('van') || lower.contains('bus')) {
      return Icons.airport_shuttle;
    }
    return Icons.directions_car;
  }

  static String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      final dt = DateTime.parse(dateStr);
      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      final amPm = dt.hour >= 12 ? "PM" : "AM";
      final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final minute = dt.minute.toString().padLeft(2, '0');
      return "${dt.day} ${months[dt.month - 1]}, ${dt.year} - $hour12:$minute $amPm";
    } catch (e) {
      return dateStr;
    }
  }

  static String formatServiceName(String? rawName, {int? hoursBooked}) {
    if (rawName == null || rawName.isEmpty) return "";
    final temp = rawName.replaceAll('_', ' ').trim();
    String formatted;
    if (temp.toLowerCase().contains("inter city renter")) {
      formatted = "Inter city renter";
    } else {
      final lower = temp.toLowerCase();
      formatted = lower[0].toUpperCase() + lower.substring(1);
    }
    if ((temp.toUpperCase().contains("HOURLY") || temp.toUpperCase().contains("HOUR")) && hoursBooked != null && hoursBooked > 0) {
      formatted = "$formatted ($hoursBooked ${hoursBooked == 1 ? 'Hour' : 'Hours'})";
    }
    return formatted;
  }

  static String formatCarType(String? carType) {
    if (carType == null || carType.isEmpty) return "";
    final text = carType.replaceAll('_', ' ');
    if (text.toUpperCase() == "MOTOR CYCEL" || text.toUpperCase() == "MOTOR CYCLE") {
      return "Motor Cycle";
    }
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static String toBanglaDigits(String numberStr) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bangla = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    for (int i = 0; i < english.length; i++) {
      numberStr = numberStr.replaceAll(english[i], bangla[i]);
    }
    return numberStr;
  }

  static double calculateBearing(LatLng start, LatLng end) {
    final double lat1 = start.latitude * (math.pi / 180.0);
    final double lng1 = start.longitude * (math.pi / 180.0);
    final double lat2 = end.latitude * (math.pi / 180.0);
    final double lng2 = end.longitude * (math.pi / 180.0);

    final double dLng = lng2 - lng1;

    final double y = math.sin(dLng) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    final double bearing = math.atan2(y, x) * (180.0 / math.pi);
    return (bearing + 360.0) % 360.0;
  }

  static Future<BitmapDescriptor> getMarkerIconFromIconData(String? carType, Color color, double size) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final sizeObj = Size(size, size);

    final lower = carType?.toLowerCase() ?? '';
    final bool isBike = lower.contains('bike') || lower.contains('motor');

    if (isBike) {
      _paintTopDownBike(canvas, sizeObj, color);
    } else {
      _paintTopDownCar(canvas, sizeObj, color);
    }

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes != null) {
      return BitmapDescriptor.bytes(bytes.buffer.asUint8List());
    }
    return BitmapDescriptor.defaultMarker;
  }

  static void _paintTopDownCar(Canvas canvas, Size size, Color color) {
    final double w = size.width;
    final double h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;
    
    final double cx = w / 2;
    final double cy = h / 2;

    paint.color = Colors.black.withAlpha(40);
    final shadowPath = Path()
      ..moveTo(cx - w * 0.22, cy - h * 0.38)
      ..quadraticBezierTo(cx, cy - h * 0.44, cx + w * 0.22, cy - h * 0.38)
      ..lineTo(cx + w * 0.24, cy + h * 0.38)
      ..quadraticBezierTo(cx, cy + h * 0.44, cx - w * 0.24, cy + h * 0.38)
      ..close();
    canvas.drawPath(shadowPath, paint);

    paint.color = const Color(0xFF1A1A1A);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - w * 0.28, cy - h * 0.28, w * 0.08, h * 0.16), Radius.circular(w * 0.02)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + w * 0.20, cy - h * 0.28, w * 0.08, h * 0.16), Radius.circular(w * 0.02)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - w * 0.28, cy + h * 0.14, w * 0.08, h * 0.18), Radius.circular(w * 0.02)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + w * 0.20, cy + h * 0.14, w * 0.08, h * 0.18), Radius.circular(w * 0.02)), paint);

    paint.color = color;
    final bodyPath = Path()
      ..moveTo(cx - w * 0.20, cy - h * 0.35)
      ..quadraticBezierTo(cx - w * 0.18, cy - h * 0.40, cx, cy - h * 0.42)
      ..quadraticBezierTo(cx + w * 0.18, cy - h * 0.40, cx + w * 0.20, cy - h * 0.35)
      ..lineTo(cx + w * 0.22, cy - h * 0.10)
      ..quadraticBezierTo(cx + w * 0.24, cy, cx + w * 0.22, cy + h * 0.20)
      ..lineTo(cx + w * 0.20, cy + h * 0.38)
      ..quadraticBezierTo(cx, cy + h * 0.41, cx - w * 0.20, cy + h * 0.38)
      ..lineTo(cx - w * 0.22, cy + h * 0.20)
      ..quadraticBezierTo(cx - w * 0.24, cy, cx - w * 0.22, cy - h * 0.10)
      ..close();
    canvas.drawPath(bodyPath, paint);

    paint.color = const Color(0xFFF44336);
    final hoodPath = Path()
      ..moveTo(cx - w * 0.20, cy - h * 0.35)
      ..quadraticBezierTo(cx - w * 0.18, cy - h * 0.40, cx, cy - h * 0.42)
      ..quadraticBezierTo(cx + w * 0.18, cy - h * 0.40, cx + w * 0.20, cy - h * 0.35)
      ..lineTo(cx + w * 0.21, cy - h * 0.15)
      ..quadraticBezierTo(cx, cy - h * 0.10, cx - w * 0.21, cy - h * 0.15)
      ..close();
    canvas.drawPath(hoodPath, paint);

    paint.color = const Color(0xFFF44336);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - w * 0.27, cy - h * 0.20, w * 0.06, h * 0.06), Radius.circular(w * 0.01)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + w * 0.21, cy - h * 0.20, w * 0.06, h * 0.06), Radius.circular(w * 0.01)), paint);

    paint.color = const Color(0xFF1E2124);
    final windshieldPath = Path()
      ..moveTo(cx - w * 0.15, cy - h * 0.16)
      ..lineTo(cx + w * 0.15, cy - h * 0.16)
      ..quadraticBezierTo(cx + w * 0.12, cy - h * 0.26, cx, cy - h * 0.27)
      ..quadraticBezierTo(cx - w * 0.12, cy - h * 0.26, cx - w * 0.15, cy - h * 0.16)
      ..close();
    canvas.drawPath(windshieldPath, paint);

    paint.color = const Color(0xFFE0E0E0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - w * 0.15, cy - h * 0.16, w * 0.30, h * 0.32),
        Radius.circular(w * 0.02),
      ),
      paint,
    );

    paint.color = const Color(0xFF1E2124);
    final rearWindowPath = Path()
      ..moveTo(cx - w * 0.14, cy + h * 0.16)
      ..lineTo(cx + w * 0.14, cy + h * 0.16)
      ..quadraticBezierTo(cx + w * 0.11, cy + h * 0.24, cx, cy + h * 0.25)
      ..quadraticBezierTo(cx - w * 0.11, cy + h * 0.24, cx - w * 0.14, cy + h * 0.16)
      ..close();
    canvas.drawPath(rearWindowPath, paint);

    paint.color = const Color(0xFFFFEB3B);
    canvas.drawArc(Rect.fromLTWH(cx - w * 0.18, cy - h * 0.43, w * 0.07, h * 0.04), 3.14, 3.14, true, paint);
    canvas.drawArc(Rect.fromLTWH(cx + w * 0.11, cy - h * 0.43, w * 0.07, h * 0.04), 3.14, 3.14, true, paint);

    paint.color = const Color(0xFFF44336);
    canvas.drawRect(Rect.fromLTWH(cx - w * 0.17, cy + h * 0.37, w * 0.06, h * 0.02), paint);
    canvas.drawRect(Rect.fromLTWH(cx + w * 0.11, cy + h * 0.37, w * 0.06, h * 0.02), paint);
  }

  static void _paintTopDownBike(Canvas canvas, Size size, Color color) {
    final double w = size.width;
    final double h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;
    
    final double cx = w / 2;
    final double cy = h / 2;

    paint.color = Colors.black.withAlpha(35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - w * 0.16, cy - h * 0.40, w * 0.32, h * 0.82),
        Radius.circular(w * 0.08),
      ),
      paint,
    );

    paint.color = const Color(0xFF222222);
    canvas.drawRect(Rect.fromLTWH(cx - w * 0.04, cy - h * 0.30, w * 0.08, h * 0.60), paint);

    paint.color = Colors.black;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - w * 0.03, cy - h * 0.42, w * 0.06, h * 0.20),
        Radius.circular(w * 0.015),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - w * 0.04, cy + h * 0.22, w * 0.08, h * 0.24),
        Radius.circular(w * 0.02),
      ),
      paint,
    );

    paint.color = const Color(0xFFF44336);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - w * 0.22, cy - h * 0.26, w * 0.44, h * 0.035), Radius.circular(w * 0.01)), paint);
    paint.color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(cx - w * 0.24, cy - h * 0.26, w * 0.04, h * 0.035), paint);
    canvas.drawRect(Rect.fromLTWH(cx + w * 0.20, cy - h * 0.26, w * 0.04, h * 0.035), paint);

    paint.color = color;
    final bodyPath = Path()
      ..moveTo(cx - w * 0.06, cy - h * 0.20)
      ..lineTo(cx + w * 0.06, cy - h * 0.20)
      ..quadraticBezierTo(cx + w * 0.12, cy - h * 0.05, cx + w * 0.08, cy + h * 0.10)
      ..lineTo(cx - w * 0.08, cy + h * 0.10)
      ..quadraticBezierTo(cx - w * 0.12, cy - h * 0.05, cx - w * 0.06, cy - h * 0.20)
      ..close();
    canvas.drawPath(bodyPath, paint);

    paint.color = const Color(0xFF1A1A1A);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - w * 0.05, cy + h * 0.02, w * 0.10, h * 0.18),
        Radius.circular(w * 0.02),
      ),
      paint,
    );

    paint.color = const Color(0xFFFFEB3B);
    canvas.drawCircle(Offset(cx, cy - h * 0.44), w * 0.025, paint);
  }

  static void fitMapToBounds(List<LatLng> points, GoogleMapController? mapController, {required bool isMounted}) {
    if (points.isEmpty || mapController == null || !isMounted) return;

    if (points.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isMounted) {
          mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: points.first, zoom: 15.0),
          ));
        }
      });
      return;
    }

    double? minLat, maxLat, minLng, maxLng;
    for (final p in points) {
      if (minLat == null || p.latitude < minLat) minLat = p.latitude;
      if (maxLat == null || p.latitude > maxLat) maxLat = p.latitude;
      if (minLng == null || p.longitude < minLng) minLng = p.longitude;
      if (maxLng == null || p.longitude > maxLng) maxLng = p.longitude;
    }
    if (minLat == null || maxLat == null || minLng == null || maxLng == null) return;

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isMounted) {
        mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80.0));
      }
    });
  }
}
