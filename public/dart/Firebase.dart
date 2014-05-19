import "dart:js";

/**
* A wrapper for the Firebase Client library
* Make sure Firebase js library is included
* on the page.
*/
class Firebase {
  static JsObject firebase = context["Firebase"];

  Firebase();

  static void log(String user, String content){
    firebase.callMethod("log",[user,content]);
  }
}

