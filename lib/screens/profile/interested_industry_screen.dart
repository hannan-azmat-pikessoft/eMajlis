import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/industry_model.dart';
import 'package:emajlis/services/industy_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class InterestedIndustryScreen extends StatefulWidget {
  final List<IndustryModel> myIndustryList;
  InterestedIndustryScreen({this.myIndustryList});

  @override
  _InterestedIndustryScreenState createState() =>
      _InterestedIndustryScreenState();
}

class _InterestedIndustryScreenState extends State<InterestedIndustryScreen> {
  TextEditingController searchController = TextEditingController();
  List<IndustryModel> industryList = [];
  List<IndustryModel> filteredIndustryList = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: appBodyGrey,
      appBar: simpleAppbar(context, titleText: "Select Preferred Industry"),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
          padding: EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: appwhite,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SvgPicture.asset(Common.IndustrySvg),
              ),
              Text("Select Industry", style: b_14black()),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Select your industry", style: n_14grey()),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300],
                      blurRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextFormField(
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  controller: searchController,
                  onChanged: onSearchTextChanged,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: appBlack,
                    ),
                    fillColor: appwhite,
                    filled: true,
                    hintText: "Search Industry",
                    border: searchborder(),
                    focusedBorder: searchborder(),
                    errorBorder: searchborder(),
                    enabledBorder: searchborder(),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 15),
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  industryList
                              .where((element) => element.isSelected)
                              .toList()
                              .length !=
                          0
                      ? industryList
                              .where((element) => element.isSelected)
                              .toList()
                              .length
                              .toString() +
                          " out of 4 max"
                      : "No Industry Selected",
                  style: b_14black(),
                ),
              ),
              Container(
                width: double.infinity,
                height: h * 0.4,
                child: filteredIndustryList.length != 0 ||
                        searchController.text.isNotEmpty
                    ? Container(
                        child: ListView.builder(
                          itemCount: filteredIndustryList.length,
                          itemBuilder: (context, i) {
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                filteredIndustryList[i].name,
                                style: b_14black(),
                              ),
                              value: filteredIndustryList[i].isSelected,
                              checkColor: appBlack,
                              activeColor: appwhite,
                              selectedTileColor: appBlack,
                              onChanged: (bool val) {
                                if (filteredIndustryList[i].isSelected) {
                                  setState(() {
                                    filteredIndustryList[i].isSelected = false;
                                  });
                                } else {
                                  if (filteredIndustryList
                                          .where(
                                              (element) => element.isSelected)
                                          .toList()
                                          .length <
                                      4) {
                                    setState(() {
                                      filteredIndustryList[i].isSelected = true;
                                    });
                                  }
                                }
                              },
                            );
                          },
                        ),
                      )
                    : Container(
                        child: ListView.builder(
                          itemCount: industryList.length,
                          itemBuilder: (context, i) {
                            return CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text(
                                industryList[i].name,
                                style: b_14black(),
                              ),
                              value: industryList[i].isSelected,
                              checkColor: appBlack,
                              activeColor: appwhite,
                              selectedTileColor: appBlack,
                              onChanged: (bool val) {
                                if (industryList[i].isSelected) {
                                  setState(() {
                                    industryList[i].isSelected = false;
                                  });
                                } else {
                                  if (industryList
                                          .where(
                                              (element) => element.isSelected)
                                          .toList()
                                          .length <
                                      4) {
                                    setState(() {
                                      industryList[i].isSelected = true;
                                    });
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
              ),
              InkWell(
                onTap: () {
                  onSave();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: appBlack,
                    borderRadius: BorderRadius.circular(5),
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

  Future<void> onSearchTextChanged(String text) async {
    filteredIndustryList.clear();
    if (text.isEmpty) {
      setState(() {
        filteredIndustryList.clear();
      });
      return;
    }

    industryList.forEach((indusrtyDetails) {
      if (indusrtyDetails.name.toLowerCase().contains(text.toLowerCase()))
        filteredIndustryList.add(indusrtyDetails);
    });
  }

  Future<void> loadData() async {
    final overlay = LoaderOverlay.of(context);
    final response = await overlay.during(getIndustries());
    setState(() {
      industryList = response;
      for (var i = 0; i < industryList.length; i++) {
        if (widget.myIndustryList.any((e) => e.id == industryList[i].id)) {
          industryList[i].isSelected = true;
        }
      }
    });
  }

  Future<void> onSave() async {
    final selected = industryList
        .where((element) => element.isSelected)
        .map((e) => e.id)
        .toList()
        .join(',');
    final overlay = LoaderOverlay.of(context);
    final isSuccess = await overlay.during(
      saveIntrestedIndustries(selected),
    );
    if (isSuccess) {
      Navigator.pop(context, industryList.where((e) => e.isSelected).toList());
    } else {
      toastBuild("Somthing went wrong, Try again later");
    }
  }
}

OutlineInputBorder searchborder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(
      color: Colors.grey[300],
    ),
  );
}
