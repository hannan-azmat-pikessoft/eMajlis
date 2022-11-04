import 'package:emajlis/models/education_model.dart';
import 'package:emajlis/models/goal_model.dart';
import 'package:emajlis/models/industry_model.dart';
import 'package:emajlis/models/meeting_preference_model.dart';
import 'package:emajlis/models/profile_model.dart';
import 'package:emajlis/models/social_links_model.dart';
import 'organization_model.dart';

class MyProfile {
  ProfileModel profile;
  SocialLinksModel socialLinks;
  List<GoalModel> goalList = [];
  List<IndustryModel> interestedIndustryList = [];
  List<MeetingPreferenceModel> meetingPreferenceList = [];
  List<OrganizationModel> organizationList = [];
  EducationModel education;
  IndustryModel workIndustry;
  int profilePercentage;
  bool isPersonalInformationCompleted;
  bool isGoalsCompleted;
  bool isEducationCompleted;
  bool isIndustryCompleted;
  bool isMeetingPreferencesCompleted;
  bool isSocialLinksCompleted;
}
