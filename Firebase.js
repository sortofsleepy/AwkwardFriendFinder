var Firebase = require("firebase");
var ref = new Firebase("https://randomchristmas.firebaseio.com/");
var users = ref.child("users");

var Flame = (function(){
    var API = {
        test:function(){
          console.log("works");
        },
        /**
         * Adds a user to the DB
         * @param{String} name to use for the user
         * @param{Object} _data initial data to write.
         */
        addUser:function(name,_data){
            verifyUser(name,function(data){
                if(data === false){
                    users.child(name).set(_data);
                }
            })
        },


        /**
         * Gets the user's information
         * @param{String} name name of the user
         * @param{Function} callback callback to run on the returned user's data.
         */
        getUser:function(name,callback){
            verifyUser(name,function(data){
                if(data !== false){
                    callback(data);
                }
            })
        },

        /**
         * Updates a user's info
         * @param{String} name name of the user
         * @param{Object} _data data that needs to be updated in object format
         */
        update:function(name,_data){
            verifyUser(name,function(data){
                if(data !== false){
                    users.child(name).update(_data);
                }
            })
        },

        /**
         * Logs a tweet for the user
         * @param name username
         * @param tweet_data the data for the tweet.
         */
        pushTweet:function(name,tweet_data){

            //trying to verify the user causes things to go nuts.
            //seems to go fine without having to check for a user first
            var tweet = JSON.parse(tweet_data.tweet);
            var date = Date.now()
            users.child(name).child("tweets").child(date).update({
                "id":tweet.id,
                "text":tweet.text,
                "created_at":tweet.created_at,
                "geo":tweet.geo,
                "place":tweet.place
            })
        }
    }


    function verifyUser(name,callback){
        users.on("value",function(data){
            if(data.hasChild(name)){
                callback(data);
            }else{
                callback(false);
            }
        })

    }


    return API;
})();


module.exports = Flame;