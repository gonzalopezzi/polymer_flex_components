@HtmlImport('fx_borrar.html')
library flex_components.lib.fx_borrar;

import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart' show HtmlImport;
import 'dart:html';

/**
 * A Polymer fx-borrar element.
 */
@PolymerRegister('fx-borrar')
class FxBorrar extends PolymerElement {
  FxBorrar.created() : super.created();
  factory FxBorrar () => new Element.tag("fx-borrar");
}
