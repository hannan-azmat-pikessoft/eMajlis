import 'dart:convert';
import 'package:emajlis/environment.dart';
import 'package:emajlis/models/city_model.dart';
import 'package:emajlis/models/country_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommonProvider extends ChangeNotifier {
  List<CountryModel> countryList = [];
  List<CityModel> cityList = [];
  int idToRedirect = -1;

  Future<void> loadCountries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<CountryModel> items = [];
    try {
      var response = await http.get(
        Uri.parse(Environment.Host + 'country'),
        headers: Utility.httpHeaders(prefs),
      );

      final json = jsonDecode(response.body);
      final list = json["result"];
      for (int i = 0; i < list.length; i++) {
        CountryModel cdata = CountryModel(
          list[i]['country_id'],
          list[i]['iso'],
          list[i]['name'],
          list[i]['nicename'],
          list[i]['iso3'],
          list[i]['numcode'],
          list[i]['phonecode'],
          list[i]['country'],
        );
        items.add(cdata);
      }
    } catch (e) {
      print("Exception-API.loadCountries:" + e.toString());
    }
    countryList = items;
  }

  Future<void> loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    List<CityModel> items = [];
    try {
      var response = await http.get(
        Uri.parse(Environment.Host + 'city'),
        headers: Utility.httpHeaders(prefs),
      );

      final json = jsonDecode(response.body);
      final list = json["city"];
      for (int i = 0; i < list.length; i++) {
        CityModel item = CityModel(
          list[i]["name"],
          list[i]["id"],
        );
        items.add(item);
      }
    } catch (e) {
      print("Exception-API.loadCities:" + e.toString());
    }
    cityList = items;
  }

  void setIdToRedirect(int id) {
    idToRedirect = id;
  }
}
