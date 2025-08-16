import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/generation_history_screen/generation_history_screen.dart';
import '../presentation/music_generation_screen/music_generation_screen.dart';
import '../presentation/generation_progress_screen/generation_progress_screen.dart';
import '../presentation/audio_playback_screen/audio_playback_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String generationHistory = '/generation-history-screen';
  static const String musicGeneration = '/music-generation-screen';
  static const String generationProgress = '/generation-progress-screen';
  static const String audioPlayback = '/audio-playback-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    settings: (context) => const SettingsScreen(),
    generationHistory: (context) => const GenerationHistoryScreen(),
    musicGeneration: (context) => const MusicGenerationScreen(),
    generationProgress: (context) => const GenerationProgressScreen(),
    audioPlayback: (context) => const AudioPlaybackScreen(),
    // TODO: Add your other routes here
  };
}
