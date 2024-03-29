import 'package:i18n_extension/i18n_extension.dart';

extension Localization on String {
  static final _t = Translations.byLocale("hu_hu") +
      {
        "en_en": {
          "Classroom": "Classroom",
          "Next": "Next",
          "Done": "Done",
          "Cancel": "Cancel",
          "Back": "Back",
          "Invalid room": "Room can't be empty"
        },
        "hu_hu": {
          "Classroom": "Terem",
          "Next": "Tovább",
          "Done": "Kész",
          "Cancel": "Mégse",
          "Back": "Vissza",
          "Invalid room": "A semmi közepén lesz ez az óra? Na ne."
        },
        "de_de": {
          "Classroom": "Raum",
          "Next": "Nächste",
          "Done": "Fertig",
          "Cancel": "Kündigen",
          "Back": "Zurück",
          "Invalid room": "Raum kann nicht leer sein"
        }
      };

  String get i18n => localize(this, _t);
  String fill(List<Object> params) => localizeFill(this, params);
  String plural(int value) => localizePlural(value, this, _t);
  String version(Object modifier) => localizeVersion(modifier, this, _t);
}
