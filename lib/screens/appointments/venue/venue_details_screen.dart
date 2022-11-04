import 'package:carousel_slider/carousel_slider.dart';
import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/models/venue_model.dart';
import 'package:emajlis/utlis/loader_overlay.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/fonts.dart';
import 'package:emajlis/widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class VenueDetailsScreen extends StatefulWidget {
  final VenueModel model;
  const VenueDetailsScreen({Key key, this.model}) : super(key: key);

  @override
  _VenueDetailScreenState createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailsScreen> {
  SharedPreferences pref;
  LoaderOverlay overlay;
  double height;
  double width;

  int _current = 0;

  List<Widget> imageSliders = [];
  final colorsbox = [
    Colors.blue,
    Colors.cyan,
    Colors.red,
    Colors.green,
    Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    imageSliders = widget.model.imagesList.map((item) {
      return Container(
        child: Image(
          fit: BoxFit.cover,
          image: NetworkImage(item),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: simpleAppbar(context, isAppTitle: true, titleText: "Venue Info"),
      backgroundColor: appBodyGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              items: imageSliders,
              options: CarouselOptions(
                disableCenter: true,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayAnimationDuration: Duration(seconds: 2),
                enlargeCenterPage: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: widget.model.imagesList.map((e) {
                  int index = widget.model.imagesList.indexOf(e);
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: _current == index ? appBlack : appgreydate,
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: width,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        widget.model.title ?? '',
                        style: b_14black(),
                      ),
                      Spacer(),
                      for (var i = 0; i < widget.model.rating; i++)
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 15,
                        )
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 15,
                            ),
                            SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                widget.model.location,
                                style: n_10grey(),
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.lock_clock,
                              size: 15,
                            ),
                            SizedBox(width: 10),
                            Text(
                              DateFormat.jm().format(DateFormat("hh:mm:ss")
                                      .parse(widget.model.openingTime)) +
                                  " - " +
                                  DateFormat.jm().format(DateFormat("hh:mm:ss")
                                      .parse(widget.model.closingTime)),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: n_10grey(),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: appwhite,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description",
                          style: b_14black(),
                        ),
                        SizedBox(height: 5),
                        Text(
                          widget.model.description,
                          style: n_12grey(),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Social Links",
                          style: b_14black(),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                openUrl(widget.model.twitterLink);
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                child: SvgPicture.asset(Common.TwitterSvg),
                              ),
                            ),
                            SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                openUrl(widget.model.linkedinLink);
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                child: SvgPicture.asset(Common.LinkedinSvg),
                              ),
                            ),
                            SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                openUrl(widget.model.instagramLink);
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                child: SvgPicture.asset(Common.InstagramSvg),
                              ),
                            ),
                            SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                openUrl(widget.model.facebookLink);
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                child: SvgPicture.asset(Common.FacebookSvg),
                              ),
                            ),
                            SizedBox(width: 5),
                            InkWell(
                              onTap: () {
                                openUrl(widget.model.websiteLink);
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 5, 5),
                                child: Icon(Icons.language_sharp),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: appwhite,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Amenties",
                          style: b_14black(),
                        ),
                        SizedBox(height: 5),
                        Container(
                          height: height * 0.1,
                          child: ListView.builder(
                            itemCount: widget.model.amenities.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) {
                              return Container(
                                margin: EdgeInsets.only(top: 5, bottom: 5),
                                width: width * 0.22,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      widget.model.amenities[i].image,
                                      scale: 2,
                                      color: appBlack,
                                    ),
                                    Text(
                                      widget.model.amenities[i].name,
                                      style: b_12black(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: appwhite,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Offerings",
                          style: b_14black(),
                        ),
                        SizedBox(height: 5),
                        Container(
                          height: height * 0.2,
                          child: ListView.builder(
                            itemCount: widget.model.offeringsList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) {
                              return Container(
                                margin: EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.all(10),
                                width: width * 0.4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    colors: [
                                      colorsbox[i][800],
                                      colorsbox[i][200],
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.model.offeringsList[i],
                                      style: n_12white(),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: appwhite,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "House Rules",
                          style: b_14black(),
                        ),
                        SizedBox(height: 5),
                        Wrap(
                          children: [
                            for (var i = 0;
                                i < widget.model.houseRulesList.length;
                                i++)
                              Container(
                                margin: EdgeInsets.all(3),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: appGrey6,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.model.houseRulesList[i],
                                  style: n_12white(),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: appwhite,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Special Features",
                          style: b_14black(),
                        ),
                        SizedBox(height: 5),
                        Wrap(
                          children: [
                            for (var i = 0;
                                i < widget.model.specialFeaturesList.length;
                                i++)
                              Container(
                                margin: EdgeInsets.all(3),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: appGrey6,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.model.specialFeaturesList[i],
                                  style: n_12white(),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  dynamic openUrl(url) async {
    url = "http://" + url;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      error(context, "Invalid link");
    }
  }
}
