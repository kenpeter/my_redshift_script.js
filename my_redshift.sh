#!/usr/bin/env node 

var isOnline = require('is-online');
var request = require("request");
var exec = require('child_process').exec;
var spawn = require('child_process').spawn;

isOnline(function(err, online) {
  if(online == true) {
    var address = "melbourne victoria";
    var re;
    var address_weather;
    var geo_urll;

    var lat;
    var lng;
    var weather_url;
    var temp;

    var my_extra_temp = 5000;
    var my_temp;
    var redshift_cmd;

    console.log('It is online.');

    // https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_Objects/String/replace 
    re = /\s/gi;
    address_weather = address.replace(re, ',');

    geo_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + address_weather + "&sensor=true"
    console.log('url: ' + geo_url);

    // Get geo data
    request({
      url: geo_url,
      json: true
    }, function (error, response, body) {
      if (!error && response.statusCode === 200) {
        lat = body['results'][0]['geometry']['location']['lat'];
        lng = body['results'][0]['geometry']['location']['lng'];
        console.log('lat: ' + lat + ' ' + 'lng: ' + lng);

        // Get weather
        weather_url = "http://api.openweathermap.org/data/2.5/weather?q=" + address_weather
        console.log('weather url: ' + weather_url);

        request({
          url: weather_url,
          json: true
        }, function(err, res, body){
          temp = body['main']['temp'];
          my_temp = Math.round(temp) + my_extra_temp; 
          console.log('temperature: ' + temp);

          redshift_cmd = "gtk-redshift -l " + lat + ":" + lng + " -t " + my_temp + ":" + my_temp; 
          console.log(redshift_cmd);

          // http://stackoverflow.com/questions/20643470/execute-a-command-line-binary-with-node-js
          var child = spawn('gtk-redshift', [
            '-l', lat + ":" + lng,
            '-t', my_temp + ":" + my_temp
          ]);          

          // leave
          process.exit();
        }); 
      }
    });
 
 
  }
  else {
    console.log('It is offline.');

    // "gtk-redshift -l -37.814107:144.96328 -t 5282:5282 &"
    var cmd = "gtk-redshift -l -37.814107:144.96328 -t 5282:5282 &";
    console.log('Using this: ' + cmd);
    var lat = '-37.814107';
    var lng = '144.96328';
    var my_temp = '5282';
    var child = spawn('gtk-redshift', [
      '-l', lat + ":" + lng,
      '-t', my_temp + ":" + my_temp
    ]);

    // leave
    process.exit();
  }

 
   
});


