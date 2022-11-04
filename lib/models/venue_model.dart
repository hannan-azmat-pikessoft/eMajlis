import 'package:emajlis/models/amenity_model.dart';

class VenueModel {
  String id;
  String title;
  String linkedinLink;
  String facebookLink;
  String instagramLink;
  String twitterLink;
  String websiteLink;
  String location;
  String latitude;
  String longitude;
  String description;
  String openingTime;
  String closingTime;
  int rating;
  List<dynamic> imagesList = [];
  List<AmenityModel> amenities = [];
  List<dynamic> offeringsList = [];
  List<dynamic> houseRulesList = [];
  List<dynamic> specialFeaturesList = [];

  VenueModel({
    this.id,
    this.title,
    this.facebookLink,
    this.instagramLink,
    this.twitterLink,
    this.websiteLink,
    this.location,
    this.latitude,
    this.longitude,
    this.description,
    this.openingTime,
    this.closingTime,
    this.rating,
    this.imagesList,
    this.offeringsList,
    this.houseRulesList,
    this.specialFeaturesList,
    this.amenities,
    this.linkedinLink,
  });
}
