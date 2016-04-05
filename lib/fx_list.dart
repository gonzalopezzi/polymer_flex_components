@HtmlImport('fx_list.html')
library flex_components.lib.fx_list;

import 'package:polymer/polymer.dart';
import 'package:polymer_flex_components/fx_base.dart';
import 'dart:html';
import 'dart:async';
import 'package:web_components/web_components.dart' show HtmlImport;
import 'package:reflectable/reflectable.dart';
import "package:observe/observe.dart";
import "package:polymer_autonotify/polymer_autonotify.dart" show AutonotifyBehavior;

import 'package:animation/animation.dart' as anim;

@PolymerRegister('fx-list')
class FxList extends FxBase with AutonotifyBehavior,Observable {

  @observable @Property (observer:'dataProviderChanged') List dataProvider;
  @observable @property List<WrappedItem> wrappedDataProvider = new ObservableList();
  @property String labelField;
  @property String prompt = "";
  @observable @property bool allowMultipleSelection = false;

  @observable @property bool focusEnabled = true;

  @observable @Property (observer:'selectedItemChanged', notify:true) dynamic selectedItem;
  @observable @Property (observer:'selectedItemsChanged', notify:true) List selectedItems = new ObservableList();
  @observable @Property (observer:'selectedIndexChanged', notify:true) int selectedIndex = -1;
  @observable @property List<int> selectedIndices = [];
  bool _selectedItemDirty = false;

  bool _selectedIndexAndIndicesInSync = true;

  @property String itemRenderer;

  @observable @Property(observer:'focusedChanged') bool focused = false;
  @observable @Property(observer:'focusedIndexChanged') int focusedIndex = -1;

  @observable @Property(observer:'listHeightChanged') int listHeight = 250;

  bool _flgDataProviderDirty = false;

  StreamSubscription keyboardStreamSubs;
  static const EventStreamProvider<CustomEvent> selectionChangeEvent = const EventStreamProvider<CustomEvent>("selection-change");
  Stream<CustomEvent> get onSelectionChange =>  FxList.selectionChangeEvent.forTarget(this);

  DivElement lstDiv;
  int scrollPosition;

  /// Constructor used to create instance of FxDropdownList.
  FxList.created() : super.created() {
  }
  factory FxList () => new Element.tag('fx-list');

  @override
  void ready () {
    set ("focusEnabled", focusEnabled);
    set ("focused", focused);
    set ("listHeight", listHeight);
    set ("selectedItem", selectedItem);
    set ("selectedIndex", selectedIndex);
    set ("selectedIndices", selectedIndices);
  }

  @reflectable
  String selectedClass (bool sel, int index, int focusedIndex) => "item-holder " + (sel ? " selected " : "") + (index == focusedIndex ? " focused" : "");

  @reflectable
  String focusedClass (bool focused) =>  focused ? "focused" : "";

  @reflectable
  bool itemRendererIsNull () => itemRenderer == null;

  @reflectable
  void focusedIndexChanged (int newValue, int oldValue) {
    notifyPath("focusedIndex", newValue);
  }

  @override
  void attached () {
    queryLstDiv();
    lstDiv.onScroll.listen((Event event) {
      scrollPosition = lstDiv.scrollTop;
    });
    _setLstHeight();
  }

  void queryLstDiv () {
    lstDiv = $['lst'] as DivElement;
  }

  @reflectable
  void listHeightChanged (int newValue, int oldValue) {
    _setLstHeight();
  }

  void _setLstHeight() {
    if (lstDiv != null) {
      lstDiv.style.height = "${listHeight}px";
    }
  }

  @override
  void focus () {
    this.querySelector(".focus-manager").focus();
    set("focusEnabled", focusEnabled);
    focused = true;
    set("focused", focused);
  }

  @reflectable
  void focusedChanged (bool newValue, bool oldValue) {
    print ("list focusedChanged");
    if (focusEnabled) {
      if (focused) {
        keyboardStreamSubs = window.onKeyDown.listen(keyDownHandler);
      }
      else {
        if (keyboardStreamSubs != null)
          keyboardStreamSubs.cancel();
      }
    }
    invalidateProperties();
  }

  void _wrapDataProvider () {
    List<WrappedItem> wrapped = new List<WrappedItem> ();
    for (int i = 0; i < dataProvider.length; i++) {
      dynamic item = dataProvider[i];
      wrapped.add(new WrappedItem (item)..selected = false
        ..index = i);
    }
    _setSelectionsInWrappedDataProvider(wrapped);
    wrappedDataProvider.clear();
    wrappedDataProvider.addAll(wrapped);
  }


  void _updateSelectedInDataProvider() {
    for (int i = 0; i < wrappedDataProvider.length; i++) {
      /*set("wrappedDataProvider.${i}.selected", false);*/
      (wrappedDataProvider[i] as WrappedItem).selected = false;
    }
    /*wrappedDataProvider.forEach((WrappedItem item) {
      item.selected = false;
    });*/
    _setSelectionsInWrappedDataProvider (wrappedDataProvider);
  }

  void _setSelectionsInWrappedDataProvider (List<WrappedItem> wrapped) {
    _syncSelectedIndexAndIndices();
    if (allowMultipleSelection) {
      selectedIndices.forEach((int i) {
        wrapped[i].selected = true;
      });
    }
    else {
      if (selectedIndex >= 0) {
        /*set("wrappedDataProvider.${selectedIndex}.selected", true);*/
        (wrapped[selectedIndex] as WrappedItem).selected = true;
      }
    }
  }

  @reflectable
  void dataProviderChanged (List newValue, List oldValue) {
    _flgDataProviderDirty = true;
    _selectedIndexAndIndicesInSync = false;
    invalidateProperties();
  }

  @reflectable
  void selectedIndexChanged (int newValue, int oldValue) {
    if (dataProvider != null && newValue >= 0)
      /*set ("selectedItem", dataProvider[selectedIndex]);*/
      selectedItem = dataProvider[selectedIndex];
  }

  @reflectable
  void selectedItemChanged (dynamic newValue, dynamic oldValue) {
    _selectedItemDirty = true;
    _selectedIndexAndIndicesInSync = false;
    invalidateProperties();
  }

  @reflectable
  void selectedItemsChanged (List newValue, List oldValue) {
    (newValue as ObservableList).changes.listen ((_) {
      _selectedItemDirty = true;
      _selectedIndexAndIndicesInSync = false;
      invalidateProperties();
    });
    _selectedItemDirty = true;
    _selectedIndexAndIndicesInSync = false;
    invalidateProperties();
  }

  @reflectable
  void focusHandler (Event e, [_]) {
    focused = true;
    keyboardStreamSubs = window.onKeyDown.listen(keyDownHandler);
  }

  /** Flecha Abajo: 40
   *  Flecha arriba: 38
   *  Intro: 13
   */
  void keyDownHandler (KeyboardEvent event) {
    switch (event.keyCode) {
      case 40:
        event.preventDefault();
        event.stopImmediatePropagation();
        _incrementFocusedIndex();
        break;
      case 38:
        event.preventDefault();
        event.stopImmediatePropagation();
        _decrementFocusedIndex();
        break;
      case 13:
        selectedIndex = focusedIndex;
        selectedItem = dataProvider[selectedIndex];
        fire("selection-change", detail: selectedItem);
        focusedIndex = -1;
        break;
      case 27:
        invalidateProperties();
        break;
    }
  }

  void _incrementFocusedIndex () {
    if (dataProvider != null) {
      if (focusedIndex == null) {
        focusedIndex = 0;
        _updateListScrollToFocusedItem();
      }
      else if (focusedIndex < dataProvider.length -1) {
        focusedIndex ++;
        _updateListScrollToFocusedItem();
      }
    }
  }

  void _decrementFocusedIndex () {
    if (dataProvider != null) {
      if (focusedIndex > 0) {
        focusedIndex--;
        _updateListScrollToFocusedItem();
      }
    }
  }

  void _updateListScrollToFocusedItem () {
    Element lst = $["lst"];
    Element item = lst.querySelectorAll(".item-holder")[focusedIndex];
    if (item.offsetTop < lst.scrollTop) {
      anim.animate(lst, duration:200, easing:anim.Easing.QUADRATIC_EASY_IN_OUT,
      properties:{'scrollTop': item.offsetTop});
    }
    if ((item.offsetTop + item.clientHeight - lst.scrollTop) > lst.clientHeight) {
      anim.animate(lst, duration:200, easing:anim.Easing.QUADRATIC_EASY_IN_OUT,
      properties:{'scrollTop': item.offsetTop - (lst.clientHeight - item.clientHeight)});
    }
  }

  void _updateListScrollToFocusedItemUp () {
    Element lst = $["lst"];
    Element item = this.shadowRoot.querySelectorAll(".item-holder")[focusedIndex];
    if (item.offsetTop < lst.scrollTop) {
      anim.animate(lst, duration:200, easing:anim.Easing.QUADRATIC_EASY_IN_OUT,
      properties:{'scrollTop': item.offsetTop});
    }
  }

  @reflectable
  void blurHandler (Event e, [_]) {
    focused = false;
    focusedIndex = -1;
    keyboardStreamSubs.cancel();
  }

  @reflectable
  void clickItem (Event e, [_]) {
    // Click sets focus:
    (this.querySelector(".focus-manager") as ButtonElement).focus();

    int index = int.parse((e.target as Element).dataset['index']);
    if (allowMultipleSelection) {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
        selectedItems.remove(dataProvider[index]);
      }
      else {
        selectedIndices.add(index);
        if(selectedItems == null){
          selectedItems = new ObservableList();
        }
        selectedItems.add(dataProvider[index]);
      }
      fire("selection-change", detail: selectedItems);
    }
    else {
      if (selectedIndex != index) {
        selectedIndex = index;
        selectedItem = dataProvider[index];
        fire("selection-change", detail: selectedItem);
      }
    }
  }

  bool isIndexSelected (int index, List<int> selectedIndices) {
    return selectedIndices.contains(index);
  }

  void _syncSelectedIndexAndIndices () {
    if (!_selectedIndexAndIndicesInSync) {
      if (allowMultipleSelection) {
        selectedIndices.clear();
      }
      else {
        /*set ("selectedIndex", -1);*/
        selectedIndex = -1;
      }
      for (int i = 0; i < dataProvider.length; i++) {
        dynamic item = dataProvider[i];
        if (allowMultipleSelection) {
          if (selectedItems != null && selectedItems.contains(item)) {
            selectedIndices.add(i);
          }
        }
        else {
          if (item == selectedItem) {
            /*set ("selectedIndex", i);*/
            selectedIndex = i;
          }
        }
      }
      _selectedIndexAndIndicesInSync = true;
    }
  }

  @override
  void commitProperties () {
    super.commitProperties();
    if (_flgDataProviderDirty) {
      _wrapDataProvider();
      _flgDataProviderDirty = false;
    }
    if (_selectedItemDirty) {
      _syncSelectedIndexAndIndices();
      _updateSelectedInDataProvider();
      _selectedItemDirty = false;
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
    if (labelField != null) {
      InstanceMirror im = jsProxyReflectable.reflect(value);
      salida = im.invokeGetter(labelField);
    }
    return salida;
  }
}

@jsProxyReflectable
class WrappedItem extends Observable {
  @observable @reflectable dynamic listItem;
  @observable @reflectable int index;
  @observable @reflectable bool selected;
  WrappedItem (this.listItem);
}

