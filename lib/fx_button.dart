@HtmlImport('fx_button.html')
library flex_components.lib.fx_button;

import 'package:polymer/polymer.dart';
import 'package:polymer_flex_components/fx_base.dart';
import 'dart:html';
import 'package:web_components/web_components.dart' show HtmlImport;

@PolymerRegister('fx-button')
class FxButton extends FxBase {


  @property String label;
  @Property(notify:true, observer: 'labelChanged', reflectToAttribute: true) String label2;
  @property bool pressed = false;
  @property String type = 'primary';
  @property bool disabled = false;
  @property bool toggle = false;
  
  /// Constructor used to create instance of FxButton.
  FxButton.created() : super.created();

  factory FxButton () => new Element.tag('fx-button');

  @reflectable
  mouseDownHandler (event, [_]) {
    if(toggle)
      set('pressed', !pressed);
    else
      set('pressed', true);
  }

  @reflectable
  mouseUpHandler (event, [_]) {
    if(!toggle)
      set('pressed', false);
  }

  @reflectable
  String pressedClass(bool p) {
    return (p == true) ? 'pressed' : '';
  }

  @reflectable
  String typeClass(String t, bool e) {
    return (e == false) ? t : 'disabled';
  }

  @reflectable
  typeChanged(String newValue, String oldValue) {
    Polymer.updateStyles();
  }
}
