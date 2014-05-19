part of Flint;



class Request {
  static HttpRequest req = new HttpRequest();


  static void post(String url,var data,[Function callback]){
      req.open("POST",url);
      req.send(data);

      req.onLoadEnd.listen((event){
        if(callback != null){
          callback();
        }
      });

  }

  static void getSync(var url,[Function callback]){
    HttpRequest req = new HttpRequest();
    req.open("GET",url,async:false);
    var data = null;
    req.onLoadEnd.listen((event){
      print("Done grabbing stuff from ${url}");
      if(callback != null){
        callback(event.target.responseText);
      }else{
        data = event.target.responseText;
      }
    });


    req.send();

  }

  static void get(var url,[Function callback]){
    HttpRequest req = new HttpRequest();
    req.open("GET",url);

    req.onLoadEnd.listen((event){
      print("Done grabbing stuff from ${url}");
      if(callback != null){
        callback(event.target.responseText);
      }
    });


    req.send();
  }
}