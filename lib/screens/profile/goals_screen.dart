import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/goal_model.dart';
import 'package:emajlis/services/goals_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GoalsScreen extends StatefulWidget {
  final List<GoalModel> myGoalList;
  const GoalsScreen({this.myGoalList});

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List updatelist = [];

  var itemdata;
  List<GoalModel> goalList = [];
  List<GoalModel> sendgoalList = [];

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
      appBar: simpleAppbar(context, titleText: "Select goals"),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                child: SvgPicture.asset(Common.GoalsSvg),
              ),
              Text("Select your goals and objectives", style: b_14black()),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Max 3 goals allowed", style: n_14grey()),
              ),
              Container(
                width: double.infinity,
                height: h * 0.5,
                child: GridView.builder(
                    itemCount: goalList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 1.5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      crossAxisCount: 2,
                    ),
                    itemBuilder: (BuildContext context, int i) {
                      return InkWell(
                        onTap: () {
                          if (goalList[i].isSelected) {
                            setState(() {
                              goalList[i].isSelected = false;
                            });
                          } else {
                            if (goalList
                                    .where((element) => element.isSelected)
                                    .toList()
                                    .length <
                                3) {
                              setState(() {
                                goalList[i].isSelected = true;
                              });
                            }
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: goalList[i].isSelected == true
                                ? appBlack
                                : appwhite,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 5,
                                offset: Offset(0, 5),
                                color: Colors.grey[300],
                              )
                            ],
                          ),
                          child: Text(
                            goalList[i].name,
                            style: goalList[i].isSelected == true
                                ? b_12white()
                                : b_12black(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }),
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

  Future<void> loadData() async {
    final overlay = LoaderOverlay.of(context);
    final response = await overlay.during(getGoals());
    setState(() {
      goalList = response;
      for (var i = 0; i < goalList.length; i++) {
        if (widget.myGoalList.any((e) => e.id == goalList[i].id)) {
          goalList[i].isSelected = true;
        }
      }
    });
  }

  Future<void> onSave() async {
    final selected = goalList
        .where((element) => element.isSelected)
        .map((e) => e.id)
        .toList()
        .join(',');
    final overlay = LoaderOverlay.of(context);
    final response = await overlay.during(
      saveGoals(selected),
    );
    if (response.status) {
      Navigator.pop(context, goalList.where((e) => e.isSelected).toList());
    } else {
      toastBuild(response.message);
    }
  }
}
