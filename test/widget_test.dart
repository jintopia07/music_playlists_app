import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';

import 'package:music_play_list/bloc/audio_bloc.dart';
import 'package:music_play_list/bloc/audio_event.dart';
import 'package:music_play_list/bloc/audio_state.dart';
import 'package:music_play_list/main.dart';
import 'package:music_play_list/models/playlist.dart';
import 'package:music_play_list/screens/playlist_screen.dart';
import 'widget_test.mocks.dart';
import 'dart:ui';

// สร้าง mock ของ AudioBloc
@GenerateMocks([AudioBloc])
void main() {
  testWidgets('PlaylistScreen shows playlists when loaded',
      (WidgetTester tester) async {
    final mockAudioBloc = MockAudioBloc();

    final testPlaylists = [
      Playlist(
        id: '1',
        name: 'Test Playlist',
        creator: 'Tester',
        coverUrl: 'https://picsum.photos/id/1/200/200',
        songIds: ['1', '2'],
      ),
    ];

    // จำลองสถานะของ Bloc ด้วย whenListen
    whenListen(
      mockAudioBloc,
      Stream.fromIterable([
        const AudioState().copyWith(status: AudioStatus.loading),
        const AudioState().copyWith(
          status: AudioStatus.loaded,
          playlists: testPlaylists,
          currentView: ScreenView.playlists,
        ),
      ]),
      initialState: const AudioState(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AudioBloc>.value(
          value: mockAudioBloc,
          child: const PlaylistScreen(),
        ),
      ),
    );

    // เล่มต้นควรเห็น CircularProgressIndicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // รอให้สถานะเปลี่ยนไปเป็น loaded
    await tester.pumpAndSettle();

    // ควรเห็น ListView และ ListTile
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(ListTile), findsWidgets);
  });

  testWidgets('MyApp creates a MaterialApp with correct theme',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MaterialApp), findsOneWidget);

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.debugShowCheckedModeBanner, false);
    expect(app.theme?.appBarTheme.backgroundColor, Colors.black);
    expect(app.theme?.scaffoldBackgroundColor, Colors.black);
  });
}
