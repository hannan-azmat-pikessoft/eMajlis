import 'package:emajlis/models/profile_model.dart';
import 'package:emajlis/screens/profile/profile_information_screen.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SavedProfileScreen extends StatefulWidget {
  @override
  _SavedProfileScreenState createState() => _SavedProfileScreenState();
}

class _SavedProfileScreenState extends State<SavedProfileScreen> {
  LoaderOverlay overlay;
  double height;
  double width;

  List<ProfileModel> items = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadData();
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    this.height = MediaQuery.of(context).size.height;
    this.width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: simpleAppbar(context, titleText: "Saved"),
      body: Container(
        child: Column(
          children: [
            if (items.length == 0)
              Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Center(
                  child: Text("No profiles saved", style: b_16Black()),
                ),
              )
            else
              Container(
                // height: height - height * 0.15,
                width: width,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: ListView.builder(
                  itemCount: items.length,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return userItem(i);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget userItem(int index) {
    ProfileModel item = items[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileInformationScreen(
              memberId: item.id,
              isFromChatScreen: false,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: appwhite,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 35,
              backgroundColor: appBlack,
              backgroundImage: NetworkImage(item.imageUrl),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.firstname,
                      style: TextStyle(
                        color: appBlack,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      item.profession,
                      style: TextStyle(
                        color: appGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final response = await overlay.during(
                  removeSavedProfileForLater(item.id),
                );
                success(context, response.message);
                if (response.status) {
                  setState(() {
                    items.removeWhere((element) => element.id == item.id);
                  });
                }
              },
              child: Icon(
                Icons.remove_circle_outline,
                color: appBlack,
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Future<void> loadData() async {
    overlay = LoaderOverlay.of(context);
    final response = await overlay.during(
      getSavedProfileForLater(),
    );
    setState(() {
      items = response;
    });
  }
}
