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
}
