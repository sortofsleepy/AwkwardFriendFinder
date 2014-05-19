library Flint;

import "dart:html";
import "dart:async";
import "dart:svg";
import "dart:web_audio";
import "dart:js";
import "dart:convert";
part "Dom.dart";
part "Media/Audio.dart";
part "Data/Request.dart";


part "Templates/Template.dart";
part "TweenMax.dart";

String rootElement = "SITE";
String templateRoot = "./";

/**
* The main class.
*/
class Flint extends Object with Dom,Audio,Request{
  //the element we act upon
  Element domElement;

  // constructor if desired, might be easiest to just
  // use the select() function.
  Flint([String selector=""]){
    if(selector != ""){
      domElement = Element.querySelector(selector);
    }
  }

  void _setElement(Element newElement){
    domElement = newElement;
  }

/**
  * Jquery like selector;
*/
  static Flint select([String selector=""]){
    if(selector != ""){
      Element domElement = querySelector(selector);
      return new Flint()._setElement(domElement);
    }
  }


}//end class


/**
* In Dart, certain aspects of HTML5 are automatically
* sanatized, like data-attributes
*
* This creates a validator object to be used in case you need to allow some attributes.
*/
DocumentFragment whitelist(String element,String html,List _attributes){
//rule list for what HTML attributes are allowed
  NodeValidatorBuilder safeAttributes = new NodeValidatorBuilder.common();
  safeAttributes.allowElement(element,attributes:_attributes);


  //need to construct a empty div to sanatize stuff.
  DivElement box = new DivElement();

  //create the safe fragment w/ validator rules
  DocumentFragment safe = box.createFragment(html,validator:safeAttributes);


  return safe;
}

Element sanatizeElement(String element,String html,List _attributes){
//rule list for what HTML attributes are allowed
  NodeValidatorBuilder safeAttributes = new NodeValidatorBuilder.common();
  safeAttributes.allowElement(element,attributes:_attributes);

//  var e = new Element.html("<h1></h1>");
  //create the safe fragment w/ validator rules
  return new Element.html(html,validator:safeAttributes);


}