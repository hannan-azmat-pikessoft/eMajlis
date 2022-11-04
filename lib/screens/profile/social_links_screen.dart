import 'package:emajlis/models/social_links_model.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/textinput.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SocialLinksScreen extends StatefulWidget {
  final SocialLinksModel socialLinks;
  SocialLinksScreen({this.socialLinks});
  @override
  _SocialLinksScreenState createState() => _SocialLinksScreenState();
}

class _SocialLinksScreenState extends State<SocialLinksScreen> {
  TextEditingController facebookC = TextEditingController();
  TextEditingController instagramC = TextEditingController();
  TextEditingController linkedinC = TextEditingController();
  TextEditingController twitterC = TextEditingController();
  TextEditingController websiteC = TextEditingController();

  @override
  void initState() {
    super.initState();
    linkedinC.text = widget.socialLinks.linkedin;
    twitterC.text = widget.socialLinks.twitter;
    instagramC.text = widget.socialLinks.instagram;
    websiteC.text = widget.socialLinks.website;
    facebookC.text = widget.socialLinks.facebook;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBodyGrey,
      appBar: simpleAppbar(
        context,
        titleText: "Website Link",
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: appwhite,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // fieldName("Facebook"),
              // TextFormField(
              //   style: TextStyle(color: appGrey2),
              //   cursorColor: appGrey2,
              //   textInputAction: TextInputAction.done,
              //   controller: facebookC,
              //   keyboardType: TextInputType.text,
              //   decoration: inputDecoration2(
              //     hintText: 'Enter facebook Ex: @username',
              //   ),
              //   validator: (value) {
              //     if (value.trim().isEmpty) {
              //       return "Enter facebook user name";
              //     } else if ((value.length <= 1)) {
              //       return "Enter complete facebook url";
              //     } else {
              //       return null;
              //     }
              //   },
              // ),
              // fieldName("Instagram"),
              // TextFormField(
              //   style: TextStyle(color: appGrey2),
              //   cursorColor: appGrey2,
              //   textInputAction: TextInputAction.done,
              //   controller: instagramC,
              //   keyboardType: TextInputType.text,
              //   decoration: inputDecoration2(
              //     hintText: 'Enter instagram Ex: @username',
              //   ),
              // ),
              // fieldName("Linkedin"),
              // TextFormField(
              //   style: TextStyle(color: appGrey2),
              //   cursorColor: appGrey2,
              //   textInputAction: TextInputAction.done,
              //   controller: linkedinC,
              //   keyboardType: TextInputType.text,
              //   decoration: inputDecoration2(
              //     hintText: 'Enter Linked in Ex: user-name',
              //   ),
              // ),
              // fieldName("Twitter"),
              // TextFormField(
              //   style: TextStyle(color: appGrey2),
              //   cursorColor: appGrey2,
              //   textInputAction: TextInputAction.done,
              //   controller: twitterC,
              //   keyboardType: TextInputType.text,
              //   decoration: inputDecoration2(
              //     hintText: 'Enter Twitter User Name eg:@username',
              //   ),
              // ),
              fieldName("Website"),
              TextFormField(
                style: TextStyle(color: appGrey2),
                cursorColor: appGrey2,
                textInputAction: TextInputAction.done,
                controller: websiteC,
                keyboardType: TextInputType.text,
                decoration: inputDecoration2(
                  hintText: 'Enter Site Domain eg:www.example.com',
                ),
              ),
              InkWell(
                onTap: () {
                  onSave();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 30),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: appBlack,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: double.infinity,
                  height: 60,
                  child: Text(
                    "Save",
                    style: b_14white(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding fieldName(String name) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(name, style: b_14black()),
    );
  }

  Future<void> onSave() async {
    SocialLinksModel request = new SocialLinksModel();
    request.linkedin = linkedinC.text;
    request.twitter = twitterC.text;
    request.instagram = instagramC.text;
    request.website = websiteC.text;
    request.facebook = facebookC.text;
    final overlay = LoaderOverlay.of(context);
    final isSuccess = await overlay.during(
      saveSocialLinks(request),
    );
    if (isSuccess) {
      Navigator.pop(context, request);
    } else {
      toastBuild("Somthing went wrong");
    }
  }
}
