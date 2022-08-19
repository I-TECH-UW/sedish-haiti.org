var http = require("https");

var options = {  
    host : "0.0.0.0",
    port : "8080",
    timeout : 1000,
    rejectUnauthorized: false
};

var request = http.request(options, (res) => {  
    console.log(`STATUS: ${res.statusCode}`);
    if (res.statusCode == 200 || res.statusCode == 401) {
        process.exit(0);
    }
    else {
        process.exit(1);
    }
});

request.on('error', function(err) {  
    console.log('ERROR');
    process.exit(1);
});

request.end();  