var bittrex = require('node-bittrex-api');
var json2csv = require('json2csv');
var fs = require('fs');

var rawData = [];
var count = 0;

var fields = ['O', 'H', 'L','C','V','T','BV','market'];

bittrex.sendCustomRequest('https://bittrex.com/api/v1.1/public/getmarkets', function(data, err) {
	if(err) { return console.log(err) }

		var marketsArr = data.result;

	for(var i=0; i<marketsArr.length; i++) {
		var marketName = marketsArr[i].MarketName;
		bittrex.getcandles({
			marketName: marketName,
			tickInterval: 'hour',
		}, function(data, err) {
			//console.log(marketsArr[count].MarketName);
			if(err) {
				console.log("err");
				count++; 
				if(count==263) {
					console.log("scan end");
					var result = json2csv({data: rawData, fields: fields});
					fs.writeFile("data.csv", result, function (err) {
						if (err) {
							return console.log(err);
						}
						console.log("The file was saved!");
					});

				}
				return //console.log(err);
			}
			res = data.result;
			res.forEach(function(e) { e.market = marketsArr[count].MarketName; })
			rawData = rawData.concat(res);
			count++;
			if(count==263) {
				console.log("scan end");
				var result = json2csv({data: rawData, fields: fields});
				fs.writeFile("data.csv", result, function (err) {
					if (err) {
						return console.log(err);
					}
					console.log("The file was saved!");
				});
			}
		});
	}
});
