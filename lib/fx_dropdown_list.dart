@HtmlImport('fx_dropdown_list.html')
library flex_components.lib.fx_dropdown_list;

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'dart:async';
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:reflectable/reflectable.dart';
import 'package:polymer_flex_components/fx_base.dart';
import 'package:polymer_flex_components/fx_list.dart';
import "package:observe/observe.dart";
import "package:polymer_autonotify/polymer_autonotify.dart" show AutonotifyBehavior;

/**
 * A Polymer fx-dropdown-list element.
 */
@PolymerRegister('fx-dropdown-list')
class FxDropdownList extends FxBase with AutonotifyBehavior,Observable {

  @observable @Property(observer:'dataProviderChanged', notify:true) List dataProvider;
  @observable @property String labelField;
  @observable @property String prompt = "";
  @observable @property int listHeight = 150;

  @observable @property bool deployed = false;

  @observable @Property(observer:'selectedItemChanged', notify:true) dynamic selectedItem;
  @observable @Property(observer:'selectedIndexChanged', notify:true) int selectedIndex = -1;
  bool _selectedItemDirty = false;

  @observable @property String itemRenderer = null;

  @observable @property bool focused;
  @observable @property int focusedIndex;

  StreamSubscription keyboardStreamSubs;

  @Property(computed: 'isUnselected(selectedItem, selectedIndex)')
  bool unselected;

  @Property(computed: 'isSelected(selectedItem, selectedIndex)')
  bool selected;

  @Property(computed: 'isNull(itemRenderer)')
  bool isNullItemRenderer;

  @Property(computed: 'isNotNull(itemRenderer)')
  bool isNotNullItemRenderer;

  /// Constructor used to create instance of FxDropdownList.
  FxDropdownList.created() : super.created();

  factory FxDropdownList () => new Element.tag('fx-dropdown-list');

  @override
  void ready  () {
    set("selectedIndex", selectedIndex);
    set("selectedItem", selectedItem);
    set("itemRenderer", itemRenderer);
    set("focused", false);
    set("focusedIndex", null);
  }

  @reflectable
  bool isUnselected (dynamic selectedItem, int selectedIndex) {
    bool out = selectedItem == null || selectedIndex == -1;
    print ("unselected: $out");
    return out;
  }

  @reflectable
  bool isSelected (dynamic selectedItem, int selectedIndex) {
    bool out = selectedItem != null && selectedIndex != -1;
    print ("selected: $out");
    return out;
  }

  @reflectable
  bool isNull (dynamic value) => value == null;

  @reflectable
  bool isNotNull (dynamic value) => value != null;

  @reflectable
  String focusedClass (bool focused) => (focused ? "focused" : "");

  @reflectable
  void dataProviderChanged (List newValue, List oldValue) {
    /*selectedItem = null;*/
    _selectedItemDirty = true;
    invalidateProperties();
  }

  @reflectable
  void selectedIndexChanged (int newValue, int oldValue) {
    if (dataProvider != null && selectedIndex >= 0)
      selectedItem = dataProvider[selectedIndex];
  }

  @reflectable
  void selectedItemChanged (dynamic newValue, dynamic oldValue) {
    _selectedItemDirty = true;
    invalidateProperties();
  }

  @reflectable
  void toggleDeployed (Event e, [_]) {
    e.stopImmediatePropagation();
    (this.querySelector("#placeholder") as ButtonElement).focus();
    // Click also sets focus:

    this.deployed = !deployed;
    //print ("toggleDeployed. Deployed: $deployed");
    invalidateProperties();
  }

  @reflectable
  void focusHandler (Event e, [_]) {
    print("Dropdown focusHandler");
    focused = true;
    keyboardStreamSubs = window.onKeyDown.listen(keyDownHandler);
  }

  /** Arrow key down: 40
   *  Arrow key up: 38
   *  Intro: 13
   */
  @reflectable
  void keyDownHandler (KeyboardEvent event, [_]) {
    switch (event.keyCode) {
      case 40:
        if (!deployed) {
          deployed = true;
          FxList lst = this.querySelector("#fxlst");
          lst.focusEnabled = true;
          lst.focus();

          invalidateProperties();
        }
        break;
      case 27:
        deployed = false;
        invalidateProperties();
        FxList lst = this.querySelector("#fxlst");
        lst.focusEnabled = false;
        break;
    }
  }

  @reflectable
  void blurHandler (Event e, [_]) {
    focused = false;
    /*
     * TODO: This has stopped working. The list shuts down if the user scrolls down with mouse click
     *
     * if (deployed && !browser.isIe) {
      deployed = false;
      invalidateProperties();
    }*/
    keyboardStreamSubs.cancel();
  }

  @reflectable
  void onSelectionChangeHandler (CustomEvent e, [_]) {
    e.stopPropagation();
    selectedItem = e.detail;

    /*_selectedItemDirty = true;
    invalidateProperties(); TODO: ESTO NO DEBERíA SER NECESARIO */
    fire("selection-change", detail: e.detail);
  }

  @override
  void detached() {
    super.detached();
    window.removeEventListener("click", windowClickHandler);
  }

  @override
  void commitProperties () {
    //print ("CommitProperties Dropdown");
    super.commitProperties();
    Element listDiv = $['fxlst'] as Element;
    if (_selectedItemDirty) {
      List<Element> lst = this.querySelectorAll(".item-holder");
      if (selectedItem == null) {
        selectedIndex = -1;
      }
      else {
        bool found = false;
        for (int i = 0; i < dataProvider.length; i++) {
          dynamic item = dataProvider[i];
          if (item == selectedItem) {
            found = true;
            selectedIndex = i;
          }
        }
        if (!found) {
          selectedIndex = -1;
        }
      }
      _selectedItemDirty = false;
    }
    if (deployed) {
      //print ("Deployed!");
      listDiv.classes.add('deployed');
      listDiv.scrollTop = 0;
      try { window.addEventListener("click", windowClickHandler); } catch (e) {}
    }
    else {
      //print ("Undeployed!");
      listDiv.classes.remove('deployed');
      try { window.removeEventListener("click", windowClickHandler); } catch (e) {}
    }
  }

  @reflectable
  void windowClickHandler (Event e, [_]) {
    if (this.deployed) {
      //print ("windowClickHandler. Deployed: $deployed");
      this.deployed = false;
      invalidateProperties();
    }
  }

  @reflectable
  String render (dynamic value) {
    String rendered = "";
    if (value is String) {
      rendered = renderString (value);
    }
    if (value is Map) {
      rendered = renderMap (value);
      if (labelField != null)
        rendered = value[labelField];
    }
    else { // Object
      rendered = renderObject (value);
    }
    return rendered;
  }

  String renderString (String value) {
    return value;
  }

  String renderMap (Map value) {
    if (labelField != null) {
      return value[labelField];
    }
    else {
      return "$value";
    }
  }

  String renderObject (Object value) {
    String salida = "$value";
    if (labelField != null && value != null) {
      InstanceMirror im = jsProxyReflectable.reflect(value);
      salida = im.invokeGetter(labelField);
    }
    return salida;
  }

}
