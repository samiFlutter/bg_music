import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

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


class MusicWidgets {
  
  late AudioPlayer audioPlayer;
  MusicWidgets(){
      audioPlayer = AudioPlayer()..setAsset("assets/audio/Elevator.mp3");
  }
  

 Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        audioPlayer.positionStream,
        audioPlayer.bufferedPositionStream,
        audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  myProgressBar(Stream<PositionData> positionDataStream,AudioPlayer audioPlayer) {

  return StreamBuilder<PositionData>(
                stream: positionDataStream,
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
                    onSeek: audioPlayer.seek,
                  );
                }));
}
  
}
