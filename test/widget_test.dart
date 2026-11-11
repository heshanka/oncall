import 'package:flutter_test/flutter_test.dart';
import 'package:oncall/main.dart';

void main() {
  test('rotation matches given schedule', () {
    expect(personFor(DateTime(2026, 11, 10)), 'Heshanka');
    expect(personFor(DateTime(2026, 11, 11)), 'Mahdi');
    expect(personFor(DateTime(2026, 11, 12)), 'Saleh');
    expect(personFor(DateTime(2026, 11, 13)), 'Kevser');
    expect(personFor(DateTime(2026, 11, 14)), 'Heshanka');
    expect(personFor(DateTime(2026, 11, 9)), 'Kevser');
    expect(personFor(DateTime(2027, 3, 30)), personFor(DateTime(2027, 3, 26)));
  });
}
