import "Flint/Flint.dart";
import "dart:html";
import "dart:async";
import "dart:convert";
import "dart:js";
import "App.dart";
import "Messages.dart";

final double half = (window.innerHeight / 2) - 150;
var timer;
void main(){
  String status = getStatus();

  loadCommon();


  if(status == "false"){
    loadIntro();
  }else if(status == "true"){
    loadMain();
  }


//debugLoad();


}//end main

void loadCommon(){
  String status = getStatus();

//get the common parts of the site.
  Template header = new Template(templateRoot + "header.html","header",true);

/**
  * Append our header to the main tag.
  * Since we're using Hogan as a template engine, need
  * to get a little fancier with a callback.
  */
  header.appendTo(querySelector("#SITE"),(engine,template,element){


    var options = null;
    if(status == "true"){
      options = new JsObject.jsify({
          "sign_in_visible":"signed-in"
      });
    }else if(status == "false"){
      options = new JsObject.jsify({
          "sign_in_visible":"not-signed-in"
      });
    }
    element.innerHtml = template.callMethod('render',[options]);


  });

//when the user clicks "sign in", lets let them sign in
  Element signin = querySelector("#signin");
  signin.onClick.listen((event){
    window.location.href  = "/awkwardfriendship/signin";
  });
}





/**
 * Loads the intro.
 */
void loadIntro(){
  //Trying to get copy as centered as possible, figure out how much that ought to be.
  Element intro = querySelector("#intro");

  double half = (window.innerHeight / 2) - 150;

  timer = new Timer.periodic(const Duration(milliseconds:10),(e){
    var body = querySelector("html");
    var disclaimer = querySelector("#disclaimer");


    if(body.className.indexOf("wf-active") != -1){
      TweenMax.to(intro,1.5,{
          "marginTop":half,
          "ease":"Power3.easeInOut"
      });



      TweenMax.to(querySelector("#disclaimer"),1.2,{
        "bottom":0,
          "ease":"Power3.easeInOut"
      });

      timer.cancel();
    }
  });



  //when the window resizes, we need to re-center stuff;
  window.onResize.listen((event){
    double half = (window.innerHeight / 2) - 150;
    TweenMax.to(intro,0.5,{
        "marginTop":half
    });
  });
}

void fontCallback(e){


}


void debugLoad(){
  Template main = new Template(templateRoot + "main.html","main page",true);
  main.appendTo(querySelector("#SITE"),(engine,template,element){


//write username to SITE tag for easy access later
      Element site = query("#SITE");
      site.setAttribute("data-sender","sortofsleepy");

//fetch the current cache of users
      HttpRequest.getString("/users").then((String contents){

//prep template optinos
        var options = new JsObject.jsify({
            "user":"sortofsleepy",
            "candidates":contents,
            "catchphrase":getRandomDirection()
        });



       Element good = sanatizeElement("section",template.callMethod('render',[options]),["data-user"]);
//render template
        element.children.add(good);

        start();
      });


  });
}



/**
 * Shows the main section
 */
void loadMain(){

  var disclaimer = querySelector("#disclaimer");

  TweenMax.to(querySelector("#disclaimer"),1.2,{
      "bottom":0,
      "ease":"Power3.easeInOut"
  });



  Template main = new Template(templateRoot + "main.html","main page",true);
  main.appendTo(querySelector("#SITE"),(engine,template,element){


    if((window.localStorage["user"] == null) && (window.localStorage["candidates"] == null)){

      Request.get("/awkwardfriendship/credentials",(data){

        //setup to decode data
        Map user = JSON.decode(data);

        //write username to SITE tag for easy access later
        Element site = query("#SITE");
        site.setAttribute("data-sender",user["screen_name"]);
        //also store usrname in local storage
        window.localStorage["user"] = user["screen_name"];

        /** Populate our list of potential recipients */
        Request.get("/awkwardfriendship/stock",(contents){
          window.localStorage["candidates"] = contents;

          //prep template optinos
          var options = new JsObject.jsify({
              "user":user["screen_name"],
              "candidates":contents,
              "catchphrase":getRandomDirection(),
              "endmessage":getRandomEndMessage()
          });

          Element good = sanatizeElement("section",template.callMethod('render',[options]),["data-user"]);

          //render template
          element.children.add(good);

          //make sure to push msg panels out of view first
          Element send = querySelector("#sending-panel");
          Element end = querySelector("#end-panel");

          end.style.marginLeft = window.innerWidth.toString() + "px";
          send.style.marginLeft = window.innerWidth.toString() + "px";

          start();
        });//end users fetching

      });//end credential fetch


    }else{

        //prep template optinos
      var options = new JsObject.jsify({
          "user":window.localStorage["user"],
          "candidates":window.localStorage["candidates"],
          "catchphrase":getRandomDirection(),
          "endmessage":getRandomEndMessage()
      });

      Element good = sanatizeElement("section",template.callMethod('render',[options]),["data-user"]);

      //render template
      element.children.add(good);

      //make sure to push msg panels out of view first
      Element send = querySelector("#sending-panel");
      Element end = querySelector("#end-panel");

      end.style.marginLeft = window.innerWidth.toString() + "px";
      send.style.marginLeft = window.innerWidth.toString() + "px";
      start();

    }




  }); // end template callback


}




/**
 * Gets the logged in status of the user.
 */
String getStatus(){
  String status;
  HttpRequest req = new HttpRequest();
  req.open("GET","/status",async:false);

  req.onLoadEnd.listen((e){
    Map data = JSON.decode(e.target.responseText);
    status = data["status"];
  });

  req.send();

  return status;
}