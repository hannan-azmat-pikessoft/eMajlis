import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/venue_model.dart';
import 'package:emajlis/screens/appointments/venue/venue_details_screen.dart';
import 'package:emajlis/services/venue_service.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VenueListScreen extends StatefulWidget {
  @override
  _VenueListScreenState createState() => _VenueListScreenState();
}

class _VenueListScreenState extends State<VenueListScreen> {
  SharedPreferences pref;
  LoaderOverlay overlay;
  double height;
  double width;

  List<VenueModel> venueList = [];
  List<VenueModel> filteredList = [];
  TextEditingController searchController;
  Icon _searchIcon = new Icon(Icons.search, color: appBlack);

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    Future.delayed(Duration.zero, () {
      loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: simpleAppbar(context, isAppTitle: true, titleText: "Venues"),
      backgroundColor: appBodyGrey,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          width: width,
          child: Column(
            children: [
              Container(
                height: height / 16,
                width: width,
                decoration: BoxDecoration(
                  color: appwhite,
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  border: Border.all(color: appwhite),
                ),
                child: new TextField(
                  controller: searchController,
                  cursorColor: appBlack,
                  style: TextStyle(fontSize: 12),
                  decoration: InputDecoration(
                    prefixIcon: _searchIcon,
                    hintText: 'Search a venue',
                    focusColor: Colors.pink,
                    hoverColor: Colors.red,
                    hintStyle: TextStyle(fontSize: 12, color: appgreydate),
                    fillColor: Colors.amber,
                    contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                  onChanged: (value) => onSearchTextChanged(value),
                  onTap: () {
                    onSearchPressed();
                  },
                ),
              ),
              SizedBox(height: 20),
              filteredList.length != 0 || searchController.text.isNotEmpty
                  ? ListView.separated(
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VenueDetailsScreen(
                                    model: filteredList[index],
                                  ),
                                ),
                              );
                            },
                            child: new Container(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    foregroundColor: appBlack,
                                    backgroundColor: appBlack,
                                    backgroundImage: NetworkImage(
                                      filteredList[index].imagesList[0] ??
                                          Common.NoImage150,
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Text(filteredList[index].title ?? '')
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  : venueList.length == 0
                      ? Padding(
                          padding: const EdgeInsets.all(100.0),
                          child: Text("No Venues", style: b_16Black()),
                        )
                      : RefreshIndicator(
                          onRefresh: () => loadData(),
                          child: Container(
                            height: height - (height * 0.2 + 11),
                            child: ListView.builder(
                              itemCount: venueList.length,
                              itemBuilder: (context, i) {
                                return venueItem(venueList[i]);
                              },
                            ),
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget venueItem(VenueModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VenueDetailsScreen(
                    model: item,
                  ),
                ),
              );
            },
            child: Container(
              width: width,
              height: height * 0.35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: appBlack,
              ),
              child: Column(
                children: [
                  Container(
                    height: height * 0.24,
                    decoration: BoxDecoration(
                      color: appBlack,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(
                          item.imagesList[0] ?? Common.DefaultVenue,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: height * 0.11,
                    child: Container(
                      decoration: BoxDecoration(
                        color: appwhite,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      padding: const EdgeInsets.only(
                        left: 15,
                        top: 15,
                        right: 15,
                        bottom: 15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.title ?? '',
                                style: b_14black(),
                              ),
                              Spacer(),
                              for (var i = 0; i < item.rating; i++)
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 15,
                                )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  item.location ?? '',
                                  style: n_10grey(),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.lock_clock,
                                size: 15,
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Text(
                                  DateFormat.jm().format(DateFormat("hh:mm:ss")
                                          .parse(item.openingTime)) +
                                      " - " +
                                      DateFormat.jm().format(
                                        DateFormat("hh:mm:ss")
                                            .parse(item.closingTime),
                                      ),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  style: n_10grey(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  void onSearchTextChanged(String val) {
    filteredList.clear();
    if (val.isNotEmpty) {
      setState(() {});
      for (int i = 0; i < venueList.length; i++) {
        if ((venueList[i].title ?? "")
            .toLowerCase()
            .contains(val.toLowerCase())) {
          filteredList.add(venueList[i]);
        }
        setState(() {});
      }
    }
  }

  void onSearchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close, color: appBlack);
      } else {
        this._searchIcon = new Icon(Icons.search, color: appBlack);
        filteredList.clear();
        searchController.clear();
      }
    });
  }

  Future<void> loadData() async {
    pref = await SharedPreferences.getInstance();
    overlay = LoaderOverlay.of(context);
    overlay.show();
    final response = await getVenues();
    setState(() {
      venueList = response;
    });
    overlay.hide();
  }
}
