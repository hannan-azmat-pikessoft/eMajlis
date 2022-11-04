import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/member_model.dart';
import 'package:emajlis/providers/common_provider.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/screens/profile/profile_information_screen.dart';
import 'package:emajlis/services/message_api.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/textinput.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:provider/provider.dart';

class ConnectionsScreen extends StatefulWidget {
  ConnectionsScreen({
    Key key,
  });

  @override
  _ConnectionsScreenState createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen>
    with SingleTickerProviderStateMixin {
  ConnectionProvider pConnection;
  LoaderOverlay overlay;
  double height = 0;
  double width = 0;

  List<MemberModel> filteredNames = []; // names filtered by search text
  List<MemberModel>filteredMyNetworkNames = [];
  TextEditingController networkNameSearchController;
  Icon _networkNameSearchIcon = new Icon(Icons.search);

  TabController _tabController;
  int tabIndex = 0;
  Icon _searchIcon = new Icon(Icons.search);
  TextEditingController searchController;
  String messageText = '';

  @override
  void initState() {
    super.initState();
    final idToRedirect = context.read<CommonProvider>().idToRedirect;
    context.read<CommonProvider>().setIdToRedirect(-1);
    if (idToRedirect > -1) {
      tabIndex = idToRedirect;
    }
    pConnection = context.read<ConnectionProvider>();
    pConnection.loadConnections();
    searchController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(Duration.zero, () {
      initialize();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    searchController.dispose();
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
      appBar: simpleAppbar(
        context,
        titleText: "My Connections",
        isNavBack: false,
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: Container(
          height: height,
          color: appBodyGrey,
          width: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                FlutterToggleTab(
                  isShadowEnable: false,
                  selectedIndex: tabIndex,
                  width: 62,
                  borderRadius: 30,
                  height: 35,
                  selectedBackgroundColors: [appBlack],
                  unSelectedBackgroundColors: [Colors.white],
                  selectedTextStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unSelectedTextStyle: TextStyle(
                    color: appLightGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  initialIndex: tabIndex,
                  labels: ["My Network", "Invitations"],
                  selectedLabelIndex: (index) {
                    setState(() {
                      tabIndex = index;
                    });
                  },
                ),
                IndexedStack(
                  sizing: StackFit.expand,
                  index: tabIndex,
                  children: [
                    connectionsSection(),
                    invitationsSection(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget invitationsSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: width,
      child: Column(
        children: [
          SizedBox(height: 20),
          if (context.watch<ConnectionProvider>().invitationList.length != 0)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextFormField(
                onTap: () {
                  _searchPressed();
                },
                controller: searchController,
                maxLength: 30,
                onChanged: (value) => _buildList(value),
                style: TextStyle(
                  color: appGrey,
                ),
                cursorColor: appGrey2,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  prefixIcon: IconButton(
                    icon: _searchIcon,
                    onPressed: _searchPressed,
                    color: appBlack,
                  ),
                  counterText: '',
                  hintText: 'Search a connection',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: appLightGrey,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          SizedBox(height: 20),
          if (context.watch<ConnectionProvider>().invitationList.length != 0)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'New Invitations',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (filteredNames.length != 0 || searchController.text.isNotEmpty)
            ListView.separated(
              separatorBuilder: (context, index) {
                return Divider();
              },
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: filteredNames.length,
              itemBuilder: (BuildContext context, int index) {
                return new GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileInformationScreen(
                          isFromChatScreen: false,
                          memberId: filteredNames[index].id,
                        ),
                      ),
                    );
                  },
                  child: new Container(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: appBlack,
                          backgroundImage: NetworkImage(
                            filteredNames[index].imageUrl ?? Common.NoImage150,
                          ),
                        ),
                        SizedBox(width: 15),
                        Text(filteredNames[index].firstName ?? ''),
                      ],
                    ),
                  ),
                );
              },
            )
          else if (context.watch<ConnectionProvider>().invitationList.length ==
              0)
            if (context.watch<ConnectionProvider>().friendList.length == 0)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: Text(
                      "No invitations",
                      style: b_16Black(),
                    ),
                  ),
                  SizedBox(height: 50),
                  InkWell(
                    onTap: () {
                      goToDashboardScreen();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: appwhite,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Text(
                        "+ Add people to your network",
                        style: b_14black(),
                      ),
                    ),
                  ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.all(100),
                child: Text(
                  "No invitations",
                  style: b_16Black(),
                ),
              )
          else
            Consumer<ConnectionProvider>(
              builder: (context, pConnection, child) {
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount:
                      context.watch<ConnectionProvider>().invitationList.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return invitationItem(
                      pConnection.invitationList[i],
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget invitationItem(MemberModel item) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: UniqueKey(),
      onDismissed: (direction) async {
        await onRemoveInvitation(item, 0);
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
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: appwhite,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: appBlack,
                  backgroundImage: NetworkImage(
                    item.imageUrl ?? Common.NoImage150,
                  ),
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
                GestureDetector(
                  onTap: () async {
                    await onRemoveInvitation(item, 0);
                  },
                  child: Container(
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
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    await onRemoveInvitation(item, 1);
                  },
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: appBlack,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: appBlack,
                        width: 2,
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/images/icons/like.svg',
                      color: Colors.white,
                      height: 15,
                    ),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        item.message,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        style: TextStyle(color: appBlack),
                                        children: [
                                          TextSpan(
                                            text: 'Do you want to add ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.normal,
                                              fontSize: 16,
                                            ),
                                          ),
                                          TextSpan(
                                            text: item.firstName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' to your profile ?',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: width / 25),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      await onRemoveInvitation(item, 1);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 120,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: appBlack,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        'Accept',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await onRemoveInvitation(item, 0);
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 120,
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: appBlack),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        'Cancel',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: appBlack,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  height: 25,
                  width: width,
                  decoration: BoxDecoration(
                    color: appBodyGrey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      item.message,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget connectionsSection() {
    if (context.watch<ConnectionProvider>().friendList.length == 0) {
      return addPeople();
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Container(
          width: width,
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          child: Consumer<ConnectionProvider>(
            builder: (context, pConnection, child) {
              return ListView.builder(
                itemCount:
                    context.watch<ConnectionProvider>().friendList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  return connectionItem(pConnection.friendList[i]);
                },
              );
            },
          ),
        ),
      );
    }
  }

  Widget addPeople() {
    return Padding(
      padding: const EdgeInsets.only(top: 50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Step out, start networking',
              style: TextStyle(
                color: appBlack,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            SvgPicture.asset('assets/images/graphics/addConnection.svg'),
            SizedBox(height: 40),
            InkWell(
              onTap: () {
                goToDashboardScreen();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: appwhite,
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "+ Add people to your network",
                  style: b_14black(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget connectionItem(MemberModel item) {
    return Dismissible(
      direction: DismissDirection.endToStart,
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
              GestureDetector(
                onTap: () {
                  onComposeMessage(
                    context,
                    item.id,
                    item.firstName,
                  );
                },
                child: SvgPicture.asset(
                  'assets/images/icons/msgIcon.svg',
                  height: 20,
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
      } else {
        this._searchIcon = new Icon(Icons.search);
        filteredNames.clear();
        searchController.clear();
      }
    });
  }
  void _networkSearchPressed() {
    setState(() {
      if (this._networkNameSearchIcon.icon == Icons.search) {
        this._networkNameSearchIcon = new Icon(Icons.close);
      } else {
        this._networkNameSearchIcon = new Icon(Icons.search);
        filteredNames.clear();
        searchController.clear();
      }
    });
  }
  void _buildList(String val) {
    filteredNames.clear();
    setState(() {});
    if (val.isNotEmpty) {
      setState(() {});
      for (int i = 0;
          i < context.read<ConnectionProvider>().invitationList.length;
          i++) {
        if ((context.read<ConnectionProvider>().invitationList[i].firstName ??
                "")
            .toLowerCase()
            .contains(val.toLowerCase())) {
          filteredNames
              .add(context.read<ConnectionProvider>().invitationList[i]);
        }
        setState(() {});
      }
    }
  }

  Future<void> initialize() async {
    overlay = LoaderOverlay.of(context);
  }

  Future<void> onRefresh() async {
    overlay.show();
    await pConnection.loadConnections();
    overlay.hide();
  }

  Future<void> onRemoveInvitation(MemberModel item, int status) async {
    final isSuccess = await overlay.during(
      pConnection.addRemoveInvitation(
        item.id,
        status,
      ),
    );
    if (isSuccess) {
      pConnection.removeInvitation(item.id); // To Remove Invitation From List
      if (status == 1) {
        setState(() {
          MemberModel friendModel = new MemberModel();
          friendModel.id = item.id;
          friendModel.firstName = item.firstName;
          friendModel.lastName = item.lastName;
          friendModel.imageUrl = item.imageUrl;
          friendModel.job = item.job;
          pConnection.addFriend(friendModel); // Add The New Friend To The List
        });
        success(context, "Invitation Accepted");
      } else {
        success(context, "Invitation Declined");
      }
    } else {
      somethingWentWrong(context);
    }
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
      await pConnection.loadConnections();
    } else {
      somethingWentWrong(context);
    }
  }

  Future<void> onComposeMessage(context, id, name) async {
    final isSent = await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
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
                      toastBuild('Something went wrong');
                    } else {
                      setState(() {
                        messageText = "";
                      });
                      FocusScope.of(context).requestFocus(new FocusNode());
                      Navigator.pop(context, true);
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
    if (isSent != null && isSent) {
      success(context, "Message sent");
    }
  }

  void goToDashboardScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          screenIndex: 0,
          id: -1,
        ),
      ),
      (route) => false,
    );
  }
}
