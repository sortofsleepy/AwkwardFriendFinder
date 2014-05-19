import "dart:math";


var messages = [
    "Happy Holidays ",
    "Believe in yourself",
    "The difference between stumbling blocks and stepping stones is how you use them ",
    "Hows it going? I hope you're well ",
    "Always remember that you are unique. Just like everybody else. ",
    "In order to carry a positive action we must develop here a positive vision ",
    "Don't worry, things will turn out just fine ",
    "I hope you have a blessed new year ",
    "Don't be grumpy, be happy ",
    "Life is abotu learning to dance in the rain ",
    "Live simply, dream big ",
    "Be so good they can't ignore you ",
    "Above all try ",
    "Theres no need to be perfect ",
    "Be yourself ",
    "Hug harder ",
    "Happiness is found when you stop comparing yourself to others ",
    "Comfort is the enemy of achievement ",
    "Stress less ",
    "Taking time to live life will only inspire your work ",
    "If opportunity doesn’t knock, build a door ",
    "Replace negative thoughts with positive ones, you'll start having positive results. "
];


var punc = [
    "?",
    ".",
    "!",
    ":)",
    ";)"
];
var directions = [
   "Prepare for friendship!",
    "This just might be the one!",
    "3,2,1 Friendship!",
    "Akward conversation go!",
    "All aboard the USS Friendship!"
];

var endmessages = [
  "Lets hope no one thinks you're weird!",
  "I'm sure whatever you sent was quite nice.",
  "Isn't it wonderful how technology can bring us all closer together like this?"
  "I'm sure no one will think anything of a random stranger contacting them over the internet",
  "This could go either way, hope it's positive!",
  "Pat yourself on the back, you just made the world a better place!"
];

/**
* Returns a random catchphrase for the directions.
*/
String getRandomDirection(){
  var rnd = new Random();
  return directions[rnd.nextInt(directions.length - 1)];
}

/**
  Returns a random message
*/

String randomMessage(var to,String url,String hashtag){
  var rand = new Random();

  String message = messages[rand.nextInt(messages.length)];
  message += "@${to["screen_name"]} ";
  message += " #akwardfriendship ${url}";

  return message;

}

String orderedMessage(String to, String url, String hashtag,int index){
  String message = messages[index];
  message += "@${to} ";
  message += " #akwardfriendship ${url}";

  return message;
}
/**
* Returns a random endmessage for the directions.
*/
String getRandomEndMessage(){
  var rnd = new Random();
  return endmessages[rnd.nextInt(endmessages.length - 1)];
}
