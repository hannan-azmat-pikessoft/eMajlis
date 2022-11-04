import 'package:emajlis/models/member_model.dart';
import 'package:emajlis/services/profile_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:flutter/cupertino.dart';

class BlockedUsersScreen extends StatefulWidget {
  @override
  _BlockedUsersScreenState createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  LoaderOverlay overlay;
  double height;
  double width;

  List<MemberModel> blockUserList = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    this.height = MediaQuery.of(context).size.height;
    this.width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: simpleAppbar(context, titleText: "Blocked Users"),
      body: Container(
        child: Column(
          children: [
            if (blockUserList.length == 0)
              Padding(
                padding: const EdgeInsets.only(top: 200.0),
                child: Center(
                  child: Text("No Blocked Users", style: b_16Black()),
                ),
              )
            else
              Container(
                height: height - height * 0.15,
                width: width,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: ListView.builder(
                  itemCount: blockUserList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return userItem(index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget userItem(int index) {
    MemberModel item = blockUserList[index];

    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: appwhite,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
                      item.firstName,
                      style: TextStyle(
                        color: appBlack,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "city",
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
                overlay.show();
                final isSuccess = await blockUnblockMember(item.id, 1);
                overlay.hide();
                if (isSuccess) {
                  toastBuild("Profile Unblocked.");
                  setState(() {
                    blockUserList.removeWhere((e) => e.id == item.id);
                  });
                } else {
                  somethingWentWrong(context);
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
    overlay.show();
    final response = await getBlockedMembers();
    overlay.hide();
    setState(() {
      blockUserList = response;
    });
  }
}
