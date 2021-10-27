const mysql = require("mysql");
const http = require("http");

const connection = mysql.createConnection({
  host: "localhost",
  user: "user",
  database: "arrle",
  password: "123456"
});

connection.connect(function(err){
    if (err) {
      return console.error("Ошибка: " + err.message);
    }
    else{
      console.log("Подключение к серверу MySQL успешно установлено");
    }
 });

const hostname = 'localhost';
const port = 4000;

const server = http.createServer((req, res) => {
    try {
        let data = '';
        req.on('data', chunk => {
          data += chunk;
        })
        req.on('end', () => {
        try {
          console.log(JSON.parse(data)); 
          request = JSON.parse(data)["request"]

            connection.query(
              request,
              function(err, results, fields) {
                res.statusCode = 200;
                res.setHeader('Content-Type', 'text/json');
                if (err != null) {
                  data = {
                    result: "no_ok",
                    error: err.message
                  }
                  res.end(JSON.stringify(data));
                  return
                }
                if (Array.isArray(results)) {
                  data = {
                    result: "ok",
                    content: results
                  }
                  res.end(JSON.stringify(data));
                  return
                }
                data = {
                  result: "ok",
                  content: []
                }
                res.end(JSON.stringify(data));
                return
              }
            )
        }
        catch(e) {
          res.statusCode = 200;
          res.setHeader('Content-Type', 'text/plain');
          res.end('{ "result": "no_ok" }');
        }
        })
    }
    catch(e) {
        console.log(e)
    }

});


server.listen(port, hostname, () => {
  console.log(`SQL http://${hostname}:${port}/`);
});