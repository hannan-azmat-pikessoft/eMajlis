import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:emajlis/environment.dart';
import 'package:emajlis/consts/storage_keys_const.dart';
import 'package:emajlis/models/education_model.dart';
import 'package:emajlis/models/goal_model.dart';
import 'package:emajlis/models/industry_model.dart';
import 'package:emajlis/models/meeting_preference_model.dart';
import 'package:emajlis/models/member_model.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/models/organization_model.dart';
import 'package:emajlis/models/profile_model.dart';
import 'package:emajlis/models/response_model.dart';
import 'package:emajlis/models/social_links_model.dart';
import 'package:emajlis/utlis/utility.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<MyProfile> getMyProfile() async {
  final prefs = await SharedPreferences.getInstance();
  return getMemberProfile(prefs.getString(StorageKeys.MemberId));
}

Future<MyProfile> getMemberProfile(String memberId) async {
  final utility = new Utility();
  final prefs = await SharedPreferences.getInstance();
  MyProfile myProfile = new MyProfile();
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'myprofile'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(
        <String, String>{"member_id": memberId},
      ),
    );

    final json = jsonDecode(response.body);
    if (json['status']) {
      final objProfile = json["result"]["profile"];
      final objGoal = json["result"]["goal"];
      final objIndustry = json["result"]["industry"];
      final objFavMeeting = json["result"]["favorite_ways_meeting"];
      final objEducation = json["result"]["education"];
      final objPreviousOrganization = json["result"]["previous_organization"];
      // final objCompleteness = json["result"]["profile_completeness"] as int;

      myProfile.profile = new ProfileModel(
        id: objProfile["id"],
        firstname: utility.utf8convert(objProfile["firstname"]),
        svc: objProfile['credit_score'],
        email: objProfile["email"],
        imageUrl: objProfile["image_url"],
        profileStatus: objProfile["profileStatus"],
        genderId: int.parse(objProfile["gender"]),
        profession: objProfile["profession"],
        introduction: utility.utf8convert(objProfile["introduction"]),
        country: objProfile["country"],
        city: objProfile["city"],
        currentOrganization: objProfile["current_organization"],
        phoneNumber: objProfile["phone_no"],
        dialcode: objProfile["dialcode"],
        isRequestSent: objProfile["is_request_sent"],
        isSaved: objProfile["is_saved"] == 1,
        isBlocked: objProfile["is_blocked"] == 1,
      );
      if (myProfile.profile.introduction == 'null') {
        myProfile.profile.introduction = null;
      }

      myProfile.workIndustry = new IndustryModel(
        id: int.parse(objProfile["work_industry_id"]),
        name: objProfile["work_industry"],
      );

      myProfile.socialLinks = new SocialLinksModel(
        facebook: objProfile["facebook_link"],
        instagram: objProfile["instagram_link"],
        twitter: objProfile["twitter_link"],
        linkedin: objProfile["linkedin_link"],
        website: objProfile["website_link"],
      );

      myProfile.goalList = [];
      for (var i = 0; i < objGoal.length; i++) {
        final goalModel = new GoalModel(
          id: objGoal[i]["id"],
          name: objGoal[i]["name"],
        );
        myProfile.goalList.add(goalModel);
      }

      myProfile.interestedIndustryList = [];
      for (var i = 0; i < objIndustry.length; i++) {
        final indusrtyModel = new IndustryModel(
          id: int.parse(objIndustry[i]["id"]),
          name: objIndustry[i]["name"],
        );
        myProfile.interestedIndustryList.add(indusrtyModel);
      }

      myProfile.meetingPreferenceList = [];
      for (var i = 0; i < objFavMeeting.length; i++) {
        final meetModel = new MeetingPreferenceModel(
          id: objFavMeeting[i]["id"],
          imageName: objFavMeeting[i]["image_name"],
          preferenceTypeName: objFavMeeting[i]["preference_type"],
        );
        myProfile.meetingPreferenceList.add(meetModel);
      }

      if (objEducation.length > 0) {
        myProfile.education = new EducationModel(
          city: objEducation[0]["city"],
          school: objEducation[0]["school"],
          degree: objEducation[0]["degree"],
        );
      }

      myProfile.organizationList = [];
      for (var i = 0; i < objPreviousOrganization.length; i++) {
        final preOrgModel = new OrganizationModel(
          organizationName: objPreviousOrganization[i]["organization_name"],
          designation: objPreviousOrganization[i]["designation"],
        );
        myProfile.organizationList.add(preOrgModel);
      }

      myProfile = updateCompletionPercentage(myProfile);
    } else {
      return null;
    }
  } catch (e) {
    print("Exception-API.getMeetingPreferences:" + e.toString());
  }
  return myProfile;
}

Future<List<ProfileModel>> getSavedProfileForLater() async {
  final utility = new Utility();
  final prefs = await SharedPreferences.getInstance();
  List<ProfileModel> items = [];
  try {
    final response = await http.get(
      Uri.parse(Environment.Host +
          'profile_new/saved_profiles?member_id=' +
          prefs.getString(StorageKeys.MemberId)),
      headers: Utility.httpHeaders(prefs),
    );

    final json = jsonDecode(response.body);
    final list = json["result"];
    for (int i = 0; i < list.length; i++) {
      ProfileModel item = ProfileModel(
        id: list[i]['id'],
        firstname: utility.utf8convert(list[i]['firstname']),
        imageUrl: list[i]['image'],
        email: list[i]['email'],
        profession: list[i]['jobtitle'],
      );
      items.add(item);
    }
  } catch (e) {
    print("Exception-API.getSavedProfileForLater:" + e.toString());
  }
  return items;
}

Future<String> saveProfileForLater(String otherMemberId) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'profile_new/save_for_later'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "save_member_id": otherMemberId,
      }),
    );
    return jsonDecode(response.body)["message"];
  } catch (e) {
    print("Exception-API.saveProfileForLater:" + e.toString());
  }
  return '';
}

Future<ResponseModel> removeSavedProfileForLater(String otherMemberId) async {
  final prefs = await SharedPreferences.getInstance();
  ResponseModel result = new ResponseModel();
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'profile_new/remove_saved_profile'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "save_member_id": otherMemberId,
      }),
    );
    final obj = jsonDecode(response.body);
    result.status = obj["status"];
    result.message = obj["message"];
  } on SocketException catch (e) {
    print("SocketException-removeSavedProfileForLater:" + e.toString());
    result.message = 'No Internet Connection';
  } on Exception catch (e) {
    print("Exception-API.removeSavedProfileForLater:" + e.toString());
    result.message = 'Something went wrong';
  }
  return result;
}

Future<String> makeProfilePrivate(int isPrivate) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    var response = await http.post(
      Uri.parse(Environment.Host + 'profile_new/mark_profile'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, dynamic>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "profile_status": isPrivate,
      }),
    );
    final json = jsonDecode(response.body);
    return json["message"];
  } catch (e) {
    print("Exception-API.makeProfilePrivate:" + e.toString());
  }
  return '';
}

Future<bool> blockUnblockMember(String otherMemberId, int isUnblock) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'general_new/block'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, dynamic>{
        "from_member_id": prefs.getString(StorageKeys.MemberId),
        "to_member_id": otherMemberId,
        "is_unblock": isUnblock,
      }),
    );
    final json = jsonDecode(response.body);
    return json["status"];
  } catch (e) {
    print("Exception-API.blockUnblockMember:" + e.toString());
  }
  return false;
}

Future<List<MemberModel>> getBlockedMembers() async {
  final prefs = await SharedPreferences.getInstance();
  List<MemberModel> items = [];
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'general_new/block_users'),
      headers: Utility.httpHeaders(prefs),
    );

    final json = jsonDecode(response.body);
    final obj = json["result"];
    if (obj.length > 0) {
      final list = json["result"]["block_users"];
      for (int i = 0; i < list.length; i++) {
        MemberModel item = MemberModel(
          id: list[i]['id'],
          firstName: list[i]['firstname'],
          imageUrl: list[i]['image_url'],
          email: list[i]['email'],
        );
        items.add(item);
      }
    }
  } catch (e) {
    print("Exception-API.getBlockedMembers:" + e.toString());
  }
  return items;
}

Future<bool> saveSocialLinks(SocialLinksModel request) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'save_social_link'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "linkedin_link": request.linkedin,
        "twitter_link": request.twitter,
        "instagram_link": request.instagram,
        "website_link": request.website,
        "facebook_link": request.facebook,
      }),
    );
    return jsonDecode(response.body)["status"];
  } catch (e) {
    print("Exception-API.saveSocialLinks:" + e.toString());
  }
  return false;
}

Future<ResponseModel> saveEducation(EducationModel request) async {
  final prefs = await SharedPreferences.getInstance();
  ResponseModel result = new ResponseModel();
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'save_education'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "id": "",
        "degree": request.degree,
        "city": request.city,
        "school": request.school,
        "education_institute_id": ""
      }),
    );
    final obj = jsonDecode(response.body);
    result.status = obj["status"];
    result.message = obj["message"];
  } on SocketException catch (e) {
    print("SocketException-saveSocialLinks:" + e.toString());
    result.message = 'No Internet Connection';
  } on Exception catch (e) {
    print("Exception-API.saveSocialLinks:" + e.toString());
    result.message = 'Something went wrong';
  }
  return result;
}

Future<bool> saveCurrentOrganization(OrganizationModel request) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'save_current_organization'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "current_occupation": request.designation,
        "current_organization": request.organizationName
      }),
    );
    return jsonDecode(response.body)["status"];
  } on SocketException catch (e) {
    print("SocketException-saveSocialLinks:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.saveSocialLinks:" + e.toString());
  }
  return false;
}

Future<bool> savePreviousOrganization(OrganizationModel request) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'save_previous_organization'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "prev_organization_id": "148",
        "organization_name": request.designation,
        "designation": request.organizationName,
      }),
    );
    return jsonDecode(response.body)["status"];
  } on SocketException catch (e) {
    print("SocketException-saveSocialLinks:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.saveSocialLinks:" + e.toString());
  }
  return false;
}

Future<bool> updateProfile(ProfileModel request) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'profile_new/update_profile'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "member_id": prefs.getString(StorageKeys.MemberId),
        "introduction": request.introduction,
        "firstname": request.firstname,
        "lastname": "",
        "email": request.email,
        "dialcode": request.dialcode,
        "phone_no": request.phoneNumber,
        "city": request.city,
        "gender": request.genderId.toString()
      }),
    );

    return jsonDecode(response.body)["status"];
  } on SocketException catch (e) {
    print("SocketException-updateProfile:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.updateProfile:" + e.toString());
  }
  return false;
}

Future<String> saveProfileImage(File image) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    String fileName = image.path.split('/').last;
    Dio dio = new Dio();
    final response = await dio.post(
      Environment.Host + 'save_profile_picture',
      options: Options(
        headers: {
          "accept": "*/*",
          "Content-Type": "multipart/form-data",
          'AUTH-API-KEY': prefs.getString(StorageKeys.EncryptedToken)
        },
      ),
      data: FormData.fromMap({
        "member_id": prefs.getString(StorageKeys.MemberId),
        "image": await MultipartFile.fromFile(image.path, filename: fileName),
      }),
    );
    return response.data["result"]["image_url"] as String;
  } on SocketException catch (e) {
    print("SocketException-updateProfile:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.updateProfile:" + e.toString());
  }
  return '';
}

Future<bool> deleteMember() async {
  final prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'profile_new/delete_member'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(
        <String, dynamic>{"member_id": prefs.getString(StorageKeys.MemberId)},
      ),
    );
    return jsonDecode(response.body)["status"];
  } on SocketException catch (e) {
    print("SocketException-deleteMember:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.deleteMember:" + e.toString());
  }
  return false;
}

Future<bool> saveCreditScore(String otherMemberId, String id) async {
  final prefs = await SharedPreferences.getInstance();
  try {
    final response = await http.post(
      Uri.parse(Environment.Host + 'profile_new/save_credit_score'),
      headers: Utility.httpHeaders(prefs),
      body: jsonEncode(<String, String>{
        "credit_score_given_to": otherMemberId,
        "credit_score_given_by": prefs.getString(StorageKeys.MemberId),
        "level": id
      }),
    );
    return jsonDecode(response.body)['status'];
  } on SocketException catch (e) {
    print("SocketException-deleteMember:" + e.toString());
  } on Exception catch (e) {
    print("Exception-API.deleteMember:" + e.toString());
  }
  return false;
}

MyProfile updateCompletionPercentage(MyProfile myProfile) {
  int imagePercentage = 0,
      introPercentage = 0,
      goalsPercentage = 0,
      educationPercentage = 0,
      industryPercentage = 0,
      meetingPercentage = 0,
      socialPercentage = 0;

  if (myProfile.profile.imageUrl != "") {
    imagePercentage = 10;
  } else {
    imagePercentage = 0;
  }

  if (myProfile.profile.introduction != "") {
    introPercentage = 10;
  } else {
    introPercentage = 0;
  }

  if (myProfile.goalList.length != 0) {
    goalsPercentage = 20;
  } else {
    goalsPercentage = 0;
  }

  if (myProfile.education != null) {
    educationPercentage = 20;
  } else {
    educationPercentage = 0;
  }

  if (myProfile.interestedIndustryList.length != 0) {
    industryPercentage = 20;
  } else {
    industryPercentage = 0;
  }

  if (myProfile.meetingPreferenceList.length != 0) {
    meetingPercentage = 10;
  } else {
    meetingPercentage = 0;
  }

  if (myProfile.socialLinks.linkedin.length != 0 ||
      myProfile.socialLinks.website.length != 0 ||
      myProfile.socialLinks.instagram.length != 0 ||
      myProfile.socialLinks.twitter.length != 0 ||
      myProfile.socialLinks.facebook.length != 0) {
    socialPercentage = 10;
  } else {
    socialPercentage = 0;
  }

  myProfile.profilePercentage = imagePercentage + // Personal Information
      introPercentage + // Personal Information
      goalsPercentage + // Goals
      educationPercentage + // Education
      industryPercentage + // Industry
      socialPercentage + // Social Links
      meetingPercentage; // Meeting Preferences

  myProfile.isPersonalInformationCompleted =
      (imagePercentage + introPercentage) == 20;
  myProfile.isGoalsCompleted = goalsPercentage == 20;
  myProfile.isEducationCompleted = educationPercentage == 20;
  myProfile.isIndustryCompleted = industryPercentage == 20;
  myProfile.isMeetingPreferencesCompleted = meetingPercentage == 10;
  myProfile.isSocialLinksCompleted = socialPercentage == 10;

  return myProfile;
}
