library polymer_flex_components.events.mouse_event;

import 'dart:html';
import 'dart:js' as js;

class MockMouseEvent implements Event {

  MockMouseEvent(this._type, this._target);

  Element _target;
  @override
  Element get target => _target;
  void set target (Element t) {
    _target = t;
  }

  String _type;
  @override
  String get type => _type;
  void set type (String t) {
    _type = t;
  }

  js.JsObject blink_jsObject;

  String _selector;
  Element get matchingTarget {
  }

  static Event internalCreateEvent() {
  }

  bool operator ==(other) => false;
  int get hashCode => 0;

  static const int AT_TARGET = 2;
  static const int BUBBLING_PHASE = 3;
  static const int CAPTURING_PHASE = 1;
  bool get bubbles => false;
  bool get cancelable => false;
  DataTransfer get clipboardData => null;
  EventTarget get currentTarget => null;
  bool get defaultPrevented => false;
  int get eventPhase => 0;
  List<Node> get path => null;
  int get timeStamp => 0;
  void _initEvent(String eventTypeArg, bool canBubbleArg, bool cancelableArg) {}
  void preventDefault() {}
  void stopImmediatePropagation() {}
  void stopPropagation() {}
}