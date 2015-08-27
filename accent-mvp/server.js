//Modules
var express = require('express');
var app = express();
var io      = require("socket.io");         // web socket external module
var easyrtc = require("easyrtc");           // EasyRTC external module

//Statically serve files in these directories  -easyRTC
app.use("/js", express.static(__dirname + '/easyrtc/js'));
app.use("/images", express.static(__dirname + '/easyrtc/images'));
app.use("/css", express.static(__dirname + '/easyrtc/css'));

//For my homepage
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');

app.use("/css", express.static(__dirname + '/public/css'));
app.use("/img", express.static(__dirname + '/public/img'));

// Needed to parse form data 
app.use(express.bodyParser());

//global variables
var loggedIn = false,
	loggedInFirst = false,
    password = 'accent';

//Temporary home page
app.get('/', function (req, res) {
	if (loggedIn == false) {
		console.log("false");
		res.sendfile(__dirname + '/public/login.html');
	} else {
		console.log("true");
		res.sendfile(__dirname + '/easyrtc/demo_multiparty.html');
		setInterval(function(){
			loggedIn = false;
		}, 5 * 1000);   
	}
});

//Respond to POST from login form
app.post('/login', function (req, res) {
	//console.log("Posted data:" + JSON.stringify(req.body));
    //console.log("Logged in");
	if (req.body.pw == password) {
		if (loggedInFirst == false) {
			var easyrtcServer = easyrtc.listen(app, socketServer, {'apiEnable':'true'});
		}
		console.log("Logged in");
		loggedIn = true;
		loggedInFirst = true;
		res.send("Logged in");
	} else { res.send("Incorrect password.") }
	//res.sendfile(__dirname + '/easyrtc/demo_multiparty.html');
});

//var webServer = app.listen(process.env.port || 8080); //original WebMatrix port
var webServer = app.listen(8080);
console.log('Listening on port ' + 80);

// Start Socket.io so it attaches itself to Express server
var socketServer = io.listen(webServer);