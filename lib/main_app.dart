// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
@HtmlImport('main_app.html')
library polymer_flex_components.lib.main_app;


import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:polymer_flex_components/fx_button.dart';

/// Uses [FxButton]
@PolymerRegister('main-app')
class MainApp extends PolymerElement {
  /// Constructor used to create instance of MainApp.
  MainApp.created() : super.created();


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
