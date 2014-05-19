/**
 * A Twitter library.
 * @type {string}
 */
var key = "YOUR_OWN_KEY";
var secret = "YOUR_OWN_SECRET";
var joined = new Buffer(key + ":" + secret).toString("base64");

var http = require("http");
var https = require("https");
var fs = require("fs");
var OAuth = require("OAuth");
var url = require("url");
// WINSTON!!!!!!!
var winston = require("winston");

var TwitterApi = function(_res,_type){
    this.type = typeof(_type) !== undefined ? _type : "app";
    this.res = _res;
    this.events = {};
}


TwitterApi.prototype = {
    init:function(res){
        this.res = res;
        if(this.type === "app"){
            API.appAuth(key,secret,res);
        }else{
            API.regAuth(key,secret,res);
        }
    },
    tweet:function(data,callback){
        API.oauth.post("https://api.twitter.com/1.1/statuses/update.json",API.token,API.secret,{
            status:data.message,
            display_coordinates:true
        },function(err,data){
            if(err){
                console.log("Issue sending tweet : " + err.data);
            }else{
               if((callback !== undefined) && (callback !== null)){
                   callback(data);
               }
            }
        });
    },
    getCurrentUser:function(callback){
        API.oauth.get("https://api.twitter.com/1.1/account/verify_credentials.json",API.token,API.secret,function(err,data){
            if(err){
                console.log("Error getting user details : " + err.data);
                winston.log("Error getting user details : " + err);
            }else{
                callback(data);
            }
        });
    },

    getAccess:function(request,callback){
      API.getAccessToken(request,callback);
    },

    /**
     * Adds a event to be triggered
     * @param event
     * @param callback
     */
    addEvent:function(event,callback){
      this.events[event] = callback;
    },

    searchUsers:function(term,callback){
        var token = API.token;
        var secret = API.secret;

        API.oauth.get("https://api.twitter.com/1.1/search/tweets.json?count=100&q=" + term,token,secret,function(err,data){
            callback(data);
        })
    },

    search:function(_term,_options){
        var query = encodeURI(_term);

        if((_options !== undefined) && (_options !== null)){
            var result_type = typeof(_options.result_type) !== undefined ? _options.result_type : "mixed";
            var count = typeof(_options.count) !== undefined ? _options.count : 100;
        }

        API.appApi(function(token){

            var options = {
                host:"api.twitter.com",
                path:"/1.1/search/tweets.json?q=" + query + "&result_type=" + result_type + "&count=" + count,
                headers:{
                    "Authorization":"Bearer" + " " + token
                }
            }

            var req = https.request(options,function(res){
                var chunk = "";

                res.on("data",function(data){
                    chunk += data;
                });

                res.on("end",function(){
                    //cache search locally
                    fs.writeFile(__dirname + "/public/data/Search.json",chunk,function(err){
                        if(err){
                            console.log(err);
                        }
                    })
                })
            });

            req.on("error",function(err,err2){
                console.log(err);
                console.log(err2);
            });

            req.end();
        })
    }
};



var API = {


    regAuth:function(_key,_secret,res){
        var parent = this;
        this.res = res;
        this.oauth = new OAuth.OAuth(
            "https://api.twitter.com/oauth/request_token",
            "https://api.twitter.com/oauth/access_token",
            _key,
            _secret,
            "1.0A",
            null,
            "HMAC-SHA1"
        );

        this.oauth.getOAuthRequestToken(function(error, oauth_token, oauth_token_secret, results){
            if(error) {
                console.log('error');
                console.log(error);
            }
            else {
                // store the tokens in the session
                parent.token = oauth_token;
                parent.secret = oauth_token_secret;


                // redirect the user to authorize the token
                res.redirect("https://api.twitter.com/oauth/authenticate?oauth_token="+oauth_token);
            }
        })
    },

    appAuth:function(){
        var options = {
            host:"api.twitter.com",
            path:"/oauth2/token",
            method:"POST",
            headers:{
                "Authorization": "Basic" + " " + joined,
                "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
            }
        }

        var parent = this;
        var req = https.request(options,function(res){
            var chunk = "";

            res.on("data",function(data){

                chunk += data;
            })

            res.on("end",function(data){

                var data = JSON.parse(chunk);
                parent.app_token = data.access_token;
            })

        })


        req.on("error",function(e,e2){
            console.log(e);
            console.log(e2);
        })

        req.write("grant_type=client_credentials");
        req.end();
    },
    getAccessToken:function(request,callback){
        var parent = this;
        var res = this.res;
        if((this.token !== undefined) && (this.secret !== undefined)){
            var parts = url.parse(request.url,true);

            this.oauth.getOAuthAccessToken(this.token,this.secret,parts.query.oauth_verifier,function(err,access_token,access_token_secret,results){
                parent.token = access_token;
                parent.secret = access_token_secret;


                callback(access_token,access_token_secret);
            });


        }
    },


    appApi:function(callback){
        this.appGetToken(callback);
    },


    appGetToken:function(_callback){
        var parent = this;
        setInterval(function(){
            if(parent.token !== undefined){
                clearInterval(this);
                _callback(parent.app_token);
            }
        })
    }


}

module.exports = TwitterApi;