@HtmlImport('fx_panel.html')
library flex_components.lib.fx_panel;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart' show HtmlImport;

/**
 * A Polymer fx-panel element.
 */
@PolymerRegister('fx-panel')
class FxPanel extends PolymerElement {

  FxPanel.created() : super.created();

  factory FxPanel () => new Element.tag("fx-panel");

}
