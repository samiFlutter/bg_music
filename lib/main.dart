import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AudioPlayer _audioPlayer;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _audioPlayer = AudioPlayer()..setAsset("assets/audio/Elevator.mp3");
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_down_rounded),
          onPressed: () {},
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.more_horiz))],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF144771), Color(0xFF071A2C)],
        )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: ((context, snapshot) {
                  final positionData = snapshot.data;
                  return ProgressBar(
                    barHeight: 8,
                    baseBarColor: Colors.grey[600],
                    bufferedBarColor: Colors.grey,
                    progressBarColor: Colors.red,
                    thumbColor: Colors.red,
                    timeLabelTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    progress: positionData?.position ?? Duration.zero,
                    total: positionData?.duration ?? Duration.zero,
                    buffered: positionData?.buffredPosition ?? Duration.zero,
                    onSeek: _audioPlayer.seek,
                  );
                })),
            const SizedBox(
              height: 20,
            ),
            Controls(audioPlayer: _audioPlayer)
          ],
        ),
      ),
    );
  }
}

class Controls extends StatelessWidget {
  const Controls({
    super.key,
    required this.audioPlayer,
  });
  final AudioPlayer audioPlayer;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final prossingState = playerState?.processingState;
        final playing = playerState?.playing;

        if (!(playing ?? false)) {
          return IconButton(
            onPressed: audioPlayer.play,
            icon: Icon(Icons.play_arrow_rounded),
            iconSize: 80,
            color: Colors.white,
          );
        } else if (prossingState != ProcessingState.completed) {
          return IconButton(
              onPressed: audioPlayer.pause,
              iconSize: 80,
              color: Colors.white,
              icon: const Icon(Icons.pause_rounded));
        }
        return Icon(
          Icons.play_arrow_rounded,
          size: 80,
          color: Colors.white,
        );
      },
    );
  }
}

class PositionData {
  const PositionData(this.position, this.buffredPosition, this.duration);
  final Duration position;
  final Duration buffredPosition;
  final Duration duration;
}
