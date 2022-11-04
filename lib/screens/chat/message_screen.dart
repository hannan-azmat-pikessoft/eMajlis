import 'package:emajlis/main.dart';
import 'package:emajlis/models/message_thread_model.dart';
import 'package:emajlis/providers/common_provider.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/chat/chat_screen.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/services/message_api.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class MessageScreen extends StatefulWidget {
  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  LoaderOverlay overlay;
  List<MessageThreadModel> messageThreadList = [];
  int idToRedirect = -1; // FCM-ID

  @override
  void initState() {
    super.initState();
    idToRedirect = context.read<CommonProvider>().idToRedirect;
    context.read<CommonProvider>().setIdToRedirect(-1);
    Future.delayed(Duration.zero, () {
      initialize();
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
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: simpleAppbar(
        context,
        titleText: "Messages",
        isNavBack: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: appBlack,
          onRefresh: onRefresh,
          child: Container(
            alignment: Alignment.topCenter,
            color: context.watch<ConnectionProvider>().friendList.length == 0 ||
                    messageThreadList.length == 0
                ? appBodyGrey
                : appwhite,
            height: size.height,
            // - size.height * 0.23,
            padding: EdgeInsets.only(right: 10),
            child: (messageThreadList.length == 0)
                ? Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No message yet",
                          style: b_16Black(),
                        ),
                      ),
                      addPeopleAndMesages(),
                    ],
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(5),
                    itemCount: messageThreadList.length,
                    itemBuilder: (context, i) => connectionTile(i),
                  ),
          ),
        ),
      ),
    );
  }

  Widget connectionTile(int i) {
    MessageThreadModel message = messageThreadList[i];

    return Dismissible(
      direction: DismissDirection.endToStart,
      key: UniqueKey(),
      //Key('$i'),
      onDismissed: (direction) {
        setState(() {
          deleteMessage(true, message.messageId.toString());
          messageThreadList.remove(i);
          loadMessageThreads(false);
        });
      },
      background: Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: appwhite,
        ),
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
      child: InkWell(
        onTap: () async {
          moveToChat(message);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 7),
          decoration: BoxDecoration(
            color: appwhite,
          ),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: black,
              ),
              child: Image.network(
                message.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(
              message.memberName,
              style: TextStyle(
                color: appBlack,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              message.lastMessage,
              style: TextStyle(
                color: appGrey,
                fontSize: 12,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeago.format(message.lastMessageDate),
                  //  lastMessageDate(message.lastMessageDate),
                  style: n_9grey(),
                ),
                if (message.unseenMessages < 1)
                  Container(
                    width: 15,
                  )
                else
                  Container(
                    width: 15,
                    height: 15,
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: black,
                    ),
                    child: Center(
                      child: Text(
                        message.unseenMessages.toString(),
                        style: TextStyle(
                          color: appwhite,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addPeopleAndMesages() {
    if (context.watch<ConnectionProvider>().friendList.length == 0) {
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
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 50),
        child: InkWell(
          onTap: () {
            goToConnectionsScreen();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: appwhite,
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "Start a conversation",
              style: b_14black(),
            ),
          ),
        ),
      );
    }
  }

  Future<void> initialize() async {
    overlay = LoaderOverlay.of(context);
    final xMessageList = MyApp.getMessageThreads(context);
    if (xMessageList != null) {
      setState(() {
        messageThreadList = xMessageList;
      });
      if (idToRedirect > 0 &&
          messageThreadList.any((e) => e.otherMemberId == idToRedirect)) {
        final item = messageThreadList
            .firstWhere((e) => e.otherMemberId == idToRedirect);
        moveToChat(item);
      } else {
        loadMessageThreads(false);
      }
    } else {
      loadMessageThreads(true);
    }
  }

  Future<void> loadMessageThreads(bool showLoader) async {
    if (showLoader) {
      overlay.show();
    }
    final response = await MessageApi.getMessageThreads();
    setState(() {
      messageThreadList = response;
      MyApp.setMessageThreads(context, messageThreadList);
    });
    if (idToRedirect > 0) {
      if (messageThreadList.any((e) => e.otherMemberId == idToRedirect)) {
        final item = messageThreadList
            .firstWhere((e) => e.otherMemberId == idToRedirect);
        moveToChat(item);
      }
    }
    if (showLoader) {
      overlay.hide();
    }
  }

  Future<void> onRefresh() async {
    loadMessageThreads(true);
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

  void goToConnectionsScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          screenIndex: 2,
          id: -1,
        ),
      ),
      (route) => false,
    );
  }

  String lastMessageDate(DateTime lastMessageDate) {
    final timeFormat = new DateFormat('hh:mm a');
    final dayFormat = new DateFormat('EEEE');
    final dateFormat = new DateFormat('dd-MM-yyyy');
    final DateTime now = DateTime.now();
    final int hours = now.difference(lastMessageDate).inHours;
    if (hours < 24) {
      return timeFormat.format(lastMessageDate);
    } else if (hours < 48) {
      return 'yesterday';
    } else if (hours < 144) {
      return dayFormat.format(lastMessageDate);
    } else {
      return dateFormat.format(lastMessageDate);
    }
  }

  Future<void> moveToChat(MessageThreadModel message) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          message: message,
        ),
      ),
    );
    if (result == null) {
      loadMessageThreads(false);
    }
  }

  Future<void> deleteMessage(bool showLoader, String messageId) async {
    if (showLoader) {
      overlay.show();
    }
    final response = await MessageApi.deleteMessage(messageId);
    setState(() {
      //messageThreadList = response;
      // MyApp.setMessageThreads(context, messageThreadList);
    });
    if (showLoader) {
      overlay.hide();
    }
  }
}
