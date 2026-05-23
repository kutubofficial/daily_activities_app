import 'dart:async';
import 'package:flutter/material.dart';

class StudyTimerScreen extends StatefulWidget {
  const StudyTimerScreen({super.key});

  @override
  State<StudyTimerScreen> createState() => _StudyTimerScreenState();
}

class _StudyTimerScreenState extends State<StudyTimerScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMinutes = 10;
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinished = false;

  late AnimationController _pulseController;

  final List<int> _presets = [10,20,30,60];

  @override
  void initState() {
    super.initState();
    _totalSeconds = _selectedMinutes * 60;
    _remainingSeconds = _totalSeconds;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds == 0) return;
    setState(() {
      _isRunning = true;
      _isFinished = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _timer?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isRunning = false;
          _isFinished = true;
        });
        _showFinishedDialog();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _isFinished = false;
    });
  }

  void _selectPreset(int minutes) {
    _timer?.cancel();
    setState(() {
      _selectedMinutes = minutes;
      _totalSeconds = minutes * 60;
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _isFinished = false;
    });
  }


  String get _formattedTime {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress =>
      _totalSeconds == 0 ? 0 : _remainingSeconds / _totalSeconds;

  Color get _progressColor {
    if (_progress > 0.5) return Colors.teal;
    if (_progress > 0.25) return Colors.orange;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121111),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Study Timer',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        // iconTheme: const IconThemeData(color: Colors.white),
        leading: GestureDetector(
          onTap: ()=>Navigator.pop(context),
          child: Padding(padding: EdgeInsets.all(12),
          child: Image.asset('assets/icons/back.png',height:24,width: 24,color: Colors.white,colorBlendMode: BlendMode.srcIn,
      ),),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            const Text(
              'Select Duration',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            _buildPresetChips(),

            const SizedBox(height: 40),

            _buildCircularClock(),

            const SizedBox(height: 48),

            _buildControls(),

            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, _) => Opacity(
                opacity: _isRunning
                    ? 0.5 + 0.5 * _pulseController.value
                    : 1.0,
                child: Text(
                  _isFinished ? 'Session Complete!' : _isRunning ? 'Stay Focused...' : 'Paused — Ready when you are',
                  style: TextStyle(
                    color: _isFinished ? Colors.teal : Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChips() {
    return Wrap(
      spacing: 10,
      children: _presets.map((min) {
        final isSelected = min == _selectedMinutes;
        return GestureDetector(
          onTap: () => _selectPreset(min),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.teal : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.teal : Colors.white24,
              ),
            ),
            child: Text('$min min',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCircularClock() {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 12,
              color: Colors.white10,
            ),
          ),
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 12,
              strokeCap: StrokeCap.round,
              color: _progressColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text( _formattedTime,
                style: const TextStyle( color: Colors.white,fontSize: 56,fontWeight: FontWeight.w300,letterSpacing: 4,
                  fontFeatures: [FontFeature.tabularFigures()],),
              ),
              const SizedBox(height: 6),
              Text('$_selectedMinutes min session',
                style: const TextStyle(color: Colors.white38,fontSize: 13,),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: Icons.refresh_rounded,
          color: Colors.white24,
          onTap: _resetTimer,
          size: 52,
        ),
        const SizedBox(width: 20),

        _ControlButton(
          icon: _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.teal,
          onTap: _isRunning ? _pauseTimer : _startTimer,
          size: 70,
          iconSize: 36,
        ),

        const SizedBox(width: 20),
           _ControlButton(
          icon: Icons.skip_next_rounded,
          color: Colors.white24,
          onTap: () {
            _timer?.cancel();
            setState(() {
              _remainingSeconds = 0;
              _isRunning = false;
              _isFinished = true;
            });
            _showFinishedDialog();
          },
          size: 52,
        ),
      ],
    );
  }
    void _showFinishedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Time is Up!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Great job! Take a short break and come back stronger.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetTimer();
            },
            child:const Text('Reset', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () => Navigator.pop(context),
            child:const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.size,
    this.iconSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color,shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.35),blurRadius: 12,spreadRadius: 2,),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}