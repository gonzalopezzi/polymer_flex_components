@HtmlImport('fx_panel_title.html')
library flex_components.lib.fx_panel_title;

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart' show HtmlImport;

/**
 * A Polymer fx-panel-title element.
 */
@PolymerRegister('fx-panel-title')
class FxPanelTitle extends PolymerElement {

  /// Constructor used to create instance of FxPanelTitle.
  FxPanelTitle.created() : super.created();

  /*
   * Optional lifecycle methods - uncomment if needed.
   *

  /// Called when an instance of fx-panel-title is inserted into the DOM.
  attached() {
    super.attached();
  }

  /// Called when an instance of fx-panel-title is removed from the DOM.
  detached() {
    super.detached();
  }

  /// Called when an attribute (such as  a class) of an instance of
  /// fx-panel-title is added, changed, or removed.
  attributeChanged(String name, String oldValue, String newValue) {
  }

  /// Called when fx-panel-title has been fully prepared (Shadow DOM created,
  /// property observers set up, event listeners attached).
  ready() {
  }

  */

}
