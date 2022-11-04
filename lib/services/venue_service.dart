import 'dart:convert';
import 'dart:io';
import 'package:emajlis/environment.dart';
import 'package:emajlis/models/amenity_model.dart';
import 'package:emajlis/models/venue_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<VenueModel>> getVenues() async {
  final Utility utility = new Utility();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  List<VenueModel> items = [];
  try {
    var response = await http.get(
      Uri.parse(Environment.Host + 'general_new/coworking_spaces'),
      headers: Utility.httpHeaders(prefs),
    );

    var list = jsonDecode(response.body)['result'];
    for (var i = 0; i < list.length; i++) {
      var dd = list[i]["amenities"];
      List<AmenityModel> amenities = [];
      for (int j = 0; j < dd.length; j++) {
        amenities.add(
          new AmenityModel(
            name: dd[j]['name'],
            image: dd[j]['image'],
          ),
        );
      }
      VenueModel item = new VenueModel(
        id: list[i]["id"],
        title: utility.utf8convert(list[i]["title"]),
        facebookLink: list[i]["facebook_link"],
        instagramLink: list[i]["instagram_link"],
        linkedinLink: list[i]["linkedin_link"],
        websiteLink: list[i]["website_link"],
        twitterLink: list[i]["twitter_link"],
        latitude: list[i]["lat"],
        longitude: list[i]["lng"],
        location: utility.utf8convert(list[i]["location"]),
        description: utility.utf8convert(list[i]["description"]),
        openingTime: list[i]["opening_time"],
        closingTime: list[i]["closing_time"],
        rating: list[i]["ratings"],
        imagesList: list[i]["images"],
        offeringsList: list[i]["offerings"],
        houseRulesList: list[i]["house_rules"],
        specialFeaturesList: list[i]["special_features"],
        amenities: amenities,
      );
      items.add(item);
    }
  } on SocketException catch (e) {
    print("SocketException-getVenues:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.getVenues:" + e.toString());
  }

  return items;
}
