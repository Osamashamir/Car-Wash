// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get email => 'بريد إلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get forgotPassword => 'هل نسيت كلمة السر؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signInWithGoogle => 'تسجيل الدخول باستخدام جوجل';

  @override
  String get dontHaveAnAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'اشتراك';

  @override
  String get bookService => 'حجز خدمة';

  @override
  String get selectServiceType => 'اختر نوع الخدمة';

  @override
  String get numberOfCars => 'عدد السيارات';

  @override
  String carDetails(int index) {
    return 'تفاصيل السيارة $index';
  }

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get chooseDate => 'اختر تاريخًا';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get chooseTime => 'اختر وقتًا';

  @override
  String get address => 'العنوان';

  @override
  String get currentLocation => 'الموقع الحالي';

  @override
  String get fillRequiredFields => 'يرجى ملء جميع الحقول المطلوبة';

  @override
  String get bookingSuccess => 'تم تقديم الحجز بنجاح!';

  @override
  String get bookNow => 'احجز الآن';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get book => 'احجز';

  @override
  String get offer => 'عروض';

  @override
  String get feedback => 'ملاحظات';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get viewOrder => 'عرض الطلب';

  @override
  String get offers => 'عروض';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get congratulations => '🎉 مبروك!';

  @override
  String get freeCarWash => 'لقد حصلت على غسيل سيارات مجاني';

  @override
  String get complain => 'شكوى';

  @override
  String get feedbackSuccess => 'تم تقديم الملاحظات بنجاح!';

  @override
  String get selectType => 'اختر النوع';

  @override
  String get addScreenshot => 'انقر لإضافة لقطة شاشة';

  @override
  String get additionalNotes => 'ملاحظات إضافية';

  @override
  String get submit => 'إرسال';

  @override
  String get yourOrders => 'طلباتك';

  @override
  String get filterByDate => 'تصفية حسب التاريخ';

  @override
  String get noOrdersFound => 'لم يتم العثور على طلبات.';

  @override
  String get giveFeedback => 'قدم ملاحظاتك';

  @override
  String get today => 'اليوم';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get thisYear => 'هذه السنة';

  @override
  String get all => 'الكل';
}
