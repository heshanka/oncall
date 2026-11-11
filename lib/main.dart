import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Rotation order, starting from [anchorDate].
const rotation = ['Heshanka', 'Mahdi', 'Saleh', 'Kevser'];

/// The day rotation[0] was on call (Tue, 10 Nov 2026).
final anchorDate = DateTime.utc(2026, 11, 10);

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String personFor(DateTime day) {
  // Compare calendar dates in UTC to avoid DST off-by-one errors.
  final d = DateTime.utc(day.year, day.month, day.day);
  final diff = d.difference(anchorDate).inDays;
  return rotation[diff % rotation.length]; // Dart % is always non-negative
}

String fmt(DateTime d) =>
    '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}';

// Circus palette
const red = Color(0xFFE63946);
const cream = Color(0xFFFFF3D6);
const yellow = Color(0xFFFFC93C);
const ink = Color(0xFF3B0A45);
const letterColors = [
  Color(0xFFFF4D6D),
  Color(0xFFFFB703),
  Color(0xFF06D6A0),
  Color(0xFF4CC9F0),
  Color(0xFFB5179E),
  Color(0xFFFF8500),
];

void main() => runApp(const OnCallApp());

class OnCallApp extends StatelessWidget {
  const OnCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'On-Call Circus',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  DateTime today = DateTime.now();

  /// Endless loop driving the sunburst, confetti, wobbles and waves.
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  /// The big "ta-da!" entrance. Tap the screen to replay it.
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  final _confetti = List.generate(90, (_) => _Particle.random());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _loop.dispose();
    _pop.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() => today = DateTime.now());
      _pop.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = personFor(today);
    final upcoming = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day + i + 1),
    );

    return Scaffold(
      backgroundColor: red,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _pop.forward(from: 0),
        child: AnimatedBuilder(
          animation: Listenable.merge([_loop, _pop]),
          builder: (context, _) {
            final t = _loop.value;
            final pop = Curves.elasticOut.transform(_pop.value);
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _SunburstPainter(t)),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _ConfettiPainter(_confetti, t)),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: CustomPaint(painter: _BuntingPainter(t)),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _banner(t, pop),
                            const SizedBox(height: 16),
                            // Flexible bounds the FittedBox so the name
                            // shrinks instead of overflowing small screens.
                            Flexible(child: _wavyName(name, t, pop)),
                            _dateTag(t),
                          ],
                        ),
                      ),
                      _comingUp(upcoming, t),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _banner(double t, double pop) {
    final wobble = math.sin(t * 2 * math.pi * 3) * 0.05;
    return Transform.rotate(
      angle: wobble,
      child: Transform.scale(
        scale: pop,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: ink,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: yellow, width: 4),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, offset: Offset(0, 6)),
                ],
              ),
              child: const Text(
                "🎪 TODAY'S ON-CALL IS 🎪",
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  color: yellow,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wavyName(String name, double t, double pop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: FittedBox(
        child: Transform.scale(
          scale: pop,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < name.length; i++)
                Transform.translate(
                  offset: Offset(
                    0,
                    math.sin(t * 2 * math.pi * 2 + i * 0.7) * 12,
                  ),
                  child: Transform.rotate(
                    angle: math.sin(t * 2 * math.pi * 2 + i) * 0.12,
                    child: _OutlinedLetter(
                      name[i],
                      letterColors[i % letterColors.length],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateTag(double t) {
    final s = 1 + math.sin(t * 2 * math.pi * 3) * 0.04;
    return Transform.scale(
      scale: s,
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ink, width: 3),
        ),
        child: Text(
          '✨ ${fmt(today)} ✨',
          style: const TextStyle(
            color: ink,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _comingUp(List<DateTime> days, double t) {
    return Column(
      children: [
        const Text(
          '🎟️ NEXT UP IN THE RING 🎟️',
          style: TextStyle(
            color: cream,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            shadows: [Shadow(color: ink, offset: Offset(2, 2))],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final d = days[i];
              final who = personFor(d);
              final bob = math.sin(t * 2 * math.pi * 2 + i * 0.9) * 6;
              return Transform.translate(
                offset: Offset(0, bob),
                child: Container(
                  width: 100,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: letterColors[i % letterColors.length],
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cream, width: 3),
                    boxShadow: const [
                      BoxShadow(color: Colors.black26, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        who,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        fmt(d),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A chunky letter with a thick ink outline + drop shadow.
class _OutlinedLetter extends StatelessWidget {
  const _OutlinedLetter(this.char, this.color);
  final String char;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const size = 96.0;
    return Stack(
      children: [
        Text(
          char,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 11
              ..strokeJoin = StrokeJoin.round
              ..color = ink,
            shadows: const [
              Shadow(color: Colors.black45, offset: Offset(4, 8)),
            ],
          ),
        ),
        Text(
          char,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Rotating red & cream circus-tent sunburst.
class _SunburstPainter extends CustomPainter {
  _SunburstPainter(this.t);
  final double t;

  static const rays = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final radius = size.longestSide * 1.2;
    final sweep = 2 * math.pi / rays;
    // Rotate by exactly two rays per loop so the repeat is seamless.
    final rot = t * sweep * 2;
    final paint = Paint();
    for (var i = 0; i < rays; i++) {
      paint.color = i.isEven ? red : cream;
      final a = rot + i * sweep;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(
          center.dx + radius * math.cos(a),
          center.dy + radius * math.sin(a),
        )
        ..lineTo(
          center.dx + radius * math.cos(a + sweep),
          center.dy + radius * math.sin(a + sweep),
        )
        ..close();
      canvas.drawPath(path, paint);
    }
    // Soft spotlight in the middle.
    canvas.drawCircle(
      center,
      size.shortestSide * 0.6,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.55),
                Colors.white.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: center, radius: size.shortestSide * 0.6),
            ),
    );
  }

  @override
  bool shouldRepaint(_SunburstPainter old) => old.t != t;
}

/// Swinging triangle flags across the top.
class _BuntingPainter extends CustomPainter {
  _BuntingPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    const flagW = 34.0;
    final count = (size.width / flagW).ceil() + 1;
    canvas.drawLine(
      Offset(0, 6),
      Offset(size.width, 6),
      Paint()
        ..color = ink
        ..strokeWidth = 3,
    );
    for (var i = 0; i < count; i++) {
      final x = i * flagW;
      final swing = math.sin(t * 2 * math.pi * 3 + i * 0.8) * 0.25;
      canvas.save();
      canvas.translate(x + flagW / 2, 6);
      canvas.rotate(swing);
      final path = Path()
        ..moveTo(-flagW / 2 + 2, 0)
        ..lineTo(flagW / 2 - 2, 0)
        ..lineTo(0, 40)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = letterColors[i % letterColors.length],
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BuntingPainter old) => old.t != t;
}

class _Particle {
  _Particle(
    this.x,
    this.y0,
    this.speed,
    this.size,
    this.color,
    this.phase,
    this.spin,
    this.round,
  );

  factory _Particle.random() {
    final r = math.Random();
    return _Particle(
      r.nextDouble(),
      r.nextDouble(),
      1 + r.nextInt(2), // whole loops per cycle → seamless repeat
      5 + r.nextDouble() * 7,
      letterColors[r.nextInt(letterColors.length)],
      r.nextDouble() * 2 * math.pi,
      (r.nextInt(5) - 2),
      r.nextBool(),
    );
  }

  final double x, y0, size, phase;
  final int speed, spin;
  final Color color;
  final bool round;
}

/// Endless falling confetti.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in particles) {
      final y = ((p.y0 + t * p.speed) % 1.0) * (size.height + 40) - 20;
      final x = p.x * size.width + math.sin(t * 2 * math.pi * 2 + p.phase) * 18;
      paint.color = p.color;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 2 * math.pi * p.spin + p.phase);
      if (p.round) {
        canvas.drawCircle(Offset.zero, p.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.size,
            height: p.size * 0.5,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
