import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> {
  String weatherCondition = 'Cloudy';
  String temperature = 'T°C';
  String humidity = 'Humidity';
  String windSpeed = 'windspeed';
  String assetImageFile = 'lib/assets/cloudy.png';

  String location = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.cloud, color: Colors.lightBlue,),
          title: const Text(
            'Weather App',
            style: TextStyle(color: Colors.lightBlue),
            textAlign: TextAlign.center,
          ),
          centerTitle: true,
          backgroundColor: Colors.black12,
        ),
        body: SingleChildScrollView(
          child: Column(
          children: <Widget>[
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    onChanged: (value) {
                      location = value;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter Location',
                    ),
                  ),

                ),
                Container(
                  child: GestureDetector(
                    onTap: () {
                      setLocation(location);
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    child: Image.asset(
                      'lib/assets/search.png',
                      width: 50,
                      height: 50,
                      color: Colors.lightBlue,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 300,
              width: double.infinity,
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(assetImageFile),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 15,),
            Text(
              weatherCondition,
              style: TextStyle(fontSize: 24, ),        
            ),
            SizedBox(height: 10,),
            Text(
              temperature,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const ImageIcon(
                        AssetImage('lib/assets/humidity.png'),
                        size: 50,
                      ),
                      Text(
                        humidity,
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const ImageIcon(
                      AssetImage('lib/assets/windspeed.png'),
                      size: 50,
                    ),
                    Text(
                      windSpeed,
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),)
              ],
            )
          ],
        ),
        ),
      ),
    );
  }

  void setWeaather(List<dynamic> temperature, List<dynamic> humidity,
      List<dynamic> windSpeed, List<dynamic> weather_code) {
    String? weatherCondition;
    int weathercode = weather_code[getCurrentTimeIndex()];

    if (weathercode == 0) {
      weatherCondition = "Clear";
    } else if (weathercode <= 3 && weathercode > 0) {
      weatherCondition = "Cloudy";
    } else if ((weathercode >= 51 && weathercode <= 67) ||
        (weathercode >= 80 && weathercode <= 99)) {
      weatherCondition = "Rain";
    } else if ((weathercode >= 71 && weathercode <= 77)) {
      weatherCondition = "Snow";
    }

    setState(() {
      this.weatherCondition = weatherCondition.toString();
      this.temperature = temperature[getCurrentTimeIndex()].toString() + "°C";
      this.humidity = humidity[getCurrentTimeIndex()].toString() + "%";
      this.windSpeed = windSpeed[getCurrentTimeIndex()].toString() + "km/h";

      switch (this.weatherCondition) {
        case "Clear":
          assetImageFile = "lib/assets/clear.png";
          break;
        case "Cloudy":
          assetImageFile = "lib/assets/cloudy.png";
          break;
        case "Rain":
          assetImageFile = "lib/assets/rain.png";
          break;
        case "Snow":
          assetImageFile = "lib/assets/snow.png";
          break;
      }
    });
  }

  void fetchWeatherData(double latitude, double longitude) async {
    // Get current location

    // Make API request to fetch weather data
    var url =
        "https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&hourly=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&timezone=auto";
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the response body
      var data = jsonDecode(response.body)['hourly'] as Map<String, dynamic>;
      //print(data);

      // Extract the weather information
      var weathercode = data['weather_code'];
      var temperature = data['temperature_2m'];
      var humidity = data['relative_humidity_2m'];
      var windSpeed = data['wind_speed_10m'];

      // Update the state with the fetched weather data
      setWeaather(temperature, humidity, windSpeed, weathercode);
    } else {
      // Handle error response
      print(
          'Failed to fetch weather data. Status code: ${response.statusCode}');
    }
  }

  void setLocation(String locationName) {
    locationName = locationName.replaceAll(" ", "+");
    if(locationName[locationName.length-1] == "+"){
      locationName = locationName.substring(0, locationName.length - 1);
    }


    String urlString = "https://geocoding-api.open-meteo.com/v1/search?name=" +
        locationName +
        "&count=10&language=en&format=json";

    http.get(Uri.parse(urlString)).then((response) {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body)['results'] as List<dynamic>;

        var result = data[0] as Map<String, dynamic>;
        double latitude = result['latitude'];
        double longitude = result['longitude'];
        fetchWeatherData(latitude, longitude);
      } else {
        print(
            'Failed to fetch location data. Status code: ${response.statusCode}');
      }
    }).catchError((error) {
      print('Error fetching location data: $error');
    });
  }

  int getCurrentTimeIndex() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    return hour;
  }
}
