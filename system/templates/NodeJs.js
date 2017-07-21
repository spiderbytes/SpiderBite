var http = require('http');
var url  = require('url');
var sys  = require('sys');

// ### PB2Web ServerPort ###

http.createServer(function (req, res) {

	res.writeHead(200, { 'Content-Type': 'text/html', 'Access-Control-Allow-Origin' : '*'});

	var query =  url.parse(req.url, true).query;
	var request = query.request;

	process.on('uncaughtException', function (err) {
		// console.log(err);
		res.write(err.message);
		res.end();
	})

	if (request) {
		if (PB2NodeJsFunctions[request]) {

			delete query.request;
			delete query.rnd;

			// Parameter
			var keys = Object.keys(query);
			var params = [];
			for (var i = 0; i < keys.length; i++) {
				params.push(query[keys[i]]);
			}

			res.write(PB2NodeJsFunctions[request].apply(PB2NodeJsFunctions[request], params));
			res.end();

		}
	}

}).listen(port);

	sys.puts("PB2NodeJs Server Running on " + port); 

// #########################
// ### PB2Web ServerCode ###
// #########################
