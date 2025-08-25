// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get email => 'ای میل';

  @override
  String get password => 'پاس ورڈ';

  @override
  String get forgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get login => 'لاگ ان';

  @override
  String get signInWithGoogle => 'گوگل کے ساتھ سائن ان کریں';

  @override
  String get dontHaveAnAccount => 'کھاتہ نہیں ہے؟';

  @override
  String get signUp => 'سائن اپ';

  @override
  String get bookService => 'سروس بک کروائیں';

  @override
  String get selectServiceType => 'سروس کی قسم منتخب کریں';

  @override
  String get numberOfCars => 'گاڑیوں کی تعداد';

  @override
  String carDetails(int index) {
    return 'گاڑی $index کی تفصیلات';
  }

  @override
  String get selectDate => 'تاریخ منتخب کریں';

  @override
  String get chooseDate => 'ایک تاریخ منتخب کریں';

  @override
  String get selectTime => 'وقت منتخب کریں';

  @override
  String get chooseTime => 'وقت منتخب کریں';

  @override
  String get address => 'پتہ';

  @override
  String get currentLocation => 'موجودہ مقام';

  @override
  String get fillRequiredFields => 'براہ کرم تمام ضروری فیلڈز بھریں';

  @override
  String get bookingSuccess => 'بکنگ کامیابی سے جمع کرائی گئی!';

  @override
  String get bookNow => 'ابھی بک کریں';

  @override
  String get profile => 'پروفائل';

  @override
  String get book => 'بک کریں';

  @override
  String get offer => 'آفر';

  @override
  String get feedback => 'فیڈ بیک';

  @override
  String get myProfile => 'میرا پروفائل';

  @override
  String get viewOrder => 'آرڈر دیکھیں';

  @override
  String get offers => 'آفرز';

  @override
  String get logout => 'لاگ آؤٹ';

  @override
  String get congratulations => '🎉 مبارک ہو!';

  @override
  String get freeCarWash => 'آپ کو ایک مفت کار واش ملا ہے';

  @override
  String get complain => 'شکایت';

  @override
  String get feedbackSuccess => 'فیڈ بیک کامیابی سے جمع ہو گیا!';

  @override
  String get selectType => 'قسم منتخب کریں';

  @override
  String get addScreenshot => 'اسکرین شاٹ شامل کرنے کے لیے ٹیپ کریں';

  @override
  String get additionalNotes => 'اضافی نوٹس';

  @override
  String get submit => 'جمع کروائیں';

  @override
  String get yourOrders => 'آپ کے آرڈرز';

  @override
  String get filterByDate => 'تاریخ کے لحاظ سے فلٹر کریں';

  @override
  String get noOrdersFound => 'کوئی آرڈر نہیں ملا۔';

  @override
  String get giveFeedback => 'فیڈ بیک دیں';

  @override
  String get today => 'آج';

  @override
  String get thisWeek => 'اس ہفتے';

  @override
  String get thisMonth => 'اس مہینے';

  @override
  String get thisYear => 'اس سال';

  @override
  String get all => 'سب';
}
