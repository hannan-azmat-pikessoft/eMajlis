import 'package:emajlis/screens/profile/faq_screen.dart';
import 'package:emajlis/utlis/flutter_device_type.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RaiseAnIssueScreen extends StatefulWidget {
  @override
  _RaiseAnIssueScreenState createState() => _RaiseAnIssueScreenState();
}

class _RaiseAnIssueScreenState extends State<RaiseAnIssueScreen> {
  SharedPreferences pref;
  LoaderOverlay overlay;
  double height;
  double width;

  final List<String> _dropdownValues = [
    "General",
    "App related",
    "Member related",
  ];

  final _bodyController = TextEditingController();
  String selectedValue = "General";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: simpleAppbar(context, titleText: "Raise an issue"),
      backgroundColor: appBodyGrey,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  openHelpBottomModal(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: appwhite,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text(
                          'Get Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'An eMajlis agent will reach you within 2 days',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          bottom: 10,
                          right: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FAQScreen(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: appwhite,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text(
                          'FAQ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'FAQ section is to get answers to some common queries',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          bottom: 10,
                          right: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                decoration: BoxDecoration(
                  color: appwhite,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: const Text(
                        'Customer Care',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 17, right: 17, bottom: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'support@emajlis.ae',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.6)),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                'feedback@emajlis.ae',
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.6)),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> openHelpBottomModal(context) {
    return showModalBottomSheet(
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
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: width,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: appBlack,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: width * 0.4),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(""),
                    SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                          color: appBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10, right: 10),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: appGrey2, width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: appBlack, width: 1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      filled: true,
                      fillColor: appwhite,
                    ),
                    value: selectedValue,
                    onChanged: (String newValue) {
                      setState(() {
                        selectedValue = newValue;
                      });
                    },
                    items: _dropdownValues.map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10, right: 10),
                  child: TextFormField(
                    controller: _bodyController,
                    minLines: 6,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    autofocus: false,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: appGrey2, width: 1),
                      ),
                      hintText: 'Describe the problem',
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                            left: 10, bottom: 10, right: 10, top: 20),
                        child: GestureDetector(
                          onTap: () {
                            send();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                            decoration: BoxDecoration(
                              color: appBlack,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                color: appwhite,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (Device.get().hasNotch) ...[
                  SizedBox(
                    height: 20,
                  )
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> send() async {
    final Email email = Email(
      body: _bodyController.text,
      subject: selectedValue,
      recipients: ['info@emajlis.com'],
    );
    try {
      await FlutterEmailSender.send(email);
      success(context, 'Help Message Sent Succesfully!');
    } catch (error) {
      print(error.toString());
    }
  }
}
