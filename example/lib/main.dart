import 'package:flutter/material.dart';
import 'package:janus_client_example/Home.dart';
import 'package:janus_client_example/typed_examples/audio_bridge.dart';
import 'package:janus_client_example/typed_examples/google_meet.dart';
import 'package:janus_client_example/typed_examples/record_play.dart';
import 'package:janus_client_example/typed_examples/sip.dart';
import 'package:janus_client_example/typed_examples/streaming.dart';
import 'package:janus_client_example/typed_examples/video_call.dart';
import 'typed_examples/text_room.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    theme: ThemeData(
        colorScheme: ColorScheme.light(background: Colors.white, primary: Colors.black, secondary: Colors.black, onPrimary: Colors.white, onSecondary: Colors.white),
        listTileTheme: ListTileThemeData(titleTextStyle: TextStyle(color: Colors.black)),
        appBarTheme: AppBarTheme(titleTextStyle: TextStyle(color: Colors.white), backgroundColor: Colors.purple)),
    darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(background: Colors.black, primary: Colors.white, secondary: Colors.white, onPrimary: Colors.black, onSecondary: Colors.black),
        listTileTheme: ListTileThemeData(titleTextStyle: TextStyle(color: Colors.white)),
        appBarTheme: AppBarTheme(titleTextStyle: TextStyle(color: Colors.white), backgroundColor: Colors.grey)),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    routes: {
      "/google-meet": (c) => GoogleMeet(),
      "/typed_sip": (c) => TypedSipExample(),
       "/record_play": (c) => RecordPlayExample(),
      "/typed_streaming": (c) => TypedStreamingV2(),
      "/typed_video_call": (c) => TypedVideoCallV2Example(),
      "/typed_audio_bridge": (c) => TypedAudioRoomV2(),
      "/typed_text_room": (c) => TypedTextRoom(),
      "/": (c) => Home()
    },
  ));
}
