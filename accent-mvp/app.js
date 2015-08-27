var connect = require('connect');
var janrain = require('janrain-api');
var express = require('express');
var io      = require("socket.io");         // web socket external module
var easyrtc = require("easyrtc");           // EasyRTC external module
var app = express.createServer();
var engageAPI = janrain('4bbfc1a39c5f10681e062678ecf10ae6cb8fb172');
// Start Socket.io so it attaches itself to Express server
var socketServer = io.listen(webServer);

//Statically serve files in these directories  -easyRTC
app.use("/js", express.static(__dirname + '/easyrtc/js'));
app.use("/images", express.static(__dirname + '/easyrtc/images'));
app.use("/css", express.static(__dirname + '/easyrtc/css'));
app.use("/css", express.static(__dirname + '/public/css'));
app.use("/img", express.static(__dirname + '/public/img'));
// Needed to parse form data 
app.use(express.bodyParser());
  
app.get('/', function(req, res){
	res.sendfile(__dirname + '/index.html');
});

app.post('/', function (req, res) {
	console.log("Posted req data:" + JSON.stringify(req.body));
	console.log("Posted resp data:" + JSON.stringify(res.body));
	//res.send("Logged in");
	res.sendfile(__dirname + '/easyrtc/demo_multiparty.html');
});

var webServer = app.listen(8080);

// Start Socket.io so it attaches itself to Express server
var socketServer = io.listen(webServer);

var easyrtcServer = easyrtc.listen(app, socketServer, {'apiEnable':'true'});


