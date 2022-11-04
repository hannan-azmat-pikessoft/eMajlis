import 'dart:convert';
import 'dart:developer';
import 'package:emajlis/models/message_thread_model.dart';
import 'package:emajlis/models/my_profile_model.dart';
import 'package:emajlis/providers/appointment_provider.dart';
import 'package:emajlis/providers/common_provider.dart';
import 'package:emajlis/providers/connection_provider.dart';
import 'package:emajlis/screens/appointments/appointment_details_screen.dart';
import 'package:emajlis/screens/appointments/appointments_screen.dart';
import 'package:emajlis/screens/chat/message_screen.dart';
import 'package:emajlis/screens/connections/connections_screen.dart';
import 'package:emajlis/providers/home_provider.dart';
import 'package:emajlis/screens/home/dashboard_screen.dart';
import 'package:emajlis/screens/splash/splash_logo_screen.dart';
import 'package:emajlis/utlis/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  'This channel is used for important notifications.', // description
  importance: Importance.high,
  playSound: true,
);

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('logo');
final IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
  requestSoundPermission: false,
  requestBadgePermission: false,
  requestAlertPermission: false,
);
final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase >>
  await Firebase.initializeApp();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage((_firebaseMessagingBackgroundHandler));
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
  // Firebase <<

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static void setMyProfile(BuildContext context, MyProfile data) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setMyProfile(data);
  }

  static MyProfile getMyProfile(BuildContext context) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    return state.getMyProfile();
  }

  //-------------------------------------------
  static void setMessageThreads(
      BuildContext context, List<MessageThreadModel> data) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.setMessageThreads(data);
  }

  static List<MessageThreadModel> getMessageThreads(BuildContext context) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    return state.getMessageThreads();
  }

  //-------------------------------------------

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = new GlobalKey<NavigatorState>();
  MyProfile _myprofile;
  List<MessageThreadModel> _messageThreadList;

  @override
  void initState() {
    super.initState();
    registerFirebaseMessaging();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => CommonProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'eMajlis',
        navigatorKey: navigatorKey,
        theme: ThemeData(
          fontFamily: 'Aeonik',
          primaryColor: Colors.black,
          backgroundColor: appBlackBackground,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashLogoScreen(),
        routes: {
          "connection": (_) => ConnectionsScreen(),
          "appointment": (_) => AppointmentsScreen(),
        },
      ),
    );
  }

  //-------------------------------------------
  void setMyProfile(MyProfile data) {
    setState(() {
      _myprofile = data;
    });
  }

  MyProfile getMyProfile() {
    return _myprofile;
  }

  //-------------------------------------------
  void setMessageThreads(List<MessageThreadModel> data) {
    setState(() {
      _messageThreadList = data;
    });
  }

  List<MessageThreadModel> getMessageThreads() {
    return _messageThreadList;
  }

  //-------------------------------------------

  void registerFirebaseMessaging() async {
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (payload) async {
        if (payload != null) {
          final decodedPayload = jsonDecode(payload);
          handleNotificationClickEvent(
            decodedPayload['messageType'],
            decodedPayload['senderId'],
          );
        }
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Message data: ${message.data}');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int unRead = prefs.getInt('unRead') ?? 0;
      unRead++;

      prefs.setInt('unRead', unRead);

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }

      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        int unRead = prefs.getInt('unRead') ?? 0;
        unRead++;
        prefs.setInt('unRead', unRead);
        log(message.notification.toString());

        var body = jsonDecode(message.data['body'] as String);
        var payload = jsonEncode({
          'messageType': message.data['type'],
          'senderId': body['sender_id'].toString(),
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        });

        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              color: Colors.blue,
              playSound: true,
            ),
            iOS: IOSNotificationDetails(
                presentSound: false, threadIdentifier: "1"),
          ),
          payload: payload,
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('onMessageOpenedApp');
      String messageType = message.data['type'];
      var decodedBody = jsonDecode(message.data['body']);
      String senderId = (decodedBody['sender_id']).toString();
      if (messageType != null) {
        handleNotificationClickEvent(messageType, senderId);
      }
    });

    FirebaseMessaging.instance.getInitialMessage().then((event) {
      print('onMessageOpenedApp');
      if (event != null) {
        String messageType = event.data['type'];
        var decodedBody = jsonDecode(event.data['body']);
        String senderId = (decodedBody['sender_id']).toString();
        if (messageType != null) {
          handleNotificationClickEvent(messageType, senderId);
        }
      }
    });
  }

  void handleNotificationClickEvent(String messageType, String senderId) {
    switch (messageType) {
      case 'chat':
        navigatorKey.currentState.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MessageScreen(
                  //  screenIndex: 1,
                  //id: int.parse(senderId),
                  ),
            ),
            (route) => false);
        break;
      case 'like': // Invitation
        navigatorKey.currentState.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                screenIndex: 1,
                id: 1,
              ),
            ),
            (route) => false);
        break;
      case 'like_accepted': // Connection
        navigatorKey.currentState.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                screenIndex: 1,
                id: 0,
              ),
            ),
            (route) => false);
        break;
      case 'booking':
        navigatorKey.currentState.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                screenIndex: 3,
                id: -1,
              ),
            ),
            (route) => false);
        break;
      case 'appointment':
        navigatorKey.currentState.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                screenIndex: 3,
                id: -1,
              ),
            ),
            (route) => false);
        break;
      case 'svc':
        navigatorKey.currentState.push(MaterialPageRoute(
          builder: (context) => AppointmentDetailsScreen(
            otherMemberId: senderId,
          ),
        ));
        break;

      default:
    }
  }
}
