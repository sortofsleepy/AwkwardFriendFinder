part of Flint;

/**
* A wrapper for the TweenMax library
* Make sure TweenMax js library is included
* on the page.
*/
class TweenMax {
  static JsObject tweenmax = context["TweenMax"];

  TweenMax();

/**
  * Equivalant to TweenMax.to;
*/
  static void to(Element el, double time,var props,[Function f]){
    var properties = {};
    properties = new JsObject.jsify(props);
    tweenmax.callMethod("to",[el,time,properties]);
    if(f != null){
      f();
    }
  }

  static void toGroup(List el, double time,var props,[Function f]){
    var properties = {};
    properties = new JsObject.jsify(props);
    tweenmax.callMethod("to",[el,time,properties]);
    if(f != null){
      f();
    }
  }
}

