import 'package:emajlis/models/member_model.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/home/quick_connect_screen.dart';
import 'package:emajlis/screens/profile/profile_information_screen.dart';
import 'package:emajlis/services/message_api.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/textinput.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class OnlyConnectionsScreen extends StatefulWidget {
  final String memberId;
  final bool isFromMyProfile;
  final List<MemberModel> connectionList;

  const OnlyConnectionsScreen({
    this.memberId,
    this.isFromMyProfile,
    this.connectionList,
  });

  @override
  _OnlyConnectionsState createState() => _OnlyConnectionsState();
}

class _OnlyConnectionsState extends State<OnlyConnectionsScreen> {
  ConnectionProvider pConnection;
  LoaderOverlay overlay;

  List<MemberModel> connectionList = [];
  List<MemberModel> myConnectionList = [];
  String myMemberId = '';
  String messageText = '';

  @override
  void initState() {
    super.initState();
    pConnection = context.read<ConnectionProvider>();
    myMemberId = pConnection.myMemberId;
    myConnectionList = pConnection.friendList;
    connectionList = widget.connectionList;
    Future.delayed(Duration.zero, () {
      loadFriends();
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: simpleAppbar(
        context,
        titleText: "Connections",
      ),
      body: Container(
        child: Column(
          children: [
            if (connectionList.length == 0)
              Padding(
                padding: const EdgeInsets.only(top: 200.0),
                child: Center(
                  child: Text("No networks", style: b_16Black()),
                ),
              )
            else
              Container(
                height: height - height * 0.15,
                width: width,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: ListView.builder(
                  itemCount: connectionList.length,
                  shrinkWrap: true,
                  itemBuilder: (context, i) {
                    return connectionItem(i);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget connectionItem(int index) {
    MemberModel item = connectionList[index];
    bool isConnected = myConnectionList.any((element) => element.id == item.id);

    return Dismissible(
      direction: myMemberId != item.id
          ? DismissDirection.endToStart
          : DismissDirection.none,
      key: UniqueKey(),
      onDismissed: (direction) async {
        await onRemoveFriend(item.id, 0);
      },
      background: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: appRed,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.clear,
          color: appRed,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          if (myMemberId != item.id) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileInformationScreen(
                  memberId: item.id,
                  isFromChatScreen: false,
                ),
              ),
            );
          }
        },
        child: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: appwhite,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            children: [
              if (item.imageUrl != null)
                CircleAvatar(
                  radius: 35,
                  backgroundColor: appBlack,
                  backgroundImage: NetworkImage(
                    item.imageUrl,
                  ),
                )
              else
                CircleAvatar(
                  radius: 35,
                  backgroundColor: appBlack,
                  foregroundColor: appGrey3,
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
                        item.job,
                        style: TextStyle(
                          color: appGrey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (myMemberId != item.id)
                if (isConnected)
                  GestureDetector(
                    onTap: () {
                      onMsgTap(
                        context,
                        item.id,
                        item.firstName,
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/images/icons/msgIcon.svg',
                      height: 20,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () async {
                      final response = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuickConnectScreen(
                            currentProfile: item.imageUrl,
                            currentName: item.firstName,
                            otherMemberId: item.id,
                          ),
                        ),
                      );
                      if (response != null && response) {
                        success(context, "Request Sent");
                      }
                    },
                    child: Container(
                      height: 35,
                      width: 35,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: appBlack,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/icons/thumbs-up.svg',
                        color: appwhite,
                      ),
                    ),
                  ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onRemoveFriend(String friendId, int status) async {
    final isSuccess = await overlay.during(
      pConnection.addRemoveFriend(
        friendId,
        status,
        "",
      ),
    );
    if (isSuccess) {
      if (status == 1) {
        success(context, "Accepted");
      } else {
        success(context, "Deleted");
      }
      //TODO_NIFAL : Need To Remove From The List and Set To Main
    } else {
      somethingWentWrong(context);
    }
  }

  void onMsgTap(context, id, name) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 30.0),
                  child: Text(
                    "Write your message to $name",
                    style: b_14black(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    maxLines: 4,
                    autofocus: true,
                    cursorColor: appBlack,
                    decoration: InputDecoration(
                      border: outlineInputBorder(),
                      focusedBorder: outlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        messageText = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () async {
                    overlay.show();
                    final response = await MessageApi.saveMessage(
                      id,
                      messageText,
                    );
                    overlay.hide();
                    if (response == null || response == false) {
                      somethingWentWrong(context);
                    } else {
                      setState(() {
                        messageText = "";
                      });
                      success(context, "Message sent");
                      FocusScope.of(context).requestFocus(new FocusNode());
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    decoration: BoxDecoration(
                      color: appBlack,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Send',
                      style: b_14white(),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> loadFriends() async {
    final response = await pConnection.getMemberConnections(widget.memberId);
    setState(() {
      connectionList = response;
    });
  }
}
