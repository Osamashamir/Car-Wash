// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get login => 'Se connecter';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get dontHaveAnAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get bookService => 'Réserver un service';

  @override
  String get selectServiceType => 'Sélectionner le type de service';

  @override
  String get numberOfCars => 'Nombre de voitures';

  @override
  String carDetails(int index) {
    return 'Détails de la voiture $index';
  }

  @override
  String get selectDate => 'Sélectionner la date';

  @override
  String get chooseDate => 'Choisir une date';

  @override
  String get selectTime => 'Sélectionner l\'heure';

  @override
  String get chooseTime => 'Choisir l\'heure';

  @override
  String get address => 'Adresse';

  @override
  String get currentLocation => 'Localisation actuelle';

  @override
  String get fillRequiredFields => 'Veuillez remplir tous les champs obligatoires';

  @override
  String get bookingSuccess => 'Réservation soumise avec succès !';

  @override
  String get bookNow => 'Réserver maintenant';

  @override
  String get profile => 'Profil';

  @override
  String get book => 'Réserver';

  @override
  String get offer => 'Offres';

  @override
  String get feedback => 'Retour d\'information';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get viewOrder => 'Voir la commande';

  @override
  String get offers => 'Offres';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get congratulations => '🎉 Félicitations !';

  @override
  String get freeCarWash => 'Vous avez obtenu 1 lavage de voiture gratuit';

  @override
  String get complain => 'Plainte';

  @override
  String get feedbackSuccess => 'Retour d\'information soumis avec succès !';

  @override
  String get selectType => 'Sélectionner le type';

  @override
  String get addScreenshot => 'Appuyer pour ajouter une capture d\'écran';

  @override
  String get additionalNotes => 'Notes supplémentaires';

  @override
  String get submit => 'Soumettre';

  @override
  String get yourOrders => 'Vos commandes';

  @override
  String get filterByDate => 'Filtrer par date';

  @override
  String get noOrdersFound => 'Aucune commande trouvée.';

  @override
  String get giveFeedback => 'Donner son avis';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get thisYear => 'Cette année';

  @override
  String get all => 'Tout';
}
