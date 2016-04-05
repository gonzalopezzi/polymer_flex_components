@HtmlImport('fx_panel_content.html')
library flex_components.lib.fx_panel_content;

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart' show HtmlImport;
import 'dart:html';

/**
 * A Polymer fx-panel-content element.
 */
@PolymerRegister('fx-panel-content')
class FxPanelContent extends PolymerElement {

  /// Constructor used to create instance of FxPanelContent.
  FxPanelContent.created() : super.created();
  factory FxPanelContent () => new Element.tag('fx-panel-content');

}
