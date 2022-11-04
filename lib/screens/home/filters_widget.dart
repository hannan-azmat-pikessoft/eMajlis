import 'package:emajlis/models/city_model.dart';
import 'package:emajlis/models/goal_model.dart';
import 'package:emajlis/models/industry_model.dart';
import 'package:emajlis/providers/common_provider.dart';
import 'package:emajlis/services/goals_service.dart';
import 'package:emajlis/services/industy_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class Filters extends StatefulWidget {
  final String emirate;
  final int gender;
  final String industry;
  final String network;
  final double sliderValue;
  Filters(
      {this.emirate,
      this.gender,
      this.industry,
      this.network,
      this.sliderValue});
  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  TextEditingController emirateController = new TextEditingController();
  TextEditingController networkController = new TextEditingController();
  TextEditingController industryController = new TextEditingController();
  SharedPreferences pref;
  LoaderOverlay overlay;
  double height;
  double width;

  List<IndustryModel> industryList = [];
  List<GoalModel> goalList = [];
  List<CityModel> cityList = [];

  String gender = '';
  double _sliderValue;
  int id;
  int index;
  int selectedIndex;

  String emirates = "Select an emirates";
  String network = "Select a network";
  String industry = "Select an industry";

  @override
  void initState() {
    super.initState();
    cityList = context.read<CommonProvider>().cityList;
    emirateController.text = widget.emirate ?? "";
    networkController.text = widget.network ?? "";
    industryController.text = widget.industry ?? "";
    _sliderValue = widget.sliderValue ?? 0;
    id = widget.gender != null ? (widget.gender - 1) : null;
    selectedIndex = widget.gender;
    Future.delayed(Duration.zero, () {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: simpleAppbar(
        context,
        titleText: "Filters",
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          color: appBodyGrey,
          height: height,
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Location',
                  style: b_14black(),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: height / 5,
                  width: width,
                  decoration: BoxDecoration(
                    color: appwhite,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: appwhite),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Around me(${_sliderValue.toInt() ?? ''} km)',
                          style: b_14black(),
                        ),
                        Expanded(
                          child: Slider(
                            value: _sliderValue,
                            activeColor: appBlack,
                            inactiveColor: appGrey4,
                            min: 0,
                            max: 100,
                            label: _sliderValue.toString() ?? '',
                            onChanged: (val) async {
                              setState(() {
                                _sliderValue = val;
                              });
                            },
                          ),
                        ),
                        Text(
                          'Available Emirates',
                          style: b_14black(),
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: () {
                            showAvailableEmirates(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                emirateController.text.length == 0
                                    ? emirates
                                    : emirateController.text,
                                style: TextStyle(color: appGrey5),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: appBlack,
                                  size: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Industries',
                  style: b_14black(),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showAvailableIndusties(context);
                },
                child: Container(
                  height: height / 15,
                  width: width,
                  decoration: BoxDecoration(
                    color: appwhite,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: appwhite),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          industryController.text.length == 0
                              ? industry
                              : industryController.text,
                          style: TextStyle(color: appGrey5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: appBlack,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Networking Objections',
                  style: b_14black(),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showAvailableNetworks(context);
                },
                child: Container(
                  height: height / 15,
                  width: width,
                  decoration: BoxDecoration(
                    color: appwhite,
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    border: Border.all(color: appwhite),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          networkController.text.length == 0
                              ? network
                              : networkController.text,
                          style: TextStyle(color: appGrey5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: appBlack,
                          size: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Gender',
                  style: b_14black(),
                ),
              ),
              Container(
                height: height / 15,
                width: width,
                decoration: BoxDecoration(
                  color: appwhite,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  border: Border.all(color: appwhite),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Radio(
                      value: 0,
                      activeColor: appBlack,
                      groupValue: id,
                      onChanged: (val) async {
                        setState(() {
                          gender = 'Male';
                          id = 0;
                          selectedIndex = 1;
                        });
                      },
                    ),
                    Text(
                      'Male',
                      style: TextStyle(
                        fontSize: 14,
                        color: appGrey4,
                      ),
                    ),
                    Radio(
                      value: 1,
                      activeColor: appBlack,
                      groupValue: id,
                      onChanged: (val) async {
                        setState(() {
                          gender = 'Female';
                          id = 1;
                          selectedIndex = 2;
                        });
                      },
                    ),
                    Text(
                      'Female',
                      style: TextStyle(
                        fontSize: 14,
                        color: appGrey4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        networkController.clear();
                        emirateController.clear();
                        industryController.clear();
                        _sliderValue = 0.0;
                        id = 2;
                        gender = '';
                        int e;
                        selectedIndex = e;
                      });
                    },
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        color: appBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      onApply();
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      decoration: BoxDecoration(
                        color: appBlack,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAvailableEmirates(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titleTextStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: appBlack,
          ),
          title: new Text(
            "Please select emirate of Residence",
            style: b_14black(),
          ),
          content: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return Container(
                height: height * 0.35,
                width: width / 1.1,
                child: ListView.builder(
                  itemCount: cityList.length,
                  itemBuilder: (context, i) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              index = i;
                              emirates = cityList[i].name;
                              emirateController.text = cityList[i].name;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              cityList[i].name,
                              style: TextStyle(
                                color: index == i ? appBlack : appGrey2,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: height / 12,
                    width: width / 3,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: appBlack,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Select',
                      style: b_16white(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: height / 12,
                    width: width / 3,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: appwhite,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Cancel',
                      style: b_16Black(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showAvailableNetworks(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titleTextStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: appBlack,
          ),
          title: new Text(
            "Please select a network",
            style: b_14black(),
          ),
          content: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return Container(
                height: height * 0.35,
                width: width / 1.1,
                child: ListView.builder(
                  itemCount: goalList.length,
                  itemBuilder: (context, i) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              index = i;
                              network = goalList[i].name;
                              networkController.text = goalList[i].name;
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              goalList[i].name,
                              style: TextStyle(
                                color: index == i ? appBlack : appGrey2,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: height / 12,
                    width: width / 3,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: appBlack,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Select',
                      style: b_16white(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: height / 12,
                    width: width / 3,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: appwhite,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Cancel',
                      style: b_16Black(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showAvailableIndusties(BuildContext context) {
    FocusScope.of(context).requestFocus(new FocusNode());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          titleTextStyle: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: appBlack,
          ),
          title: new Text(
            "Please select an Industry",
            style: b_14black(),
          ),
          content: StatefulBuilder(
            builder: (context, StateSetter setState) {
              return Container(
                height: height * 0.35,
                width: width / 1.1,
                child: ListView.builder(
                  itemCount: industryList.length,
                  itemBuilder: (context, i) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              index = i;
                              industry = industryList[i].name;
                              industryController.text = industryList[i].name;
                            });
                            SharedPreferences sharedPreferences =
                                await SharedPreferences.getInstance();
                            sharedPreferences.setString("industry", industry);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              industryList[i].name,
                              style: TextStyle(
                                color: index == i ? appBlack : appGrey2,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: height / 12,
                    width: width / 3,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: appBlack,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Select',
                      style: b_16white(),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: height / 12,
                    width: width / 3,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: appwhite,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text(
                      'Cancel',
                      style: b_16Black(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void onApply() {
    Navigator.pop(context, [
      emirateController.text,
      industryController.text,
      networkController.text,
      _sliderValue,
      selectedIndex
    ]);
  }

  Future<void> loadData() async {
    pref = await SharedPreferences.getInstance();
    overlay = LoaderOverlay.of(context);
    overlay.show();
    await loadIndustries();
    await loadGoals();
    overlay.hide();
  }

  Future<void> loadIndustries() async {
    final response = await getIndustries();
    setState(() {
      industryList = response;
    });
  }

  Future<void> loadGoals() async {
    final response = await getGoals();
    setState(() {
      goalList = response;
    });
  }
}
