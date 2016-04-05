@HtmlImport('fx_date_chooser.html')
library flex_components.lib.fx_date_chooser;

import 'package:polymer/polymer.dart';
import 'package:polymer_flex_components/fx_base.dart';
import 'package:web_components/web_components.dart' show HtmlImport;
import 'dart:html';
import 'package:reflectable/reflectable.dart';
import "package:observe/observe.dart";
import "package:polymer_autonotify/polymer_autonotify.dart" show AutonotifyBehavior;


/**
 * A Polymer fx-date-chooser element.
 */
@PolymerRegister('fx-date-chooser')
class FxDateChooser extends FxBase with AutonotifyBehavior,Observable {

  FxDateChooser.created() : super.created();
  factory FxDateChooser () => new Element.tag("fx-date-chooser");

  bool _weekDaysDirty = true;

  Function _changeCallback;  //TODO: Cambiar esto por un stream
  void set changeCallback (Function f) {
    this._changeCallback = f;
  }

  @observable @Property(observer:'selectedDateChanged', notify:true) DateTime selectedDate;
  DateTime truncatedSelectedDate;
  @observable @property bool isPrevMonthDisabled = true;
  @observable @property bool isNextMonthDisabled = true;
  @observable @Property(observer:'minDateChanged') DateTime minDate;
  @observable @Property(observer:'maxDateChanged') DateTime maxDate;

  @override
  void ready () {
  }

  @reflectable
  void maxDateChanged (DateTime newValue, DateTime oldValue) {
    print ("maxDateChanged: $newValue $maxDate");
    invalidateProperties();
    invalidateDisplay();
  }

  @reflectable
  void minDateChanged (DateTime newValue, DateTime oldValue) {
    print ("maxDateChanged $newValue $minDate");
    invalidateProperties();
    invalidateDisplay();
  }

  @reflectable
  void selectedDateChanged (DateTime newValue, DateTime oldValue) {
    bool change = newValue != oldValue;
    if (newValue != null) {
      truncatedSelectedDate = new DateTime(newValue.year, newValue.month, newValue.day, 0, 0, 0, 0);
      _displayedDate = newValue;
    }
    if (change) {
      if (_changeCallback != null) {
        _changeCallback({'selectedDate':newValue});
      }
      invalidateProperties();
      invalidateDisplay();
    }
  }

  DateTime _displayedDate = new DateTime.now();

  @observable @property int firstDayOfWeek = 0;

  List<String> weekDayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  List<String> monthNames = ["January", "February", "March", "April",
  "May", "June", "July", "August", "September",
  "October", "November", "December"];

  TableRowElement _trWeeks;
  TableSectionElement _tableBody;
  Map<ButtonElement, DateTime> buttonData = new Map<ButtonElement, DateTime> ();

  void attached () {
    _trWeeks = this.querySelector("#week-day-row") as TableRowElement;
    _tableBody = this.querySelector("#day-table-body") as TableSectionElement;
    invalidateProperties();
    invalidateDisplay();
  }

  @override
  void updateDisplay () {
    super.updateDisplay();
    displayWeekNames ();
    displayDays ();
    checkEnabled ();
  }

  @observable @property String monthLabel;

  void displayWeekNames () {
    if (_weekDaysDirty && _trWeeks != null) {
      _trWeeks.children.clear();
      SpanElement weekLabel;
      for (int i = firstDayOfWeek; i < 7 + firstDayOfWeek; i++) {
        TableCellElement cell = new TableCellElement();
        weekLabel = new SpanElement()
          ..className = "style-scope fx-date-chooser week-label"
          ..appendText(weekDayNames[(i % 7)]);
        cell.append (weekLabel);
        _trWeeks.append(cell);
      }
      _weekDaysDirty = false;
    }
  }

  void _initButtonData () {
    buttonData = new Map<ButtonElement, DateTime> ();
  }

  void displayDays () {
    int lastDayOfWeek = (firstDayOfWeek + 6) % 7; /* TODO: QUITAR ESTE HARDCODE. ESTO DEBE DEPENDER DE firstDayOfWeek */
    _initButtonData ();
    DateTime firstDate = new DateTime (_displayedDate.year, _displayedDate.month, 1, 0, 0);
    while (((firstDate.weekday - firstDayOfWeek) % 7) > (firstDayOfWeek - firstDayOfWeek % 7)) {
      firstDate = firstDate.subtract(new Duration(days:1));
    }
    DateTime lastDate = new DateTime (_displayedDate.year, _displayedDate.month + 1, 1, 0, 0);
    lastDate.subtract(new Duration (days:1));
    while ((lastDate.weekday % 7) != (lastDayOfWeek % 7)) {
      lastDate = lastDate.add(new Duration(days:1));
    }

    _tableBody.children = new List<Element> ();

    int dayCounter = 0;
    TableRowElement tr;
    for (DateTime currentDate = firstDate.add(new Duration(hours:12)) /*Soluciona bug calendario verano / invierno*/ ;
    currentDate.difference(lastDate).inDays <= 0;
    currentDate = currentDate.add(new Duration (days:1))) {
      if (dayCounter % 7 == 0) { // Must create a new row
        tr = new TableRowElement();
        _tableBody.append(tr);
      }
      tr.append(new TableCellElement()
        ..append(createButtonElement (currentDate))
      );
      dayCounter++;
    }
  }

  void checkEnabled () {
    isPrevMonthDisabled = _displayedDate != null && minDate != null ? new DateTime(_displayedDate.year, _displayedDate.month).isAtSameMomentAs(new DateTime(minDate.year, minDate.month)) : false;
    isNextMonthDisabled = _displayedDate != null && maxDate != null ? new DateTime(_displayedDate.year, _displayedDate.month).isAtSameMomentAs(new DateTime(maxDate.year, maxDate.month)) : false;
  }

  void dayButtonClick (MouseEvent event) {
    selectedDate = copyDateTime (buttonData[event.target]);
    invalidateDisplay();
  }

  DateTime copyDateTime (DateTime d) {
    return new DateTime (d.year, d.month, d.day);
  }

  ButtonElement createButtonElement (DateTime currentDate)  {
    DateTime curDate = copyDateTime(currentDate);
    ButtonElement button = new ButtonElement()
      ..appendText("${curDate.day}");
    if (curDate.month != _displayedDate.month) {
      button.className = "style-scope fx-date-chooser day-button other-month-day-button";
    }
    else {
      if (selectedDate != null && curDate.difference(truncatedSelectedDate).inHours == 0) {
        button.className = "style-scope fx-date-chooser day-button selected-day";
      }
      else {
        button.className = "style-scope fx-date-chooser day-button";
      }
    }

    buttonData[button] = curDate;
    button.onClick.listen(dayButtonClick);
    return button;
  }

  @reflectable
  void prevMonth(event, [_]) {
    _displayedDate = new DateTime (_displayedDate.year, _displayedDate.month-1, _displayedDate.day);
    invalidateProperties();
    invalidateDisplay();
  }

  @reflectable
  void nextMonth(event, [_]) {
    _displayedDate = new DateTime (_displayedDate.year, _displayedDate.month+1, _displayedDate.day);
    invalidateProperties();
    invalidateDisplay();
  }

  void refreshDisplayedDate(){
    if(!_displayedDate.isAtSameMomentAs(selectedDate)){
      _displayedDate = selectedDate;
      invalidateProperties();
      invalidateDisplay();
    }
  }

  @override
  void commitProperties () {
    monthLabel = "${monthNames[_displayedDate.month - 1]} - ${_displayedDate.year}";
  }
}
