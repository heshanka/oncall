// Run: flutter test tool/make_icons_test.dart  — regenerates web/icons + favicon.
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter_test/flutter_test.dart';

const red = ui.Color(0xFFE63946), cream = ui.Color(0xFFFFF3D6);
const yellow = ui.Color(0xFFFFC93C), ink = ui.Color(0xFF3B0A45);

Future<void> render(int px, String path, {bool maskable = false}) async {
  final rec = ui.PictureRecorder();
  final c = ui.Canvas(rec);
  final s = px.toDouble(), center = ui.Offset(s / 2, s / 2);
  c.drawRect(ui.Rect.fromLTWH(0, 0, s, s), ui.Paint()..color = red);
  const rays = 16;
  final sweep = 2 * math.pi / rays;
  for (var i = 0; i < rays; i += 2) {
    final a = i * sweep;
    c.drawPath(
      ui.Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(center.dx + s * math.cos(a), center.dy + s * math.sin(a))
        ..lineTo(center.dx + s * math.cos(a + sweep),
            center.dy + s * math.sin(a + sweep))
        ..close(),
      ui.Paint()..color = cream,
    );
  }
  final r = s * (maskable ? 0.26 : 0.32);
  c.drawCircle(center, r + s * 0.035, ui.Paint()..color = yellow);
  c.drawCircle(center, r, ui.Paint()..color = ink);
  final star = ui.Path();
  for (var i = 0; i < 10; i++) {
    final rr = i.isEven ? r * 0.72 : r * 0.3;
    final a = -math.pi / 2 + i * math.pi / 5;
    final p = center + ui.Offset(rr * math.cos(a), rr * math.sin(a));
    i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
  }
  c.drawPath(star..close(), ui.Paint()..color = yellow);
  final img = await rec.endRecording().toImage(px, px);
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('generate icons', () async {
    await render(192, 'web/icons/Icon-192.png');
    await render(512, 'web/icons/Icon-512.png');
    await render(192, 'web/icons/Icon-maskable-192.png', maskable: true);
    await render(512, 'web/icons/Icon-maskable-512.png', maskable: true);
    await render(180, 'web/icons/apple-touch-icon.png');
    await render(32, 'web/favicon.png');
  });
}
