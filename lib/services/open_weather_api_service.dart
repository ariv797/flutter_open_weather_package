import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_weather/enums/weather_units.dart';
import 'package:open_weather/models/weather_data.dart';
import 'package:open_weather/utils/constants.dart';

class OpenWeather {
  OpenWeather({@required this.apiKey});

  /// [apiKey] is used to authenticate the user with OpenWeather API.
  /// without proper API key, the other functions throws Exception.
  final String apiKey;

  /// Retrieves the WeatherData object by the current city name
  /// In order to use the function, [cityName] is required
  /// It is possible to set the weather units by setting a specific value in [weatherUnits]
  Future<WeatherData> currentWeatherByCityName(
      {@required String cityName,
      WeatherUnits weatherUnits = WeatherUnits.IMPERIAL}) async {
    try {
      Map<String, dynamic> _currentWeather = await _sendRequest('weather',
          cityName: cityName, weatherUnits: weatherUnits);

      return WeatherData.fromJson(_currentWeather);
    } catch (err) {
      rethrow;
    }
  }

  /// Retrieves the WeatherData object by the current location
  /// In order to use the function, [latitude] and [longitude] is required
  /// It is possible to set the weather units by setting a specific value in [weatherUnits]
  Future<WeatherData> currentWeatherByLocation(
      {@required double latitude,
      @required double longitude,
      WeatherUnits weatherUnits = WeatherUnits.IMPERIAL}) async {
    try {
      Map<String, dynamic> _currentWeather = await _sendRequest('weather',
          lat: latitude, lon: longitude, weatherUnits: weatherUnits);

      return WeatherData.fromJson(_currentWeather);
    } catch (err) {
      rethrow;
    }
  }

  /// General request handler
  /// [tag] is being used to specify some options in order to make it robust
  /// [lat] is for latitude
  /// [lon] is for longitude
  /// [cityName] is for cityName
  /// [weatherUnits] is for setting the weather unit.
  Future<Map<String, dynamic>> _sendRequest(
    final String tag, {
    final double lat,
    final double lon,
    final String cityName,
    final WeatherUnits weatherUnits,
  }) async {
    String url = _buildUrl(tag, cityName, lat, lon, weatherUnits);

    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonBody = json.decode(response.body);
      return jsonBody;
    } else {
      throw Exception("Open Weather API exception - ${response.body}");
    }
  }

  /// GFunction to set up the request URL with the specified parameters
  /// [tag] is being used to specify some options in order to make it robust
  /// [lat] is for latitude
  /// [lon] is for longitude
  /// [cityName] is for cityName
  /// [weatherUnits] is for setting the weather unit.
  String _buildUrl(
    final String tag,
    final String cityName,
    final double lat,
    final double lon,
    final WeatherUnits weatherUnits,
  ) {
    String url = AppStrings.API_BASE_URL +
        '$tag?units=${weatherUnitsString[weatherUnits]}';

    if (cityName != null) {
      url += '&q=$cityName&';
    } else {
      url += '&lat=$lat&lon=$lon&';
    }

    url += 'appid=$apiKey&';
    return url;
  }
}
