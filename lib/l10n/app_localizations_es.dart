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
}
