import 'dart:async';

import 'package:emajlis/models/appointment_model.dart';
import 'package:emajlis/utlis/flutter_device_type.dart';
import 'package:flutter/material.dart';
import 'package:jitsi_meet/jitsi_meet.dart';

class AppointmentMeeting extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentMeeting({
    Key key,
    @required this.appointment,
  }) : super(key: key);

  @override
  _AppointmentMeetingState createState() => _AppointmentMeetingState();
}

class _AppointmentMeetingState extends State<AppointmentMeeting> {
  final String serverUrl = "https://meet.jit.si/";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      loadJitsi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  void loadJitsi() async {
    try {
      print('-----------loadJitsi---------------');
      final String subject = "Call with " + widget.appointment.personName;
      final String roomName = 'emajlis_${widget.appointment.appointmentId}_';

      Map<FeatureFlagEnum, bool> featureFlags = {
        FeatureFlagEnum.ADD_PEOPLE_ENABLED: false,
        FeatureFlagEnum.CALENDAR_ENABLED: false,
        FeatureFlagEnum.CLOSE_CAPTIONS_ENABLED: false,
        FeatureFlagEnum.CHAT_ENABLED: false,
        FeatureFlagEnum.INVITE_ENABLED: false,
        FeatureFlagEnum.LIVE_STREAMING_ENABLED: false,
        FeatureFlagEnum.MEETING_PASSWORD_ENABLED: false,
        FeatureFlagEnum.RAISE_HAND_ENABLED: false,
        FeatureFlagEnum.RECORDING_ENABLED: false,
        FeatureFlagEnum.WELCOME_PAGE_ENABLED: false,
        FeatureFlagEnum.TOOLBOX_ALWAYS_VISIBLE: true,
        FeatureFlagEnum.TILE_VIEW_ENABLED: true,
      };

      if (Device.get().isAndroid) {
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = true;
      } else if (Device.get().isIos) {
        featureFlags[FeatureFlagEnum.PIP_ENABLED] = false;
        featureFlags[FeatureFlagEnum.IOS_RECORDING_ENABLED] = false;
      }

      // Define meetings options here
      var options = JitsiMeetingOptions(room: roomName)
        ..serverURL = serverUrl
        ..subject = subject
        ..userDisplayName = "Me"
        ..userEmail = "${widget.appointment.memberId}@emajlis.com"
        ..audioOnly = false
        ..audioMuted = false
        ..videoMuted = false
        ..featureFlags.addAll(featureFlags);

      await JitsiMeet.joinMeeting(
        options,
        listener: JitsiMeetingListener(
          onConferenceWillJoin: (message) {
            debugPrint("${options.room} will join with message: $message");
          },
          onConferenceJoined: (message) {
            const limit = const Duration(minutes: 45);
            new Timer.periodic(
              limit,
              (Timer timer) {
                JitsiMeet.closeMeeting();
                Navigator.pop(context);
              },
            );

            debugPrint("${options.room} joined with message: $message");
          },
          onConferenceTerminated: (message) {
            debugPrint("${options.room} joined with message: $message");
            Navigator.pop(context);
          },
          genericListeners: [
            JitsiGenericListener(
              eventName: 'readyToClose',
              callback: (dynamic message) {
                debugPrint("readyToClose callback");
              },
            ),
          ],
        ),
      );
    } catch (error) {
      print("---------loadJitsi ----------error: $error");
    }
  }
}
