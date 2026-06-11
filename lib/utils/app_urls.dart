import '../store/important_consts.dart';

class AppUrls {
  static const String baseUrl = "http://3.209.161.158/api";
  // customer
  static const String sendOtpCustomer =
      "$baseUrl/v1/customer/send-otp-for-signup-or-login";
  static const String verifyOtpCustomer =
      "$baseUrl/v1/customer/otp-verification-with-login";
  static const String getCurrentCustomerUser =
      "$baseUrl/v1/customer/get-current-customer-user";
  static const String customerProfileUpdate =
      "$baseUrl/v1/customer/profile-update";
  static const String customerProfilePictureUpdate =
      "$baseUrl/v1/customer/customer-profile-picture-update";
  static const String rentalInfo =
      "$baseUrl/v1/rental-trip/rental-info";
  static String? get profileImageUrl {
    final image = ImportantConsts.userData?.data?.user?.profilePicture;

    if (image == null || image.isEmpty) {
      return null;
    }

    return "$baseUrl/assets/uploads/images/$image";
  }
}
