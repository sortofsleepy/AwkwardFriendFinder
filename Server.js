var flatiron = require("flatiron");
var app = flatiron.app;
var connect = require("connect").static;
var fs = require("fs");
var url = require("url");
var session = require("connect").session;
var cookieParser = require("connect").cookieParser;
var parser = require("connect").bodyParser;

// WINSTON!!!!!!!
var winston = require("winston");
winston.add(winston.transports.File, { filename: __dirname + '/Errors.log' });


// PORTS!!!!!
var PORT = 5000 || proces.env.PORT;

// CATCHPHRASES!!!!!
var CATCHPHRASE = encodeURIComponent("#randomchristmas");

// Street cred yo!
var creds = {};

//use functions
app.use(flatiron.plugins.http,{});


//setup static file directories.
app.http.before.push(connect(__dirname + "/public"));
app.http.before.push(connect(__dirname + "/public/static"));
app.http.before.push(connect(__dirname + "/public/dart"));
app.http.before.push(connect(__dirname + "/public/templates"));
app.http.before.push(connect(__dirname + "/public/img"));
app.http.before.push(cookieParser());
app.http.before.push(parser());
app.http.before.push(session({secret:"blsifhosifheosif"}));


app.http.before.push(function(req,res){


    var found = app.router.dispatch(req,res);

    if(!found){
		res.emit("next");
	}


});

//whether or not someone is logged in.
var logged_in = false;

//Twitter API wrapper
var Twitter = require("./Twitter");
var tw = new Twitter();

//Firebase wrapper
var Flame = require("./Firebase");


//start app
app.start(PORT);
/*====================== ROUTES YO! ====================== */


/**
 * Home page
 */
app.router.get("/awkwardfriendship",function(){
    var res = this.res;

    var parent = this;
    console.log(this.req.session.token);

    loadTemplate("index",function(data){
        parent.res.end(data);
    },true);


});

app.router.post("/awkwardfriendship/tweet",function(){
    var res = this.res;
    //var data = JSON.parse(this.req.chunks.toString("utf-8"));
    var data = {
        message:Math.random() * 999999999
    }
    tw.tweet(data,function(tweet_data){
        var sender = JSON.parse(tweet_data).user.screen_name;
        //log the tweet for the user in FB
        Flame.pushTweet(sender,{
            tweet:tweet_data
        })

        res.writeHead(200,{
            "Content-Type":"application/json"
        })


        var status = {
            tweet_sent:"true"
        }
        res.end(JSON.stringify(status));
    });


})


app.router.get("/awkwardfriendship/signin",function(){
    var res = this.res;
    tw.init(res);
});

app.router.get("/status",function(){
    var res = this.res;
    res.writeHead(200,{'Content-Type':"application/json"});
    var parent = this;

    if(this.req.session.token === undefined){
        parent.res.end(JSON.stringify({status:"false"}))
    }else{
        parent.res.end(JSON.stringify({
            status:"true"
        }))
    }
});


/**
 * Polls for and stores user handles to tweet at.
 */
app.router.get("/awkwardfriendship/stock",function(){
    var res = this.res;
    console.log("stocking users");

    res.writeHead(200,{'Content-Type':"application/json"});
    var parent = this;

    //start a search to cache data and store a list of users
    tw.searchUsers("christmas",function(data){

        /**
         * Need to filter through the data.
         */
        var cache = [];
        data = JSON.parse(data);
        var datalen = data.statuses.length;
        for(var i = 0;i<datalen;++i){
            var obj = data.statuses[i];

            var user = {
                id:obj.user.id,
                screen_name:obj.user.screen_name,
                followers:obj.user.followers_count,
                geo_enabled:obj.user.geo_enabled,
                profile_image:obj.user.profile_image_url
            };

            cache.push(user);


        }

        //cache data for laters.
        fs.writeFile(__dirname + "/public/data/Search.json",JSON.stringify(cache),function(err){
            if(err){
                winston.log("Trouble writing user list : " + err);
            }
        })

        //output something if we need to check data received.
        res.end(JSON.stringify(cache))
    });
})

/**
 * Needed route to swap reg token for access token
 */
app.router.get("/awkwardfriendship/preauth",function(){
    var res = this.res;
    var session = this.req.session;
    tw.getAccess(this.req,function(token,secret){
        //at this point we have access token and secret
        session.token = token;
        session.secret = secret;


        /**
         * Make sure to add the user to DB
         * if they're here for the first time.
         * (DB API automatically protects against
         * duplicates)
         */
        tw.getCurrentUser(function(data){
            data = JSON.parse(data);
            var details = {
                id:data.id,
                screen_name:data.screen_name,
                location:data.location,
                geo_enabled:data.geo_enabled,
                tweets:[]

            }
            Flame.addUser(data.screen_name,details);
        })

        res.redirect("/");
    });
});



/**
 * Fetches our user's details from teh server
 */
app.router.get("/awkwardfriendship/credentials",function(){
    var res = this.res;
    res.writeHead(200,{'Content-Type':"application/json"});
    tw.getCurrentUser(function(data){
        data = JSON.parse(data);

        var details = {
            id:data.id,
            screen_name:data.screen_name,
            location:data.location,
            geo_enabled:data.geo_enabled

        }

        res.end(JSON.stringify(details));
    })
});

/**
 * Revokes a user's token
 */
app.router.get("/revoke",function(){

})

app.router.path("/awkwardfriendship/send",function(){
    this.post(function(){
       this.req.on("data",function(chunk){
           console.log("here");
           console.log(chunk);
       })

        this.req.on("end",function(){
            console.log("end")
        })
    })
})
/**
 * gets a list of possible users
 */

app.router.get("/awkwardfriendship/users",function(){
    var res = this.res;
    var req = this.req;

    res.writeHead(200,{
        'Content-Type':"application/json"
    });

    fs.readFile(__dirname + "/public/data/Search.json",function(err,data){
        if(err){
            winston.error("Issue pulling search results from the cache : " + err);
        }else{
            res.end(data);
        }
    });
});

function addNewUser(){
    tw.getCurrentUser(function(data){
        data = JSON.parse(data);


        var details = {
            id:data.id,
            screen_name:data.screen_name,
            location:data.location,
            geo_enabled:data.geo_enabled

        }

        res.end(JSON.stringify(details));
    })
}


/**
 * Loads a template
 * @param _file
 * @param _callback
 * @param _index
 */
function loadTemplate(_file,_callback,_index){
    var template = null;

    if(_file !== "index"){
        fs.readFile(__dirname + "/public/templates/" + _file + ".html" ,"utf8",function(err,data){
            _callback(data);
        })

    }else{

        fs.readFile(__dirname + "/public/templates/index.html" ,"utf8",function(err,data){
            _callback(data);
        })

    }
}