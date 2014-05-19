import "dart:html";
import "dart:convert";
import "dart:math";
import "Messages.dart";
import "Flint/Flint.dart";
import "dart:js";

Flickr photo;
/**
* Starts the main app
*/
void start(){
  photo = new Flickr();

  //lets grab a random user
  var content = window.localStorage["candidates"];
  content = JSON.decode(content);
  var users = [];
  var rnd = new Random();

  var size = 0;
  //calculate size;
  for(var i in content){
    size++;
  }



  var user = content[rnd.nextInt(size)];

  // Make sure instructions sit roughly halfway down.
  double half = (window.innerHeight / 2) - 150;
  querySelector("#instructions").style.marginTop = "-900px";
  TweenMax.to(querySelector("#instructions"),1.5,{
      "marginTop":half,
      "ease":"Power3.easeInOut"
  });
  window.onResize.listen((e){
    double half = (window.innerHeight / 2) - 150;
    TweenMax.to(querySelector("#instructions"),1.5,{
        "marginTop":half,
        "ease":"Power3.easeInOut"
    });
  });


  querySelector("#send-msg").style.marginTop = "-900px";
  TweenMax.to(querySelector("#send-msg"),1.5,{
      "marginTop":half,
      "ease":"Power3.easeInOut"
  });


  TweenMax.to(querySelector("#end-msg"),1.5,{
      "marginTop":half,
      "ease":"Power3.easeInOut"
  });

  window.onResize.listen((e){
    double half = (window.innerHeight / 2) - 150;
    TweenMax.to(querySelector("#send-msg"),1.5,{
        "marginTop":half,
        "ease":"Power3.easeInOut"
    });

    TweenMax.to(querySelector("#end-msg"),1.5,{
        "marginTop":half,
        "ease":"Power3.easeInOut"
    });
  });


  //for when the user clicks on the send button.
  querySelector("#send").onClick.listen((e){
    sendMessage(user);


  });
}

void sendMessage(user){

  Tweet t = new Tweet(user);
/**
  * Tween sending message into place.
  */
  TweenMax.to(querySelector("#sending-panel"),0.7,{
      "marginLeft":0,
      "ease":"Power3.easeInOut",

  },(){
    t.sendMessage((){


      print("all done");

      TweenMax.to(querySelector("#end-panel"),0.7,{
          "marginLeft":0,
          "ease":"Power3.easeInOut"
      });

      querySelector("#end-btn").onClick.listen((e){
        window.location.href = "/";
      });
    });
  });
}




class Tweet {

  String msg,sender;
  var recipient;
  var rnd = new Random();


  Tweet(var user){
    recipient = user;


    //get the sender
    sender = window.localStorage["user"];
  }

  void sendMessage([Function callback,bool random=true]){
    if(!random){
      print(orderedMessage(recipient,photo.getUrl(),"#awkwardfriendship",3));
    }else{
      print(randomMessage(recipient,photo.getUrl(),"#awkwardfriendship"));
      var message = randomMessage(recipient,photo.getUrl(),"#awkwardfriendship");

      var data = {
          "message":message,
          "to":recipient,
          "from":"sortofsleepy"
      };
      Request.post("/awkwardfriendship/tweet",JSON.encode(data),(){
        if(callback != null){
          callback();
        }
      });
    }

  }
}

/**
* Fetches a random image from Flickr
*/
class Flickr{
  String url = "http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=395c2fe62c6f8323dda0a1a9cbb7de69&tags=happy&format=json&nojsoncallback=1&per_page=200";
  var image;
  Random rnd = new Random();
  Flickr(){
    //make a request to FLickr to get a image
    //var images = JSON.decode(Request.getSync(url));
    //print(images);

    if(window.localStorage["flickr-pinged"] != "true"){
      Request.get(url,(data){
        window.localStorage["flickr-pinged"] = "true";
        window.localStorage["flickr-data"] = data;
      });

    }else{
      var data = JSON.decode(window.localStorage["flickr-data"]);
      var size = 0;
      for(var i in data["photos"]["photo"]){
        size++;
      }

      getImage(size,data["photos"]["photo"]);
    }

  }

  String getUrl(){
    if(image != null){
      return image["id"];
    }else{
      return "false";
    }
  }
  void getImage(int size,var data){
    var index = rnd.nextInt(size);
    var image_data = data[index];
    String url = "http://farm" + image_data["farm"].toString() + ".staticflickr.com/" + image_data["server"].toString() + "/" + image_data["id"].toString() + "_" + image_data["secret"].toString() + ".jpg";

    //shorten url
    HttpRequest req = new HttpRequest();
    req.open("POST","https://www.googleapis.com/urlshortener/v1/url",async:false);
    req.setRequestHeader("Content-Type","application/json");
    req.onLoadEnd.listen((event){
      image = JSON.decode(event.target.responseText);
    });

    req.send('{"longUrl":"${url}"}');
  }
}