@HtmlImport('fx_date_field.html')
library flex_components.lib.fx_date_field;
import 'package:polymer/polymer.dart';
import 'package:reflectable/reflectable.dart';
import 'package:polymer_flex_components/fx_base.dart';
import 'package:polymer_flex_components/fx_date_chooser.dart';
import "package:observe/observe.dart";
import "package:polymer_autonotify/polymer_autonotify.dart" show AutonotifyBehavior;
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:html';

/**
 * A Polymer fx-date-field element.
 */
@PolymerRegister('fx-date-field')
class FxDateField extends FxBase with AutonotifyBehavior,Observable {

  @observable @Property (observer: 'dateChooserVisibleChanged') bool dateChooserVisible = false;

  FxDateChooser _dateChooser;

  @observable @Property (observer: 'selectedDateChanged', notify:true) DateTime selectedDate;
  @observable @property String formatString = "yyyy-MM-dd";

  FxDateField.created() : super.created() {
  }
  factory FxDateField() => new Element.tag('fx-date-field');

  void attached () {
    _dateChooser = ($['date-field-date-chooser'] as FxDateChooser);
  }

  @reflectable
  void selectedDateChanged (DateTime newValue, DateTime oldValue) {
    dateChooserVisible = false;
  }

  @reflectable
  void dateChooserVisibleChanged (bool newValue, bool oldValue) {
    invalidateProperties();
  }

  @reflectable
  void toggleDateChooser (event, [_]) {
    dateChooserVisible = !dateChooserVisible;
    invalidateProperties();
  }

  @reflectable
  String format (DateTime date) {
    var formatter = new DateFormat(formatString);
    return formatter.format(date);
  }

  @override
  void commitProperties () {
    super.commitProperties();
    if (dateChooserVisible) {
      _dateChooser.style.visibility = 'visible';
      _dateChooser.style.opacity = '1';
    }
    else {
      _dateChooser.style.opacity = '0';
      new Timer(new Duration(milliseconds:400), () {
        _dateChooser.style.visibility = 'hidden';
      });
    }
  }
}
