// import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
// import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/industry_model.dart';
import 'package:emajlis/models/member_model.dart';
import 'package:emajlis/screens/home/filters_widget.dart';
import 'package:emajlis/screens/home/quick_connect_screen.dart';
import 'package:emajlis/screens/profile/profile_information_screen.dart';
import 'package:emajlis/services/general_service.dart';
import 'package:emajlis/services/industy_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/progress.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/svg.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  double height;
  double width;

  List<MemberModel> memberList = [];
  TextEditingController searchController;
  bool tapped = false;
  Icon _searchIcon = new Icon(Icons.search, color: appBlack);
  bool isInitialSearchProgressing = true;
  bool isSearchInProgress = false;
  String textToSearch = '';

  double sliderValue;
  int genderInNumber; //1 as Male and 2 as Female

  String emirates;
  String network;
  String industry;

  int selectedIndustryId;
  String selectedIndustryName;
  List<IndustryModel> industryList = [];
  LoaderOverlay overlay;
  bool isInitialSearchProgressingForIndustry = true;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    Future.delayed(Duration.zero, () {
      loadDatas();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> onSearchTextChanged(String text) async {
    if (text != '') {
      if (isSearchInProgress) {
        textToSearch = text;
      } else {
        if (text != '') {
          if (selectedIndustryId != null) {
            oneSelectIndustry();
          } else {
            isSearchInProgress = true;
            final response = await searchPeoples(
              searchText: text,
              emirate: emirates,
              industry: industry,
              network: network,
              gender: genderInNumber,
              sliderValue: sliderValue.toString(),
            );
            isSearchInProgress = false;
            if (searchController.text.trim() != '') {
              setState(() {
                memberList = response;
                if (memberList.length > 0) {
                  isInitialSearchProgressing = false;
                }
                checkForPregession();
              });
            } else {
              setState(() {
                memberList = [];
              });
            }
          }
        }
      }
    } else {
      setState(() {
        memberList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    this.height = MediaQuery.of(context).size.height;
    this.width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 00),
            color: appBodyGrey,
            width: width,
            child: Column(
              children: [
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: appwhite,
                          borderRadius: BorderRadius.all(Radius.circular(28.0)),
                          border: Border.all(color: appwhite),
                        ),
                        child: new TextField(
                          textAlignVertical: TextAlignVertical.center,
                          controller: searchController,
                          onChanged: onSearchTextChanged,
                          onTap: () {
                            onSearchPressed();
                          },
                          cursorColor: appBlack,
                          style: TextStyle(fontSize: 12),
                          decoration: InputDecoration(
                            prefixIcon: _searchIcon,
                            hintText: 'Phone, email or username',
                            focusColor: Colors.pink,
                            hoverColor: Colors.red,
                            hintStyle: TextStyle(fontSize: 12),
                            fillColor: Colors.amber,
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CircleAvatar(
                        backgroundColor: appBlack,
                        radius: 19,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Filters(
                                  emirate: emirates,
                                  network: network,
                                  industry: industry,
                                  sliderValue: sliderValue,
                                  gender: genderInNumber,
                                ),
                              ),
                            ).then((value) {
                              if (value != null) {
                                List<dynamic> filterdata = value;
                                setState(() {
                                  emirates = filterdata[0];
                                  industry = filterdata[1];
                                  network = filterdata[2];
                                  sliderValue = filterdata[3];
                                  genderInNumber = filterdata[4];
                                });
                              } else {
                                print("no filter");
                              }
                            });
                          },
                          icon: Center(
                            child: Icon(
                              Icons.filter_list_outlined,
                              color: appwhite,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      width: double.infinity,
                      height: 65.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: industryList.length,
                        itemBuilder: (context, i) {
                          return ChipsChoice.single(
                            padding: EdgeInsets.only(left: 0),
                            value: selectedIndustryId,
                            onChanged: (val) {
                              setState(() {
                                if (val != selectedIndustryId) {
                                  selectedIndustryId = val;
                                  int iName =
                                      industryList.indexWhere((e) => e.id == val);
                                  selectedIndustryName = industryList[iName].name;
                                } else {
                                  selectedIndustryId = null;
                                }
                              });
                              oneSelectIndustry();
                            },
                            choiceItems: C2Choice.listFrom(
                              source: industryList,
                              value: (i, v) {
                                return industryList[i].id;
                              },
                              label: (i, v) => industryList[i].name,
                            ),
                            wrapped: true,
                            choiceStyle: C2ChoiceStyle(
                              borderColor: Colors.grey[300],
                              color: appwhite,
                              labelStyle: TextStyle(
                                color: appGrey6,
                              ),
                              brightness: Brightness.dark,
                              showCheckmark: false,
                            ),
                            choiceActiveStyle: C2ChoiceStyle(
                              color: appGrey6,
                              labelStyle: TextStyle(
                                color: appwhite,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (tapped)
                      searchScreen()
                    else
                      Container(
                        height: height - (height / 13) - 60,
                        width: width,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 100,
                              width: 100,
                              child: Center(
                                child: Image.asset(Common.SearchPng),
                              ),
                            ),
                            Text(
                              "Find your connections",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget searchScreen() {
    return Container(
      margin: EdgeInsets.only(top: 70),
      height: height - (height / 13) - 60,
      width: width,
      child: memberList.length == 0
          ? Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: [
                  Container(
                    child: Text("No search result"),
                  ),
                ],
              ),
            )
          : isInitialSearchProgressing
              ? circularProgress()
              : selectedIndustryId == null
                  ? ListView.separated(
                      padding: EdgeInsets.only(top: 0, bottom: 60),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileInformationScreen(
                                  memberId: memberList[index].id,
                                  isFromChatScreen: false,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: appBlack,
                                      backgroundImage: NetworkImage(
                                        memberList[index].imageUrl,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        memberList[index].firstName,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Padding(padding: EdgeInsets.only(bottom: 25));
                      },
                      itemCount: memberList.length,
                      shrinkWrap: true,
                    )
                  : ListView.separated(
                      padding: EdgeInsets.only(top: 0),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileInformationScreen(
                                  memberId: memberList[index].id,
                                  isFromChatScreen: false,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.only(
                              left: 15,
                              right: 15,
                              top: 10,
                              bottom: 10,
                            ),
                            // margin: EdgeInsets.symmetric(
                            //     horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                              color: appwhite,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundColor: appBlack,
                                        backgroundImage: NetworkImage(
                                          memberList[index].imageUrl,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                memberList[index].firstName,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              Text(
                                                memberList[index].job,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                style: TextStyle(
                                                  color: appGrey,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final response = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            QuickConnectScreen(
                                                currentName:
                                                    memberList[index].firstName,
                                                currentProfile:
                                                    memberList[index].imageUrl,
                                                otherMemberId:
                                                    memberList[index].id),
                                      ),
                                    );
                                    if (response != null && response) {
                                      success(context, "Request Sent");
                                    }
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
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Padding(padding: EdgeInsets.only(bottom: 10));
                      },
                      itemCount: memberList.length,
                      shrinkWrap: true,
                    ),
    );
  }

  void onSearchPressed() {
    setState(() {
      tapped = true;
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close, color: appBlack);
      } else {
        this._searchIcon = new Icon(Icons.search, color: appBlack);
        searchController.clear();
        memberList.clear();
      }
    });
  }

  Future<void> checkForPregession() async {
    if (textToSearch != '') {
      final text = textToSearch;
      textToSearch = '';
      await onSearchTextChanged(text);
    } else if (searchController.text.trim() == '') {
      setState(() {
        memberList = [];
      });
    }
  }

  Future<void> loadDatas() async {
    overlay = LoaderOverlay.of(context);

    overlay.show();
    await loadIndustries();
    overlay.hide();
  }

  Future<void> loadIndustries() async {
    final response = await getIndustries();
    setState(() {
      industryList = response;
    });
  }

  Future<void> oneSelectIndustry() async {
    print(selectedIndustryId);
    memberList = [];
    isSearchInProgress = true;
    final response = await searchPeoplesByIndustry(
        selectedIndustryId, searchController.text);
    memberList = response;
    isSearchInProgress = false;
    for (var i = 0; i < memberList.length; i++) {
      print(memberList[i].job);
    }
    if (response != null) {
      setState(() {
        memberList = response;
        if (memberList.length > 0) {
          isInitialSearchProgressing = false;
        }
        checkForPregession();
      });
    } else {
      setState(() {
        memberList = [];
      });
    }
  }
}
