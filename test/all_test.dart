// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
@HtmlImport('button_test.html')
@HtmlImport('list_test.html')
@TestOn('browser')
library polymer_flex_components.test.test;

import 'dart:async';
import 'package:polymer_interop/polymer_interop.dart';
import 'package:polymer_flex_components/fx_button.dart';
import 'package:polymer_flex_components/fx_list.dart';
import 'event/mouse_event.dart';
import 'package:polymer/polymer.dart';
import 'package:web_components/web_components.dart';
import 'package:test/test.dart';
import 'package:polymer_elements/iron_test_helpers.dart' as test_helpers;
import 'dart:html';
import 'dart:js';
import "package:observe/observe.dart";
import "package:polymer_autonotify/polymer_autonotify.dart" show AutonotifyBehavior;

final JsObject _MockInteractionsJs = context['MockInteractions'];

main() async {
  await initPolymer();

  group('FxButton', () {
    ButtonTest buttonTest = querySelector("button-test");
    FxButton button = buttonTest.querySelector("fx-button");

    test('Basic button with binded label', () {
      expect (button.label, equals("This is a button"));
      expect (button.querySelector("#btnContent").text.replaceAll(new RegExp(r'\n'), "").trim(), "This is a button");
    });

    test ('Change label via binding', () async {
      buttonTest.btnLabel = "Another label";
      await new Future.value(); // Los observables se propagan de forma asíncrona, por eso esta pequeña espera
      expect (button.querySelector("#btnContent").text.replaceAll(new RegExp(r'\n'), "").trim(), "Another label");
    });

  });

  group('FxList', () {
    ListTest listTest = querySelector("list-test");
    FxList list = listTest.querySelector("#single-selection");
    FxList listMultiple = listTest.querySelector("#multiple-selection");

    test ('Basic list with binded dataprovider', () {
      expect(list.dataProvider.length, equals(3));
    });
    test ('Select second item by click', () async {
      List<Element> itemHolders = list.querySelectorAll(".item-holder");
      MockMouseEvent mouseEvent = new MockMouseEvent("click", itemHolders[1]);
      list.clickItem(mouseEvent, []);
      await new Future.delayed(new Duration(milliseconds:100));
      expect(list.querySelectorAll(".selected").length, equals(1));
      expect(list.selectedIndex, equals(1));
      expect(list.selectedItem.name, equals("Mike"));
    });
    test ('Selection by click should fire selection-schange event', () async {
      bool changed = false;
      list.onSelectionChange.listen((_) {
        changed = true;
      });
      List<Element> itemHolders = list.querySelectorAll(".item-holder");
      MockMouseEvent mouseEvent = new MockMouseEvent("click", itemHolders[0]);
      list.clickItem(mouseEvent, []);
      await new Future.value();
      expect(list.selectedIndex, equals(0));
      expect(changed, equals(true));
    });
    test ('Click on selectedItem should not fire selection-change event', () async {
      bool changed = false;
      list.onSelectionChange.listen((_) {
        changed = true;
      });
      List<Element> itemHolders = list.querySelectorAll(".item-holder");
      MockMouseEvent mouseEvent = new MockMouseEvent("click", itemHolders[0]);
      list.clickItem(mouseEvent, []);
      await new Future.delayed(new Duration(milliseconds:100));
      expect(list.selectedIndex, equals(0));
      expect(changed, equals(false));
    });

    test ('Change selectedIndex (one-way binded) should change selection', () async {
      listTest.selectedIndex = 2;
      await new Future.delayed(new Duration(milliseconds:100));
      expect (list.selectedItem.name, equals("Peter"));
      List<Element> itemHolders = list.querySelectorAll(".item-holder");
      expect(itemHolders[2].classes.contains("selected"), equals(true));
    });

    test ('Change selectedIndex should not fire selection-change event', () async {
      bool fired = false;
      list.onSelectionChange.listen((_) {
        fired = true;
      });
      listTest.selectedIndex = 1;
      await new Future.delayed(new Duration(milliseconds:100));
      expect (fired, equals(false));
    });

    test ('Multiple selection list should allow multiple item selection via mouse click', () async {
      List<Element> itemHolders = listMultiple.querySelectorAll(".item-holder");
      MockMouseEvent mouseEvent1 = new MockMouseEvent("click", itemHolders[1]);
      listMultiple.clickItem(mouseEvent1, []);
      MockMouseEvent mouseEvent2 = new MockMouseEvent("click", itemHolders[2]);
      listMultiple.clickItem(mouseEvent2, []);
      await new Future.delayed(new Duration(milliseconds:100));
      expect (listMultiple.selectedItems.length, equals(2));
      expect (listMultiple.selectedItems[0].name, equals("Mike"));
      expect (listMultiple.selectedItems[1].name, equals("Peter"));
      expect (listMultiple.querySelectorAll(".selected").length, equals(2));
    });

    test ('Multiple selection list: click on selected item deselects', () async {
      List<Element> itemHolders = listMultiple.querySelectorAll(".item-holder");
      MockMouseEvent mouseEvent = new MockMouseEvent("click", itemHolders[1]);
      listMultiple.clickItem(mouseEvent, []);
      await new Future.delayed(new Duration(milliseconds:100));
      expect (listMultiple.selectedItems.length, equals(1));
      expect (listMultiple.selectedItems[0].name, equals("Peter"));
      expect (listMultiple.querySelectorAll(".selected").length, equals(1));
    });

  });
}

@PolymerRegister('button-test')
class ButtonTest extends PolymerElement with AutonotifyBehavior,Observable {
  /// Constructor used to create instance of TestModel.
  ButtonTest.created() : super.created();
  factory ButtonTest () => new Element.tag ("button-test");

  @observable @property String btnLabel = "This is a button";
}



@PolymerRegister('list-test')
class ListTest extends PolymerElement with AutonotifyBehavior,Observable {

  @observable @property int selectedIndex = -1;

  ListTest.created() : super.created();
  factory ListTest () => new Element.tag ("list-test");

  @observable @property List<Person> people = [
    new Person ("John", "Smith"),
    new Person ("Mike", "Martin"),
    new Person ("Peter", "Peterson")
  ];

}

@jsProxyReflectable
class Person extends Observable {
  @observable @reflectable String name;
  @observable @reflectable String lastName;
  Person (this.name, this.lastName);
}