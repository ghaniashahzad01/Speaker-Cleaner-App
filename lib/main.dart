import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final bool onboardingCompleted =
      prefs.getBool('onboarding_completed') ?? false;

  runApp(
    SpeakerCleanerApp(
      showOnboarding: !onboardingCompleted,
    ),
  );
}

// ============================================================
// APP
// ============================================================

class SpeakerCleanerApp extends StatelessWidget {
  final bool showOnboarding;

  const SpeakerCleanerApp({
    super.key,
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Speaker Cleaner',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F7FF7),
        ),
      ),
      home: showOnboarding
          ? const OnboardingScreen()
          : const SpeakerCleanerHome(),
    );
  }
}

// ============================================================
// ONBOARDING
// ============================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _pageController =
      PageController();

  int _currentPage = 0;

  final List<OnboardingData> _pages = const [
    OnboardingData(
      icon: Icons.volume_up_rounded,
      title: 'Welcome to\nSpeaker Cleaner',
      description:
          'Use controlled audio patterns to help move moisture from your phone speaker.',
    ),
    OnboardingData(
      icon: Icons.graphic_eq_rounded,
      title: 'Choose Your\nCleaning Mode',
      description:
          'Select Quick Clean, Water Eject, or Deep Clean according to your needs.',
    ),
    OnboardingData(
      icon: Icons.timer_outlined,
      title: 'Simple & Timed',
      description:
          'Each cleaning session automatically stops when its selected duration is complete.',
    ),
    OnboardingData(
      icon: Icons.shield_outlined,
      title: 'Use It Safely',
      description:
          'Keep the volume at a comfortable level and stop the session if the sound feels uncomfortable.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setBool(
      'onboarding_completed',
      true,
    );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            const SpeakerCleanerHome(),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage ==
        _pages.length - 1) {
      _completeOnboarding();
      return;
    }

    _pageController.nextPage(
      duration:
          const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FD),

      body: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------
            // SKIP
            // ----------------------------------------------------

            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed:
                    _completeOnboarding,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color:
                        Color(0xFF4F7FF7),
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),

            // ----------------------------------------------------
            // PAGES
            // ----------------------------------------------------

            Expanded(
              child: PageView.builder(
                controller:
                    _pageController,
                itemCount: _pages.length,

                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },

                itemBuilder:
                    (context, index) {
                  return _buildPage(
                    _pages[index],
                  );
                },
              ),
            ),

            // ----------------------------------------------------
            // DOTS
            // ----------------------------------------------------

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) {
                  final bool selected =
                      index == _currentPage;

                  return AnimatedContainer(
                    duration:
                        const Duration(
                      milliseconds: 250,
                    ),

                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),

                    width:
                        selected ? 28 : 8,

                    height: 8,

                    decoration:
                        BoxDecoration(
                      color: selected
                          ? const Color(
                              0xFF4F7FF7,
                            )
                          : const Color(
                              0xFFD5DCEB,
                            ),

                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // ----------------------------------------------------
            // BUTTON
            // ----------------------------------------------------

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 24,
              ),

              child: SizedBox(
                width:
                    double.infinity,
                height: 60,

                child: ElevatedButton(
                  onPressed: _nextPage,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFF4F7FF7,
                    ),

                    foregroundColor:
                        Colors.white,

                    elevation: 2,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),

                  child: Text(
                    _currentPage ==
                            _pages.length - 1
                        ? 'Get Started'
                        : 'Continue',

                    style:
                        const TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(
    OnboardingData data,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 30,
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          // ------------------------------------------------------
          // ICON
          // ------------------------------------------------------

          Container(
            width: 250,
            height: 250,

            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFE8EEFF),

              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.05),
                  blurRadius: 25,
                  offset:
                      const Offset(0, 10),
                ),
              ],
            ),

            child: Center(
              child: Icon(
                data.icon,
                size: 110,
                color:
                    const Color(0xFF4F7FF7),
              ),
            ),
          ),

          const SizedBox(height: 55),

          // ------------------------------------------------------
          // TITLE
          // ------------------------------------------------------

          Text(
            data.title,

            style: const TextStyle(
              fontSize: 32,
              fontWeight:
                  FontWeight.bold,
              color: Colors.black,
              height: 1.15,
            ),

            textAlign:
                TextAlign.center,
          ),

          const SizedBox(height: 18),

          // ------------------------------------------------------
          // DESCRIPTION
          // ------------------------------------------------------

          Text(
            data.description,

            style: const TextStyle(
              fontSize: 17,
              color: Colors.grey,
              height: 1.5,
            ),

            textAlign:
                TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ONBOARDING DATA
// ============================================================

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  const OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

// ============================================================
// CLEANING MODE
// ============================================================

enum CleaningMode {
  quick,
  water,
  deep,
}

class CleaningModeInfo {
  final String name;
  final String description;
  final IconData icon;
  final int duration;
  final double startFrequency;
  final double endFrequency;

  const CleaningModeInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.duration,
    required this.startFrequency,
    required this.endFrequency,
  });
}

// ============================================================
// HOME
// ============================================================

class SpeakerCleanerHome extends StatefulWidget {
  const SpeakerCleanerHome({super.key});

  @override
  State<SpeakerCleanerHome> createState() =>
      _SpeakerCleanerHomeState();
}

class _SpeakerCleanerHomeState
    extends State<SpeakerCleanerHome>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer =
      AudioPlayer();

  CleaningMode _selectedMode =
      CleaningMode.water;

  bool _isCleaning = false;

  int _remainingSeconds = 30;

  double _volume = 0.50;

  Timer? _timer;

  late final AnimationController
      _pulseController;

  // ==========================================================
  // MODE DATA
  // ==========================================================

  CleaningModeInfo _getModeInfo(
    CleaningMode mode,
  ) {
    switch (mode) {
      case CleaningMode.quick:
        return const CleaningModeInfo(
          name: 'Quick Clean',
          description:
              'A short cleaning cycle',
          icon: Icons.bolt_rounded,
          duration: 15,
          startFrequency: 170,
          endFrequency: 260,
        );

      case CleaningMode.water:
        return const CleaningModeInfo(
          name: 'Water Eject',
          description:
              'Designed for moisture displacement',
          icon:
              Icons.water_drop_outlined,
          duration: 30,
          startFrequency: 150,
          endFrequency: 300,
        );

      case CleaningMode.deep:
        return const CleaningModeInfo(
          name: 'Deep Clean',
          description:
              'A longer frequency sweep',
          icon:
              Icons.graphic_eq_rounded,
          duration: 45,
          startFrequency: 120,
          endFrequency: 350,
        );
    }
  }

  CleaningModeInfo
      get _currentModeInfo =>
          _getModeInfo(_selectedMode);

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _remainingSeconds =
        _currentModeInfo.duration;

    _pulseController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 900),
      lowerBound: 0.92,
      upperBound: 1.08,
    );
  }

  // ==========================================================
  // START
  // ==========================================================

  Future<void> _startCleaning() async {
    if (_isCleaning) return;

    final mode =
        _currentModeInfo;

    try {
      final audioBytes =
          _generateCleaningTone(
        durationSeconds:
            mode.duration,
        startFrequency:
            mode.startFrequency,
        endFrequency:
            mode.endFrequency,
      );

      await _audioPlayer.setVolume(
        _volume,
      );

      await _audioPlayer.play(
        BytesSource(audioBytes),
      );

      if (!mounted) return;

      setState(() {
        _isCleaning = true;
        _remainingSeconds =
            mode.duration;
      });

      _pulseController.repeat(
        reverse: true,
      );

      _startCountdown();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Unable to play cleaning sound: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // COUNTDOWN
  // ==========================================================

  void _startCountdown() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds <= 1) {
          timer.cancel();
          _finishCleaning();
        } else {
          setState(() {
            _remainingSeconds--;
          });
        }
      },
    );
  }

  // ==========================================================
  // FINISH
  // ==========================================================

  Future<void> _finishCleaning() async {
    _timer?.cancel();

    await _audioPlayer.stop();

    _pulseController.stop();
    _pulseController.value = 1.0;

    if (!mounted) return;

    setState(() {
      _isCleaning = false;
      _remainingSeconds =
          _currentModeInfo.duration;
    });
  }

  // ==========================================================
  // STOP
  // ==========================================================

  Future<void> _stopCleaning() async {
    _timer?.cancel();

    await _audioPlayer.stop();

    _pulseController.stop();
    _pulseController.value = 1.0;

    if (!mounted) return;

    setState(() {
      _isCleaning = false;
      _remainingSeconds =
          _currentModeInfo.duration;
    });
  }

  // ==========================================================
  // MODE SELECT
  // ==========================================================

  void _selectMode(
    CleaningMode mode,
  ) {
    if (_isCleaning) return;

    setState(() {
      _selectedMode = mode;
      _remainingSeconds =
          _getModeInfo(mode).duration;
    });
  }

  // ==========================================================
  // SETTINGS
  // ==========================================================

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder:
              (context, setSheetState) {
            return Container(
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFF8F9FD),
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),

              padding:
                  const EdgeInsets.fromLTRB(
                24,
                12,
                24,
                30,
              ),

              child: SafeArea(
                child:
                    SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,
                          decoration:
                              BoxDecoration(
                            color: Colors
                                .grey.shade300,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      const Text(
                        'Settings',
                        style:
                            TextStyle(
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 25,
                      ),

                      _buildSettingsSection(
                        icon: Icons
                            .volume_up_rounded,
                        title:
                            'Cleaning Volume',

                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons
                                      .volume_down_rounded,
                                  color:
                                      Color(
                                    0xFF4F7FF7,
                                  ),
                                ),

                                Expanded(
                                  child:
                                      Slider(
                                    value:
                                        _volume,
                                    min: 0.20,
                                    max: 0.70,
                                    divisions:
                                        10,

                                    activeColor:
                                        const Color(
                                      0xFF4F7FF7,
                                    ),

                                    onChanged:
                                        (value) async {
                                      setSheetState(
                                        () {
                                          _volume =
                                              value;
                                        },
                                      );

                                      setState(
                                        () {
                                          _volume =
                                              value;
                                        },
                                      );

                                      await _audioPlayer
                                          .setVolume(
                                        value,
                                      );
                                    },
                                  ),
                                ),

                                const Icon(
                                  Icons
                                      .volume_up_rounded,
                                  color:
                                      Color(
                                    0xFF4F7FF7,
                                  ),
                                ),
                              ],
                            ),

                            Text(
                              '${(_volume * 100).round()}%',
                              style:
                                  const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight
                                        .bold,
                                color:
                                    Color(
                                  0xFF4F7FF7,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 5,
                            ),

                            const Text(
                              'Keep the volume at a comfortable level.',
                              style:
                                  TextStyle(
                                color:
                                    Colors.grey,
                                fontSize: 14,
                              ),
                              textAlign:
                                  TextAlign
                                      .center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _buildSettingsSection(
                        icon: Icons
                            .graphic_eq_rounded,
                        title:
                            'Current Cleaning Mode',

                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,

                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFFE8EEFF,
                                ),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  14,
                                ),
                              ),

                              child: Icon(
                                _currentModeInfo
                                    .icon,
                                color:
                                    const Color(
                                  0xFF4F7FF7,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 14,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    _currentModeInfo
                                        .name,
                                    style:
                                        const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 3,
                                  ),

                                  Text(
                                    '${_currentModeInfo.duration} seconds',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      _buildSettingsTile(
                        icon: Icons
                            .shield_outlined,
                        title:
                            'Safety Information',
                        subtitle:
                            'Read important usage guidance',
                        onTap: () {
                          Navigator.pop(
                            context,
                          );
                          _showSafetyInformation();
                        },
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      _buildSettingsTile(
                        icon: Icons
                            .info_outline_rounded,
                        title:
                            'About Speaker Cleaner',
                        subtitle:
                            'Learn about this app',
                        onTap: () {
                          Navigator.pop(
                            context,
                          );
                          _showAbout();
                        },
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Center(
                        child: Text(
                          'Speaker Cleaner • v1.0.0',
                          style: TextStyle(
                            color: Colors
                                .grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // SETTINGS SECTION
  // ==========================================================

  Widget _buildSettingsSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                    const Color(0xFF4F7FF7),
              ),

              const SizedBox(width: 12),

              Text(
                title,
                style:
                    const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          child,
        ],
      ),
    );
  }

  // ==========================================================
  // SETTINGS TILE
  // ==========================================================

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,

      borderRadius:
          BorderRadius.circular(20),

      child: InkWell(
        onTap: onTap,

        borderRadius:
            BorderRadius.circular(20),

        child: Padding(
          padding:
              const EdgeInsets.all(18),

          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFFE8EEFF),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),

                child: Icon(
                  icon,
                  color:
                      const Color(0xFF4F7FF7),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .chevron_right_rounded,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SAFETY
  // ==========================================================

  void _showSafetyInformation() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color:
                    Color(0xFF4F7FF7),
              ),

              SizedBox(width: 10),

              Text('Safety'),
            ],
          ),

          content:
              const SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  'Please follow these guidelines:',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  '• Keep the phone volume at a comfortable level.\n\n'
                  '• Do not place the phone directly against your ear while the cleaning sound is playing.\n\n'
                  '• Stop the cleaning session if the sound feels uncomfortable.\n\n'
                  '• This app uses audio to help move moisture and does not guarantee complete water or dust removal.\n\n'
                  '• If the phone has significant liquid damage, allow it to dry properly and seek professional assistance when necessary.',
                  style: TextStyle(
                    height: 1.45,
                    color:
                        Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
              ),
              child:
                  const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // ABOUT
  // ==========================================================

  void _showAbout() {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          title: const Text(
            'About Speaker Cleaner',
          ),

          content: const Text(
            'Speaker Cleaner is an audio-based utility designed to play controlled low-frequency sound patterns that may help move moisture from a phone speaker.\n\n'
            'It provides different cleaning modes and timed audio sessions.\n\n'
            'Version 1.0.0',
            style: TextStyle(
              height: 1.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
              ),
              child:
                  const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================================
  // GENERATE WAV
  // ==========================================================

  Uint8List _generateCleaningTone({
    required int durationSeconds,
    required double startFrequency,
    required double endFrequency,
  }) {
    const int sampleRate = 44100;
    const int channels = 1;
    const int bitsPerSample = 16;

    final int numberOfSamples =
        sampleRate * durationSeconds;

    final int bytesPerSample =
        bitsPerSample ~/ 8;

    final int dataSize =
        numberOfSamples *
            channels *
            bytesPerSample;

    final int fileSize =
        44 + dataSize;

    final ByteData bytes =
        ByteData(fileSize);

    _writeString(
      bytes,
      0,
      'RIFF',
    );

    bytes.setUint32(
      4,
      fileSize - 8,
      Endian.little,
    );

    _writeString(
      bytes,
      8,
      'WAVE',
    );

    _writeString(
      bytes,
      12,
      'fmt ',
    );

    bytes.setUint32(
      16,
      16,
      Endian.little,
    );

    bytes.setUint16(
      20,
      1,
      Endian.little,
    );

    bytes.setUint16(
      22,
      channels,
      Endian.little,
    );

    bytes.setUint32(
      24,
      sampleRate,
      Endian.little,
    );

    final int byteRate =
        sampleRate *
            channels *
            bytesPerSample;

    bytes.setUint32(
      28,
      byteRate,
      Endian.little,
    );

    final int blockAlign =
        channels * bytesPerSample;

    bytes.setUint16(
      32,
      blockAlign,
      Endian.little,
    );

    bytes.setUint16(
      34,
      bitsPerSample,
      Endian.little,
    );

    _writeString(
      bytes,
      36,
      'data',
    );

    bytes.setUint32(
      40,
      dataSize,
      Endian.little,
    );

    const double amplitude = 0.35;

    double phase = 0.0;

    const int fadeSamples = 2205;

    for (
      int i = 0;
      i < numberOfSamples;
      i++
    ) {
      final double progress =
          i / numberOfSamples;

      final double currentFrequency =
          startFrequency +
              ((endFrequency -
                      startFrequency) *
                  progress);

      phase +=
          2 *
              pi *
              currentFrequency /
              sampleRate;

      double envelope = 1.0;

      if (i < fadeSamples) {
        envelope =
            i / fadeSamples;
      } else if (
          i >
              numberOfSamples -
                  fadeSamples) {
        envelope =
            (numberOfSamples - i) /
                fadeSamples;
      }

      final double sample =
          sin(phase) *
              amplitude *
              envelope;

      final int pcmValue =
          (sample * 32767).round();

      bytes.setInt16(
        44 + (i * 2),
        pcmValue,
        Endian.little,
      );
    }

    return bytes.buffer.asUint8List();
  }

  // ==========================================================
  // WRITE STRING
  // ==========================================================

  void _writeString(
    ByteData data,
    int offset,
    String value,
  ) {
    for (
      int i = 0;
      i < value.length;
      i++
    ) {
      data.setUint8(
        offset + i,
        value.codeUnitAt(i),
      );
    }
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _timer?.cancel();

    _pulseController.dispose();

    _audioPlayer.dispose();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final mode =
        _currentModeInfo;

    final double progress =
        (mode.duration -
                _remainingSeconds) /
            mode.duration;

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FD),

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,

        elevation: 0,

        title: const Text(
          'Speaker Cleaner',
          style: TextStyle(
            fontSize: 28,
            fontWeight:
                FontWeight.bold,
            color: Colors.black,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
                _openSettings,

            icon: const Icon(
              Icons.more_vert,
              color: Colors.black,
              size: 28,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child:
            SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
            ),

            child: Column(
              children: [
                const SizedBox(
                  height: 25,
                ),

                // SPEAKER
                AnimatedBuilder(
                  animation:
                      _pulseController,

                  builder:
                      (context, child) {
                    return Transform.scale(
                      scale: _isCleaning
                          ? _pulseController
                              .value
                          : 1.0,

                      child: Container(
                        width: 220,
                        height: 220,

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFE8EEFF,
                          ),

                          shape:
                              BoxShape.circle,

                          boxShadow: [
                            BoxShadow(
                              color:
                                  _isCleaning
                                      ? const Color(
                                          0xFF4F7FF7,
                                        ).withOpacity(
                                          0.18,
                                        )
                                      : Colors
                                          .black
                                          .withOpacity(
                                          0.05,
                                        ),

                              blurRadius:
                                  _isCleaning
                                      ? 35
                                      : 25,

                              spreadRadius:
                                  _isCleaning
                                      ? 8
                                      : 0,

                              offset:
                                  const Offset(
                                0,
                                10,
                              ),
                            ),
                          ],
                        ),

                        child:
                            Center(
                          child: Icon(
                            _isCleaning
                                ? Icons
                                    .volume_up_rounded
                                : Icons
                                    .volume_up_outlined,

                            size: 90,

                            color:
                                const Color(
                              0xFF4F7FF7,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(
                  height: 30,
                ),

                Text(
                  _isCleaning
                      ? 'Cleaning Speaker...'
                      : 'Remove Water & Dust',

                  style:
                      const TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.black,
                  ),

                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  _isCleaning
                      ? '$_remainingSeconds seconds remaining'
                      : mode.description,

                  style:
                      const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.4,
                  ),

                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(
                  height: 25,
                ),

                const Align(
                  alignment:
                      Alignment.centerLeft,

                  child: Text(
                    'Cleaning Mode',
                    style:
                        TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                _buildModeCard(
                  CleaningMode.quick,
                ),

                const SizedBox(
                  height: 10,
                ),

                _buildModeCard(
                  CleaningMode.water,
                ),

                const SizedBox(
                  height: 10,
                ),

                _buildModeCard(
                  CleaningMode.deep,
                ),

                const SizedBox(
                  height: 20,
                ),

                // ACTIVE SESSION
                Container(
                  width:
                      double.infinity,

                  padding:
                      const EdgeInsets.all(
                    20,
                  ),

                  decoration:
                      BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      24,
                    ),
                  ),

                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            mode.icon,
                            color:
                                const Color(
                              0xFF4F7FF7,
                            ),
                            size: 30,
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          Expanded(
                            child: Text(
                              mode.name,
                              style:
                                  const TextStyle(
                                fontSize: 19,
                                fontWeight:
                                    FontWeight
                                        .w600,
                              ),
                            ),
                          ),

                          Text(
                            _isCleaning
                                ? '$_remainingSeconds sec'
                                : '${mode.duration} sec',

                            style:
                                const TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color:
                                  Color(
                                0xFF4F7FF7,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_isCleaning) ...[
                        const SizedBox(
                          height: 18,
                        ),

                        ClipRRect(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),

                          child:
                              LinearProgressIndicator(
                            value:
                                progress,

                            minHeight: 8,

                            backgroundColor:
                                const Color(
                              0xFFE8EEFF,
                            ),

                            valueColor:
                                const AlwaysStoppedAnimation<
                                    Color>(
                              Color(
                                0xFF4F7FF7,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                // BUTTON
                SizedBox(
                  width:
                      double.infinity,

                  height: 64,

                  child:
                      ElevatedButton(
                    onPressed:
                        _isCleaning
                            ? _stopCleaning
                            : _startCleaning,

                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          _isCleaning
                              ? const Color(
                                  0xFFFF5555,
                                )
                              : const Color(
                                  0xFF4F7FF7,
                                ),

                      foregroundColor:
                          Colors.white,

                      elevation: 2,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [
                        Icon(
                          _isCleaning
                              ? Icons
                                  .stop_rounded
                              : Icons
                                  .play_arrow_rounded,
                          size: 29,
                        ),

                        const SizedBox(
                          width: 9,
                        ),

                        Text(
                          _isCleaning
                              ? 'Stop Cleaning'
                              : 'Start Cleaning',

                          style:
                              const TextStyle(
                            fontSize: 20,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(
                  height: 16,
                ),

                const Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [
                    Icon(
                      Icons
                          .volume_down_outlined,
                      size: 18,
                      color:
                          Colors.grey,
                    ),

                    SizedBox(width: 6),

                    Text(
                      'Keep volume at a safe level',
                      style:
                          TextStyle(
                        fontSize: 14,
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // MODE CARD
  // ==========================================================

  Widget _buildModeCard(
    CleaningMode mode,
  ) {
    final info =
        _getModeInfo(mode);

    final bool selected =
        _selectedMode == mode;

    return GestureDetector(
      onTap: _isCleaning
          ? null
          : () => _selectMode(mode),

      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),

        padding:
            const EdgeInsets.all(15),

        decoration:
            BoxDecoration(
          color: selected
              ? const Color(
                  0xFFE8EEFF,
                )
              : Colors.white,

          borderRadius:
              BorderRadius.circular(
            18,
          ),

          border: Border.all(
            color: selected
                ? const Color(
                    0xFF4F7FF7,
                  )
                : Colors.transparent,

            width: 1.5,
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,

              decoration:
                  BoxDecoration(
                color: selected
                    ? const Color(
                        0xFF4F7FF7,
                      )
                    : const Color(
                        0xFFF0F2F8,
                      ),

                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),

              child: Icon(
                info.icon,

                color: selected
                    ? Colors.white
                    : const Color(
                        0xFF4F7FF7,
                      ),
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    info.name,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    info.description,
                    style:
                        const TextStyle(
                      fontSize: 13,
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Text(
                  '${info.duration}s',
                  style:
                      const TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                if (selected)
                  const Icon(
                    Icons
                        .check_circle_rounded,
                    color:
                        Color(
                      0xFF4F7FF7,
                    ),
                    size: 20,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}