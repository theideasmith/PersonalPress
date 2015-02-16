var express = require('express')
var app 	= express()
var path = require('path')
app.use(express.static(__dirname + '/views'));;
app.get("/", function(req, res){
	//res.render('main.html')
	res.sendFile(path.join(__dirname, '/views/main.html'));
})

var server = app.listen(3000, function () {
	var host = server.address().address
	var port = server.address().port
	console.log('App listening at http://%s:%s', host, port)
})