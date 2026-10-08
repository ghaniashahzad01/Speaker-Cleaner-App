import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _bg = Color(0xFF06101F);
const _surface = Color(0xFF0D1B31);
const _surface2 = Color(0xFF122544);
const _blue = Color(0xFF20B8FF);
const _blue2 = Color(0xFF4C6FFF);
const _purple = Color(0xFF9B5CFF);
const _text = Color(0xFFF7FAFF);
const _muted = Color(0xFF93A4BE);
const _danger = Color(0xFFFF4D78);
const _success = Color(0xFF42E8A1);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
  runApp(SpeakerCleanerApp(showOnboarding: !onboardingCompleted));
}

class SpeakerCleanerApp extends StatelessWidget {
  final bool showOnboarding;
  const SpeakerCleanerApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Speaker Cleaner',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: _bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _blue,
          brightness: Brightness.dark,
        ),
      ),
      home: showOnboarding ? const OnboardingScreen() : const SpeakerCleanerHome(),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  const OnboardingData({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final pages = const [
    OnboardingData(
      icon: Icons.speaker_rounded,
      eyebrow: 'CLEAR SOUND. BETTER EXPERIENCE.',
      title: 'Speaker Cleaner',
      description: 'A simple audio tool designed to help move moisture from your phone speaker.',
    ),
    OnboardingData(
      icon: Icons.bolt_rounded,
      eyebrow: 'CHOOSE YOUR MODE',
      title: 'Clean Your Way',
      description: 'Pick Quick Clean, Water Eject, or Deep Clean and let the timer handle the session.',
    ),
    OnboardingData(
      icon: Icons.graphic_eq_rounded,
      eyebrow: 'SMOOTH & TIMED',
      title: 'Watch The Waves',
      description: 'A visual cleaning experience keeps you informed while your speaker is active.',
    ),
    OnboardingData(
      icon: Icons.shield_rounded,
      eyebrow: 'USE IT RESPONSIBLY',
      title: 'Built With Safety In Mind',
      description: 'Keep volume comfortable and stop the session whenever the sound feels uncomfortable.',
    ),
  ];

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SpeakerCleanerHome(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  void _next() {
    if (_currentPage == pages.length - 1) {
      _complete();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, top: 8),
                    child: TextButton(
                      onPressed: _complete,
                      child: const Text('Skip', style: TextStyle(color: _muted, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (_, index) => _OnboardingPage(data: pages[index]),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: index == _currentPage ? 28 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: index == _currentPage
                            ? const LinearGradient(colors: [_blue, _purple])
                            : null,
                        color: index == _currentPage ? null : Colors.white24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: _GradientButton(
                    label: _currentPage == pages.length - 1 ? 'Get Started' : 'Continue',
                    icon: _currentPage == pages.length - 1 ? Icons.arrow_forward_rounded : Icons.chevron_right_rounded,
                    onTap: _next,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 255,
            height: 255,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF173E73), Color(0xFF0B1930), _bg],
              ),
              border: Border.all(color: _blue.withOpacity(.22)),
              boxShadow: [
                BoxShadow(color: _blue.withOpacity(.14), blurRadius: 60, spreadRadius: 8),
                BoxShadow(color: _purple.withOpacity(.08), blurRadius: 90, spreadRadius: 15),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.graphic_eq_rounded, size: 170, color: _blue),
                Icon(data.icon, size: 64, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 42),
          Text(data.eyebrow, style: const TextStyle(fontSize: 11, letterSpacing: 1.8, color: _blue, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(data.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 36, height: 1.05, fontWeight: FontWeight.w800, color: _text)),
          const SizedBox(height: 18),
          Text(data.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.55, color: _muted)),
        ],
      ),
    );
  }
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

enum CleaningMode { quick, water, deep }

class SpeakerCleanerHome extends StatefulWidget {
  const SpeakerCleanerHome({super.key});
  @override
  State<SpeakerCleanerHome> createState() => _SpeakerCleanerHomeState();
}

class _SpeakerCleanerHomeState extends State<SpeakerCleanerHome> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  CleaningMode _selectedMode = CleaningMode.water;
  bool _isCleaning = false;
  int _remainingSeconds = 30;
  double _volume = .50;
  Timer? _timer;
  late final AnimationController _pulseController;
  late final AnimationController _waveController;

  CleaningModeInfo _getModeInfo(CleaningMode mode) {
    switch (mode) {
      case CleaningMode.quick:
        return const CleaningModeInfo(name: 'Quick Clean', description: 'A short cleaning cycle', icon: Icons.bolt_rounded, duration: 15, startFrequency: 170, endFrequency: 260);
      case CleaningMode.water:
        return const CleaningModeInfo(name: 'Water Eject', description: 'Designed for moisture displacement', icon: Icons.water_drop_rounded, duration: 30, startFrequency: 150, endFrequency: 300);
      case CleaningMode.deep:
        return const CleaningModeInfo(name: 'Deep Clean', description: 'A longer frequency sweep', icon: Icons.graphic_eq_rounded, duration: 45, startFrequency: 120, endFrequency: 350);
    }
  }

  CleaningModeInfo get _mode => _getModeInfo(_selectedMode);

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _mode.duration;
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000), lowerBound: .94, upperBound: 1.06);
    _waveController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  Future<void> _startCleaning() async {
    if (_isCleaning) return;
    final mode = _mode;
    try {
      final bytes = _generateCleaningTone(durationSeconds: mode.duration, startFrequency: mode.startFrequency, endFrequency: mode.endFrequency);
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play(BytesSource(bytes));
      if (!mounted) return;
      setState(() {
        _isCleaning = true;
        _remainingSeconds = mode.duration;
      });
      _pulseController.repeat(reverse: true);
      _startCountdown();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Unable to play cleaning sound.');
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _finishCleaning();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  Future<void> _finishCleaning() async {
    _timer?.cancel();
    await _audioPlayer.stop();
    _pulseController.stop();
    _pulseController.value = 1;
    if (!mounted) return;
    setState(() {
      _isCleaning = false;
      _remainingSeconds = _mode.duration;
    });
    _showCompletion();
  }

  Future<void> _stopCleaning() async {
    _timer?.cancel();
    await _audioPlayer.stop();
    _pulseController.stop();
    _pulseController.value = 1;
    if (!mounted) return;
    setState(() {
      _isCleaning = false;
      _remainingSeconds = _mode.duration;
    });
  }

  void _selectMode(CleaningMode mode) {
    if (_isCleaning) return;
    setState(() {
      _selectedMode = mode;
      _remainingSeconds = _getModeInfo(mode).duration;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  void _showCompletion() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
        decoration: const BoxDecoration(color: _surface, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 28),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(shape: BoxShape.circle, color: _success.withOpacity(.12), border: Border.all(color: _success.withOpacity(.35))),
                child: const Icon(Icons.check_rounded, color: _success, size: 48),
              ),
              const SizedBox(height: 20),
              const Text('Cleaning Complete!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _text)),
              const SizedBox(height: 8),
              Text('${_mode.name} finished successfully.', style: const TextStyle(color: _muted, fontSize: 15)),
              const SizedBox(height: 24),
              _GradientButton(label: 'Clean Again', icon: Icons.refresh_rounded, onTap: () => Navigator.pop(context)),
              const SizedBox(height: 10),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done', style: TextStyle(color: _muted))),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: MediaQuery.of(context).size.height * .86,
          decoration: const BoxDecoration(color: _surface, borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 25),
                  const Text('Settings', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 7),
                  const Text('Fine-tune your cleaning experience.', style: TextStyle(color: _muted)),
                  const SizedBox(height: 24),
                  _SettingsCard(
                    icon: Icons.volume_up_rounded,
                    title: 'Cleaning Volume',
                    child: Column(
                      children: [
                        Row(children: [
                          const Icon(Icons.volume_down_rounded, color: _blue),
                          Expanded(
                            child: Slider(
                              value: _volume,
                              min: .20,
                              max: .70,
                              divisions: 10,
                              activeColor: _blue,
                              inactiveColor: Colors.white12,
                              onChanged: (value) async {
                                setSheetState(() {});
                                setState(() => _volume = value);
                                await _audioPlayer.setVolume(value);
                              },
                            ),
                          ),
                          const Icon(Icons.volume_up_rounded, color: _blue),
                        ]),
                        Text('${(_volume * 100).round()}%', style: const TextStyle(fontSize: 20, color: _blue, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        const Text('Keep the volume at a comfortable level.', style: TextStyle(color: _muted)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SettingsCard(
                    icon: Icons.graphic_eq_rounded,
                    title: 'Current Cleaning Mode',
                    child: _ModeMiniRow(info: _mode),
                  ),
                  const SizedBox(height: 14),
                  _SettingsTile(icon: Icons.shield_rounded, title: 'Safety Information', subtitle: 'Important usage guidance', onTap: () { Navigator.pop(context); _showSafetyInformation(); }),
                  const SizedBox(height: 10),
                  _SettingsTile(icon: Icons.info_rounded, title: 'About Speaker Cleaner', subtitle: 'App information and version', onTap: () { Navigator.pop(context); _showAbout(); }),
                  const SizedBox(height: 24),
                  Center(child: Text('Speaker Cleaner • v1.0.0', style: TextStyle(color: Colors.white.withOpacity(.35)))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSafetyInformation() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        title: const Row(children: [Icon(Icons.shield_rounded, color: _blue), SizedBox(width: 10), Text('Safety')]),
        content: const SingleChildScrollView(child: Text(
          '• Keep the phone volume at a comfortable level.\n\n'
          '• Do not place the phone directly against your ear while the cleaning sound is playing.\n\n'
          '• Stop the cleaning session if the sound feels uncomfortable.\n\n'
          '• This app uses audio to help move moisture and does not guarantee complete water or dust removal.\n\n'
          '• For significant liquid or physical damage, allow the device to dry properly and seek professional assistance when necessary.',
          style: TextStyle(color: _muted, height: 1.5),
        )),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
      ),
    );
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        title: const Text('About Speaker Cleaner'),
        content: const Text(
          'Speaker Cleaner is an audio-based utility designed to play controlled sound patterns that may help move moisture from a phone speaker.\n\n'
          'It provides different cleaning modes and timed audio sessions.\n\nVersion 1.0.0',
          style: TextStyle(color: _muted, height: 1.5),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Uint8List _generateCleaningTone({required int durationSeconds, required double startFrequency, required double endFrequency}) {
    const sampleRate = 44100;
    const channels = 1;
    const bitsPerSample = 16;
    final numberOfSamples = sampleRate * durationSeconds;
    final bytesPerSample = bitsPerSample ~/ 8;
    final dataSize = numberOfSamples * channels * bytesPerSample;
    final fileSize = 44 + dataSize;
    final bytes = ByteData(fileSize);
    _writeString(bytes, 0, 'RIFF');
    bytes.setUint32(4, fileSize - 8, Endian.little);
    _writeString(bytes, 8, 'WAVE');
    _writeString(bytes, 12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, channels, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    final byteRate = sampleRate * channels * bytesPerSample;
    bytes.setUint32(28, byteRate, Endian.little);
    final blockAlign = channels * bytesPerSample;
    bytes.setUint16(32, blockAlign, Endian.little);
    bytes.setUint16(34, bitsPerSample, Endian.little);
    _writeString(bytes, 36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);
    const amplitude = .35;
    var phase = 0.0;
    const fadeSamples = 2205;
    for (var i = 0; i < numberOfSamples; i++) {
      final progress = i / numberOfSamples;
      final currentFrequency = startFrequency + ((endFrequency - startFrequency) * progress);
      phase += 2 * pi * currentFrequency / sampleRate;
      var envelope = 1.0;
      if (i < fadeSamples) envelope = i / fadeSamples;
      if (i > numberOfSamples - fadeSamples) envelope = (numberOfSamples - i) / fadeSamples;
      final sample = sin(phase) * amplitude * envelope;
      bytes.setInt16(44 + (i * 2), (sample * 32767).round(), Endian.little);
    }
    return bytes.buffer.asUint8List();
  }

  void _writeString(ByteData data, int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      data.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_mode.duration - _remainingSeconds) / _mode.duration;
    return Scaffold(
      body: Stack(
        children: [
          const _AmbientBackground(),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHero(),
                      const SizedBox(height: 24),
                      _buildModes(),
                      const SizedBox(height: 18),
                      if (_isCleaning) _buildSession(progress),
                      if (_isCleaning) const SizedBox(height: 16),
                      _GradientButton(
                        label: _isCleaning ? 'Stop Cleaning' : 'Start Cleaning',
                        icon: _isCleaning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                        danger: _isCleaning,
                        onTap: _isCleaning ? _stopCleaning : _startCleaning,
                      ),
                      const SizedBox(height: 14),
                      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.volume_down_rounded, size: 16, color: _muted), SizedBox(width: 6), Text('Keep volume at a safe level', style: TextStyle(color: _muted, fontSize: 13))]),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [_blue2, _purple]), borderRadius: BorderRadius.circular(13), boxShadow: [BoxShadow(color: _blue.withOpacity(.2), blurRadius: 18)]),
            child: const Icon(Icons.speaker_rounded, color: Colors.white, size: 23),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text.rich(TextSpan(children: [TextSpan(text: 'Speaker ', style: TextStyle(color: _text)), TextSpan(text: 'Cleaner', style: TextStyle(color: _blue))]), style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
              SizedBox(height: 2),
              Text('Clear sound. Better experience.', style: TextStyle(color: _muted, fontSize: 11)),
            ]),
          ),
          IconButton(onPressed: _openSettings, icon: const Icon(Icons.settings_rounded, color: _text)),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _waveController]),
      builder: (_, __) => Container(
        height: 270,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF102C52), Color(0xFF09182D)]),
          border: Border.all(color: _blue.withOpacity(.16)),
          boxShadow: [BoxShadow(color: _blue.withOpacity(_isCleaning ? .13 : .06), blurRadius: 40, spreadRadius: 2)],
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _WavePainter(progress: _waveController.value, active: _isCleaning))),
            Center(
              child: Transform.scale(
                scale: _isCleaning ? _pulseController.value : 1,
                child: Container(
                  width: 172,
                  height: 172,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [Color(0xFF173B69), Color(0xFF0A1A30)]),
                    border: Border.all(color: _blue.withOpacity(.55), width: 1.5),
                    boxShadow: [BoxShadow(color: _blue.withOpacity(_isCleaning ? .25 : .10), blurRadius: 42, spreadRadius: 6)],
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    Container(width: 124, height: 124, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _purple.withOpacity(.35), width: 1))),
                    Icon(_isCleaning ? Icons.volume_up_rounded : Icons.speaker_rounded, size: 70, color: _text),
                  ]),
                ),
              ),
            ),
            Positioned(left: 20, top: 18, child: _Pill(icon: _isCleaning ? Icons.radio_button_checked_rounded : Icons.check_circle_rounded, text: _isCleaning ? 'CLEANING' : 'READY', color: _isCleaning ? _blue : _success)),
            Positioned(right: 20, bottom: 18, child: Text(_isCleaning ? '${_remainingSeconds}s remaining' : 'Speaker ready', style: const TextStyle(color: _muted, fontWeight: FontWeight.w600))),
          ],
        ),
      ),
    );
  }

  Widget _buildModes() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Choose Cleaning Mode', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _ModeCard(mode: CleaningMode.quick, info: _getModeInfo(CleaningMode.quick), selected: _selectedMode == CleaningMode.quick, enabled: !_isCleaning, onTap: () => _selectMode(CleaningMode.quick))),
        const SizedBox(width: 10),
        Expanded(child: _ModeCard(mode: CleaningMode.water, info: _getModeInfo(CleaningMode.water), selected: _selectedMode == CleaningMode.water, enabled: !_isCleaning, onTap: () => _selectMode(CleaningMode.water))),
        const SizedBox(width: 10),
        Expanded(child: _ModeCard(mode: CleaningMode.deep, info: _getModeInfo(CleaningMode.deep), selected: _selectedMode == CleaningMode.deep, enabled: !_isCleaning, onTap: () => _selectMode(CleaningMode.deep))),
      ]),
    ]);
  }

  Widget _buildSession(double progress) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: _surface.withOpacity(.92), borderRadius: BorderRadius.circular(22), border: Border.all(color: _blue.withOpacity(.12))),
      child: Column(children: [
        Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(color: _blue.withOpacity(.12), borderRadius: BorderRadius.circular(13)), child: Icon(_mode.icon, color: _blue)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_mode.name, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 2), Text('Cleaning in progress', style: const TextStyle(color: _muted, fontSize: 12))])),
          Text('${(progress * 100).round()}%', style: const TextStyle(color: _blue, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 15),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.white10, valueColor: const AlwaysStoppedAnimation(_blue))),
      ]),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final CleaningMode mode;
  final CleaningModeInfo info;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  const _ModeCard({required this.mode, required this.info, required this.selected, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 132,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: selected ? const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF174D7B), Color(0xFF172957)]) : null,
          color: selected ? null : _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _blue.withOpacity(.75) : Colors.white10, width: selected ? 1.4 : 1),
          boxShadow: selected ? [BoxShadow(color: _blue.withOpacity(.10), blurRadius: 24)] : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(gradient: selected ? const LinearGradient(colors: [_blue, _blue2]) : null, color: selected ? null : Colors.white.withOpacity(.06), borderRadius: BorderRadius.circular(13)), child: Icon(info.icon, color: selected ? Colors.white : _blue)),
            if (selected) const Icon(Icons.check_circle_rounded, color: _blue, size: 20),
          ]),
          const Spacer(),
          Text(info.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text('${info.duration} sec', style: const TextStyle(fontSize: 11, color: _muted)),
        ]),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;
  const _GradientButton({required this.label, required this.icon, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 62,
          decoration: BoxDecoration(
            gradient: danger ? const LinearGradient(colors: [Color(0xFFFF3864), Color(0xFFFF587A)]) : const LinearGradient(colors: [_blue, _blue2, _purple]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: (danger ? _danger : _blue).withOpacity(.20), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white, size: 25), const SizedBox(width: 10), Text(label, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))]),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _Pill({required this.icon, required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(30), border: Border.all(color: color.withOpacity(.25))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: color, size: 14), const SizedBox(width: 5), Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1))]),
  );
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SettingsCard({required this.icon, required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: _blue.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: _blue)), const SizedBox(width: 11), Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))]), const SizedBox(height: 14), child]),
  );
}

class _ModeMiniRow extends StatelessWidget {
  final CleaningModeInfo info;
  const _ModeMiniRow({required this.info});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: Colors.white.withOpacity(.04), borderRadius: BorderRadius.circular(16)),
    child: Row(children: [Container(width: 44, height: 44, decoration: BoxDecoration(gradient: const LinearGradient(colors: [_blue, _blue2]), borderRadius: BorderRadius.circular(13)), child: Icon(info.icon, color: Colors.white)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(info.name, style: const TextStyle(fontWeight: FontWeight.w700)), Text('${info.duration} seconds', style: const TextStyle(color: _muted, fontSize: 12))]))]),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
    color: _surface,
    borderRadius: BorderRadius.circular(19),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: _blue.withOpacity(.10), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: _blue)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12))])), const Icon(Icons.chevron_right_rounded, color: _muted)]),
      ),
    ),
  );
}

class _AmbientBackground extends StatelessWidget {
  const _AmbientBackground();
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [_bg, Color(0xFF07172A), _bg]),
    ),
    child: Stack(children: [
      Positioned(top: -120, right: -100, child: _Glow(color: _blue, size: 300)),
      Positioned(bottom: -150, left: -100, child: _Glow(color: _purple, size: 330)),
    ]),
  );
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  const _Glow({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(.045), boxShadow: [BoxShadow(color: color.withOpacity(.08), blurRadius: 100, spreadRadius: 30)]));
}

class _WavePainter extends CustomPainter {
  final double progress;
  final bool active;
  _WavePainter({required this.progress, required this.active});
  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height * .52;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = active ? 2 : 1.2..color = _blue.withOpacity(active ? .55 : .18);
    final path = Path();
    for (var x = 0.0; x <= size.width; x += 3) {
      final normalized = x / size.width;
      final wave = sin((normalized * pi * 12) + progress * pi * 2) * (active ? 20 : 7);
      final y = centerY + wave;
      if (x == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => oldDelegate.progress != progress || oldDelegate.active != active;
}
