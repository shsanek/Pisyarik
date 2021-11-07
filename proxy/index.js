	var httpProxy = require('http-proxy');
	var fs = require('fs');
	//
	// Create the HTTPS proxy server in front of a HTTP server
	//
	httpProxy.createServer({
		target: {
			host: '127.0.0.1',
			port: 8080
		},
		ssl: {
			key: fs.readFileSync('key/key.pem', 'utf8'),
			cert: fs.readFileSync('key/certificate.pem', 'utf8')
		},
        ws: true
	}).listen(8443);
