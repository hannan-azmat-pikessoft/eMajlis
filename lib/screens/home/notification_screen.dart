import 'package:cached_network_image/cached_network_image.dart';
import 'package:emajlis/consts/common_const.dart';
import 'package:emajlis/screens/appointments/appointment_details_screen.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:emajlis/widgets/app_bar.dart';
import 'package:emajlis/widgets/progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/home_provider.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool loading = true;
  var tempId;

  @override
  void initState() {
    if (context.read<HomeProvider>().notificationList != null &&
        context.read<HomeProvider>().notificationList.length > 0) {
      loading = false;
    }

    super.initState();
    context.read<HomeProvider>().notification().whenComplete(() {
      setState(() {
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: simpleAppbar(context, titleText: "Notifications"),
        body: Container(
          padding: EdgeInsets.only(top: 10.0),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: loading
              ? circularProgress()
              : Consumer<HomeProvider>(builder: (context, n, _) {
                  return ListView.builder(
                    itemCount:
                        context.read<HomeProvider>().notificationList.length,
                    itemBuilder: (context, i) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 5.0),
                        decoration: BoxDecoration(color: appwhite),
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: ListTile(
                          onTap: () {
                            var type = n.notificationList[i].type;
                            if (type == "like") {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardScreen(
                                      screenIndex: 2,
                                      id: -1,
                                    ),
                                  ),
                                  (route) => false);
                            } else if (type == "svc") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AppointmentDetailsScreen(
                                    otherMemberId:
                                        n.notificationList[i].senderId,
                                  ),
                                ),
                              );
                            } else if (type == "booking") {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardScreen(
                                      screenIndex: 3,
                                      id: -1,
                                    ),
                                  ),
                                  (route) => false);
                            }
                            setState(() {});
                          },
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.circle,
                                size: 10.0,
                                color: appwhite,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 0),
                              ),
                              if (n.notificationList[i].type == "svc")
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 3, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: appMustard,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(Common.SecuritySvg),
                                        SizedBox(width: 3),
                                        Text(
                                          'SVC',
                                          style: TextStyle(
                                            color: appBlack,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                CachedNetworkImage(
                                  imageBuilder: (context, imageProvider) {
                                    return Container(
                                      height: 40.0,
                                      width: 40.0,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                  imageUrl: n.notificationList[i].imageUrl,
                                  width: 40,
                                  height: 40,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                                )
                            ],
                          ),
                          title: Text(n.notificationList[i].title,
                              style: TextStyle(
                                  fontSize: 12.0, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(top: 40.0),
                                  ),
                                  Flexible(
                                      child: RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                  fontSize: 10.0,
                                                  color: appBlack),
                                              children: [
                                        TextSpan(
                                            text: n.notificationList[i].message,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      ]))),
                                ],
                              ),
                              Text(
                                  DateFormat("dd-MM-yyyy").format(
                                          DateTime.parse(n.notificationList[i]
                                              .createdDate)) +
                                      "  " +
                                      DateFormat("h:mma").format(DateTime.parse(
                                          n.notificationList[i].createdDate)),
                                  style:
                                      TextStyle(fontSize: 9.0, color: appBlack))
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
        ));
  }
}
