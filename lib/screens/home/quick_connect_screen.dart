import 'package:emajlis/models/message_template_model.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/services/message_api.dart';
import 'package:emajlis/utlis/flutter_device_type.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class QuickConnectScreen extends StatefulWidget {
  final String currentProfile;
  final String currentName;
  final String otherMemberId;

  QuickConnectScreen({
    this.currentProfile,
    this.currentName,
    this.otherMemberId,
  });

  @override
  _QuickConnectScreenState createState() => _QuickConnectScreenState();
}

class _QuickConnectScreenState extends State<QuickConnectScreen> {
  ConnectionProvider pConnection;
  SharedPreferences pref;
  LoaderOverlay overlay;
  TextEditingController textController = new TextEditingController();

  // int _current = 0;
  int index;
  List<MessageTemplateModel> templateList = [];
  final ValueNotifier<int> _current = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    pConnection = context.read<ConnectionProvider>();
    textController.text = "";
    Future.delayed(Duration.zero, () {
      loadData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Color(0xff111111),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15, top: 15),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white,
              ),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: size.width * 0.3,
                  width: size.width * 0.3,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(size.width * 0.3 / 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * 0.3 / 2),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      widget.currentProfile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: Device.screenHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: appBodyGrey,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Reach out to ' +
                              '${widget.currentName}' +
                              ' with a purpose',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          'Start your conversation with a right note',
                          style: TextStyle(
                            fontSize: 13,
                            color: appGrey4,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(20),
                        padding: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: appwhite,
                          boxShadow: [
                            BoxShadow(
                              color: appLightGrey.withOpacity(0.5),
                              blurRadius: 10.0, // soften the shadow
                              spreadRadius: 1.0, //extend the shadow
                              offset: Offset(
                                5.0, // Move to right 10  horizontally
                                5.0, // Move to bottom 10 Vertically
                              ),
                            )
                          ],
                        ),
                        child: TextFormField(
                          maxLines: 5,
                          maxLength: 300,
                          controller: textController,
                          decoration: InputDecoration(
                            counterStyle: TextStyle(
                              color: appBlack,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            hintText: 'Enter your message...',
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Quick templates',
                          style: TextStyle(
                            fontSize: 19,
                            color: appBlack,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints(
                          minHeight: 100,
                          maxHeight: 130,
                        ),
                        child: ValueListenableBuilder<int>(
                            valueListenable: _current,
                            builder: (BuildContext context, int value,
                                Widget child) {
                              return PageView(
                                pageSnapping: true,
                                physics: CustomPhysics(),
                                controller: PageController(
                                  initialPage: 0,
                                  viewportFraction: 0.8,
                                ),
                                onPageChanged: (value) {
                                  // setState(() {
                                  Future.delayed(
                                      const Duration(milliseconds: 100), () {
                                    _current.value = value;
                                  });
                                  //});
                                },
                                children: templateList.map(
                                  (item) {
                                    index = templateList.indexOf(item);
                                    return InkWell(
                                      onTap: () {
                                        textController.text = item.name;
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(15),
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 7.0,
                                          vertical: 7,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: (_current.value == index)
                                              ? appBlack
                                              : appwhite,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  appLightGrey.withOpacity(0.2),
                                              blurRadius: 10.0,
                                              // soften the shadow
                                              spreadRadius: 1.0,
                                              //extend the shadow
                                              offset: Offset(
                                                5.0,
                                                // Move to right 10  horizontally
                                                5.0, // Move to bottom 10 Vertically
                                              ),
                                            )
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                              color: (_current.value == index)
                                                  ? appwhite
                                                  : appBlack,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              );
                            }),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          primary: Colors.black,
                          padding: EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 41,
                          ),
                        ),
                        onPressed: () async {
                          if (textController.text.trim() == '') {
                            toastBuild("Please enter the message");
                          } else {
                            final isSuccess = await overlay.during(
                              pConnection.addRemoveFriend(
                                widget.otherMemberId,
                                1,
                                textController.text,
                              ),
                            );
                            if (isSuccess) {
                              Navigator.of(context).pop();
                              success(context, "Requested");
                              // Navigator.
                            } else {
                              somethingWentWrong(context);
                            }
                          }
                        },
                        child: Text(
                          'Send',
                          style: TextStyle(
                            fontSize: 12,
                            color: appwhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 35),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loadData() async {
    pref = await SharedPreferences.getInstance();
    overlay = LoaderOverlay.of(context);
    await loadMessageTemplates();
  }

  Future<void> loadMessageTemplates() async {
    final response = await overlay.during(
      MessageApi.getMessageTemplates(),
    );
    setState(() {
      templateList = response;
    });
  }
}

class CustomPhysics extends ScrollPhysics {
  const CustomPhysics({ScrollPhysics parent}) : super(parent: parent);

  @override
  CustomPhysics applyTo(ScrollPhysics ancestor) {
    return CustomPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 20,
        stiffness: 20,
        damping: 1,
      );
}
