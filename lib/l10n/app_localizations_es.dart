// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Has olvidado tu contraseña?';

  @override
  String get login => 'Acceso';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get dontHaveAnAccount => '¿No tienes una cuenta?';

  @override
  String get signUp => 'Inscribirse';

  @override
  String get bookService => 'Book a Service';

  @override
  String get selectServiceType => 'Select Service Type';

  @override
  String get numberOfCars => 'Number of Cars';

  @override
  String carDetails(int index) {
    return 'Car $index Details';
  }

  @override
  String get selectDate => 'Select Date';

  @override
  String get chooseDate => 'Choose a date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get chooseTime => 'Choose time';

  @override
  String get address => 'Address';

  @override
  String get currentLocation => 'Current Location';

  @override
  String get fillRequiredFields => 'Please fill all required fields';

  @override
  String get bookingSuccess => 'Booking submitted successfully!';

  @override
  String get bookNow => 'Book Now';

  @override
  String get profile => 'Profile';

  @override
  String get book => 'Book';

  @override
  String get offer => 'Offer';

  @override
  String get feedback => 'Feedback';

  @override
  String get myProfile => 'My Profile';

  @override
  String get viewOrder => 'View Order';

  @override
  String get offers => 'Offers';

  @override
  String get logout => 'Logout';

  @override
  String get congratulations => '🎉 Congratulations!';

  @override
  String get freeCarWash => 'You\'ve got 1 Free Car Wash';

  @override
  String get complain => 'Complain';

  @override
  String get feedbackSuccess => 'Feedback submitted successfully!';

  @override
  String get selectType => 'Select Type';

  @override
  String get addScreenshot => 'Tap to add screenshot';

  @override
  String get additionalNotes => 'Additional Notes';

  @override
  String get submit => 'Submit';

  @override
  String get yourOrders => 'Your Orders';

  @override
  String get filterByDate => 'Filter by Date';

  @override
  String get noOrdersFound => 'No orders found.';

  @override
  String get giveFeedback => 'Give Feedback';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get all => 'All';
}
