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

class WorkIndustryScreen extends StatefulWidget {
  final IndustryModel workIndustry;
  WorkIndustryScreen({this.workIndustry});

  @override
  _WorkIndustryScreenState createState() => _WorkIndustryScreenState();
}

class _WorkIndustryScreenState extends State<WorkIndustryScreen> {
  double height;
  TextEditingController searchController = TextEditingController();
  IndustryModel selectedIndustry;

  List<IndustryModel> industryList = [];
  List<IndustryModel> filteredIndustryList = [];

  @override
  void initState() {
    super.initState();
    selectedIndustry = widget.workIndustry;
    Future.delayed(Duration.zero, () {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: appBodyGrey,
      appBar: simpleAppbar(context, titleText: "Select Industry"),
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
              Text(
                "Select Industry",
                style: b_14black(),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Select your industry", style: n_14grey()),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: appgreydate,
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
                    selectedIndustry.id == 0 ? "0" : "1" + " out of 1 max",
                    style: b_14black()),
              ),
              Container(
                  width: double.infinity,
                  height: height * 0.4,
                  child: filteredIndustryList.length != 0 ||
                          searchController.text.isNotEmpty
                      ? Container(
                          child: ListView.builder(
                            itemCount: filteredIndustryList.length,
                            itemBuilder: (context, i) {
                              return RadioListTile(
                                dense: true,
                                contentPadding: EdgeInsets.all(0),
                                value: filteredIndustryList[i].id,
                                groupValue: selectedIndustry.id,
                                title: Text(
                                  filteredIndustryList[i].name,
                                  style: b_14black(),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    selectedIndustry = filteredIndustryList[i];
                                  });
                                },
                                activeColor: Colors.black,
                              );
                            },
                          ),
                        )
                      : Container(
                          child: ListView.builder(
                            itemCount: industryList.length,
                            itemBuilder: (context, i) {
                              return RadioListTile(
                                dense: true,
                                contentPadding: EdgeInsets.all(0),
                                value: industryList[i].id,
                                groupValue: selectedIndustry.id,
                                title: Text(
                                  industryList[i].name,
                                  style: b_14black(),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    selectedIndustry = industryList[i];
                                  });
                                },
                                activeColor: Colors.black,
                              );
                            },
                          ),
                        )),
              InkWell(
                onTap: () {
                  if (selectedIndustry.id > 0) {
                    onSave();
                  } else {
                    warning(context, "Please select industry");
                  }
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
    });
  }

  Future<void> onSave() async {
    final overlay = LoaderOverlay.of(context);
    final isSuccess = await overlay.during(
      saveWorkIndustry(selectedIndustry.id),
    );
    if (isSuccess) {
      Navigator.pop(context, selectedIndustry);
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
