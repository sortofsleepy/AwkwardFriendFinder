part of Flint;

/**
 * This defines a Template on which to render components to make up a page
 */


class Template {
  String template = "";
  String name = "";

  //for if we're using a Template engine
  JsObject engine;

  //element we've appended template to
  Element appendedTo;

  Template([String template_name="",String page_name="page",bool _engine=false]) {
    if(template_name != ""){
      loadTemplate(template_name);
    }

    if(page_name != ""){
      name = page_name;
    }

    if(_engine){
      engine = context["Hogan"];
    }
  }

/**
  * Fetches a template from the server to load.
*/
  void loadTemplate(String templatename){
    HttpRequest req = new HttpRequest();
    req.open("GET",templateRoot + templatename,async:false);

    req.onLoadEnd.listen((event){
      template = event.target.responseText;
    });

    req.send();

  }

/**
  * Appends the template to a DOM element
*/
  void appendTo(Element domElement,[Function callback]){
    appendedTo = domElement;


    //if we have a Template engine setup to drive the thing
    if(engine != null){
      JsObject raw_template = engine.callMethod("compile",['${template}']);
      //if we passed in a callback
      if(callback != null){
        callback(engine,raw_template,appendedTo);
      }
    }else{
      //just set the template.
      appendedTo.appendHtml(template);
    }

  }

}
