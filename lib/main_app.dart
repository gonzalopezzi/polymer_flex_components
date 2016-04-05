// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
@HtmlImport('main_app.html')
library polymer_flex_components.lib.main_app;


import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_flex_components/fx_button.dart';
import 'package:polymer_flex_components/fx_borrar.dart';
import 'package:polymer_flex_components/fx_list.dart';
import 'package:polymer_flex_components/fx_dropdown_list.dart';
import 'package:polymer_flex_components/fx_date_chooser.dart';
import 'package:polymer_flex_components/fx_date_field.dart';
import 'package:polymer_flex_components/fx_panel.dart';
import 'package:polymer_flex_components/fx_panel_title.dart';
import 'package:polymer_flex_components/fx_panel_content.dart';
import 'package:polymer_flex_components/fx_panel_footer.dart';
import 'package:polymer_flex_components/fx_slider.dart';
import 'package:polymer_flex_components/fx_item_renderer.dart';
import 'package:polymer_flex_components/sample/persona_item_renderer.dart';
import "package:observe/observe.dart";
import "package:polymer_autonotify/polymer_autonotify.dart" show AutonotifyBehavior;


@PolymerRegister('main-app')
class MainApp extends PolymerElement with AutonotifyBehavior,Observable{

  @observable @property List<num> sliderValue = [300,500];
  @property DateTime selectedDate = new DateTime.now();
  @observable @property DateTime minDate = new DateTime(2015, 12, 15);
  @observable @property DateTime maxDate = new DateTime(2016, 3, 15);
  @Property(observer:'selectedIndexChanged') int selectedIndex = -1;
  @observable @property dynamic selectedItem;

  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created();

  @Property(observer:'listDataProviderChanged')
  List<Persona> listDataProvider = [new Persona ("Pepe", "Pérez"),
                                   new Persona ("Juan", "Juárez"),
                                   new Persona ("Martín", "Martínez"),
                                   new Persona ("Jaime", "Pérez"),
                                   new Persona ("Miguel", "Rodríguez"),
                                   new Persona ("Pablo", "Pérez"),
                                   new Persona ("Eduardo", "Márquez")];

  @override
  void ready () {
    set ("selectedDate", selectedDate);
  }

  @reflectable
  void buttonClicked (event, [_]) {
    FxButton button = querySelector("#btn2");
    assert(button.label=="Click Me Too!");
    listDataProvider[1].nombre = "Juanito";
  }

  @reflectable
  void selectedIndexChanged (int newValue, int oldValue) {
    notifyPath("selectedIndex", selectedIndex);
  }

  @reflectable
  void listDataProviderChanged (List<String> newDP, List<String> oldDP) {
    print ("Data Provider Changed");
  }

  // Optional lifecycle methods - uncomment if needed.

//  /// Called when an instance of main-app is inserted into the DOM.
//  attached() {
//    super.attached();
//  }

//  /// Called when an instance of main-app is removed from the DOM.
//  detached() {
//    super.detached();
//  }

//  /// Called when an attribute (such as a class) of an instance of
//  /// main-app is added, changed, or removed.
//  attributeChanged(String name, String oldValue, String newValue) {
//    super.attributeChanged(name, oldValue, newValue);
//  }

//  /// Called when main-app has been fully prepared (Shadow DOM created,
//  /// property observers set up, event listeners attached).
//  ready() {
//  }
}

@jsProxyReflectable
class Persona extends Observable {
  @observable @reflectable String nombre;
  @observable @reflectable String apellidos;
  Persona (this.nombre, this.apellidos);

  String toString () => "$nombre $apellidos";
}
