class ProfileModel {
  String id;
  String firstname;
  String email;
  int genderId;
  String imageUrl;
  String profession;
  String city;
  String country;
  String profileStatus;
  String currentOrganization;
  String introduction;
  String phoneNumber;
  String svc;
  String dialcode;
  int isRequestSent;
  bool isSaved;
  bool isBlocked;

  ProfileModel({
    this.id,
    this.firstname,
    this.profileStatus,
    this.email,
    this.genderId,
    this.imageUrl,
    this.city,
    this.svc,
    this.country,
    this.profession,
    this.currentOrganization,
    this.introduction,
    this.phoneNumber,
    this.dialcode,
    this.isRequestSent,
    this.isSaved,
    this.isBlocked,
  });
}
