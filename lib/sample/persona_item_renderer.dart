@HtmlImport('persona_item_renderer.html')
library flex_components.lib.sample.persona_item_renderer;

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'package:polymer_flex_components/flex_components.dart';
import 'package:web_components/web_components.dart' show HtmlImport;
import "package:observe/observe.dart";
import "package:polymer_autonotify/polymer_autonotify.dart" show AutonotifyBehavior;

@PolymerRegister('persona-item-renderer')
class PersonaItemRenderer extends PolymerElement with AutonotifyBehavior,Observable implements DataRenderer {

  @property @observable dynamic data;

  /// Constructor used to create instance of PersonaItemRenderer.
  PersonaItemRenderer.created() : super.created();

  factory PersonaItemRenderer () => new Element.tag('persona-item-renderer');

}
