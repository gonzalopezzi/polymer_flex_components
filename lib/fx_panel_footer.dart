@HtmlImport('fx_panel_footer.html')
library flex_components.lib.fx_panel_footer;

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart' show HtmlImport;
import 'dart:html';

/**
 * A Polymer fx-panel-footer element.
 */
@PolymerRegister('fx-panel-footer')
class FxPanelFooter extends PolymerElement {

  FxPanelFooter.created() : super.created();
  factory FxPanelFooter () => new Element.tag("fx-panel-footer");

}
